//
//  FavoritesRepository.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/22/26.
//

import CoreData
import UIKit

final class FavoritesRepository {

    static let shared = FavoritesRepository()
    private let context = CoreDataStack.shared.context

    func save(post: Post) {
        guard !isFavorite(id: post.id) else { return }

        let entity = PostEntity(context: context)
        entity.id = post.id
        entity.author = post.author
        entity.text = post.description
        entity.likes = Int64(post.likes)
        //entity.image = post.image
        //entity.views = Int64(post.views)

        CoreDataStack.shared.saveContext()
    }

    func fetchAll() -> [Post] {
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()

        let result = (try? context.fetch(request)) ?? []
        return result.map {
            Post(
                id: $0.id ?? "",
                author: $0.author ?? "",
                description: $0.text ?? "",
                image: "post1",
                likes: Int($0.likes),
                views: 0
            )
        }

    }

    func isFavorite(id: String) -> Bool {
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1

        let count = (try? context.count(for: request)) ?? 0
        return count > 0
    }

    func remove(id: String) {
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)

        let objects = (try? context.fetch(request)) ?? []
        objects.forEach { context.delete($0) }

        CoreDataStack.shared.saveContext()
    }
}
