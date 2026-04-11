import Foundation

protocol FeedServiceProtocol {
    func fetchPosts(limit: Int) async throws -> [SocialFeedPost]
}

final class FeedService: FeedServiceProtocol {
    private struct APIUser: Decodable {
        let id: Int
        let username: String
    }

    private struct APIPost: Decodable {
        let id: Int
        let userId: Int
        let title: String
        let body: String
    }

    private let session: URLSession

    init(session: URLSession = FeedService.makeSession()) {
        self.session = session
    }

    func fetchPosts(limit: Int = 20) async throws -> [SocialFeedPost] {
        let clampedLimit = max(1, min(50, limit))

        async let postsTask: [APIPost] = request("https://jsonplaceholder.typicode.com/posts?_limit=\(clampedLimit)")
        async let usersTask: [APIUser] = request("https://jsonplaceholder.typicode.com/users")

        let (posts, users) = try await (postsTask, usersTask)
        let usersById = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0.username) })

        return posts.enumerated().map { index, post in
            let username = usersById[post.userId] ?? "Athlete"
            let avatarURL = URL(string: "https://i.pravatar.cc/120?u=\(post.userId)")
            let photoURL = URL(string: "https://picsum.photos/seed/workout_\(post.id)/960/640")
            let caption = "\(post.title.capitalized)\n\n\(post.body)"
            let date = Calendar.current.date(byAdding: .hour, value: -(index * 3), to: Date()) ?? Date()

            return SocialFeedPost(
                id: String(post.id),
                username: username,
                avatarURL: avatarURL,
                photoURL: photoURL,
                caption: caption,
                date: date
            )
        }
    }

    private func request<T: Decodable>(_ rawURL: String) async throws -> T {
        guard let url = URL(string: rawURL) else {
            throw APIError.badURL
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw APIError.network
        }

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw APIError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decoding
        }
    }

    private static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadRevalidatingCacheData
        config.urlCache = URLCache(
            memoryCapacity: 40 * 1024 * 1024,
            diskCapacity: 120 * 1024 * 1024,
            diskPath: "feed-service-cache"
        )
        return URLSession(configuration: config)
    }
}
