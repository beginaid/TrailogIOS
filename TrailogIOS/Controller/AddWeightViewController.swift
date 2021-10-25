import UIKit
import Firebase
import SVProgressHUD

class AddWeightViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils.setButtonStyle(registerButton, Const.colorAccent)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func handleRegisterButton(_ sender: Any) {
        SVProgressHUD.show()
        if let user = Auth.auth().currentUser {
            let date = Utils.getDateFromDatePicker(datePicker)
            if let weightText = weightTextField.text {
                if weightText.isEmpty {
                    SVProgressHUD.dismiss()
                    Utils.showSuccess(Const.errorFormsNotFilled)
                    return
                }
                let weightDic = [
                    Const.firebaseFieldWeight: weightText,
                    Const.firebaseFieldCreatedAt: FieldValue.serverTimestamp(),
                ] as [String : Any]
                db.collection("\(Const.firebaseCollectionWeight)_\(user.uid)").document(date).setData(weightDic) { err in
                    if let err = err {
                        SVProgressHUD.dismiss()
                        Utils.showError(Const.errorDefault)
                        print(err)
                    } else {
                        SVProgressHUD.dismiss()
                        Utils.showSuccess(Const.successAdd)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 150
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
        }
    }
    
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}
