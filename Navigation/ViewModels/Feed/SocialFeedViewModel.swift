import Foundation

final class SocialFeedViewModel {
    enum State {
        case idle
        case loading
        case content([SocialFeedPost])
        case error(String)
    }

    private let service: FeedServiceProtocol
    private let cacheRepository: FeedCacheRepositoryProtocol

    private(set) var state: State = .idle {
        didSet { onStateChange?(state) }
    }

    var onStateChange: ((State) -> Void)?

    init(
        service: FeedServiceProtocol,
        cacheRepository: FeedCacheRepositoryProtocol
    ) {
        self.service = service
        self.cacheRepository = cacheRepository
    }

    func setGenre(_ genre: FeedGenre) {
        (service as? FeedGenreConfigurable)?.setGenre(genre)
    }

    @MainActor
    func loadInitial() async {
        state = .loading

        if let cached = try? cacheRepository.loadPosts(limit: 20).filter({ $0.id.hasPrefix("catapi_") }),
           !cached.isEmpty {
            state = .content(cached)
        }

        await refresh()
    }

    @MainActor
    func refresh() async {
        do {
            let posts = try await service.fetchPosts(limit: 20)
            try? cacheRepository.save(posts: posts)
            state = posts.isEmpty
                ? .error(L10n.tr("home.state.empty"))
                : .content(posts)
        } catch {
            if let cached = try? cacheRepository.loadPosts(limit: 20).filter({ $0.id.hasPrefix("catapi_") }),
               !cached.isEmpty {
                state = .content(cached)
                return
            }
            let message = (error as? LocalizedError)?.errorDescription ?? L10n.tr("api.error.network")
            state = .error(message)
        }
    }
}
