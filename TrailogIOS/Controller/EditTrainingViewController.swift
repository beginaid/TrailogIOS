import UIKit
import Firebase
import SVProgressHUD

class EditTrainingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var verticalStackView: UIStackView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var deleteTrainingButton: UIButton!
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
        deleteTrainingButton.backgroundColor = UIColor(named: "AccentColor")
        deleteTrainingButton.layer.cornerRadius = 3.0
        
        for event in contentsMap.keys {
            let weight = contentsMap[event]!["負荷"]!
            let reps = contentsMap[event]!["回数"]!
            addForm(self.verticalStackView, event, weight, reps)
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
                self.db.collection("trainings_\(uid)").document(date).delete() { err in
                    if let err = err {
                        SVProgressHUD.dismiss()
                        SVProgressHUD.showError(withStatus: "エラーが発生しました")
                        print(err)
                    } else {
                        SVProgressHUD.dismiss()
                        SVProgressHUD.showSuccess(withStatus: "トレーニング削除完了")
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
        }
        
        SVProgressHUD.show()
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let date = "2021-" + self.date.replacingOccurrences(of: "/", with: "-")
            let trainingDic = [
                "contents": contentMap,
                "createdAd": FieldValue.serverTimestamp(),
            ] as [String : Any]
            db.collection("trainings_\(uid)").document(date).setData(trainingDic) { err in
                if let err = err {
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showError(withStatus: "エラーが発生しました")
                    print(err)
                } else {
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccess(withStatus: "トレーニング編集完了")
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
        addForm(self.verticalStackView, Const.dropListTraining[0], "", "")
    }
    
    func addForm(_ verticalStackView: UIStackView, _ eventPlaceholder: String,  _ weightPlaceholder: String,  _ repsPlaceholder: String) {
        let addPickerView = createPickerView(verticalStackView)
        let addStackView = createAddStackView(verticalStackView, eventPlaceholder,  weightPlaceholder, repsPlaceholder, addPickerView)
        verticalStackView.addArrangedSubview(addStackView)
    }
        
    func createPickerView(_ verticalStackView: UIStackView) -> UIPickerView {
        let addPickerView: UIPickerView = UIPickerView()
        addPickerView.tag = verticalStackView.subviews.count + 1
        addPickerView.delegate = self
        addPickerView.dataSource = self
        return addPickerView
    }
    
    func createAddStackView(_ verticalStackView: UIStackView, _ eventPlaceholder: String,  _ weightPlaceholder: String,  _ repsPlaceholder: String, _ addPickerView: UIPickerView) -> UIStackView {
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
        addEventTextField.text = eventPlaceholder
        addWeightTextField.attributedPlaceholder = NSAttributedString(string: "負荷 [kg]", attributes: attributes)
        addWeightTextField.borderStyle = .roundedRect
        addWeightTextField.text = weightPlaceholder
        addWeightTextField.keyboardType = UIKeyboardType.decimalPad
        addRepsTextField.attributedPlaceholder = NSAttributedString(string: "回数 [回]", attributes: attributes)
        addRepsTextField.borderStyle = .roundedRect
        addRepsTextField.text = repsPlaceholder
        addRepsTextField.keyboardType = UIKeyboardType.numberPad
        addEventTextField.adjustsFontSizeToFitWidth = true
        addEventTextField.tag = 100 + verticalStackView.subviews.count + 1
        addEventTextField.widthAnchor.constraint(equalTo: addWeightTextField.widthAnchor, multiplier: 2).isActive = true
        addEventTextField.widthAnchor.constraint(equalTo: addRepsTextField.widthAnchor, multiplier: 2).isActive = true
        
        addStackView.axis = .horizontal
        addStackView.alignment = .fill
        addStackView.distribution = .equalSpacing
        addStackView.spacing = 4
        addStackView.translatesAutoresizingMaskIntoConstraints = false
        addStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addEventTextField.inputView = addPickerView
        return addStackView
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
