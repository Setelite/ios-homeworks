//
//  ProfileCoordinator..swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 11/29/25.
//

import UIKit

final class ProfileCoordinator: Coordinator {

    private let navigationController: UINavigationController
    private let userService: UserService

    init(navigationController: UINavigationController,
         userService: UserService = CurrentUserService()) {
        self.navigationController = navigationController
        self.userService = userService
    }

    func start() {
        let user = userService.getUser(login: "Wowgorno")
        let viewModel = ProfileViewModel(user: user)
        let vc = ProfileViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: false)
    }
}
