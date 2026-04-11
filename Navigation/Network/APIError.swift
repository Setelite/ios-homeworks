import Foundation

enum APIError: LocalizedError {
    case badURL
    case network
    case invalidResponse
    case notFound
    case decoding

    var errorDescription: String? {
        switch self {
        case .badURL:
            return L10n.tr("api.error.bad_url")
        case .network:
            return L10n.tr("api.error.network")
        case .invalidResponse:
            return L10n.tr("api.error.invalid_response")
        case .notFound:
            return L10n.tr("api.error.not_found")
        case .decoding:
            return L10n.tr("api.error.decoding")
        }
    }
}
