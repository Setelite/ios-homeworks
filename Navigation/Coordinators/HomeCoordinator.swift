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
        let feedViewModel = SocialFeedViewModel(
            service: FeedService(),
            cacheRepository: CoreDataFeedCacheRepository()
        )
        let vc = HomeViewController(remoteFeedViewModel: feedViewModel)
        let login = FirebaseSessionStorage.shared.user?.email ?? "Wowgorno"
        let user = userService.getUser(login: login)
        vc.configureAvatar(user?.avatar)
        vc.onOpenProfile = { [weak self] in
            guard let self else { return }
            let profileLogin = FirebaseSessionStorage.shared.user?.email ?? "Wowgorno"
            let currentUser = self.userService.getUser(login: profileLogin)
            let vm = ProfileViewModel(user: currentUser)
            let profileVC = ProfileViewController(
                viewModel: vm,
                screenMode: .myProfile
            )
            self.navigationController.pushViewController(profileVC, animated: true)
        }
        navigationController.setViewControllers([vc], animated: false)
    }
}
