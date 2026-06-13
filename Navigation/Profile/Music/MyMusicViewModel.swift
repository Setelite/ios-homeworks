import Foundation

final class MyMusicViewModel {
    private let service: MusicCatalogServiceProtocol
    private(set) var tracks: [MusicTrack] = []

    var onStateChange: ((ScreenState) -> Void)?
    var onDataChanged: (() -> Void)?

    init(service: MusicCatalogServiceProtocol = MusicCatalogService()) {
        self.service = service
    }

    func load() {
        Task {
            await MainActor.run {
                self.onStateChange?(.loading(L10n.tr("music.state.loading")))
            }

            do {
                let loaded = try await service.fetchTracks(query: "top hits 2026", limit: 50)
                await MainActor.run {
                    self.tracks = loaded
                    self.onDataChanged?()
                    self.onStateChange?(loaded.isEmpty ? .empty(L10n.tr("music.state.empty")) : .content)
                }
            } catch {
                await MainActor.run {
                    self.onStateChange?(.error(L10n.tr("music.state.error")))
                }
            }
        }
    }
}
