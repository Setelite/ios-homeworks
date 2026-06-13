import Foundation

struct Celebrity: Equatable {
    let id: Int
    let name: String
    let country: String?
    let imageURL: URL?
    let portfolio: [String]
}

protocol CelebritiesServiceProtocol {
    func fetchCelebrities(limit: Int) async throws -> [Celebrity]
}

final class CelebritiesService: CelebritiesServiceProtocol {
    private struct PersonResponse: Decodable {
        struct Country: Decodable {
            let name: String?
        }

        struct ImageData: Decodable {
            let medium: String?
            let original: String?
        }

        let id: Int
        let name: String
        let country: Country?
        let image: ImageData?
    }

    private struct CastCreditResponse: Decodable {
        struct Embedded: Decodable {
            struct Show: Decodable {
                let name: String
            }

            let show: Show?
        }

        let embedded: Embedded?

        private enum CodingKeys: String, CodingKey {
            case embedded = "_embedded"
        }
    }

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func fetchCelebrities(limit: Int) async throws -> [Celebrity] {
        guard limit > 0 else { return [] }

        let peopleURL = URL(string: "https://api.tvmaze.com/people?page=1")!
        let people: [PersonResponse] = try await fetch(type: [PersonResponse].self, from: peopleURL)
        let selected = Array(people.prefix(limit))

        return try await withThrowingTaskGroup(of: Celebrity.self) { group in
            for person in selected {
                group.addTask { [weak self] in
                    let portfolio = try await self?.fetchPortfolio(for: person.id) ?? []
                    return Celebrity(
                        id: person.id,
                        name: person.name,
                        country: person.country?.name,
                        imageURL: URL(string: person.image?.medium ?? person.image?.original ?? ""),
                        portfolio: portfolio
                    )
                }
            }

            var result: [Celebrity] = []
            for try await celebrity in group {
                result.append(celebrity)
            }

            let idToIndex = Dictionary(uniqueKeysWithValues: selected.enumerated().map { ($1.id, $0) })
            return result.sorted { (idToIndex[$0.id] ?? 0) < (idToIndex[$1.id] ?? 0) }
        }
    }

    private func fetchPortfolio(for personId: Int) async throws -> [String] {
        let url = URL(string: "https://api.tvmaze.com/people/\(personId)/castcredits?embed=show")!
        let credits: [CastCreditResponse] = try await fetch(type: [CastCreditResponse].self, from: url)

        var seen = Set<String>()
        var portfolio: [String] = []

        for credit in credits {
            guard let title = credit.embedded?.show?.name, !title.isEmpty else { continue }
            if seen.insert(title).inserted {
                portfolio.append(title)
            }
            if portfolio.count == 3 { break }
        }

        return portfolio
    }

    private func fetch<T: Decodable>(type: T.Type, from url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try decoder.decode(T.self, from: data)
    }
}
