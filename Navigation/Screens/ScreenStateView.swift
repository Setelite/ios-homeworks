import UIKit

enum ScreenState {
    case loading(String)
    case empty(String)
    case error(String)
    case content
}

final class ScreenStateView: UIView {
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let stackView = UIStackView()

    var onRetry: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(_ state: ScreenState) {
        switch state {
        case .loading(let message):
            isHidden = false
            activityIndicator.startAnimating()
            messageLabel.text = message
            retryButton.isHidden = true

        case .empty(let message):
            isHidden = false
            activityIndicator.stopAnimating()
            messageLabel.text = message
            retryButton.isHidden = true

        case .error(let message):
            isHidden = false
            activityIndicator.stopAnimating()
            messageLabel.text = message
            retryButton.isHidden = false

        case .content:
            activityIndicator.stopAnimating()
            isHidden = true
        }
    }

    private func setupUI() {
        backgroundColor = StyleGuide.Colors.backgroundPrimary

        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        activityIndicator.hidesWhenStopped = true

        messageLabel.font = StyleGuide.Fonts.body(16, weight: .medium)
        messageLabel.textColor = StyleGuide.Colors.textSecondary
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        retryButton.setTitle(L10n.tr("common.retry"), for: .normal)
        retryButton.titleLabel?.font = StyleGuide.Fonts.body(16, weight: .semibold)
        retryButton.tintColor = StyleGuide.Colors.accent
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        addSubview(stackView)
        stackView.addArrangedSubview(activityIndicator)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(retryButton)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24)
        ])

        isHidden = true
    }

    @objc private func retryTapped() {
        onRetry?()
    }
}
