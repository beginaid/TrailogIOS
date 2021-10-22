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
        Utils.setButtonStyle(loginButton)
        signupTextView.delegate = self
        Utils.setHyperTextStyle(signupTextView)
    }
    
    
    @IBAction func handleLoginButton(_ sender: Any) {
        if let address = mailTextField.text,
           let password = passwordTextField.text {
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
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
                            SVProgressHUD.showError(withStatus: "エラーが起きました\n再度お試しください")
                        }
                        return
                    }
                }
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        self.performSegue(withIdentifier: "LoginToSignup", sender: self)
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
