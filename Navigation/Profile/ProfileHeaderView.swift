//
//  ProfileHeaderView.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 22.07.2025.
//

import UIKit
import SnapKit

final class ProfileHeaderView: UIView {
    var onProfileSettingsTap: (() -> Void)?
    var onEditProfileTap: (() -> Void)?
    var onAvatarTap: (() -> Void)?
    
    // MARK: - UI
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = StyleGuide.Colors.accent.cgColor
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = StyleGuide.Fonts.title(18)
        label.textColor = StyleGuide.Colors.textPrimary
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = StyleGuide.Fonts.body(14, weight: .regular)
        label.textColor = StyleGuide.Colors.muted
        return label
    }()
    
    private let statusTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = L10n.tr("profile.status.new_placeholder")
        textField.font = StyleGuide.Fonts.body(14, weight: .regular)
        textField.textColor = StyleGuide.Colors.textPrimary
        textField.backgroundColor = StyleGuide.Colors.card
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = StyleGuide.Colors.borderStrong.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var setStatusButton = CustomButton(
        title: L10n.tr("profile.status.update"),
        backgroundColor: StyleGuide.Colors.accent
    ) { [weak self] in
        guard let self else { return }
        self.applyStatusUpdate()
    }

    private let friendsValueLabel = UILabel()
    private let friendsTitleLabel = UILabel()
    private let followersValueLabel = UILabel()
    private let followersTitleLabel = UILabel()
    private let countersStackView = UIStackView()
    private let profileSettingsButton = UIButton(type: .system)
    private let editProfileButton = UIButton(type: .system)
    private let avatarEditBadgeView = UIView()
    private let avatarEditIconView = UIImageView()
    private let avatarBorderLayer = CAShapeLayer()

    // MARK: - Properties
    private var statusText: String = ""
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = StyleGuide.Colors.backgroundSecondary
        setupViews()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(statusLabel)
        addSubview(statusTextField)
        addSubview(setStatusButton)
        addSubview(countersStackView)
        addSubview(editProfileButton)
        addSubview(profileSettingsButton)
        avatarImageView.addSubview(avatarEditBadgeView)
        avatarEditBadgeView.addSubview(avatarEditIconView)

        configureCountersUI()
        configureActionButtons()
        configureAvatarEditUI()
    }
    
    private func setupConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(100)
        }
        
        avatarEditBadgeView.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(2)
            make.width.height.equalTo(26)
        }
        
        avatarEditIconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(14)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.top).offset(10)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.equalTo(nameLabel)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }

        countersStackView.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(10)
            make.leading.equalTo(nameLabel)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }

        statusTextField.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }

        setStatusButton.snp.makeConstraints { make in
            make.top.equalTo(statusTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }

        editProfileButton.snp.makeConstraints { make in
            make.top.equalTo(setStatusButton.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(profileSettingsButton.snp.leading).offset(-10)
            make.height.equalTo(40)
            make.width.equalTo(profileSettingsButton.snp.width)
            make.bottom.equalToSuperview().inset(16)
        }

        profileSettingsButton.snp.makeConstraints { make in
            make.top.equalTo(editProfileButton.snp.top)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
    }

    // MARK: - Public configure
    func configure(with user: User, friendsCount: Int, followersCount: Int) {
        avatarImageView.image = user.avatar.squareCropped()
        nameLabel.text = user.fullName
        statusLabel.text = user.status
        statusText = user.status
        friendsValueLabel.text = "\(friendsCount)"
        followersValueLabel.text = "\(followersCount)"
    }

    // MARK: - Actions
    private func setupActions() {
        statusTextField.addTarget(self, action: #selector(statusTextChanged(_:)), for: .editingChanged)
        setStatusButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        profileSettingsButton.addTarget(self, action: #selector(profileSettingsPressed), for: .touchUpInside)
        editProfileButton.addTarget(self, action: #selector(editProfilePressed), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarPressed))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyAvatarCircleMask()
    }

    private func applyAvatarCircleMask() {
        let side = min(avatarImageView.bounds.width, avatarImageView.bounds.height)
        let x = (avatarImageView.bounds.width - side) / 2
        let y = (avatarImageView.bounds.height - side) / 2
        let circleRect = CGRect(x: x, y: y, width: side, height: side)
        let circlePath = UIBezierPath(ovalIn: circleRect).cgPath

        let mask = CAShapeLayer()
        mask.path = circlePath
        avatarImageView.layer.mask = mask

        avatarBorderLayer.removeFromSuperlayer()
        avatarBorderLayer.path = circlePath
        avatarBorderLayer.fillColor = UIColor.clear.cgColor
        avatarBorderLayer.strokeColor = StyleGuide.Colors.accent.cgColor
        avatarBorderLayer.lineWidth = 2
        avatarImageView.layer.addSublayer(avatarBorderLayer)
    }
    
    @objc private func statusTextChanged(_ textField: UITextField) {
        statusText = textField.text ?? ""
    }
    
    @objc private func buttonPressed() {
        applyStatusUpdate()
    }

    @objc private func profileSettingsPressed() {
        onProfileSettingsTap?()
    }

    @objc private func editProfilePressed() {
        onEditProfileTap?()
    }
    
    @objc private func avatarPressed() {
        onAvatarTap?()
    }

    private func applyStatusUpdate() {
        let normalized = statusText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }
        statusLabel.text = normalized
    }

    private func configureCountersUI() {
        friendsValueLabel.font = StyleGuide.Fonts.body(16, weight: .semibold)
        friendsValueLabel.textColor = StyleGuide.Colors.textPrimary
        friendsValueLabel.textAlignment = .left

        friendsTitleLabel.font = StyleGuide.Fonts.caption(12, weight: .regular)
        friendsTitleLabel.textColor = StyleGuide.Colors.textSecondary
        friendsTitleLabel.text = L10n.tr("profile.friends")

        followersValueLabel.font = StyleGuide.Fonts.body(16, weight: .semibold)
        followersValueLabel.textColor = StyleGuide.Colors.textPrimary
        followersValueLabel.textAlignment = .left

        followersTitleLabel.font = StyleGuide.Fonts.caption(12, weight: .regular)
        followersTitleLabel.textColor = StyleGuide.Colors.textSecondary
        followersTitleLabel.text = L10n.tr("profile.followers")

        let leftColumn = UIStackView(arrangedSubviews: [friendsValueLabel, friendsTitleLabel])
        leftColumn.axis = .vertical
        leftColumn.spacing = 2

        let rightColumn = UIStackView(arrangedSubviews: [followersValueLabel, followersTitleLabel])
        rightColumn.axis = .vertical
        rightColumn.spacing = 2

        countersStackView.axis = .horizontal
        countersStackView.spacing = 18
        countersStackView.alignment = .center
        countersStackView.addArrangedSubview(leftColumn)
        countersStackView.addArrangedSubview(rightColumn)
    }

    private func configureActionButtons() {
        [editProfileButton, profileSettingsButton].forEach {
            $0.backgroundColor = StyleGuide.Colors.card
            $0.layer.cornerRadius = 10
            $0.layer.borderWidth = 1
            $0.layer.borderColor = StyleGuide.Colors.borderStrong.cgColor
            $0.titleLabel?.font = StyleGuide.Fonts.caption(13, weight: .semibold)
            $0.setTitleColor(StyleGuide.Colors.textPrimary, for: .normal)
            $0.tintColor = StyleGuide.Colors.textSecondary
            $0.semanticContentAttribute = .forceLeftToRight
        }

        editProfileButton.setTitle(L10n.tr("common.edit"), for: .normal)
        editProfileButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        profileSettingsButton.setTitle(L10n.tr("settings.title"), for: .normal)
        profileSettingsButton.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
    }
    
    private func configureAvatarEditUI() {
        avatarEditBadgeView.backgroundColor = StyleGuide.Colors.accent
        avatarEditBadgeView.layer.cornerRadius = 13
        avatarEditBadgeView.layer.borderWidth = 1
        avatarEditBadgeView.layer.borderColor = StyleGuide.Colors.inverseText.cgColor
        
        avatarEditIconView.image = UIImage(systemName: "camera.fill")
        avatarEditIconView.tintColor = StyleGuide.Colors.inverseText
        avatarEditIconView.contentMode = .scaleAspectFit
    }
}

private extension UIImage {
    func squareCropped() -> UIImage {
        let targetSide = min(size.width, size.height)
        let cropRect = CGRect(
            x: (size.width - targetSide) / 2,
            y: (size.height - targetSide) / 2,
            width: targetSide,
            height: targetSide
        )

        guard let cg = cgImage?.cropping(to: cropRect) else { return self }
        return UIImage(cgImage: cg, scale: scale, orientation: imageOrientation)
    }
}
