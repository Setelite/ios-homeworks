//
//  TabBarCoordinator.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/23/26.
//

import UIKit

final class TabBarCoordinator: Coordinator {

    let tabBarController = UITabBarController()

    func start() {

        // Feed
        let feedNav = UINavigationController()
        let feedCoordinator = FeedCoordinator(navigationController: feedNav)
        feedCoordinator.start()

        feedNav.tabBarItem = UITabBarItem(
            title: "Feed",
            image: UIImage(systemName: "list.bullet"),
            tag: 0
        )

        // Favorites (без координатора — ок по ДЗ)
        let favoritesVC = FavoritesViewController()
        let favoritesNav = UINavigationController(rootViewController: favoritesVC)
        favoritesNav.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "star.fill"),
            tag: 1
        )

        // Profile
        let profileNav = UINavigationController()
        let profileCoordinator = ProfileCoordinator(
            navigationController: profileNav
        )
        profileCoordinator.start()

        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.circle"),
            tag: 2
        )

        tabBarController.viewControllers = [
            feedNav,
            favoritesNav,
            profileNav
        ]
    }
}


