//
//  LoginKoordinator.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 11/30/25.
//

import UIKit

final class LoginCoordinator: Coordinator {

    var navigationController: UINavigationController
    var onFinish: ((User) -> Void)?   // ← добавили

    private let loginFactory = MyLoginFactory()
    private var inspector: LoginInspector?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let loginVC = LogInViewController()

        let loginInspector = loginFactory.makeLoginInspector()
        loginVC.loginDelegate = loginInspector
        self.inspector = loginInspector

        // подписываемся на событие успеха
        loginInspector.onLoginSuccess = { [weak self] user in
            print("[DEBUG] LoginCoordinator.onLoginSuccess called")

            self?.onFinish?(user)     // ← передаём user в AppCoordinator
        }

        navigationController.setViewControllers([loginVC], animated: false)

    }
}
