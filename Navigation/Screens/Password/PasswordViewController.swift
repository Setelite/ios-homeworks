//
//  PasswordViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/13/26.
//

import UIKit

final class PasswordViewController: UIViewController {

    // MARK: - Callback
    var onSuccess: (() -> Void)?

    // MARK: - UI

    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = L10n.tr("password.enter")
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = StyleGuide.Fonts.title(18)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = StyleGuide.Colors.danger
        label.font = StyleGuide.Fonts.caption(14, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - State

    private var state: PasswordState!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StyleGuide.Colors.backgroundPrimary
        setupLayout()
        setupInitialState()
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    // MARK: - Setup

    private func setupInitialState() {
        if let savedPassword = KeychainService.shared.getPassword() {
            state = .enter(saved: savedPassword)
            actionButton.setTitle(L10n.tr("password.enter"), for: .normal)
        } else {
            state = .create
            actionButton.setTitle(L10n.tr("password.create"), for: .normal)
        }
    }

    // MARK: - Actions

    @objc private func buttonTapped() {
        errorLabel.isHidden = true

        guard let text = passwordTextField.text, text.count >= 4 else {
            showError(L10n.tr("password.error.too_short"))
            return
        }

        switch state {

        case .create:
            state = .repeatPassword(first: text)
            passwordTextField.text = ""
            actionButton.setTitle(L10n.tr("password.repeat"), for: .normal)

        case .repeatPassword(let first):
            if first == text {
                KeychainService.shared.savePassword(text)
                print(L10n.tr("password.log.saved"))
                onSuccess?() // ПЕРЕХОД ДАЛЬШЕ
            } else {
                showError(L10n.tr("password.error.mismatch"))
                resetToCreate()
            }

        case .enter(let saved):
            if text == saved {
                print(L10n.tr("password.log.correct"))
                onSuccess?() // ПЕРЕХОД ДАЛЬШЕ
            } else {
                showError(L10n.tr("password.error.wrong"))
                passwordTextField.text = ""
            }
        case .none:
            break
        }
    }

    // MARK: - Helpers

    private func resetToCreate() {
        state = .create
        passwordTextField.text = ""
        actionButton.setTitle(L10n.tr("password.create"), for: .normal)
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func setupLayout() {
        view.addSubview(passwordTextField)
        view.addSubview(actionButton)
        view.addSubview(errorLabel)

        NSLayoutConstraint.activate([
            passwordTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            actionButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            errorLabel.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
}
