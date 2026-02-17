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
    private let contentStack = UIStackView()
    private let descriptionLabel = UILabel()
    private let likesLabel = UILabel()
    private let viewsLabel = UILabel()

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
        setupUI()
        fillContent()
        updateFavoriteState()
    }

    private func setupUI() {
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 18, weight: .regular)
        descriptionLabel.textColor = .label

        likesLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        likesLabel.textColor = .systemRed

        viewsLabel.font = .systemFont(ofSize: 16, weight: .regular)
        viewsLabel.textColor = .secondaryLabel

        contentStack.addArrangedSubview(descriptionLabel)
        contentStack.addArrangedSubview(likesLabel)
        contentStack.addArrangedSubview(viewsLabel)
        view.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func fillContent() {
        descriptionLabel.text = post.description
        likesLabel.text = "Likes: \(post.likes)"
        viewsLabel.text = "Views: \(post.views)"
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
