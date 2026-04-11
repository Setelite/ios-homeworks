//
//  LoginKoordinator.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 11/30/25.
//

import UIKit

final class LoginCoordinator: Coordinator {

    private let navigationController: UINavigationController
    private var inspector: LoginInspector?

    var onFinish: ((User) -> Void)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let loginVC = LogInViewController()

        let checkerService = CheckerService() 
        let inspector = LoginInspector(checkerService: checkerService)
        inspector.onLoginSuccess = { [weak self] user in
            self?.onFinish?(user)
        }
        self.inspector = inspector

        loginVC.loginDelegate = inspector
        navigationController.pushViewController(loginVC, animated: true)
    }
}
