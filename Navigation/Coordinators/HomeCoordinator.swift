import UIKit

final class HomeCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let userService: UserService

    init(
        navigationController: UINavigationController,
        userService: UserService = CurrentUserService()
    ) {
        self.navigationController = navigationController
        self.userService = userService
    }

    func start() {
        let vc = HomeViewController()
        let user = userService.getUser(login: "Wowgorno")
        vc.configureAvatar(user?.avatar)
        vc.onOpenProfile = { [weak self] in
            guard let self else { return }
            let vm = ProfileViewModel(user: user)
            let profileVC = ProfileViewController(
                viewModel: vm,
                screenMode: .myProfile
            )
            self.navigationController.pushViewController(profileVC, animated: true)
        }
        navigationController.setViewControllers([vc], animated: false)
    }
}
