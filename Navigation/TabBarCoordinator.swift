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

        feedCoordinator.navigationController.tabBarItem =
            UITabBarItem(title: "Feed", image: UIImage(systemName: "list.bullet"), tag: 0)
        
        profileCoordinator.navigationController.tabBarItem =
            UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 1)

        tabBarController.viewControllers = [
            feedCoordinator.navigationController,
            profileCoordinator.navigationController
        ]
    }
}
