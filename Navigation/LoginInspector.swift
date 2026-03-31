//
//  LoginInspector.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 10/19/25.
//

import UIKit
final class LoginInspector: LoginViewControllerDelegate {

    var onLoginSuccess: ((User) -> Void)?

    private let checkerService: CheckerServiceProtocol

    init(checkerService: CheckerServiceProtocol) {
        self.checkerService = checkerService
    }

    func checkCredentials(email: String, password: String) {
        print("checkCredentials:", email)
        checkerService.checkCredentials(email: email, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.didLogin(email: email)
            case .failure(let error):
                print("Login error:", error.localizedDescription)
            }
        }
    }

    func signUp(email: String, password: String) {
        checkerService.signUp(email: email, password: password) { result in
            switch result {
            case .success:
                print("User registered")
            case .failure(let error):
                print("SignUp error:", error.localizedDescription)
            }
        }
    }

    private func didLogin(email: String) {
        let user = User(
            login: email,
            fullName: "Firebase User",
            avatar: UIImage(named: "avatar") ?? UIImage(),
            status: "Авторизован через Firebase"
        )

        onLoginSuccess?(user)
    }
}
