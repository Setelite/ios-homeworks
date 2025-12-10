//
//  FeedCoordinator.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 11/29/25.
//

import UIKit

final class FeedCoordinator: Coordinator {

    let navigationController = UINavigationController()

    func start() {
        let vc = FeedViewController()
        navigationController.setViewControllers([vc], animated: false)
    }
}
