import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupTextView: UITextView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signupTextView.delegate = self
        Utils.setButtonStyle(loginButton, Const.colorAccent)
        Utils.setHyperTextStyle(signupTextView)
    }
    
    
    @IBAction func handleLoginButton(_ sender: Any) {
        if let address = mailTextField.text,
           let password = passwordTextField.text {
            if address.isEmpty || password.isEmpty {
                Utils.showError(Const.errorDefault)
                return
            }
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                if error == nil {
                    SVProgressHUD.dismiss()
                    Utils.updateRootWindow(self.storyboard, Const.identifierMain)
                    return
                } else {
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .invalidEmail:
                            Utils.showError(Const.errorEmailInvalid)
                        case .weakPassword:
                            Utils.showError(Const.errorPasswordTooShort)
                        default:
                            Utils.showError(Const.errorDefault)
                        }
                        SVProgressHUD.dismiss()
                        return
                    }
                }
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.performSegue(withIdentifier: Const.identifierLoginToSignup, sender: self)
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        view.endEditing(true)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
