//
//  PhotosCollectionViewCell.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 18.08.2025.
//

import UIKit

final class PhotosCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "PhotosCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 6
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with imageName: String) {
        imageView.image = UIImage(named: imageName)
    }

    func configure(with image: UIImage) {
        imageView.image = image
    }
}
