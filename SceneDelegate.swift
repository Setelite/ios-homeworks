func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    window = UIWindow(windowScene: windowScene)

    let loginVC = LogInViewController()

    // ✅ Внедряем делегата через фабрику
    let loginFactory = MyLoginFactory()
    loginVC.loginDelegate = loginFactory.makeLoginInspector()

    window?.rootViewController = UINavigationController(rootViewController: loginVC)
    window?.makeKeyAndVisible()
}
