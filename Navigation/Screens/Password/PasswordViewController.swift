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
        tf.placeholder = "Введите пароль"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 14)
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
        view.backgroundColor = .systemBackground
        setupLayout()
        setupInitialState()
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    // MARK: - Setup

    private func setupInitialState() {
        if let savedPassword = KeychainService.shared.getPassword() {
            state = .enter(saved: savedPassword)
            actionButton.setTitle("Введите пароль", for: .normal)
        } else {
            state = .create
            actionButton.setTitle("Создать пароль", for: .normal)
        }
    }

    // MARK: - Actions

    @objc private func buttonTapped() {
        errorLabel.isHidden = true

        guard let text = passwordTextField.text, text.count >= 4 else {
            showError("Пароль должен быть минимум 4 символа")
            return
        }

        switch state {

        case .create:
            state = .repeatPassword(first: text)
            passwordTextField.text = ""
            actionButton.setTitle("Повторите пароль", for: .normal)

        case .repeatPassword(let first):
            if first == text {
                KeychainService.shared.savePassword(text)
                print("✅ Пароль сохранён в Keychain")
                onSuccess?() // ✅ ПЕРЕХОД ДАЛЬШЕ
            } else {
                showError("Пароли не совпадают")
                resetToCreate()
            }

        case .enter(let saved):
            if text == saved {
                print("🔓 Пароль верный")
                onSuccess?() // ✅ ПЕРЕХОД ДАЛЬШЕ
            } else {
                showError("Неверный пароль")
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
        actionButton.setTitle("Создать пароль", for: .normal)
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
