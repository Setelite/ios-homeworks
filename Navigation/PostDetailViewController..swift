//
//  PostDetailViewController..swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 11/29/25.
//

import UIKit
import StorageService

final class PostDetailViewController: UIViewController {

    var post: Post?

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = StyleGuide.Colors.backgroundPrimary
        title = L10n.tr("post.title")

        setupUI()
        updateUI()
    }

    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        titleLabel.font = StyleGuide.Fonts.title(20)
        titleLabel.textColor = StyleGuide.Colors.textPrimary

        descriptionLabel.font = StyleGuide.Fonts.body()
        descriptionLabel.textColor = StyleGuide.Colors.textSecondary
        descriptionLabel.numberOfLines = 0

        [imageView, titleLabel, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 250),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }

    private func updateUI() {
        guard let post else { return }

        titleLabel.text = post.author
        descriptionLabel.text = post.description
        imageView.image = UIImage(named: post.image)
    }
}
