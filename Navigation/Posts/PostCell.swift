//
//  PostCell.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/22/26.
//

import UIKit

final class PostCell: UITableViewCell {

    private let titleLabel = UILabel()
    var onDoubleTap: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        onDoubleTap = nil
    }

    func configure(with post: Post) {
        titleLabel.text = post.description
    }

    private func setupUI() {
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 16)

        contentView.addSubview(titleLabel)
        contentView.isUserInteractionEnabled = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(doubleTap)
        )
        tap.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(tap)
    }

    @objc private func doubleTap() {
        onDoubleTap?()
    }
}
