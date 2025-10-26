//
//  Checker.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/19/25.
//
import Foundation

final class Checker {
    static let shared = Checker()

    private let login = "wowgorno"
    private let password = "123456"

    private init() {}

    func check(login: String, password: String) -> Bool {
        return login == self.login && password == self.password
    }
}
