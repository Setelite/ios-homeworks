import Foundation

struct MusicTrack: Equatable {
    let id: Int
    let title: String
    let artist: String
    let previewURL: URL
    let artworkURL: URL?
}

protocol MusicCatalogServiceProtocol {
    func fetchTracks(query: String, limit: Int) async throws -> [MusicTrack]
}

final class MusicCatalogService: MusicCatalogServiceProtocol {
    private struct SearchResponse: Decodable {
        struct TrackResponse: Decodable {
            let trackId: Int
            let trackName: String
            let artistName: String
            let previewUrl: String?
            let artworkUrl100: String?
        }

        let results: [TrackResponse]
    }

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func fetchTracks(query: String, limit: Int) async throws -> [MusicTrack] {
        guard limit > 0 else { return [] }

        var components = URLComponents(string: "https://itunes.apple.com/search")!
        components.queryItems = [
            URLQueryItem(name: "term", value: query),
            URLQueryItem(name: "media", value: "music"),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: String(limit))
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let payload = try decoder.decode(SearchResponse.self, from: data)
        return payload.results.compactMap { item in
            guard let previewUrl = item.previewUrl,
                  let previewURL = URL(string: previewUrl) else {
                return nil
            }

            return MusicTrack(
                id: item.trackId,
                title: item.trackName,
                artist: item.artistName,
                previewURL: previewURL,
                artworkURL: URL(string: item.artworkUrl100 ?? "")
            )
        }
    }
}
