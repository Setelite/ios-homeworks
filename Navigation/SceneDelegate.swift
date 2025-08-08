//
//  SceneDelegate.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 16.07.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let feedVC = FeedViewController()
        feedVC.title = "Feed"
        let feedNav = UINavigationController(rootViewController: feedVC)
        feedNav.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "list.bullet"), tag: 0)
        
        let profileVC = LogInViewController()
        profileVC.title = "Profile"
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 1)
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [feedNav, profileNav]
        tabBarController.tabBar.barTintColor = .systemGray2
        tabBarController.tabBar.backgroundColor = .systemGray6
        tabBarController.tabBar.layer.borderColor = UIColor.systemGray2.cgColor
        tabBarController.tabBar.layer.borderWidth = 0.5
        
        let loginVC = LogInViewController()
        let navVC = UINavigationController(rootViewController: loginVC)
        window.rootViewController = navVC
        window.makeKeyAndVisible()

        
        
        self.window = window
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        
        
        
        
        
    }
    
    
    
}
