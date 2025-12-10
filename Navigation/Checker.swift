//
//  Checker.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/19/25.
//
final class Checker {
    static let shared = Checker()
    private let login = "wowgorno"
    private let password = "123456"
    private init() {}

    func check(login: String, password: String) -> Bool {
        print("[DEBUG] Checker comparing. expected: (\(self.login),\(self.password)) got: (\(login),\(password))")
        return login == self.login && password == self.password
    }
}
