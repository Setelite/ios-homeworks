//
//  TabBarCoordinator.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 11/29/25.
//

import UIKit

final class TabBarCoordinator: Coordinator {

    let tabBarController = UITabBarController()

    private let user: User

    init(user: User) {
        self.user = user
    }

    func start() {
        let feedCoordinator = FeedCoordinator()
        let profileCoordinator = ProfileCoordinator(user: user)

        feedCoordinator.start()
        profileCoordinator.start()

        let infoVC = InfoViewController()
        infoVC.title = "Info"
        infoVC.tabBarItem = UITabBarItem(
            title: "Info",
            image: UIImage(systemName: "info.circle"),
            selectedImage: UIImage(systemName: "info.circle.fill")
        )

        let infoNav = UINavigationController(rootViewController: infoVC)

        tabBarController.viewControllers = [
            feedCoordinator.navigationController,
            infoNav,
            profileCoordinator.navigationController
        ]
    }

}
