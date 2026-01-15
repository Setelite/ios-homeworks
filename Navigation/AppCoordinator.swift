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

    private var passwordCoordinator: PasswordCoordinator?
    private var tabBarCoordinator: TabBarCoordinator?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        showPassword()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    // MARK: - Password Flow (ШАГ 1–3)

    private func showPassword() {
        let coordinator = PasswordCoordinator(navigationController: navigationController)
        passwordCoordinator = coordinator

        coordinator.onFinish = { [weak self] in
            self?.showMainFlow()
        }

        coordinator.start()
    }

    // MARK: - Main Flow (ШАГ 4)

    private func showMainFlow() {
        let user = User(
            login: "local",
            fullName: "Local User",
            avatar: UIImage(),
            status: "Authorized"
        )

        let coordinator = TabBarCoordinator(user: user)
        tabBarCoordinator = coordinator
        coordinator.start()

        window.rootViewController = coordinator.tabBarController
        window.makeKeyAndVisible()

        passwordCoordinator = nil
    }
}
