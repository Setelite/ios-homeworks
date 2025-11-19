//
//  LoginInspector.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/19/25.
//
import Foundation

/// делегат проверки логина и пароля
final class LoginInspector: LoginViewControllerDelegate {
    func check(login: String, password: String) -> Bool {
        return Checker.shared.check(login: login, password: password)
    }
}
