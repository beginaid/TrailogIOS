import UIKit
import Firebase
import SVProgressHUD

class EditWorkoutViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var verticalStackView: UIStackView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var deleteWorkoutButton: UIButton!
    let db = Firestore.firestore()
    let pickerView: UIPickerView = UIPickerView()
    var date: String = ""
    var contentsMap = [String: [String: String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = date
        addButton.tintColor = .black
        deleteButton.tintColor = UIColor(named: "AccentColor")
        registerButton.backgroundColor = UIColor(named: "Black")
        registerButton.layer.cornerRadius = 3.0
        deleteWorkoutButton.backgroundColor = UIColor(named: "AccentColor")
        deleteWorkoutButton.layer.cornerRadius = 3.0
        
        for event in contentsMap.keys {
            let minutes = contentsMap[event]!["時間"]!
            let maxBpm = contentsMap[event]!["最大心拍"]!
            let avgBpm = contentsMap[event]!["平均心拍"]!
            addForm(self.verticalStackView, event, minutes, maxBpm, avgBpm)
        }
    }
    
    @IBAction func handleDeleteTrainingButton(_ sender: Any) {
        let dialog = UIAlertController(title: "確認",
                                       message: "\(self.date)のデータを\n削除しますか？",
                                       preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "削除", style: .default, handler: { (_) in
            SVProgressHUD.show()
            if let user = Auth.auth().currentUser {
                let uid = user.uid
                let date = "2021-" + self.date.replacingOccurrences(of: "/", with: "-")
                self.db.collection("workouts_\(uid)").document(date).delete() { err in
                    if let err = err {
                        SVProgressHUD.dismiss()
                        SVProgressHUD.showError(withStatus: "エラーが発生しました")
                        print(err)
                    } else {
                        SVProgressHUD.dismiss()
                        SVProgressHUD.showSuccess(withStatus: "有酸素削除完了")
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }))
        dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        self.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func handleRegisterButton(_ sender: Any) {
        var contentMap = [String: [String: String]]()
        
        let verticalSubviews = self.verticalStackView.subviews
        for verticalView in verticalSubviews {
            let horizontalSubviews = verticalView.subviews
            if horizontalSubviews.count > 0 {
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
        }
        
        SVProgressHUD.show()
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let date = "2021-" + self.date.replacingOccurrences(of: "/", with: "-")
            let workoutDic = [
                "contents": contentMap,
                "createdAd": FieldValue.serverTimestamp(),
            ] as [String : Any]
            db.collection("workouts_\(uid)").document(date).setData(workoutDic) { err in
                if let err = err {
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showError(withStatus: "エラーが発生しました")
                    print(err)
                } else {
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccess(withStatus: "有酸素編集完了")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        let subviews = verticalStackView.subviews
        if subviews.count > 2 {
            subviews.last?.removeFromSuperview()
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        addForm(self.verticalStackView, Const.dropListWorkout[0], "", "", "")
    }
    
    func addForm(_ verticalStackView: UIStackView, _ eventPlaceholder: String, _ minutesPlaceholder: String,  _ maxBpmPlaceholder: String, _ avgBpmPlaceholder: String) {
        let addPickerView = createPickerView(verticalStackView)
        let addToolBar = createToolBar()
        let addStackView = createAddStackView(verticalStackView, eventPlaceholder,  minutesPlaceholder, maxBpmPlaceholder, avgBpmPlaceholder, addPickerView, addToolBar)
        verticalStackView.addArrangedSubview(addStackView)
    }
    
    func createToolBar() -> UIToolbar {
        let addToolbar = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let addDoneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AddWorkoutViewController.done))
        addToolbar.setItems([space, addDoneItem], animated: true)
        return addToolbar
    }
    
    func createPickerView(_ verticalStackView: UIStackView) -> UIPickerView {
        let addPickerView: UIPickerView = UIPickerView()
        addPickerView.tag = verticalStackView.subviews.count + 1
        addPickerView.delegate = self
        addPickerView.dataSource = self
        return addPickerView
    }
    
    func createAddStackView(_ verticalStackView: UIStackView, _ eventPlaceholder: String,  _ minutesPlaceholder: String,  _ maxBpmPlaceholder: String, _ avgBpmPlaceholder: String, _ addPickerView: UIPickerView, _ addToolbar: UIToolbar) -> UIStackView {
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
        addEventTextField.text = eventPlaceholder
        addMinutesTextField.attributedPlaceholder = NSAttributedString(string: "時間 [分]", attributes: attributes)
        addMinutesTextField.borderStyle = .roundedRect
        addMinutesTextField.text = minutesPlaceholder
        addMinutesTextField.keyboardType = UIKeyboardType.numberPad
        addMaxBpmTextField.attributedPlaceholder = NSAttributedString(string: "最大Bpm", attributes: attributes)
        addMaxBpmTextField.borderStyle = .roundedRect
        addMaxBpmTextField.text = maxBpmPlaceholder
        addMaxBpmTextField.keyboardType = UIKeyboardType.numberPad
        addAvgBpmTextField.attributedPlaceholder = NSAttributedString(string: "平均Bpm", attributes: attributes)
        addAvgBpmTextField.borderStyle = .roundedRect
        addAvgBpmTextField.text = avgBpmPlaceholder
        addAvgBpmTextField.keyboardType = UIKeyboardType.numberPad
        addEventTextField.adjustsFontSizeToFitWidth = true
        addEventTextField.tag = 100 + verticalStackView.subviews.count + 1
        addMinutesTextField.widthAnchor.constraint(equalTo: addEventTextField.widthAnchor, multiplier: 1).isActive = true
        addMaxBpmTextField.widthAnchor.constraint(equalTo: addEventTextField.widthAnchor, multiplier: 1).isActive = true
        addAvgBpmTextField.widthAnchor.constraint(equalTo: addEventTextField.widthAnchor, multiplier: 1).isActive = true
        
        addStackView.axis = .horizontal
        addStackView.alignment = .fill
        addStackView.distribution = .equalSpacing
        addStackView.spacing = 4
        addStackView.translatesAutoresizingMaskIntoConstraints = false
        addStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addEventTextField.inputView = addPickerView
        addEventTextField.inputAccessoryView = addToolbar
        return addStackView
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        view.endEditing(true)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
