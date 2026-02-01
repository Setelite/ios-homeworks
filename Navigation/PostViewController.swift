//
//  PostViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 16.07.2025.
//

import UIKit

final class PostViewController: UIViewController {

    // ✅ ОБЯЗАТЕЛЬНО
    let post: Post
    private let favorites = FavoritesRepository.shared

    // ✅ Инициализатор
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = post.author
        updateFavoriteState()
    }

    private func updateFavoriteState() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(
                systemName: favorites.isFavorite(id: post.id)
                    ? "heart.fill"
                    : "heart"
            ),
            style: .plain,
            target: self,
            action: #selector(toggleFavorite)
        )
    }

    @objc private func toggleFavorite() {
        _ = favorites.toggle(post: post)
        updateFavoriteState()
    }
}
