//
//  KeychainService.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/13/26.
//

import Foundation
import KeychainAccess

final class KeychainService {

    static let shared = KeychainService()

    private let keychain = Keychain(service: "com.navigation.password")

    private let passwordKey = "user_password"

    private init() {}

    func savePassword(_ password: String) {
        keychain[passwordKey] = password
    }

    func getPassword() -> String? {
        keychain[passwordKey]
    }

    func hasPassword() -> Bool {
        getPassword() != nil
    }

    func removePassword() {
        try? keychain.remove(passwordKey)
    }
}
