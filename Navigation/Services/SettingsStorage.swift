//
//  SettingsStorage.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/13/26.
//

import Foundation

final class SettingsStorage {

    static let shared = SettingsStorage()
    private init() {}

    private let sortKey = "sortAscending"

    var isAscending: Bool {
        get {
            UserDefaults.standard.object(forKey: sortKey) as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: sortKey)
        }
    }
}
