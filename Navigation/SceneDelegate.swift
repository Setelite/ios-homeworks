import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    var appConfiguration: AppConfiguration?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        appConfiguration = makeRandomConfiguration()

        if let configuration = appConfiguration {
            NetworkService.request(for: configuration)
        }

        let appCoordinator = AppCoordinator(window: window)
        self.appCoordinator = appCoordinator
        appCoordinator.start()
    }

    /* 🔥 ВАЖНО ДЛЯ ЗАЧЁТА
    func sceneDidDisconnect(_ scene: UIScene) {
        do {
            try Auth.auth().signOut()
            print("✅ User signed out")
        } catch {
            print("❌ Sign out error:", error.localizedDescription)
        }
    }
    */

    private func makeRandomConfiguration() -> AppConfiguration {
        let configurations: [AppConfiguration] = [
            .people("https://swapi.dev/api/people/8"),
            .starship("https://swapi.dev/api/starships/3"),
            .planet("https://swapi.dev/api/planets/5")
        ]

        return configurations.randomElement()!
    }
}
