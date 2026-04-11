import UIKit

final class SportsCoordinator: Coordinator {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = SportsHubViewController()
        navigationController.setViewControllers([vc], animated: false)
    }
}
