import UIKit
import Firebase
import SVProgressHUD

class AddTrainingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var eventTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var repsTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var verticalStackView: UIStackView!
    @IBOutlet weak var registerButton: UIButton!
    let db = Firestore.firestore()
    let pickerView: UIPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tag = 1
        eventTextField.inputView = pickerView
        eventTextField.text = Const.dropListTraining[0]
        addButton.tintColor = .black
        deleteButton.tintColor = UIColor(named: "AccentColor")
        weightTextField.keyboardType = UIKeyboardType.decimalPad
        repsTextField.keyboardType = UIKeyboardType.numberPad
        registerButton.backgroundColor = UIColor(named: "AccentColor")
        registerButton.layer.cornerRadius = 3.0
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func handleRegisterButton(_ sender: Any) {
        var contentMap = [String: [String: String]]()
        
        let verticalSubviews = verticalStackView.subviews
        for verticalView in verticalSubviews {
            let horizontalSubviews = verticalView.subviews
            if let event = (horizontalSubviews[0] as! UITextField).text,
               let weight = (horizontalSubviews[1] as! UITextField).text,
               let reps = (horizontalSubviews[2] as! UITextField).text{
                if event.isEmpty || weight.isEmpty || reps.isEmpty {
                    SVProgressHUD.showError(withStatus: "内容を全て入力して下さい")
                    return
                }
                contentMap.updateValue(["負荷": weight], forKey: event)
                contentMap[event]!["回数"] = reps
            }
        }
        
        SVProgressHUD.show()
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            let date = dateFormatter.string(from: datePicker.date)
            
            let trainingDic = [
                "contents": contentMap,
                "createdAt": FieldValue.serverTimestamp(),
            ] as [String : Any]
            db.collection("trainings_\(uid)").document(date).setData(trainingDic) { err in
                if let err = err {
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showError(withStatus: "エラーが発生しました")
                    print(err)
                } else {
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccess(withStatus: "トレーニング追加完了")
                    let tabBarController = self.view.window?.rootViewController as! TabBarController
                    tabBarController.selectedIndex = 1
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        let subviews = verticalStackView.subviews
        if subviews.count > 1 {
            subviews.last?.removeFromSuperview()
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        let addStackView: UIStackView = UIStackView()
        let addEventTextField = DoneTextField()
        let addWeightTextField = DoneTextField()
        let addRepsTextField = DoneTextField()
        addStackView.addArrangedSubview(addEventTextField)
        addStackView.addArrangedSubview(addWeightTextField)
        addStackView.addArrangedSubview(addRepsTextField)
        
        
        let attributes = [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 16)]
        addEventTextField.attributedPlaceholder = NSAttributedString(string: "種目", attributes: attributes)
        addEventTextField.borderStyle = .roundedRect
        addWeightTextField.attributedPlaceholder = NSAttributedString(string: "負荷 [kg]", attributes: attributes)
        addWeightTextField.borderStyle = .roundedRect
        addWeightTextField.keyboardType = UIKeyboardType.decimalPad
        addRepsTextField.attributedPlaceholder = NSAttributedString(string: "回数 [回]", attributes: attributes)
        addRepsTextField.borderStyle = .roundedRect
        addRepsTextField.keyboardType = UIKeyboardType.numberPad
        addEventTextField.adjustsFontSizeToFitWidth = true
        addEventTextField.widthAnchor.constraint(equalTo: addWeightTextField.widthAnchor, multiplier: 2).isActive = true
        addEventTextField.widthAnchor.constraint(equalTo: addRepsTextField.widthAnchor, multiplier: 2).isActive = true
        
        addStackView.axis = .horizontal
        addStackView.alignment = .fill
        addStackView.distribution = .equalSpacing
        addStackView.spacing = 4
        addStackView.translatesAutoresizingMaskIntoConstraints = false
        addStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let addPickerView: UIPickerView = UIPickerView()
        addPickerView.tag = verticalStackView.subviews.count + 1
        addEventTextField.tag = 100 + verticalStackView.subviews.count + 1
        addPickerView.delegate = self
        addPickerView.dataSource = self
        addEventTextField.inputView = addPickerView
        addEventTextField.text = Const.dropListTraining[0]
        verticalStackView.addArrangedSubview(addStackView)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Const.dropListTraining.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Const.dropListTraining[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let textField = view.viewWithTag(100 + pickerView.tag) as! UITextField
        textField.text = Const.dropListTraining[row]
    }
    
    @objc func done() {
        view.endEditing(true)
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        self.view.endEditing(true)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
