import Foundation

final class SearchViewModel {
    enum Segment: Int {
        case music
    }

    enum Item: Equatable {
        case track(MusicTrack)
    }

    private let musicService: MusicCatalogServiceProtocol

    private var allTracks: [MusicTrack] = []
    private var searchText: String = ""
    private(set) var segment: Segment = .music

    private(set) var items: [Item] = []
    private(set) var selectedTrack: MusicTrack?

    var onStateChange: ((ScreenState) -> Void)?
    var onItemsChange: (() -> Void)?
    var onTrackSelected: ((MusicTrack?) -> Void)?

    init(musicService: MusicCatalogServiceProtocol = MusicCatalogService()) {
        self.musicService = musicService
    }

    func load() {
        Task {
            await MainActor.run {
                self.onStateChange?(.loading(L10n.tr("search.state.loading")))
            }
            let tracks: [MusicTrack] = (try? await musicService.fetchTracks(query: "top hits 2026", limit: 50)) ?? []

            await MainActor.run {
                self.allTracks = tracks
                self.applyFilterAndRefresh()
            }
        }
    }

    func updateSegment(index: Int) {
        segment = Segment(rawValue: index) ?? .music
        applyFilterAndRefresh()
    }

    func updateSearch(text: String) {
        searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        applyFilterAndRefresh()
    }

    func selectItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        if case .track(let track) = items[index] {
            selectedTrack = track
            onTrackSelected?(track)
        }
    }

    private func applyFilterAndRefresh() {
        let normalized = searchText.lowercased()
        let filtered: [MusicTrack]
        if normalized.isEmpty {
            filtered = allTracks
        } else {
            filtered = allTracks.filter {
                $0.title.lowercased().contains(normalized)
                || $0.artist.lowercased().contains(normalized)
            }
        }

        items = filtered.map { .track($0) }

        if let current = selectedTrack,
           filtered.contains(where: { $0.id == current.id }) {
            onTrackSelected?(current)
        } else {
            selectedTrack = filtered.first
            onTrackSelected?(selectedTrack)
        }

        onItemsChange?()
        onStateChange?(items.isEmpty ? .empty(L10n.tr("search.state.empty")) : .content)
    }
}
