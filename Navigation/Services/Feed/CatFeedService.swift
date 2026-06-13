import Foundation

final class CatFeedService: FeedServiceProtocol, FeedGenreConfigurable {
    private struct CatImage: Decodable {
        struct Breed: Decodable {
            let name: String?
            let origin: String?
            let temperament: String?
            let descriptionText: String?

            enum CodingKeys: String, CodingKey {
                case name
                case origin
                case temperament
                case descriptionText = "description"
            }
        }

        let id: String
        let url: String
        let breeds: [Breed]?
    }

    private let session: URLSession
    private let apiKey: String?
    private let decoder = JSONDecoder()
    private var selectedGenre: FeedGenre = .humor

    init(
        session: URLSession = CatFeedService.makeSession(),
        apiKey: String? = CatFeedService.readAPIKey()
    ) {
        self.session = session
        self.apiKey = apiKey
    }

    func setGenre(_ genre: FeedGenre) {
        selectedGenre = genre
    }

    func fetchPosts(limit: Int) async throws -> [SocialFeedPost] {
        let clampedLimit = max(6, min(30, limit))
        do {
            let postsWithCategory = try await fetchFromAPI(limit: clampedLimit, genre: selectedGenre, withCategory: true)
            if !postsWithCategory.isEmpty {
                return postsWithCategory
            }
        } catch {
            if let apiError = error as? APIError {
                if case .network = apiError {
                    throw apiError
                }
            }
        }

        do {
            let postsWithoutCategory = try await fetchFromAPI(limit: clampedLimit, genre: selectedGenre, withCategory: false)
            if !postsWithoutCategory.isEmpty {
                return postsWithoutCategory
            }
        } catch {
            if let apiError = error as? APIError {
                throw apiError
            }
            throw APIError.network
        }

        throw APIError.notFound
    }

    private func fetchFromAPI(limit: Int, genre: FeedGenre, withCategory: Bool) async throws -> [SocialFeedPost] {
        var components = URLComponents(string: "https://api.thecatapi.com/v1/images/search")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "has_breeds", value: "1"),
            URLQueryItem(name: "mime_types", value: "jpg,png"),
            URLQueryItem(name: "order", value: "RANDOM"),
            URLQueryItem(name: "size", value: "med"),
            URLQueryItem(name: "page", value: String(Int.random(in: 0...25)))
        ]
        if withCategory, let categoryID = genre.catAPICategoryID {
            queryItems.append(URLQueryItem(name: "category_ids", value: String(categoryID)))
        }
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw APIError.badURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        request.cachePolicy = .reloadIgnoringLocalCacheData
        if let apiKey, !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network
        }

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw APIError.invalidResponse
        }

        let images: [CatImage]
        do {
            images = try decoder.decode([CatImage].self, from: data)
        } catch {
            throw APIError.decoding
        }

        guard !images.isEmpty else { return [] }

        return images.enumerated().compactMap { index, image in
            guard let photoURL = URL(string: image.url) else { return nil }
            let breed = image.breeds?.first?.name?.nonEmpty

            return SocialFeedPost(
                id: "catapi_\(image.id)",
                username: breed ?? genre.authorTitles[index % genre.authorTitles.count],
                avatarURL: URL(string: "https://cataas.com/cat/says/Hi?width=120&height=120&fontColor=white"),
                photoURL: photoURL,
                caption: makeCaption(for: image, genre: genre),
                date: Calendar.current.date(byAdding: .minute, value: -(index * 4), to: Date()) ?? Date()
            )
        }
    }

    private func makeCaption(for image: CatImage, genre: FeedGenre) -> String {
        guard let breed = image.breeds?.first else {
            return "\(genre.captionPrefix)\nФото из The CatAPI. ID: \(image.id)"
        }

        var parts: [String] = [genre.russianCaptions.randomElement() ?? genre.captionPrefix]
        if let name = breed.name?.nonEmpty {
            parts.append("Порода: \(name).")
        }
        if let origin = translatedOrigin(breed.origin) {
            parts.append("Страна происхождения: \(origin).")
        }
        if let temperament = translatedTemperament(breed.temperament) {
            parts.append("Характер: \(temperament).")
        }
        parts.append("Источник: The CatAPI.")
        return parts.joined(separator: "\n")
    }

    private func translatedOrigin(_ raw: String?) -> String? {
        guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        let map: [String: String] = [
            "United States": "США",
            "USA": "США",
            "United Kingdom": "Великобритания",
            "England": "Англия",
            "Scotland": "Шотландия",
            "Canada": "Канада",
            "Australia": "Австралия",
            "Egypt": "Египет",
            "Russia": "Россия",
            "France": "Франция",
            "Germany": "Германия",
            "Italy": "Италия",
            "Turkey": "Турция",
            "Japan": "Япония",
            "Thailand": "Таиланд",
            "Norway": "Норвегия"
        ]
        return map[raw]
    }

    private func translatedTemperament(_ raw: String?) -> String? {
        guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return nil }
        let map: [String: String] = [
            "Affectionate": "ласковый",
            "Curious": "любознательный",
            "Friendly": "дружелюбный",
            "Gentle": "мягкий",
            "Playful": "игривый",
            "Active": "активный",
            "Calm": "спокойный",
            "Social": "общительный",
            "Intelligent": "умный",
            "Loyal": "преданный",
            "Energetic": "энергичный",
            "Independent": "самостоятельный",
            "Quiet": "тихий",
            "Sweet": "милый",
            "Agile": "ловкий"
        ]

        let translated = raw
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .compactMap { map[$0] }

        guard !translated.isEmpty else { return nil }
        return translated.joined(separator: ", ")
    }

    private static func readAPIKey() -> String? {
        (Bundle.main.object(forInfoDictionaryKey: "CAT_API_KEY") as? String)
            ?? (Bundle.main.object(forInfoDictionaryKey: "THE_CAT_API_KEY") as? String)
    }

    private static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 60 * 1024 * 1024,
            diskPath: "cat-feed-cache"
        )
        return URLSession(configuration: configuration)
    }

}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
