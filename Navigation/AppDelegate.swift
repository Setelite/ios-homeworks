//
//  AppDelegate.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 16.07.2025.
//
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private let localNotificationsService: LocalNotificationsServiceProtocol = LocalNotificationsService()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        localNotificationsService.registerForLatestUpdatesIfPossible()

        UserDefaults.standard.register(defaults: [
            "sortAscending": true,
            "themeMode": AppThemeMode.system.rawValue
        ])

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {

        UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
}
