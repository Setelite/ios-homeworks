//
//  LoginInspector.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/19/25.
//
import UIKit

final class LoginInspector: LoginViewControllerDelegate {

    var onLoginSuccess: ((User) -> Void)?

    func check(login: String, password: String) -> Bool {
        Checker.shared.check(login: login, password: password)
    }

    func didLogin() {
        print("[DEBUG] didLogin called")
        let user = User(
            login: "wowgorno",
            fullName: "Максим Горностаев",
            avatar: UIImage(named: "avatar") ?? UIImage(),
            status: "Работаем, не отдыхаем"
        )

        onLoginSuccess?(user)
    }
}
