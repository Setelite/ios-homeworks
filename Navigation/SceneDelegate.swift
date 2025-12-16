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

        // 1. Рандомно выбираем конфигурацию
        appConfiguration = makeRandomConfiguration()

        // 2. Делаем сетевой запрос при старте приложения
        if let configuration = appConfiguration {
            NetworkService.request(for: configuration)
        }

        // 3. Запускаем координатор (как и было)
        let appCoordinator = AppCoordinator(window: window)
        self.appCoordinator = appCoordinator
        appCoordinator.start()
    }

    private func makeRandomConfiguration() -> AppConfiguration {
        let configurations: [AppConfiguration] = [
            .people("https://swapi.dev/api/people/8"),
            .starship("https://swapi.dev/api/starships/3"),
            .planet("https://swapi.dev/api/planets/5")
        ]

        return configurations.randomElement()!
    }
}
