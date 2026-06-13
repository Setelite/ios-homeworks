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
                // Если аккаунта еще нет, пробуем зарегистрировать и сразу выполнить вход.
                self?.checkerService.signUp(email: email, password: password) { signUpResult in
                    switch signUpResult {
                    case .success:
                        self?.didLogin(email: email)
                    case .failure(let signUpError):
                        print("SignUp after login error:", signUpError.localizedDescription)
                    }
                }
            }
        }
    }

    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        checkerService.signUp(email: email, password: password) { result in
            switch result {
            case .success:
                self.didLogin(email: email)
                completion(.success(()))
            case .failure(let error):
                print("SignUp error:", error.localizedDescription)
                completion(.failure(error))
            }
        }
    }

    private func didLogin(email: String) {
        let sessionUser = FirebaseSessionStorage.shared.user
        let user = User(
            login: sessionUser?.email ?? email,
            fullName: sessionUser?.displayName ?? "Firebase User",
            avatar: UIImage(named: "my_photo") ?? UIImage(),
            status: L10n.tr("profile.status.firebase")
        )

        onLoginSuccess?(user)
    }
}
