//
//  FavoritesRepository.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/22/26.
//

import CoreData

final class FavoritesRepository: FavoritesRepositoryProtocol {

    static let shared = FavoritesRepository()
    private init() {}

    // MARK: - Save (background)
    func save(post: Post) {
        let context = CoreDataStack.shared.newBackgroundContext()

        context.perform {
            guard !self.isFavorite(id: post.id, context: context) else { return }

            let entity = FavoritePostEntity(context: context)
            entity.id = post.id
            entity.author = post.author
            entity.text = post.description
            entity.image = post.image
            entity.likes = Int64(post.likes)
            entity.views = Int64(post.views)

            try? context.save()
        }
    }

    // MARK: - Remove (background)
    func remove(id: String) {
        let context = CoreDataStack.shared.newBackgroundContext()

        context.perform {
            let request: NSFetchRequest<FavoritePostEntity> =
                FavoritePostEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)

            let objects = (try? context.fetch(request)) ?? []
            objects.forEach { context.delete($0) }

            try? context.save()
        }
    }

    // MARK: - Toggle
    func toggle(post: Post) -> Bool {
        if isFavorite(id: post.id) {
            remove(id: post.id)
            return false
        } else {
            save(post: post)
            return true
        }
    }

    // MARK: - Fetch all (viewContext)
    func fetchAll() -> [Post] {
        let context = CoreDataStack.shared.viewContext

        let request: NSFetchRequest<FavoritePostEntity> =
            FavoritePostEntity.fetchRequest()

        let result = (try? context.fetch(request)) ?? []

        return result.map {
            Post(
                id: $0.id ?? "",
                author: $0.author ?? "",
                description: $0.text ?? "",
                image: $0.image ?? "",
                likes: Int($0.likes),
                views: Int($0.views)
            )
        }
    }

    // MARK: - Fetch by author (ДЗ!)
    func fetch(by author: String) -> [Post] {
        let context = CoreDataStack.shared.viewContext

        let request: NSFetchRequest<FavoritePostEntity> =
            FavoritePostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "author == %@", author)

        let result = (try? context.fetch(request)) ?? []

        return result.map {
            Post(
                id: $0.id ?? "",
                author: $0.author ?? "",
                description: $0.text ?? "",
                image: $0.image ?? "",
                likes: Int($0.likes),
                views: Int($0.views)
            )
        }
    }

    // MARK: - Is favorite
    func isFavorite(id: String) -> Bool {
        isFavorite(id: id, context: CoreDataStack.shared.viewContext)
    }

    private func isFavorite(
        id: String,
        context: NSManagedObjectContext
    ) -> Bool {
        let request: NSFetchRequest<FavoritePostEntity> =
            FavoritePostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1

        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }
}
