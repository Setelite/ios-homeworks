//
//  PostTableViewCell.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 12.08.2025.
//

//import StorageService
import UIKit
import iOSIntPackage


class PostTableViewCell: UITableViewCell {
    static let identifier = "PostTableViewCell"
    var onLikeTap: (() -> Void)?

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let likesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let likesIconButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let viewsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let viewsIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "eye.fill"))
        imageView.tintColor = .darkGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UI Setup
    private func setupUI() {
        contentView.addSubview(authorLabel)
        contentView.addSubview(postImageView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(likesIconButton)
        contentView.addSubview(likesLabel)
        contentView.addSubview(viewsIconView)
        contentView.addSubview(viewsLabel)

        NSLayoutConstraint.activate([
            // Author label
            authorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Post image
            postImageView.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 12),
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor),

            // Description
            descriptionLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Likes label
            likesLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            likesLabel.leadingAnchor.constraint(equalTo: likesIconButton.trailingAnchor, constant: 10),
            likesLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

            // Likes icon
            likesIconButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            likesIconButton.centerYAnchor.constraint(equalTo: likesLabel.centerYAnchor),
            likesIconButton.widthAnchor.constraint(equalToConstant: 28),
            likesIconButton.heightAnchor.constraint(equalToConstant: 28),

            // Views label
            viewsLabel.topAnchor.constraint(equalTo: likesLabel.bottomAnchor, constant: 8),
            viewsLabel.leadingAnchor.constraint(equalTo: viewsIconView.trailingAnchor, constant: 10),
            viewsLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            viewsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            // Views icon
            viewsIconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            viewsIconView.centerYAnchor.constraint(equalTo: viewsLabel.centerYAnchor),
            viewsIconView.widthAnchor.constraint(equalToConstant: 20),
            viewsIconView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    // MARK: Configure Cell
    func configure(with post: Post, isFavorite: Bool) {
        authorLabel.text = post.author
        if let image = UIImage(named: post.image) {
            ImageProcessor().processImage(sourceImage: image, filter: .noir) { filteredImage in
                DispatchQueue.main.async {
                    self.postImageView.image = filteredImage
                }
            }
        }
        descriptionLabel.text = post.description
        likesLabel.text = "Likes: \(post.likes)"
        viewsLabel.text = "Views: \(post.views)"
        updateFavoriteUI(isFavorite: isFavorite)
    }

    private func setupActions() {
        likesIconButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        doubleTap.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTap)
    }

    @objc private func likeTapped() {
        onLikeTap?()
    }

    private func updateFavoriteUI(isFavorite: Bool) {
        likesIconButton.setImage(
            UIImage(systemName: isFavorite ? "heart.fill" : "heart"),
            for: .normal
        )
        likesIconButton.tintColor = isFavorite ? .systemRed : .lightGray
    }
}
