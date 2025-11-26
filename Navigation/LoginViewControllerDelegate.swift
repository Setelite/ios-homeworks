//
//  LoginViewControllerDelegate.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/19/25.
//

import Foundation

/// Протокол, через который LoginViewController передаёт логин и пароль на проверку

protocol LoginViewControllerDelegate: AnyObject {
    func check(login: String, password: String) -> Bool
    func didLogin()   // ← ДОБАВЬ ЭТО!
}
