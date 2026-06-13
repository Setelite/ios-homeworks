import CloudKit
import UIKit

struct CloudPost {
    let id: String
    let author: String
    let description: String
    let likes: Int
    let views: Int
    let comments: Int
    let shares: Int
    let isLiked: Bool
    let image: UIImage?
    let createdAt: Date
}

/// Cloud-backed store for user publications shared across devices/simulators.
final class CloudPostsService {
    private enum Constants {
        static let recordType = "UserPost"
    }

    private enum Keys {
        static let postId = "postId"
        static let author = "author"
        static let description = "description"
        static let likes = "likes"
        static let views = "views"
        static let comments = "comments"
        static let shares = "shares"
        static let isLiked = "isLiked"
        static let imageAsset = "imageAsset"
        static let createdAt = "createdAt"
    }

    private let container: CKContainer
    private let database: CKDatabase

    init(container: CKContainer) {
        self.container = container
        self.database = container.publicCloudDatabase
    }

    func fetchPosts(completion: @escaping (Result<[CloudPost], Error>) -> Void) {
        checkCloudAvailability { [weak self] available in
            guard let self else { return }
            guard available else {
                completion(.failure(NSError(domain: "CloudKit", code: 0, userInfo: [NSLocalizedDescriptionKey: "CloudKit is unavailable"])))
                return
            }

            let query = CKQuery(recordType: Constants.recordType, predicate: NSPredicate(value: true))
            query.sortDescriptors = [NSSortDescriptor(key: Keys.createdAt, ascending: false)]
            self.fetchPosts(query: query, accumulated: [], completion: completion)
        }
    }

    func upsert(post: CloudPost, completion: ((Result<Void, Error>) -> Void)? = nil) {
        checkCloudAvailability { [weak self] available in
            guard let self else { return }
            guard available else {
                completion?(.success(()))
                return
            }

            let recordID = CKRecord.ID(recordName: post.id)

            self.database.fetch(withRecordID: recordID) { [weak self] fetchedRecord, error in
                let record: CKRecord

                if let ckError = error as? CKError, ckError.code == .unknownItem {
                    record = CKRecord(recordType: Constants.recordType, recordID: recordID)
                } else if let fetchedRecord {
                    record = fetchedRecord
                } else if let error {
                    completion?(.failure(error))
                    return
                } else {
                    record = CKRecord(recordType: Constants.recordType, recordID: recordID)
                }

                self?.fill(record: record, with: post)
                self?.database.save(record) { _, saveError in
                    if let saveError {
                        completion?(.failure(saveError))
                    } else {
                        completion?(.success(()))
                    }
                }
            }
        }
    }

    func delete(postId: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        checkCloudAvailability { [weak self] available in
            guard let self else { return }
            guard available else {
                completion?(.success(()))
                return
            }

            let recordID = CKRecord.ID(recordName: postId)
            self.database.delete(withRecordID: recordID) { _, error in
                if let ckError = error as? CKError, ckError.code == .unknownItem {
                    completion?(.success(()))
                    return
                }

                if let error {
                    completion?(.failure(error))
                } else {
                    completion?(.success(()))
                }
            }
        }
    }

    private func fill(record: CKRecord, with post: CloudPost) {
        record[Keys.postId] = post.id as CKRecordValue
        record[Keys.author] = post.author as CKRecordValue
        record[Keys.description] = post.description as CKRecordValue
        record[Keys.likes] = post.likes as CKRecordValue
        record[Keys.views] = post.views as CKRecordValue
        record[Keys.comments] = post.comments as CKRecordValue
        record[Keys.shares] = post.shares as CKRecordValue
        record[Keys.isLiked] = post.isLiked as CKRecordValue
        record[Keys.createdAt] = post.createdAt as CKRecordValue

        if let image = post.image,
           let url = makeTemporaryImageURL(image: image, id: post.id) {
            record[Keys.imageAsset] = CKAsset(fileURL: url)
        }
    }

    private func map(record: CKRecord) -> CloudPost? {
        guard
            let id = record[Keys.postId] as? String,
            let author = record[Keys.author] as? String,
            let description = record[Keys.description] as? String,
            let likes = record[Keys.likes] as? Int,
            let views = record[Keys.views] as? Int,
            let comments = record[Keys.comments] as? Int,
            let shares = record[Keys.shares] as? Int,
            let isLiked = record[Keys.isLiked] as? Bool
        else {
            return nil
        }

        let createdAt = (record[Keys.createdAt] as? Date) ?? Date.distantPast
        let image: UIImage?
        if let asset = record[Keys.imageAsset] as? CKAsset,
           let fileURL = asset.fileURL,
           let data = try? Data(contentsOf: fileURL) {
            image = UIImage(data: data)
        } else {
            image = nil
        }

        return CloudPost(
            id: id,
            author: author,
            description: description,
            likes: likes,
            views: views,
            comments: comments,
            shares: shares,
            isLiked: isLiked,
            image: image,
            createdAt: createdAt
        )
    }

    private func makeTemporaryImageURL(image: UIImage, id: String) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("cloud_post_\(id).jpg")

        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    private func checkCloudAvailability(completion: @escaping (Bool) -> Void) {
        container.accountStatus { status, _ in
            completion(status == .available)
        }
    }

    private func fetchPosts(
        query: CKQuery,
        accumulated: [CloudPost],
        completion: @escaping (Result<[CloudPost], Error>) -> Void
    ) {
        database.fetch(
            withQuery: query,
            inZoneWith: nil,
            desiredKeys: nil,
            resultsLimit: CKQueryOperation.maximumResults
        ) { [weak self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let success):
                let pagePosts = success.matchResults.compactMap { _, itemResult -> CloudPost? in
                    guard case .success(let record) = itemResult else { return nil }
                    return self?.map(record: record)
                }

                let merged = accumulated + pagePosts

                if let cursor = success.queryCursor {
                    self?.fetchPosts(cursor: cursor, accumulated: merged, completion: completion)
                } else {
                    completion(.success(merged))
                }
            }
        }
    }

    private func fetchPosts(
        cursor: CKQueryOperation.Cursor,
        accumulated: [CloudPost],
        completion: @escaping (Result<[CloudPost], Error>) -> Void
    ) {
        database.fetch(
            withCursor: cursor,
            desiredKeys: nil,
            resultsLimit: CKQueryOperation.maximumResults
        ) { [weak self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let success):
                let pagePosts = success.matchResults.compactMap { _, itemResult -> CloudPost? in
                    guard case .success(let record) = itemResult else { return nil }
                    return self?.map(record: record)
                }

                let merged = accumulated + pagePosts

                if let nextCursor = success.queryCursor {
                    self?.fetchPosts(cursor: nextCursor, accumulated: merged, completion: completion)
                } else {
                    completion(.success(merged))
                }
            }
        }
    }
}
