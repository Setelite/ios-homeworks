import UIKit

final class SearchCoordinator: Coordinator {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = SearchViewController()
        navigationController.setViewControllers([vc], animated: false)
    }
}
