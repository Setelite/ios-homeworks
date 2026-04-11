import UIKit

final class MenuCoordinator: Coordinator {
    let navigationController: UINavigationController
    private var passwordCoordinator: PasswordCoordinator?
    private let userService: UserService

    init(
        navigationController: UINavigationController,
        userService: UserService = CurrentUserService()
    ) {
        self.navigationController = navigationController
        self.userService = userService
    }

    func start() {
        let vc = MenuViewController()
        vc.onAction = { [weak self] action in
            self?.handle(action: action)
        }
        navigationController.setViewControllers([vc], animated: false)
    }

    private func handle(action: MenuViewController.MenuAction) {
        switch action {
        case .profile:
            let login = FirebaseSessionStorage.shared.user?.email ?? "Wowgorno"
            let user = userService.getUser(login: login)
            let vm = ProfileViewModel(user: user)
            let vc = ProfileViewController(viewModel: vm)
            navigationController.pushViewController(vc, animated: true)

        case .sports:
            let vc = SportsHubViewController()
            navigationController.pushViewController(vc, animated: true)

        case .nutrition:
            let vm = FoodScannerViewModel(
                foodService: FoodService(),
                diaryRepository: CoreDataNutritionDiaryRepository()
            )
            let vc = FoodScannerViewController(viewModel: vm)
            navigationController.pushViewController(vc, animated: true)

        case .favorites:
            let vc = FavoritesViewController()
            vc.onOpenFiles = { [weak self] in self?.showFiles() }
            vc.onOpenSettings = { [weak self] in self?.showSettings() }
            navigationController.pushViewController(vc, animated: true)

        case .files:
            showFiles()

        case .settings:
            showSettings()

        case .posts:
            let vc = PostsViewController()
            navigationController.pushViewController(vc, animated: true)

        case .info:
            let vc = InfoViewController()
            navigationController.pushViewController(vc, animated: true)
        }
    }

    private func showFiles() {
        let vc = FilesViewController()
        navigationController.pushViewController(vc, animated: true)
    }

    private func showSettings() {
        let vc = SettingsViewController()
        vc.onChangePassword = { [weak self] in
            self?.showPasswordFlow()
        }
        vc.onLogout = { [weak self] in
            FirebaseSessionStorage.shared.clear()
            self?.navigationController.popToRootViewController(animated: true)
        }
        navigationController.pushViewController(vc, animated: true)
    }

    private func showPasswordFlow() {
        let coordinator = PasswordCoordinator(navigationController: navigationController)
        passwordCoordinator = coordinator

        coordinator.onFinish = { [weak self] in
            self?.passwordCoordinator = nil
            self?.navigationController.popViewController(animated: true)
        }

        coordinator.start()
    }
}
