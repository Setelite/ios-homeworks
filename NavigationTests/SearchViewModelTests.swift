import XCTest
@testable import Navigation

final class SearchViewModelTests: XCTestCase {
    private final class MusicMock: MusicCatalogServiceProtocol {
        var result: [MusicTrack] = []

        func fetchTracks(query: String, limit: Int) async throws -> [MusicTrack] {
            Array(result.prefix(limit))
        }
    }

    func testLoad_populatesTracks() {
        let music = MusicMock()
        music.result = [
            MusicTrack(id: 10, title: "Believer", artist: "Imagine Dragons", previewURL: URL(string: "https://example.com/a.mp3")!, artworkURL: nil)
        ]

        let viewModel = SearchViewModel(musicService: music)
        let exp = expectation(description: "items")
        viewModel.onItemsChange = {
            exp.fulfill()
        }

        viewModel.load()
        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(viewModel.items.count, 1)
        if case .track(let track) = viewModel.items[0] {
            XCTAssertEqual(track.artist, "Imagine Dragons")
        } else {
            XCTFail("Expected track item")
        }
    }

    func testUpdateSearch_filtersTracks() {
        let music = MusicMock()
        music.result = [
            MusicTrack(id: 10, title: "Believer", artist: "Imagine Dragons", previewURL: URL(string: "https://example.com/a.mp3")!, artworkURL: nil),
            MusicTrack(id: 11, title: "Numb", artist: "Linkin Park", previewURL: URL(string: "https://example.com/b.mp3")!, artworkURL: nil)
        ]

        let viewModel = SearchViewModel(musicService: music)
        let loadExp = expectation(description: "loaded")
        viewModel.onItemsChange = { loadExp.fulfill() }
        viewModel.load()
        waitForExpectations(timeout: 1.0)

        viewModel.updateSearch(text: "linkin")

        XCTAssertEqual(viewModel.items.count, 1)
        if case .track(let track) = viewModel.items[0] {
            XCTAssertEqual(track.title, "Numb")
        } else {
            XCTFail("Expected filtered track")
        }
    }
}
