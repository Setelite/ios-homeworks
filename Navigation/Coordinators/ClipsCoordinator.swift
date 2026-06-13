import UIKit

final class ClipsCoordinator: Coordinator {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ClipsViewController()
        navigationController.setViewControllers([vc], animated: false)
    }
}
