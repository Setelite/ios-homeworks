//
//  TabBarCoordinator..swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/14/26.
//

import UIKit

final class TabBarCoordinator: Coordinator {

    let tabBarController = UITabBarController()
    private let user: User

    var onLogout: (() -> Void)?

    init(user: User) {
        self.user = user
    }

    func start() {
        let documentsVC = ViewController()
        documentsVC.title = "Documents"
        documentsVC.tabBarItem = UITabBarItem(
            title: "Files",
            image: UIImage(systemName: "doc"),
            tag: 0
        )

        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gear"),
            tag: 1
        )

        settingsVC.onChangePassword = {
            print("Change password tapped")
        }

        settingsVC.onLogout = { [weak self] in
            self?.onLogout?()
        }

        tabBarController.viewControllers = [
            UINavigationController(rootViewController: documentsVC),
            UINavigationController(rootViewController: settingsVC)
        ]
    }
}
