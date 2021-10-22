import UIKit
import Firebase

class SettingViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils.setButtonStyle(logoutButton)
    }
    
    @IBAction func handleLogoutButton(_ sender: Any) {
        try! Auth.auth().signOut()
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        let navViewController = UINavigationController(rootViewController: loginViewController!)
        let keywindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        keywindow!.rootViewController = navViewController
    }
}
