//
//  LogInViewController.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 04.08.2025.
//


import UIKit

final class LogInViewController: UIViewController {
    
    // MARK: - Delegate
    weak var loginDelegate: LoginViewControllerDelegate?

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "VKLogo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email or phone"
        field.backgroundColor = .systemGray6
        field.layer.borderWidth = 0.5
        field.layer.borderColor = UIColor.systemGray2.cgColor
        field.layer.cornerRadius = 10
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 40))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.backgroundColor = .systemGray6
        field.layer.borderWidth = 0.5
        field.layer.borderColor = UIColor.systemGray2.cgColor
        field.layer.cornerRadius = 10
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 40))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(named: "BluePixel"), for: .normal)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true
        setupViews()
        setupKeyboardObservers()
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailField.becomeFirstResponder()
    }

    // MARK: - UI Setup
    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [logoImageView, emailField, passwordField, loginButton]
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

            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 120),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),

            emailField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 120),
            emailField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emailField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emailField.heightAnchor.constraint(equalToConstant: 50),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 50),

            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 16),
            loginButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            loginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            scrollView.contentInset.bottom = keyboardFrame.height + 16
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
    }

    // MARK: - Login Action
    @objc private func loginButtonTapped() {
        guard let login = emailField.text,
              let password = passwordField.text,
              !login.isEmpty, !password.isEmpty else {
            showAlert(title: "Ошибка", message: "Введите логин и пароль")
            return
        }

        // Проверка логина/пароля через делегат
        guard loginDelegate?.check(login: login, password: password) == true else {
            showAlert(title: "Ошибка", message: "Неверный логин или пароль")
            return
        }

        // Получаем пользователя через UserService
        let userService: UserService
        #if DEBUG
        userService = TestUserService()
        #else
        let currentUser = User(login: "wowgorno",
                               fullName: "Максим Горностаев",
                               avatar: UIImage(named: "avatar") ?? UIImage(),
                               status: "Работаем, не отдыхаем ")
        userService = CurrentUserService(user: currentUser)
        #endif

        guard let user = userService.getUser(login: login) else {
            showAlert(title: "Ошибка", message: "Пользователь не найден")
            return
        }

        openMainInterface(with: user)
    }

    private func openMainInterface(with user: User) {
        let feedVC = FeedViewController()
        let profileVC = ProfileViewController()
        profileVC.user = user

        let tabBar = UITabBarController()
        tabBar.viewControllers = [
            UINavigationController(rootViewController: profileVC),
            UINavigationController(rootViewController: feedVC)
        ]
        tabBar.selectedIndex = 0

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = tabBar
            window.makeKeyAndVisible()
        }
    }

    // MARK: - Alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
