//
//  PostCell.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/22/26.
//

import UIKit

final class PostCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private let likeImageView = UIImageView()

    var onLikeTap: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(post: Post, isFavorite: Bool) {
        titleLabel.text = post.description
        let likesText = L10n.format("post.likes", post.likes)
        let viewsText = L10n.format("post.views", post.views)
        metaLabel.text = "\(likesText)   \(viewsText)"
        likeImageView.image = UIImage(
            systemName: isFavorite ? "heart.fill" : "heart"
        )
        likeImageView.tintColor = isFavorite ? StyleGuide.Colors.danger : StyleGuide.Colors.muted
    }

    private func setupUI() {
        selectionStyle = .none

        titleLabel.numberOfLines = 0
        titleLabel.font = StyleGuide.Fonts.body()

        metaLabel.numberOfLines = 1
        metaLabel.font = StyleGuide.Fonts.caption()
        metaLabel.textColor = StyleGuide.Colors.textSecondary

        likeImageView.contentMode = .scaleAspectFit
        likeImageView.isUserInteractionEnabled = false

        contentView.addSubview(titleLabel)
        contentView.addSubview(metaLabel)
        contentView.addSubview(likeImageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        metaLabel.translatesAutoresizingMaskIntoConstraints = false
        likeImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            //  ЛАЙК — ФИКСИРОВАННЫЙ РАЗМЕР
            likeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            likeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            likeImageView.widthAnchor.constraint(equalToConstant: 24),
            likeImageView.heightAnchor.constraint(equalToConstant: 24),

            // ТЕКСТ
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: likeImageView.leadingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            metaLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(tap)
    }

    @objc private func likeTapped() {
        animateLike()
        onLikeTap?()
    }

    private func animateLike() {
        UIView.animate(withDuration: 0.15, animations: {
            self.likeImageView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.likeImageView.transform = .identity
            }
        }
    }
}
