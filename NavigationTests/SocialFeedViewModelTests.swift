import XCTest
@testable import Navigation

@MainActor
final class SocialFeedViewModelTests: XCTestCase {
    private final class FeedServiceMock: FeedServiceProtocol {
        var result: Result<[SocialFeedPost], Error> = .success([])

        func fetchPosts(limit: Int) async throws -> [SocialFeedPost] {
            try result.get()
        }
    }

    private final class CacheMock: FeedCacheRepositoryProtocol {
        var cached: [SocialFeedPost] = []

        func save(posts: [SocialFeedPost]) throws {
            cached = posts
        }

        func loadPosts(limit: Int) throws -> [SocialFeedPost] {
            Array(cached.prefix(limit))
        }
    }

    func testRefresh_usesCacheWhenNetworkFails() async {
        let service = FeedServiceMock()
        service.result = .failure(APIError.network)

        let cache = CacheMock()
        cache.cached = [
            SocialFeedPost(
                id: "1",
                username: "cached_user",
                avatarURL: URL(string: "https://example.com/avatar.jpg"),
                photoURL: URL(string: "https://example.com/photo.jpg"),
                caption: "cached",
                date: Date()
            )
        ]

        let viewModel = SocialFeedViewModel(service: service, cacheRepository: cache)
        await viewModel.refresh()

        if case .content(let posts) = viewModel.state {
            XCTAssertEqual(posts.count, 1)
            XCTAssertEqual(posts.first?.username, "cached_user")
        } else {
            XCTFail("Expected content from cache")
        }
    }
}
