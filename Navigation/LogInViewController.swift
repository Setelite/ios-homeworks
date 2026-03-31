//
//  LogInViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 04.08.2025.
//

import UIKit

final class LogInViewController: UIViewController {

    // MARK: - Delegate
    var loginDelegate: LoginViewControllerDelegate?

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let viewModel = LoginViewModel()

    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "VKLogo"))
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let loginField: UITextField = {
        let tf = UITextField()
        tf.placeholder = L10n.tr("login.email")
        tf.backgroundColor = StyleGuide.Colors.backgroundSecondary
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 0.5
        tf.layer.borderColor = StyleGuide.Colors.borderStrong.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 40))
        tf.leftViewMode = .always
        return tf
    }()

    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = L10n.tr("login.password")
        tf.isSecureTextEntry = true
        tf.backgroundColor = StyleGuide.Colors.backgroundSecondary
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 0.5
        tf.layer.borderColor = StyleGuide.Colors.borderStrong.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 40))
        tf.leftViewMode = .always
        return tf
    }()

    private lazy var loginButton = CustomButton(
        title: L10n.tr("login.submit"),
        backgroundColor: StyleGuide.Colors.accent
    ) { [weak self] in
        self?.tryLogin()
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = StyleGuide.Colors.backgroundPrimary
        setupUI()
        setupKeyboardObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginField.becomeFirstResponder()
    }

    // MARK: - Login Logic (ВАЖНО)
    private func tryLogin() {
        print("🔥 tryLogin called")

        viewModel.submit(email: loginField.text, password: passwordField.text)

        switch viewModel.state {
        case .idle:
            return
        case .errorEmpty:
            showAlert(L10n.tr("common.error"), L10n.tr("login.error.empty_credentials"))
        case .ready(let email, let password):
            loginDelegate?.checkCredentials(email: email, password: password)
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        [logoImageView, loginField, passwordField, loginButton]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [logoImageView, loginField, passwordField, loginButton]
            .forEach { contentView.addSubview($0) }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 140),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),

            loginField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 100),
            loginField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            loginField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            loginField.heightAnchor.constraint(equalToConstant: 50),

            passwordField.topAnchor.constraint(equalTo: loginField.bottomAnchor),
            passwordField.leadingAnchor.constraint(equalTo: loginField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: loginField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 50),

            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: loginField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: loginField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    // MARK: - Keyboard
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardShow(_ n: Notification) {
        if let frame = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            scrollView.contentInset.bottom = frame.height + 20
        }
    }

    @objc private func keyboardHide() {
        scrollView.contentInset = .zero
    }

    // MARK: - Alert
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.tr("common.ok"), style: .default))
        present(alert, animated: true)
    }
}
