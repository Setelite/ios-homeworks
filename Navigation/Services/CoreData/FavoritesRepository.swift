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

    private let context = CoreDataStack.shared.context

    func save(post: Post) {
        guard !isFavorite(id: post.id) else { return }

        let entity = FavoritePostEntity(context: context)
        entity.id = post.id
        entity.author = post.author
        entity.text = post.description
        entity.image = post.image          // ✅ ВАЖНО
        entity.likes = Int64(post.likes)
        entity.views = Int64(post.views)

        CoreDataStack.shared.saveContext()
    }

    func fetchAll() -> [Post] {
        let request: NSFetchRequest<FavoritePostEntity> =
            FavoritePostEntity.fetchRequest()

        let result = (try? context.fetch(request)) ?? []

        return result.map {
            Post(
                id: $0.id ?? "",
                author: $0.author ?? "",
                description: $0.text ?? "",
                image: $0.image ?? "",      // ✅ ВАЖНО
                likes: Int($0.likes),
                views: Int($0.views)
            )
        }
    }

    func isFavorite(id: String) -> Bool {
        let request: NSFetchRequest<FavoritePostEntity> =
            FavoritePostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1

        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }

    func toggle(post: Post) -> Bool {
        if isFavorite(id: post.id) {
            remove(id: post.id)
            return false
        } else {
            save(post: post)
            return true
        }
    }

    private func remove(id: String) {
        let request: NSFetchRequest<FavoritePostEntity> =
            FavoritePostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)

        let objects = (try? context.fetch(request)) ?? []
        objects.forEach { context.delete($0) }

        CoreDataStack.shared.saveContext()
    }
}
