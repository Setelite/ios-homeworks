import Foundation
import CoreLocation

protocol NearbyAthletesServiceProtocol {
    func fetchNearbyAthletes(around coordinate: CLLocationCoordinate2D, limit: Int) async throws -> [NearbyAthlete]
}

final class NearbyAthletesService: NearbyAthletesServiceProtocol {
    private struct RandomUserResponse: Decodable {
        struct User: Decodable {
            struct Name: Decodable {
                let first: String
                let last: String
            }

            let name: Name
        }

        let results: [User]
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchNearbyAthletes(around coordinate: CLLocationCoordinate2D, limit: Int) async throws -> [NearbyAthlete] {
        let cappedLimit = max(1, min(limit, 20))
        var components = URLComponents(string: "https://randomuser.me/api/")!
        components.queryItems = [
            URLQueryItem(name: "results", value: String(cappedLimit)),
            URLQueryItem(name: "inc", value: "name"),
            URLQueryItem(name: "nat", value: "ru,us,gb")
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 7

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let payload = try JSONDecoder().decode(RandomUserResponse.self, from: data)
        if payload.results.isEmpty {
            throw URLError(.cannotParseResponse)
        }

        return payload.results.enumerated().map { index, user in
            let coordinateOffset = offsetCoordinate(from: coordinate, index: index)
            let distance = Self.distance(from: coordinate, to: coordinateOffset)
            return NearbyAthlete(
                name: "\(user.name.first) \(user.name.last.prefix(1)).",
                sport: Self.sports[index % Self.sports.count],
                distanceKm: distance,
                status: Self.statuses[index % Self.statuses.count],
                coordinate: coordinateOffset
            )
        }
        .sorted { $0.distanceKm < $1.distanceKm }
    }

    private func offsetCoordinate(from base: CLLocationCoordinate2D, index: Int) -> CLLocationCoordinate2D {
        let latOffset = (Double(index % 5) - 2.0) * 0.004
        let lonOffset = (Double(index / 2 % 5) - 2.0) * 0.004
        return CLLocationCoordinate2D(latitude: base.latitude + latOffset, longitude: base.longitude + lonOffset)
    }

    private static func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation) / 1000.0
    }

    private static let sports = ["Бег", "Велоспорт", "Йога", "Кроссфит", "Плавание", "Теннис"]
    private static let statuses = [
        "Тренировка в парке",
        "Круг по району",
        "Силовая сессия",
        "Интервальный бег",
        "Разминка перед стартом"
    ]
}
