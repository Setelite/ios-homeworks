//
//  SceneDelegate.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 16.07.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // 🔹 Стартуем с LogInViewController
        let loginVC = LogInViewController()
        window.rootViewController = loginVC
        window.makeKeyAndVisible()
        
        self.window = window
        
    }
}







    

