import Foundation
import CoreLocation
import MapKit

struct NearbyAthlete {
    let name: String
    let sport: String
    let distanceKm: Double
    let status: String
    let coordinate: CLLocationCoordinate2D
}

struct TrainingChallenge {
    let title: String
    let progress: Float
    let progressText: String
    let participants: Int
}

struct LeaderboardEntry {
    let name: String
    let points: Int
    let streakDays: Int
}

final class SportsHubViewModel {
    let defaultCenterCoordinate = CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423)

    private(set) var nearbyAthletes: [NearbyAthlete] = []
    private(set) var mapRegion: MKCoordinateRegion
    private(set) var routeCoordinates: [CLLocationCoordinate2D] = []

    let challenges: [TrainingChallenge] = [
        TrainingChallenge(title: "7 дней активности", progress: 0.71, progressText: "5 / 7 дней", participants: 184),
        TrainingChallenge(title: "50 км за месяц", progress: 0.46, progressText: "23 / 50 км", participants: 97),
        TrainingChallenge(title: "10 тренировок", progress: 0.80, progressText: "8 / 10 тренировок", participants: 211)
    ]

    let leaderboard: [LeaderboardEntry] = [
        LeaderboardEntry(name: "Maxim Gornostaev", points: 1280, streakDays: 12),
        LeaderboardEntry(name: "Аня Б.", points: 1160, streakDays: 9),
        LeaderboardEntry(name: "Игорь Т.", points: 1030, streakDays: 7),
        LeaderboardEntry(name: "Марина К.", points: 980, streakDays: 6),
        LeaderboardEntry(name: "Роман В.", points: 910, streakDays: 5)
    ]

    init() {
        mapRegion = MKCoordinateRegion(
            center: defaultCenterCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
        applyUserCoordinate(defaultCenterCoordinate)
        nearbyAthletes = fallbackAthletes(around: defaultCenterCoordinate)
    }

    func applyUserCoordinate(_ coordinate: CLLocationCoordinate2D) {
        mapRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )

        routeCoordinates = [
            CLLocationCoordinate2D(latitude: coordinate.latitude + 0.0020, longitude: coordinate.longitude - 0.0030),
            CLLocationCoordinate2D(latitude: coordinate.latitude + 0.0040, longitude: coordinate.longitude - 0.0005),
            CLLocationCoordinate2D(latitude: coordinate.latitude + 0.0020, longitude: coordinate.longitude + 0.0030),
            CLLocationCoordinate2D(latitude: coordinate.latitude - 0.0020, longitude: coordinate.longitude + 0.0025),
            CLLocationCoordinate2D(latitude: coordinate.latitude - 0.0030, longitude: coordinate.longitude - 0.0015),
            CLLocationCoordinate2D(latitude: coordinate.latitude - 0.0005, longitude: coordinate.longitude - 0.0032)
        ]
    }

    func applyNearbyAthletes(_ athletes: [NearbyAthlete]) {
        if athletes.isEmpty {
            nearbyAthletes = fallbackAthletes(around: mapRegion.center)
        } else {
            nearbyAthletes = athletes
        }
    }

    func fallbackAthletes(around coordinate: CLLocationCoordinate2D) -> [NearbyAthlete] {
        [
            NearbyAthlete(
                name: "Аня Б.",
                sport: "Бег",
                distanceKm: 0.8,
                status: "Тренировка в парке",
                coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude + 0.004, longitude: coordinate.longitude - 0.001)
            ),
            NearbyAthlete(
                name: "Игорь Т.",
                sport: "Велоспорт",
                distanceKm: 1.2,
                status: "Круг по набережной",
                coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude - 0.003, longitude: coordinate.longitude - 0.003)
            ),
            NearbyAthlete(
                name: "Марина К.",
                sport: "Йога",
                distanceKm: 2.0,
                status: "Утренняя сессия",
                coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude + 0.006, longitude: coordinate.longitude + 0.005)
            )
        ]
    }
}
