import Foundation
import CoreLocation

protocol FirebaseNearbyAthletesServiceProtocol {
    func syncAndFetchNearby(
        user: FirebaseAuthenticatedUser,
        token: String,
        coordinate: CLLocationCoordinate2D,
        radiusKm: Double,
        limit: Int
    ) async throws -> [NearbyAthlete]
}

final class FirebaseNearbyAthletesService: FirebaseNearbyAthletesServiceProtocol {
    private struct FirestoreDocumentListResponse: Decodable {
        struct Document: Decodable {
            let name: String
            let fields: [String: FirestoreValue]?
        }

        let documents: [Document]?
    }

    private struct FirestorePatchRequest: Encodable {
        let fields: [String: FirestoreValue]
    }

    private enum Constants {
        static let collection = "nearby_athletes"
        static let defaultSport = "Бег"
        static let defaultStatus = "На тренировке"
        static let pageSize = 100
    }

    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func syncAndFetchNearby(
        user: FirebaseAuthenticatedUser,
        token: String,
        coordinate: CLLocationCoordinate2D,
        radiusKm: Double,
        limit: Int
    ) async throws -> [NearbyAthlete] {
        let projectID = try firebaseProjectID()
        let userID = Self.userID(from: token)
        let displayName = Self.displayName(from: user)

        try await upsertCurrentUser(
            projectID: projectID,
            userID: userID,
            displayName: displayName,
            coordinate: coordinate,
            token: token
        )

        let documents = try await fetchDocuments(projectID: projectID, token: token)
        let athletes = documents.compactMap { document -> NearbyAthlete? in
            guard
                let fields = document.fields,
                let lat = fields["lat"]?.doubleValue,
                let lon = fields["lon"]?.doubleValue
            else {
                return nil
            }

            let docUserID = document.name.split(separator: "/").last.map(String.init)
            if docUserID == userID {
                return nil
            }

            let athleteCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let distance = Self.distance(from: coordinate, to: athleteCoordinate)
            guard distance <= radiusKm else { return nil }

            return NearbyAthlete(
                name: fields["displayName"]?.stringValue ?? "Athlete",
                sport: fields["sport"]?.stringValue ?? Constants.defaultSport,
                distanceKm: distance,
                status: fields["status"]?.stringValue ?? Constants.defaultStatus,
                coordinate: athleteCoordinate
            )
        }

        return Array(athletes.sorted(by: { $0.distanceKm < $1.distanceKm }).prefix(max(1, limit)))
    }

    private func upsertCurrentUser(
        projectID: String,
        userID: String,
        displayName: String,
        coordinate: CLLocationCoordinate2D,
        token: String
    ) async throws {
        let url = try documentURL(projectID: projectID, documentID: userID)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.timeoutInterval = 8
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let sport = Self.sportForUser(userID)
        let body = FirestorePatchRequest(fields: [
            "displayName": .string(displayName),
            "sport": .string(sport),
            "status": .string(Constants.defaultStatus),
            "lat": .double(coordinate.latitude),
            "lon": .double(coordinate.longitude),
            "updatedAt": .timestamp(ISO8601DateFormatter().string(from: Date()))
        ])

        request.httpBody = try encoder.encode(body)

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.cannotWriteToFile)
        }
    }

    private func fetchDocuments(projectID: String, token: String) async throws -> [FirestoreDocumentListResponse.Document] {
        guard var components = URLComponents(string: collectionURL(projectID: projectID).absoluteString) else {
            throw URLError(.badURL)
        }
        components.queryItems = [URLQueryItem(name: "pageSize", value: String(Constants.pageSize))]
        guard let url = components.url else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.cannotLoadFromNetwork)
        }

        let payload = try decoder.decode(FirestoreDocumentListResponse.self, from: data)
        return payload.documents ?? []
    }

    private func collectionURL(projectID: String) -> URL {
        URL(string: "https://firestore.googleapis.com/v1/projects/\(projectID)/databases/(default)/documents/\(Constants.collection)")!
    }

    private func documentURL(projectID: String, documentID: String) throws -> URL {
        guard let encodedID = documentID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw URLError(.badURL)
        }
        guard let url = URL(string: "https://firestore.googleapis.com/v1/projects/\(projectID)/databases/(default)/documents/\(Constants.collection)/\(encodedID)") else {
            throw URLError(.badURL)
        }
        return url
    }

    private func firebaseProjectID() throws -> String {
        guard
            let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let info = NSDictionary(contentsOfFile: path),
            let projectID = info["PROJECT_ID"] as? String,
            !projectID.isEmpty
        else {
            throw URLError(.cannotFindHost)
        }
        return projectID
    }

    private static func userID(from token: String) -> String {
        let parts = token.split(separator: ".")
        guard parts.count > 1 else { return UUID().uuidString }

        var payload = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let padding = 4 - (payload.count % 4)
        if padding < 4 {
            payload += String(repeating: "=", count: padding)
        }

        guard
            let data = Data(base64Encoded: payload),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let sub = json["sub"] as? String,
            !sub.isEmpty
        else {
            return UUID().uuidString
        }

        return sub
    }

    private static func displayName(from user: FirebaseAuthenticatedUser) -> String {
        if let name = user.displayName, !name.isEmpty {
            return name
        }
        let local = user.email.split(separator: "@").first.map(String.init) ?? "Athlete"
        return local.prefix(1).uppercased() + local.dropFirst()
    }

    private static func sportForUser(_ userID: String) -> String {
        let sports = ["Бег", "Велоспорт", "Йога", "Кроссфит", "Плавание", "Теннис"]
        let hash = abs(userID.hashValue)
        return sports[hash % sports.count]
    }

    private static func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation) / 1000.0
    }
}

private struct FirestoreValue: Codable {
    let stringValue: String?
    let doubleValue: Double?
    let integerValue: String?
    let timestampValue: String?

    init(stringValue: String? = nil, doubleValue: Double? = nil, integerValue: String? = nil, timestampValue: String? = nil) {
        self.stringValue = stringValue
        self.doubleValue = doubleValue
        self.integerValue = integerValue
        self.timestampValue = timestampValue
    }

    static func string(_ value: String) -> FirestoreValue {
        FirestoreValue(stringValue: value)
    }

    static func double(_ value: Double) -> FirestoreValue {
        FirestoreValue(doubleValue: value)
    }

    static func int(_ value: Int) -> FirestoreValue {
        FirestoreValue(integerValue: String(value))
    }

    static func timestamp(_ value: String) -> FirestoreValue {
        FirestoreValue(timestampValue: value)
    }
}
