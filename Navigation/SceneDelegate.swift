import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

   
    private var loginInspector: LoginViewControllerDelegate?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        // экран логина
        let loginVC = LogInViewController()

        // делегат через фабрику
        let loginFactory = MyLoginFactory()
        let inspector = loginFactory.makeLoginInspector()
        self.loginInspector = inspector

      
        loginVC.loginDelegate = inspector

       
        window.rootViewController = UINavigationController(rootViewController: loginVC)
        window.makeKeyAndVisible()
        self.window = window
    }
}
