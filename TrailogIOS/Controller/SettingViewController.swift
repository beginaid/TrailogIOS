import UIKit
import Firebase

class SettingViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils.setButtonStyle(logoutButton, Const.colorAccent)
    }
    
    @IBAction func handleLogoutButton(_ sender: Any) {
        try! Auth.auth().signOut()
        Utils.updateRootWindowWithNavigation(self.storyboard!, Const.identifierLogin)
    }
}
