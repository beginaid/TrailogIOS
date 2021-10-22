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
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            if password != passwordConfirm {
                SVProgressHUD.showError(withStatus: "パスワードが一致しません")
                return
            }
            SVProgressHUD.show()
            Auth.auth().createUser(withEmail: address, password: password) {
                authResult, error in
                if error == nil {
                    SVProgressHUD.dismiss()
                    let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "Main")
                    let keywindow = UIApplication.shared.windows.first { $0.isKeyWindow }
                    keywindow!.rootViewController = mainViewController
                    return
                } else {
                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                        switch errCode {
                        case .invalidEmail:
                            SVProgressHUD.showError(withStatus: "正しいメールアドレスを\n入力してください")
                        case .emailAlreadyInUse:
                            SVProgressHUD.showError(withStatus: "このメールアドレスは\nすでに使われています")
                        case .weakPassword:
                            SVProgressHUD.showError(withStatus: "パスワードは6文字以上で\n入力してください")
                        default:
                            SVProgressHUD.showError(withStatus: "エラーが起きました\nしばらくしてから再度お試しください")
                        }
                        return
                    }
                }
            }
        }
    }
}
