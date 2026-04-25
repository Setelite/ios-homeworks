//
//  FavoritesCoordinator.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/29/26.
//

import UIKit

final class FavoritesCoordinator: Coordinator {

    let navigationController = UINavigationController()
    private var passwordCoordinator: PasswordCoordinator?

    func start() {
        let viewController = FavoritesViewController()
        viewController.title = L10n.tr("favorites.title")
        viewController.onOpenFiles = { [weak self] in
            self?.showFiles()
        }
        viewController.onOpenSettings = { [weak self] in
            self?.showSettings()
        }

        navigationController.viewControllers = [viewController]
        navigationController.tabBarItem = UITabBarItem(
            title: L10n.tr("favorites.title"),
            image: UIImage(systemName: "heart.fill"),
            tag: 1
        )
    }

    private func showFiles() {
        let vc = FilesViewController()
        navigationController.pushViewController(vc, animated: true)
    }

    private func showSettings() {
        let vc = SettingsViewController()
        vc.onChangePassword = { [weak self] in
            self?.showPasswordFlow()
        }
        vc.onLogout = { [weak self] in
            self?.navigationController.popToRootViewController(animated: false)
            NotificationCenter.default.post(name: .appDidRequestLogout, object: nil)
        }
        navigationController.pushViewController(vc, animated: true)
    }

    private func showPasswordFlow() {
        let passwordCoordinator = PasswordCoordinator(navigationController: navigationController)
        self.passwordCoordinator = passwordCoordinator

        passwordCoordinator.onFinish = { [weak self] in
            self?.passwordCoordinator = nil
            self?.navigationController.popViewController(animated: true)
        }

        passwordCoordinator.start()
    }
}
