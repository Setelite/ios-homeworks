import UIKit

struct StoryItem {
    let id: String
    let name: String
    let imageName: String
}

final class StoriesHeaderView: UIView {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private var stories: [StoryItem] = []
    var onStoryTap: ((StoryItem, Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with stories: [StoryItem]) {
        self.stories = stories
        reloadStories()
    }

    private func setupUI() {
        backgroundColor = StyleGuide.Colors.backgroundPrimary

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .top
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }

    private func reloadStories() {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        stories.forEach { item in
            let control = makeStoryControl(for: item)
            stackView.addArrangedSubview(control)
        }
    }

    private func makeStoryControl(for item: StoryItem) -> UIControl {
        let control = UIControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.widthAnchor.constraint(equalToConstant: 76).isActive = true
        control.tag = stories.firstIndex(where: { $0.id == item.id }) ?? 0

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = StyleGuide.Colors.accent.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false

        if let image = UIImage(named: item.imageName) {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "person.crop.circle.fill")
            imageView.tintColor = StyleGuide.Colors.accent
            imageView.backgroundColor = StyleGuide.Colors.backgroundSecondary
        }

        let nameLabel = UILabel()
        nameLabel.text = item.name
        nameLabel.font = StyleGuide.Fonts.caption(11, weight: .regular)
        nameLabel.textColor = StyleGuide.Colors.textPrimary
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        control.addSubview(imageView)
        control.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: control.topAnchor, constant: 4),
            imageView.centerXAnchor.constraint(equalTo: control.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: control.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: control.trailingAnchor),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: control.bottomAnchor, constant: -4)
        ])

        control.addTarget(self, action: #selector(handleStoryTap(_:)), for: .touchUpInside)
        return control
    }

    @objc private func handleStoryTap(_ sender: UIControl) {
        guard sender.tag < stories.count else { return }
        onStoryTap?(stories[sender.tag], sender.tag)
    }
}
