import UIKit

struct HomeFeedPost {
    var post: Post
    var avatarURL: URL?
    var publishedAt: Date?
    var localImage: UIImage?
    var localImageFileName: String?
    var remoteImageURL: URL?
    var likeCount: Int
    var commentCount: Int
    var shareCount: Int
    var isLiked: Bool
    var isCustomPublication: Bool
}

final class HomePostCell: UITableViewCell {
    static let identifier = "HomePostCell"

    private let cardView = UIView()
    private let avatarImageView = UIImageView()
    private let authorLabel = UILabel()
    private let dateLabel = UILabel()
    private let postImageView = UIImageView()
    private let descriptionLabel = UILabel()

    private let likeButton = UIButton(type: .system)
    private let commentButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let actionsStack = UIStackView()
    private var imageTask: URLSessionDataTask?
    private var avatarTask: URLSessionDataTask?
    private static let imageCache = NSCache<NSURL, UIImage>()

    var onLikeTap: (() -> Void)?
    var onCommentTap: (() -> Void)?
    var onShareTap: (() -> Void)?
    private var isSkeletonMode = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with model: HomeFeedPost) {
        isSkeletonMode = false
        avatarImageView.isHidden = false
        authorLabel.isHidden = false
        dateLabel.isHidden = false
        descriptionLabel.isHidden = false
        actionsStack.isHidden = false
        [cardView, authorLabel, descriptionLabel, postImageView].forEach { view in
            view.layer.removeAllAnimations()
            view.backgroundColor = .clear
        }

        authorLabel.text = model.post.author
        dateLabel.text = model.publishedAt.map(Self.relativeDateText) ?? ""
        descriptionLabel.text = model.post.description
        applyImage(model: model)
        applyAvatar(model: model)

        let likeIcon = model.isLiked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: likeIcon), for: .normal)
        likeButton.setTitle(" \(model.likeCount)", for: .normal)
        likeButton.tintColor = model.isLiked ? StyleGuide.Colors.danger : StyleGuide.Colors.textSecondary

        commentButton.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        commentButton.setTitle(" \(model.commentCount)", for: .normal)

        shareButton.setImage(UIImage(systemName: "arrowshape.turn.up.right"), for: .normal)
        shareButton.setTitle(" \(model.shareCount)", for: .normal)
    }

    func configureSkeleton() {
        isSkeletonMode = true
        authorLabel.text = nil
        dateLabel.text = nil
        descriptionLabel.text = nil
        postImageView.image = nil
        avatarImageView.image = nil
        likeButton.setTitle(nil, for: .normal)
        commentButton.setTitle(nil, for: .normal)
        shareButton.setTitle(nil, for: .normal)

        actionsStack.isHidden = true
        avatarImageView.isHidden = true
        authorLabel.isHidden = true
        dateLabel.isHidden = true
        descriptionLabel.isHidden = true

        postImageView.backgroundColor = StyleGuide.Colors.backgroundSecondary
        cardView.backgroundColor = StyleGuide.Colors.card.withAlphaComponent(0.65)

        let pulse = CABasicAnimation(keyPath: "opacity")
        pulse.fromValue = 0.45
        pulse.toValue = 1
        pulse.duration = 0.85
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        cardView.layer.add(pulse, forKey: "skeletonPulse")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        avatarTask?.cancel()
        imageTask = nil
        avatarTask = nil
        postImageView.image = nil
        avatarImageView.image = nil
        cardView.layer.removeAnimation(forKey: "skeletonPulse")
        if isSkeletonMode {
            [avatarImageView, authorLabel, dateLabel, descriptionLabel, actionsStack].forEach { $0.isHidden = false }
            postImageView.backgroundColor = .clear
            cardView.backgroundColor = StyleGuide.Colors.card
            isSkeletonMode = false
        }
    }

    private func setupUI() {
        backgroundColor = StyleGuide.Colors.backgroundPrimary
        selectionStyle = .none

        cardView.backgroundColor = StyleGuide.Colors.card
        cardView.layer.cornerRadius = 14
        cardView.layer.borderWidth = 0.5
        cardView.layer.borderColor = StyleGuide.Colors.border.cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.backgroundColor = StyleGuide.Colors.backgroundSecondary

        authorLabel.font = StyleGuide.Fonts.body(15, weight: .semibold)
        authorLabel.textColor = StyleGuide.Colors.textPrimary
        authorLabel.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.font = StyleGuide.Fonts.caption(12, weight: .regular)
        dateLabel.textColor = StyleGuide.Colors.textSecondary
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

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
        cardView.addSubview(avatarImageView)
        cardView.addSubview(authorLabel)
        cardView.addSubview(dateLabel)
        cardView.addSubview(postImageView)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(actionsStack)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            avatarImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            avatarImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 32),
            avatarImageView.heightAnchor.constraint(equalToConstant: 32),

            authorLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 11),
            authorLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            authorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            dateLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 1),
            dateLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor),

            postImageView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 10),
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

    private func applyImage(model: HomeFeedPost) {
        imageTask?.cancel()
        imageTask = nil

        if let localImage = model.localImage {
            postImageView.image = localImage
            return
        }

        if let remoteURL = model.remoteImageURL {
            let nsURL = remoteURL as NSURL
            if let cached = Self.imageCache.object(forKey: nsURL) {
                postImageView.image = cached
                postImageView.backgroundColor = .clear
                return
            }

            postImageView.image = nil
            postImageView.backgroundColor = StyleGuide.Colors.backgroundSecondary
            imageTask = URLSession.shared.dataTask(with: remoteURL) { [weak self] data, _, _ in
                guard let self,
                      let data,
                      let image = UIImage(data: data) else { return }
                Self.imageCache.setObject(image, forKey: nsURL)
                DispatchQueue.main.async {
                    self.postImageView.image = image
                    self.postImageView.backgroundColor = .clear
                }
            }
            imageTask?.resume()
            return
        }

        postImageView.image = fallbackImage(for: model)
        postImageView.backgroundColor = .clear
    }

    private func applyAvatar(model: HomeFeedPost) {
        avatarTask?.cancel()
        avatarTask = nil
        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarImageView.tintColor = StyleGuide.Colors.textSecondary

        guard let remoteURL = model.avatarURL else { return }
        let nsURL = remoteURL as NSURL

        if let cached = Self.imageCache.object(forKey: nsURL) {
            avatarImageView.image = cached
            return
        }

        avatarTask = URLSession.shared.dataTask(with: remoteURL) { [weak self] data, _, _ in
            guard let self,
                  let data,
                  let image = UIImage(data: data) else { return }

            Self.imageCache.setObject(image, forKey: nsURL)
            DispatchQueue.main.async {
                self.avatarImageView.image = image
            }
        }
        avatarTask?.resume()
    }

    private static func relativeDateText(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func fallbackImage(for model: HomeFeedPost) -> UIImage? {
        return UIImage(named: model.post.image)
    }
}
