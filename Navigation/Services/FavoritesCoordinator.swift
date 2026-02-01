//
//  FavoritesCoordinator.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/29/26.
//

import UIKit

final class FavoritesCoordinator: Coordinator {

    let navigationController = UINavigationController()

    func start() {
        let viewController = FavoritesViewController()
        viewController.title = "Favorites"

        navigationController.viewControllers = [viewController]
        navigationController.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart.fill"),
            tag: 1
        )
    }
}
