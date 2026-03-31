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

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let tabBarCoordinator = TabBarCoordinator()
        tabBarCoordinator.start()
        self.tabBarCoordinator = tabBarCoordinator

        window.rootViewController = tabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
    }
}
