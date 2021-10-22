import UIKit
import Firebase
import SVProgressHUD

class editDeleteWeightViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var modalVIew: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    let db = Firestore.firestore()
    var date: String!
    var weight: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Const.rgbLightBlack
        Utils.setModalView(modalVIew)
        Utils.setButtonStyle(editButton, Const.colorBlack)
        Utils.setButtonStyle(deleteButton, Const.colorAccent)
        dateLabel.text = date
        dateLabel.textAlignment = .center
        weightTextField.text = weight
        weightTextField.textAlignment = .center
        weightTextField.keyboardType = UIKeyboardType.decimalPad
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(editDeleteWeightViewController.tapped(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func handleEditButton(_ sender: Any) {
        SVProgressHUD.show()
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let date = "\(Const.year)-\(date.replacingOccurrences(of: "/", with: "-"))"
            if let weightText = weightTextField.text {
                if weightText.isEmpty {
                    SVProgressHUD.dismiss()
                    Utils.showError(Const.errorWeightNotFilled)
                    return
                }
                let weightDic = [
                    "weight": weightText,
                    "createdAd": FieldValue.serverTimestamp(),
                ] as [String : Any]
                db.collection("weights_\(uid)").document(date).setData(weightDic) { err in
                    if let err = err {
                        SVProgressHUD.dismiss()
                        Utils.showError(Const.errorDefault)
                        print(err)
                    } else {
                        SVProgressHUD.dismiss()
                        Utils.showSuccess(Const.successAddWeight)
                        self.presentingViewController?.dismiss(animated: true, completion: nil)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func handleDeleteButton(_ sender: Any) {
        let dialog = UIAlertController(title: "確認", message: "\(date ?? "")の体重を削除しますか？", preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        dialog.addAction(UIAlertAction(title: "OK", style: .default,
                                       handler: { action in
                                        SVProgressHUD.show()
                                        if let user = Auth.auth().currentUser {
                                            let uid = user.uid
                                            let date = "\(Const.year)-\(self.date.replacingOccurrences(of: "/", with: "-"))"
                                            self.db.collection("weights_\(uid)").document(date).delete() { err in
                                                if let err = err {
                                                    SVProgressHUD.dismiss()
                                                    Utils.showError(Const.errorDefault)
                                                    print(err)
                                                } else {
                                                    SVProgressHUD.dismiss()
                                                    Utils.showSuccess(Const.successDeleteWeight)
                                                    self.dismiss(animated: true, completion: nil)
                                                }
                                            }
                                        }
                                       }))
        self.present(dialog, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 70
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
