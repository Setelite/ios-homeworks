import Foundation

protocol FirebaseUserProfileServiceProtocol {
    func upsertUserProfile(user: FirebaseAuthenticatedUser, idToken: String) async throws
    func fetchUserEmails(idToken: String, excluding email: String?) async throws -> [String]
}

final class FirebaseUserProfileService: FirebaseUserProfileServiceProtocol {
    private struct PatchRequest: Encodable {
        let fields: [String: FirestoreFieldValue]
    }

    private let session: URLSession
    private let encoder = JSONEncoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func upsertUserProfile(user: FirebaseAuthenticatedUser, idToken: String) async throws {
        let projectID = try firebaseProjectID()
        let documentID = (user.uid?.isEmpty == false ? user.uid! : user.email)
            .replacingOccurrences(of: "[^A-Za-z0-9_-]", with: "_", options: .regularExpression)

        guard let encodedID = documentID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://firestore.googleapis.com/v1/projects/\(projectID)/databases/(default)/documents/users/\(encodedID)")
        else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.timeoutInterval = 12
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        request.httpBody = try encoder.encode(
            PatchRequest(fields: [
                "email": .string(user.email),
                "uid": .string(user.uid ?? ""),
                "displayName": .string(user.displayName ?? user.email.components(separatedBy: "@").first ?? "User"),
                "photoURL": .string(user.photoURL ?? ""),
                "updatedAt": .timestamp(ISO8601DateFormatter().string(from: Date()))
            ])
        )

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.cannotWriteToFile)
        }
    }

    func fetchUserEmails(idToken: String, excluding email: String?) async throws -> [String] {
        struct DocumentsResponse: Decodable {
            struct Document: Decodable {
                let fields: [String: FirestoreFieldValue]?
            }
            let documents: [Document]?
        }

        let projectID = try firebaseProjectID()
        guard let url = URL(string: "https://firestore.googleapis.com/v1/projects/\(projectID)/databases/(default)/documents/users?pageSize=50") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 12
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.cannotLoadFromNetwork)
        }

        let payload = try JSONDecoder().decode(DocumentsResponse.self, from: data)
        let excluded = email?.lowercased()

        let emails = (payload.documents ?? []).compactMap { document -> String? in
            let value = document.fields?["email"]?.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let value, !value.isEmpty else { return nil }
            return value
        }

        let unique = Array(Set(emails))
        return unique
            .filter { $0.lowercased() != excluded }
            .sorted()
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
}
