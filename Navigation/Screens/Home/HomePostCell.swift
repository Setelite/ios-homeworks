import UIKit

struct HomeFeedPost {
    var post: Post
    var localImage: UIImage?
    var localImageFileName: String?
    var likeCount: Int
    var commentCount: Int
    var shareCount: Int
    var isLiked: Bool
    var isCustomPublication: Bool
}

final class HomePostCell: UITableViewCell {
    static let identifier = "HomePostCell"

    private let cardView = UIView()
    private let authorLabel = UILabel()
    private let postImageView = UIImageView()
    private let descriptionLabel = UILabel()

    private let likeButton = UIButton(type: .system)
    private let commentButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let actionsStack = UIStackView()

    var onLikeTap: (() -> Void)?
    var onCommentTap: (() -> Void)?
    var onShareTap: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with model: HomeFeedPost) {
        authorLabel.text = model.post.author
        descriptionLabel.text = model.post.description
        postImageView.image = model.localImage ?? UIImage(named: model.post.image)

        let likeIcon = model.isLiked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: likeIcon), for: .normal)
        likeButton.setTitle(" \(model.likeCount)", for: .normal)
        likeButton.tintColor = model.isLiked ? StyleGuide.Colors.danger : StyleGuide.Colors.textSecondary

        commentButton.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        commentButton.setTitle(" \(model.commentCount)", for: .normal)

        shareButton.setImage(UIImage(systemName: "arrowshape.turn.up.right"), for: .normal)
        shareButton.setTitle(" \(model.shareCount)", for: .normal)
    }

    private func setupUI() {
        backgroundColor = StyleGuide.Colors.backgroundPrimary
        selectionStyle = .none

        cardView.backgroundColor = StyleGuide.Colors.card
        cardView.layer.cornerRadius = 14
        cardView.layer.borderWidth = 0.5
        cardView.layer.borderColor = StyleGuide.Colors.border.cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false

        authorLabel.font = StyleGuide.Fonts.body(15, weight: .semibold)
        authorLabel.textColor = StyleGuide.Colors.textPrimary
        authorLabel.translatesAutoresizingMaskIntoConstraints = false

        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 10
        postImageView.translatesAutoresizingMaskIntoConstraints = false

        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = StyleGuide.Fonts.body(15)
        descriptionLabel.textColor = StyleGuide.Colors.textPrimary
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        [likeButton, commentButton, shareButton].forEach {
            $0.titleLabel?.font = StyleGuide.Fonts.caption(14, weight: .medium)
            $0.tintColor = StyleGuide.Colors.textSecondary
            $0.contentHorizontalAlignment = .leading
        }

        actionsStack.axis = .horizontal
        actionsStack.distribution = .fillEqually
        actionsStack.spacing = 6
        actionsStack.translatesAutoresizingMaskIntoConstraints = false
        actionsStack.addArrangedSubview(likeButton)
        actionsStack.addArrangedSubview(commentButton)
        actionsStack.addArrangedSubview(shareButton)

        contentView.addSubview(cardView)
        cardView.addSubview(authorLabel)
        cardView.addSubview(postImageView)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(actionsStack)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            authorLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            authorLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            authorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            postImageView.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 10),
            postImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            postImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor, multiplier: 0.62),

            descriptionLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: postImageView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: postImageView.trailingAnchor),

            actionsStack.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            actionsStack.leadingAnchor.constraint(equalTo: postImageView.leadingAnchor),
            actionsStack.trailingAnchor.constraint(equalTo: postImageView.trailingAnchor),
            actionsStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10),
            actionsStack.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func setupActions() {
        likeButton.addTarget(self, action: #selector(likeTap), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(commentTap), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTap), for: .touchUpInside)
    }

    @objc private func likeTap() {
        onLikeTap?()
    }

    @objc private func commentTap() {
        onCommentTap?()
    }

    @objc private func shareTap() {
        onShareTap?()
    }
}
