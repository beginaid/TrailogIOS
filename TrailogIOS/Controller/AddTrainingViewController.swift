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
        Utils.setEventTextField(eventTextField, pickerView, Const.dropListTraining[0])
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
        var contentMap = [String: [String: String]]()
        let verticalSubviews = verticalStackView.subviews
        for verticalView in verticalSubviews {
            let horizontalSubviews = verticalView.subviews
            if let event = (horizontalSubviews[0] as! UITextField).text,
               let weight = (horizontalSubviews[1] as! UITextField).text,
               let reps = (horizontalSubviews[2] as! UITextField).text{
                if event.isEmpty || weight.isEmpty || reps.isEmpty {
                    Utils.showError(Const.errorFormsNotFilled)
                    return
                }
                contentMap.updateValue([Const.firebaseFieldWeight: weight], forKey: event)
                contentMap[event]![Const.firebaseFieldReps] = reps
            }
        }
        
        SVProgressHUD.show()
        if let user = Auth.auth().currentUser {
            let date = Utils.getDateFromDatePicker(datePicker)
            let trainingDic = [
                Const.firebaseCollectionNameContents: contentMap,
                Const.firebaseCollectionNameCreatedAt: FieldValue.serverTimestamp(),
            ] as [String : Any]
            db.collection("\(Const.firebaseCollectionNameTraining)_\(user.uid)").document(date).setData(trainingDic) { err in
                if let err = err {
                    SVProgressHUD.dismiss()
                    Utils.showError(Const.errorDefault)
                    print(err)
                } else {
                    SVProgressHUD.dismiss()
                    Utils.showSuccess(Const.successAdd)
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
        let addPickerView = createPickerView(self.verticalStackView)
        let addStackView = Utils.createAddStackViewTraining(self.verticalStackView, Const.dropListTraining[0],  "", "", addPickerView)
        verticalStackView.addArrangedSubview(addStackView)
    }
    
    func createPickerView(_ verticalStackView: UIStackView) -> UIPickerView {
        let addPickerView: UIPickerView = UIPickerView()
        addPickerView.tag = verticalStackView.subviews.count + 1
        addPickerView.delegate = self
        addPickerView.dataSource = self
        return addPickerView
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
}
