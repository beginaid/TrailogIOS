import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let window = UIWindow(windowScene: scene as! UIWindowScene)
        self.window = window
        window.makeKeyAndVisible()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if Auth.auth().currentUser?.uid != nil {
            let viewController = storyBoard.instantiateViewController(identifier: "Main")
            window.rootViewController = viewController
        } else {
            let loginViewController = storyBoard.instantiateViewController(identifier: "Login")
            let navViewController = UINavigationController(rootViewController: loginViewController)
            window.rootViewController = navViewController
        }
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window = window
        }
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
    
}
