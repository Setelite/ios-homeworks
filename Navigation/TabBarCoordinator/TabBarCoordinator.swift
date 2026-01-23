//
//  TabBarCoordinator.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/23/26.
//

import UIKit

final class TabBarCoordinator: Coordinator {

    let tabBarController = UITabBarController()

    private let user: User

   
    private let feedCoordinator = FeedCoordinator()
    private let profileCoordinator: ProfileCoordinator

    init(user: User) {
        self.user = user
        self.profileCoordinator = ProfileCoordinator(user: user)
    }

    func start() {
        // Feed
        feedCoordinator.start()
        feedCoordinator.navigationController.tabBarItem = UITabBarItem(
            title: "Feed",
            image: UIImage(systemName: "house"),
            tag: 0
        )

        // Favorites
        let favoritesVC = FavoritesViewController()
        favoritesVC.title = "Favorites"
        let favoritesNav = UINavigationController(rootViewController: favoritesVC)
        favoritesNav.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            tag: 1
        )

        // Profile
        profileCoordinator.start()
        profileCoordinator.navigationController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            tag: 2
        )

        tabBarController.viewControllers = [
            feedCoordinator.navigationController,
            favoritesNav,
            profileCoordinator.navigationController
        ]
    }
}
