//
//  AppCoordinator.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 11/29/25.
//
import UIKit

/// Арр Координатор
final class AppCoordinator: Coordinator {

    private let window: UIWindow
    private var tabBarCoordinator: TabBarCoordinator?
    private var loginCoordinator: LoginCoordinator?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        if FirebaseSessionStorage.shared.isAuthorized {
            showMainApp()
        } else {
            showLogin()
        }
    }

    private func showLogin() {
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        let coordinator = LoginCoordinator(navigationController: navigationController)
        coordinator.onFinish = { [weak self] _ in
            self?.showMainApp()
        }
        loginCoordinator = coordinator
        coordinator.start()
    }

    private func showMainApp() {
        let tabBarCoordinator = TabBarCoordinator()
        tabBarCoordinator.start()
        self.tabBarCoordinator = tabBarCoordinator
        self.loginCoordinator = nil

        window.rootViewController = tabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
    }
}
