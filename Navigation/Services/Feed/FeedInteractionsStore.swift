import Foundation

struct FeedInteractionSnapshot {
    let isLiked: Bool
    let likesCount: Int
    let commentsCount: Int
    let sharesCount: Int
}

protocol FeedInteractionsStoreProtocol {
    func snapshot(for postID: String, userID: String) -> FeedInteractionSnapshot
    func toggleLike(for postID: String, userID: String) -> FeedInteractionSnapshot
    func addComment(for postID: String, userID: String, text: String) -> FeedInteractionSnapshot
    func incrementShare(for postID: String, userID: String) -> FeedInteractionSnapshot
}

final class FeedInteractionsStore: FeedInteractionsStoreProtocol {
    private struct CommentItem: Codable {
        let id: String
        let userID: String
        let text: String
        let createdAt: Date
    }

    private struct InteractionRecord: Codable {
        var likedUserIDs: Set<String>
        var comments: [CommentItem]
        var sharesCount: Int
    }

    private enum Keys {
        static let storage = "feed.interactions.store.v1"
    }

    private let storage: UserDefaults
    private var records: [String: InteractionRecord]

    init(storage: UserDefaults = .standard) {
        self.storage = storage
        self.records = Self.load(from: storage)
    }

    func snapshot(for postID: String, userID: String) -> FeedInteractionSnapshot {
        let record = records[postID] ?? .init(likedUserIDs: [], comments: [], sharesCount: 0)
        return snapshot(from: record, userID: userID)
    }

    func toggleLike(for postID: String, userID: String) -> FeedInteractionSnapshot {
        var record = records[postID] ?? .init(likedUserIDs: [], comments: [], sharesCount: 0)
        if record.likedUserIDs.contains(userID) {
            record.likedUserIDs.remove(userID)
        } else {
            record.likedUserIDs.insert(userID)
        }
        records[postID] = record
        persist()
        return snapshot(from: record, userID: userID)
    }

    func addComment(for postID: String, userID: String, text: String) -> FeedInteractionSnapshot {
        var record = records[postID] ?? .init(likedUserIDs: [], comments: [], sharesCount: 0)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return snapshot(from: record, userID: userID)
        }
        record.comments.append(.init(id: UUID().uuidString, userID: userID, text: trimmed, createdAt: Date()))
        records[postID] = record
        persist()
        return snapshot(from: record, userID: userID)
    }

    func incrementShare(for postID: String, userID: String) -> FeedInteractionSnapshot {
        var record = records[postID] ?? .init(likedUserIDs: [], comments: [], sharesCount: 0)
        record.sharesCount += 1
        records[postID] = record
        persist()
        return snapshot(from: record, userID: userID)
    }

    private func snapshot(from record: InteractionRecord, userID: String) -> FeedInteractionSnapshot {
        FeedInteractionSnapshot(
            isLiked: record.likedUserIDs.contains(userID),
            likesCount: record.likedUserIDs.count,
            commentsCount: record.comments.count,
            sharesCount: record.sharesCount
        )
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        storage.set(data, forKey: Keys.storage)
    }

    private static func load(from storage: UserDefaults) -> [String: InteractionRecord] {
        guard
            let data = storage.data(forKey: Keys.storage),
            let records = try? JSONDecoder().decode([String: InteractionRecord].self, from: data)
        else {
            return [:]
        }
        return records
    }
}
