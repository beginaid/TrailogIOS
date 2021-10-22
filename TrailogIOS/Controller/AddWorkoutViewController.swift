import UIKit
import Firebase
import SVProgressHUD

class AddWorkoutViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var verticalStackView: UIStackView!
    @IBOutlet weak var eventTextField: UITextField!
    @IBOutlet weak var minutesTextField: UITextField!
    @IBOutlet weak var maxBpmTextField: UITextField!
    @IBOutlet weak var avgBpmTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    let db = Firestore.firestore()
    let pickerView: UIPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tag = 1
        eventTextField.inputView = pickerView
        eventTextField.text = Const.dropListWorkout[0]
        deleteButton.tintColor = UIColor(named: "AccentColor")
        addButton.tintColor = .black
        minutesTextField.keyboardType = UIKeyboardType.numberPad
        maxBpmTextField.keyboardType = UIKeyboardType.numberPad
        avgBpmTextField.keyboardType = UIKeyboardType.numberPad
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
               let minutes = (horizontalSubviews[1] as! UITextField).text,
               let maxBpm = (horizontalSubviews[2] as! UITextField).text,
               let avgBpm = (horizontalSubviews[3] as! UITextField).text {
                if event.isEmpty || minutes.isEmpty || maxBpm.isEmpty || avgBpm.isEmpty {
                    SVProgressHUD.showError(withStatus: "内容を全て入力して下さい")
                    return
                }
                contentMap.updateValue(["時間": minutes], forKey: event)
                contentMap[event]!["最大心拍"] = maxBpm
                contentMap[event]!["平均心拍"] = avgBpm
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
            db.collection("workouts_\(uid)").document(date).setData(trainingDic) { err in
                if let err = err {
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showError(withStatus: "エラーが発生しました")
                    print(err)
                } else {
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccess(withStatus: "有酸素追加完了")
                    let tabBarController = self.view.window?.rootViewController as! TabBarController
                    tabBarController.selectedIndex = 3
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
        let addMinutesTextField = DoneTextField()
        let addMaxBpmTextField = DoneTextField()
        let addAvgBpmTextField = DoneTextField()
        addStackView.addArrangedSubview(addEventTextField)
        addStackView.addArrangedSubview(addMinutesTextField)
        addStackView.addArrangedSubview(addMaxBpmTextField)
        addStackView.addArrangedSubview(addAvgBpmTextField)
        
        
        let attributes = [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 16)]
        addEventTextField.attributedPlaceholder = NSAttributedString(string: "種目", attributes: attributes)
        addEventTextField.borderStyle = .roundedRect
        addMinutesTextField.attributedPlaceholder = NSAttributedString(string: "時間 [分]", attributes: attributes)
        addMinutesTextField.borderStyle = .roundedRect
        addMaxBpmTextField.attributedPlaceholder = NSAttributedString(string: "MaxBpm", attributes: attributes)
        addMaxBpmTextField.borderStyle = .roundedRect
        addAvgBpmTextField.attributedPlaceholder = NSAttributedString(string: "AvgBpm", attributes: attributes)
        addAvgBpmTextField.borderStyle = .roundedRect
        addEventTextField.adjustsFontSizeToFitWidth = true
        addMinutesTextField.widthAnchor.constraint(equalTo: addEventTextField.widthAnchor, multiplier: 1).isActive = true
        addMaxBpmTextField.widthAnchor.constraint(equalTo: addEventTextField.widthAnchor, multiplier: 1).isActive = true
        addAvgBpmTextField.widthAnchor.constraint(equalTo: addEventTextField.widthAnchor, multiplier: 1).isActive = true
        
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
        addEventTextField.text = Const.dropListWorkout[0]
        addMinutesTextField.keyboardType = UIKeyboardType.numberPad
        addMaxBpmTextField.keyboardType = UIKeyboardType.numberPad
        addAvgBpmTextField.keyboardType = UIKeyboardType.numberPad
        verticalStackView.addArrangedSubview(addStackView)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Const.dropListWorkout.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Const.dropListWorkout[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let textField = view.viewWithTag(100 + pickerView.tag) as! UITextField
        textField.text = Const.dropListWorkout[row]
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
        view.endEditing(true)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
