//
//  PostTableViewCell.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 12.08.2025.
//

//import StorageService
import UIKit
import iOSIntPackage


final class PostTableViewCell: UITableViewCell {
    static let identifier = "PostTableViewCell"
    var onLikeTap: (() -> Void)?

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = StyleGuide.Fonts.title(18)
        label.textColor = StyleGuide.Colors.textPrimary
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = StyleGuide.Colors.textPrimary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = StyleGuide.Fonts.body(14, weight: .regular)
        label.textColor = StyleGuide.Colors.muted
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let likesLabel: UILabel = {
        let label = UILabel()
        label.font = StyleGuide.Fonts.body(15, weight: .semibold)
        label.textColor = StyleGuide.Colors.danger
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let likesIconButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = StyleGuide.Colors.muted
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let viewsLabel: UILabel = {
        let label = UILabel()
        label.font = StyleGuide.Fonts.body(15, weight: .semibold)
        label.textColor = StyleGuide.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let viewsIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "eye"))
        imageView.tintColor = StyleGuide.Colors.textSecondary
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
            likesLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            likesLabel.leadingAnchor.constraint(equalTo: likesIconButton.trailingAnchor, constant: 10),
            likesLabel.trailingAnchor.constraint(lessThanOrEqualTo: viewsIconView.leadingAnchor, constant: -20),

            // Likes icon
            likesIconButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            likesIconButton.centerYAnchor.constraint(equalTo: likesLabel.centerYAnchor),
            likesIconButton.widthAnchor.constraint(equalToConstant: 22),
            likesIconButton.heightAnchor.constraint(equalToConstant: 22),

            // Views label
            viewsLabel.centerYAnchor.constraint(equalTo: likesLabel.centerYAnchor),
            viewsLabel.leadingAnchor.constraint(equalTo: viewsIconView.trailingAnchor, constant: 10),
            viewsLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            viewsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            // Views icon
            viewsIconView.leadingAnchor.constraint(greaterThanOrEqualTo: likesLabel.trailingAnchor, constant: 20),
            viewsIconView.centerYAnchor.constraint(equalTo: viewsLabel.centerYAnchor),
            viewsIconView.widthAnchor.constraint(equalToConstant: 18),
            viewsIconView.heightAnchor.constraint(equalToConstant: 18)
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
        likesLabel.text = "\(post.likes)"
        viewsLabel.text = "\(post.views)"
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
        likesIconButton.tintColor = isFavorite ? StyleGuide.Colors.danger : StyleGuide.Colors.muted
    }
}
