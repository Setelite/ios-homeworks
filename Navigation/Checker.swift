//
//  Checker.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/19/25.
//
final class Checker {
    static let shared = Checker()
    private let email = "wowgorno@example.com" 
    private let password = "123456"
    private init() {}

    func check(email: String, password: String) -> Bool {
        print("[DEBUG] Checker comparing. expected: (\(self.email),\(self.password)) got: (\(email),\(password))")
        return email == self.email && password == self.password
    }
}
