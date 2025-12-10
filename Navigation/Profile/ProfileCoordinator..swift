//
//  ProfileCoordinator..swift
//  Navigation
//
//  Created by MAXIM GORNOSTAEV on 11/29/25.
//

import UIKit

final class ProfileCoordinator: Coordinator {

    let navigationController = UINavigationController()
    private let user: User

    init(user: User) {
        self.user = user
    }

    func start() {
        let viewModel = ProfileViewModel(user: user)
        let vc = ProfileViewController(viewModel: viewModel)

        vc.onOpenPhotos = { [weak self] photos in
            self?.showPhotos(photos)
        }

        navigationController.setViewControllers([vc], animated: false)
    }

    private func showPhotos(_ photos: [String]) {
        let vc = PhotosViewController()
        vc.photos = photos
        navigationController.pushViewController(vc, animated: true)
    }
}
