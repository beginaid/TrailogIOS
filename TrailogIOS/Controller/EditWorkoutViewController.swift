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
        Utils.setButtonStyle(registerButton, Const.colorBlack)
        Utils.setButtonStyle(deleteWorkoutButton, Const.colorAccent)
        
        for event in contentsMap.keys {
            let minutes = contentsMap[event]![Const.firebaseFieldMinutes]!
            let maxBpm = contentsMap[event]![Const.firebaseFieldMaxBpm]!
            let avgBpm = contentsMap[event]![Const.firebaseFieldAvgBpm]!
            let addPickerView = createPickerView(self.verticalStackView)
            let addStackView = Utils.createAddStackViewWorkout(self.verticalStackView, Const.dropListWorkout[0],  minutes, maxBpm, avgBpm, addPickerView)
            verticalStackView.addArrangedSubview(addStackView)
        }
    }
    
    @IBAction func handleDeleteTrainingButton(_ sender: Any) {
        let dialog = UIAlertController(title: Const.confirm,
                                       message: "\(self.date)のデータを\n削除しますか？",
                                       preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: Const.delete, style: .default, handler: { (_) in
            SVProgressHUD.show()
            if let user = Auth.auth().currentUser {
                let date = "\(Const.year)-\(self.date.replacingOccurrences(of: "/", with: "-"))"
                self.db.collection("\(Const.firebaseCollectionNameWorkout)_\(user.uid)").document(date).delete() { err in
                    if let err = err {
                        SVProgressHUD.dismiss()
                        Utils.showError(Const.errorDefault)
                        print(err)
                    } else {
                        SVProgressHUD.dismiss()
                        Utils.showSuccess(Const.successDelete)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }))
        dialog.addAction(UIAlertAction(title: Const.cancel, style: .cancel, handler: nil))
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
                        Utils.showError(Const.errorFormsNotFilled)
                        return
                    }
                    contentMap.updateValue([Const.firebaseFieldMinutes: minutes], forKey: event)
                    contentMap[event]![Const.firebaseFieldMaxBpm] = maxBpm
                    contentMap[event]![Const.firebaseFieldAvgBpm] = avgBpm
                }
            }
        }
        
        SVProgressHUD.show()
        if let user = Auth.auth().currentUser {
            let date = "\(Const.year)-\(self.date.replacingOccurrences(of: "/", with: "-"))"
            let workoutDic = [
                Const.firebaseCollectionNameContents: contentMap,
                Const.firebaseCollectionNameCreatedAt: FieldValue.serverTimestamp(),
            ] as [String : Any]
            db.collection("workouts_\(user.uid)").document(date).setData(workoutDic) { err in
                if let err = err {
                    SVProgressHUD.dismiss()
                    Utils.showError(Const.errorFormsNotFilled)
                    print(err)
                } else {
                    SVProgressHUD.dismiss()
                    Utils.showSuccess(Const.successEdit)
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
}
