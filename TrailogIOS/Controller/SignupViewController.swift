import UIKit
import Firebase
import SVProgressHUD

class SignupViewController: UIViewController {
    
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils.setButtonStyle(signupButton)
    }
    
    @IBAction func handleSignupButton(_ sender: Any) {
        if let address = mailTextField.text,
           let password = passwordTextField.text,
           let passwordConfirm = passwordConfirmTextField.text {
            if address.isEmpty || password.isEmpty || passwordConfirm.isEmpty {
                Utils.showError(Const.errorFormsNotFilled)
                return
            }
            if password != passwordConfirm {
                Utils.showError(Const.errorPasswordNotMatched)
                return
            }
            SVProgressHUD.show()
            Auth.auth().createUser(withEmail: address, password: password) {
                authResult, error in
                if error == nil {
                    SVProgressHUD.dismiss()
                    Utils.updateRootWindow(self.storyboard!, Const.identifierMain)
                    return
                } else {
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .invalidEmail:
                            Utils.showError(Const.errorEmailInvalid)
                        case .emailAlreadyInUse:
                            Utils.showError(Const.errorEmailAlreadyInUse)
                        case .weakPassword:
                            Utils.showError(Const.errorPasswordTooShort)
                        default:
                            Utils.showError(Const.errorDefault)
                        }
                        return
                    }
                }
            }
        }
    }
}
