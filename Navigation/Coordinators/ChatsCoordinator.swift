import UIKit

final class ChatsCoordinator: Coordinator {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ChatsViewController()
        navigationController.setViewControllers([vc], animated: false)
    }
}
