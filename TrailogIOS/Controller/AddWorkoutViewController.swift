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
        Utils.setEventTextField(eventTextField, pickerView, Const.dropListWorkout[0])
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
               let minutes = (horizontalSubviews[1] as! UITextField).text,
               let maxBpm = (horizontalSubviews[2] as! UITextField).text,
               let avgBpm = (horizontalSubviews[3] as! UITextField).text {
                if event.isEmpty || minutes.isEmpty || maxBpm.isEmpty || avgBpm.isEmpty {
                    Utils.showError(Const.errorFormsNotFilled)
                    return
                }
                contentMap.updateValue([Const.firebaseFieldMinutes: minutes], forKey: event)
                contentMap[event]![Const.firebaseFieldMaxBpm] = maxBpm
                contentMap[event]![Const.firebaseFieldAvgBpm] = avgBpm
            }
        }
        
        SVProgressHUD.show()
        if let user = Auth.auth().currentUser {
            let date = Utils.getDateFromDatePicker(datePicker)
            let workoutDic = [
                Const.firebaseFieldContents: contentMap,
                Const.firebaseFieldCreatedAt: FieldValue.serverTimestamp(),
            ] as [String : Any]
            db.collection("\(Const.firebaseCollectionWorkout)_\(user.uid)").document(date).setData(workoutDic) { err in
                if let err = err {
                    SVProgressHUD.dismiss()
                    Utils.showError(Const.errorDefault)
                    print(err)
                } else {
                    SVProgressHUD.dismiss()
                    Utils.showSuccess(Const.successAdd)
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
        let addPickerView = createPickerView(self.verticalStackView)
        let addStackView = Utils.createAddStackViewWorkout(self.verticalStackView, Const.dropListWorkout[0],  "", "", "", addPickerView)
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
        return Const.dropListWorkout.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Const.dropListWorkout[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let textField = view.viewWithTag(100 + pickerView.tag) as! UITextField
        textField.text = Const.dropListWorkout[row]
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
