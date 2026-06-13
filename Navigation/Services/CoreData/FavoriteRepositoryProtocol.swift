//
//  FavoriteRepositoryProtocol.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/25/26.
//

import Foundation

protocol FavoritesRepositoryProtocol {
    func toggle(post: Post) -> Bool
    func isFavorite(id: String) -> Bool
    func fetchAll() -> [Post]
}
