import Foundation
import CoreData

protocol FeedCacheRepositoryProtocol {
    func save(posts: [SocialFeedPost]) throws
    func loadPosts(limit: Int) throws -> [SocialFeedPost]
}

final class CoreDataFeedCacheRepository: FeedCacheRepositoryProtocol {
    private enum Constants {
        static let entityName = "CachedFeedPostEntity"
    }

    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    func save(posts: [SocialFeedPost]) throws {
        let context = coreDataStack.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)

        posts.forEach { post in
            let object = NSEntityDescription.insertNewObject(forEntityName: Constants.entityName, into: context)
            object.setValue(post.id, forKey: "id")
            object.setValue(post.username, forKey: "username")
            object.setValue(post.avatarURL?.absoluteString, forKey: "avatarURL")
            object.setValue(post.photoURL?.absoluteString, forKey: "photoURL")
            object.setValue(post.caption, forKey: "caption")
            object.setValue(post.date, forKey: "date")
        }

        try context.save()
    }

    func loadPosts(limit: Int = 20) throws -> [SocialFeedPost] {
        let request = NSFetchRequest<NSManagedObject>(entityName: Constants.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = max(1, min(50, limit))

        return try coreDataStack.viewContext.fetch(request).compactMap { object in
            guard
                let id = object.value(forKey: "id") as? String,
                let username = object.value(forKey: "username") as? String,
                let caption = object.value(forKey: "caption") as? String,
                let date = object.value(forKey: "date") as? Date
            else {
                return nil
            }

            return SocialFeedPost(
                id: id,
                username: username,
                avatarURL: URL(string: object.value(forKey: "avatarURL") as? String ?? ""),
                photoURL: URL(string: object.value(forKey: "photoURL") as? String ?? ""),
                caption: caption,
                date: date
            )
        }
    }
}
