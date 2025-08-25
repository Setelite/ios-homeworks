//
//  PhotosTableViewCell.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 18.08.2025.
//

import UIKit

final class PhotosTableViewCell: UITableViewCell {
    
    static let identifier = "PhotosTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Photos"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.right"))
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var imageViewsArray: [UIImageView] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageView)
        
        // Создаём 4 imageView
        for _ in 0..<4 {
            let iv = UIImageView()
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.layer.cornerRadius = 6
            iv.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(iv)
            imageViewsArray.append(iv)
        }
        
        NSLayoutConstraint.activate([
            // Заголовок
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            // Стрелка
            arrowImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            // Фото
            // Фото
            imageViewsArray[0].topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            imageViewsArray[0].leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            imageViewsArray[0].bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            imageViewsArray[1].topAnchor.constraint(equalTo: imageViewsArray[0].topAnchor),
            imageViewsArray[1].leadingAnchor.constraint(equalTo: imageViewsArray[0].trailingAnchor, constant: 8),

            imageViewsArray[2].topAnchor.constraint(equalTo: imageViewsArray[0].topAnchor),
            imageViewsArray[2].leadingAnchor.constraint(equalTo: imageViewsArray[1].trailingAnchor, constant: 8),

            imageViewsArray[3].topAnchor.constraint(equalTo: imageViewsArray[0].topAnchor),
            imageViewsArray[3].leadingAnchor.constraint(equalTo: imageViewsArray[2].trailingAnchor, constant: 8),
            imageViewsArray[3].trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            // Все фото равные по ширине
            imageViewsArray[0].widthAnchor.constraint(equalTo: imageViewsArray[1].widthAnchor),
            imageViewsArray[1].widthAnchor.constraint(equalTo: imageViewsArray[2].widthAnchor),
            imageViewsArray[2].widthAnchor.constraint(equalTo: imageViewsArray[3].widthAnchor),

            // ✅ Соотношение 1:1 для квадратных картинок
            imageViewsArray[0].heightAnchor.constraint(equalTo: imageViewsArray[0].widthAnchor),
            imageViewsArray[1].heightAnchor.constraint(equalTo: imageViewsArray[1].widthAnchor),
            imageViewsArray[2].heightAnchor.constraint(equalTo: imageViewsArray[2].widthAnchor),
            imageViewsArray[3].heightAnchor.constraint(equalTo: imageViewsArray[3].widthAnchor),

            // Все фото одинаковой высоты
            imageViewsArray[1].heightAnchor.constraint(equalTo: imageViewsArray[0].heightAnchor),
            imageViewsArray[2].heightAnchor.constraint(equalTo: imageViewsArray[0].heightAnchor),
            imageViewsArray[3].heightAnchor.constraint(equalTo: imageViewsArray[0].heightAnchor)

        ])
    }
    
    func configure(with photos: [String]) {
        for (index, imageName) in photos.prefix(4).enumerated() {
            imageViewsArray[index].image = UIImage(named: imageName)
        }
    }
}
