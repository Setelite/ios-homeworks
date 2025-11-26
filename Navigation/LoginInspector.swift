//
//  LoginInspector.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/19/25.
//
final class LoginInspector: LoginViewControllerDelegate {
    func check(login: String, password: String) -> Bool {
        return login == "wowgorno" && password == "123456"
    }

    func didLogin() {
        print("LoginInspector: didLogin() вызван")
    }
}
