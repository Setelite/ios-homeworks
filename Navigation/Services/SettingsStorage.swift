//
//  SettingsStorage.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/13/26.
//

import Foundation

enum AppThemeMode: Int {
    case system
    case light
    case dark
}

extension Notification.Name {
    static let appThemeDidChange = Notification.Name("appThemeDidChange")
}

/// Настройка: Сортировка файлов 
final class SettingsStorage {

    static let shared = SettingsStorage()
    private init() {}

    private let sortKey = "sortAscending"
    private let themeModeKey = "themeMode"

    var isAscending: Bool {
        get {
            UserDefaults.standard.object(forKey: sortKey) as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: sortKey)
        }
    }

    var themeMode: AppThemeMode {
        get {
            let raw = UserDefaults.standard.integer(forKey: themeModeKey)
            return AppThemeMode(rawValue: raw) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: themeModeKey)
            NotificationCenter.default.post(name: .appThemeDidChange, object: nil)
        }
    }
}
