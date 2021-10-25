import UIKit
import Firebase

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    private var semiModalPresenter = SemiModalPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        Utils.setTabBarStyle(self.tabBar)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: Const.identifierNavigation)
            loginViewController!.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(loginViewController!, animated: true, completion: nil)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is AddViewController {
            let addViewController = storyboard!.instantiateViewController(withIdentifier: Const.identifierAdd)
            semiModalPresenter.viewController = addViewController
            present(addViewController, animated: true)
            return false
        } else {
            return true
        }
    }
    
    func showAddWeight() {
        let targetViewController = self.storyboard!.instantiateViewController(withIdentifier: Const.identifierAddWeight)
        self.present(targetViewController, animated: true, completion: nil)
    }
    
    func showAddTraining() {
        let targetViewController = self.storyboard!.instantiateViewController(withIdentifier: Const.identifierAddTraining)
        self.present(targetViewController, animated: true, completion: nil)
    }
    
    func showAddWorkout() {
        let targetViewController = self.storyboard!.instantiateViewController(withIdentifier: Const.identifierAddWorkout)
        self.present(targetViewController, animated: true, completion: nil)
    }
}
