//
//  AppCoordinator.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 11/29/25.
//
import UIKit

final class AppCoordinator: Coordinator {

    private let window: UIWindow
    private let navigationController = UINavigationController()

    private var loginCoordinator: LoginCoordinator?   // ← важно: храним координатор

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        showLogin()
    }

    private func showLogin() {
        let coordinator = LoginCoordinator(navigationController: navigationController)
        self.loginCoordinator = coordinator

        coordinator.onFinish = { [weak self] user in
            print("[DEBUG] Login finished. User =", user.login)
            self?.showMainFlow(user: user)
        }

        coordinator.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    private func showMainFlow(user: User) {
        let tabCoordinator = TabBarCoordinator(user: user)
        tabCoordinator.start()

        window.rootViewController = tabCoordinator.tabBarController

        // освобождаем loginCoordinator
        loginCoordinator = nil
    }
}
