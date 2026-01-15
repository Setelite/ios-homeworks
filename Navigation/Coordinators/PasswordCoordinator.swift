//
//  PasswordCoordinator.swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 1/13/26.
//

import UIKit

final class PasswordCoordinator: Coordinator {

    private let navigationController: UINavigationController
    var onFinish: (() -> Void)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = PasswordViewController()
        vc.onSuccess = { [weak self] in
            self?.onFinish?()
        }
        navigationController.setViewControllers([vc], animated: false)
    }
}
