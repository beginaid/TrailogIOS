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
        Utils.setButtonStyle(registerButton, Const.colorBlack)
        Utils.setButtonStyle(deleteTrainingButton, Const.colorAccent)
        for event in contentsMap.keys {
            let weight = contentsMap[event]![Const.firebaseFieldWeight]!
            let reps = contentsMap[event]![Const.firebaseFieldReps]!
            let addPickerView = createPickerView(self.verticalStackView, event)
            let addStackView = Utils.createAddStackViewTraining(self.verticalStackView, event, weight, reps, addPickerView)
            verticalStackView.addArrangedSubview(addStackView)
        }
    }
    
    @IBAction func handleDeleteTrainingButton(_ sender: Any) {
        let dialog = UIAlertController(title: Const.confirm,
                                       message: "\(self.date)\(Const.confirmData)",
                                       preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: Const.delete, style: .default, handler: { (_) in
            SVProgressHUD.show()
            if let user = Auth.auth().currentUser {
                let date = "\(Const.year)-\(self.date.replacingOccurrences(of: "/", with: "-"))"
                self.db.collection("\(Const.firebaseCollectionTraining)_\(user.uid)").document(date).delete() { err in
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
        }
        
        SVProgressHUD.show()
        if let user = Auth.auth().currentUser {
            let date = "\(Const.year)-\(self.date.replacingOccurrences(of: "/", with: "-"))"
            let trainingDic = [
                Const.firebaseFieldContents: contentMap,
                Const.firebaseFieldCreatedAt: FieldValue.serverTimestamp(),
            ] as [String : Any]
            db.collection("\(Const.firebaseCollectionTraining)_\(user.uid)").document(date).setData(trainingDic) { err in
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
        let addPickerView = createPickerView(self.verticalStackView, Const.dropListTraining[0])
        let addStackView = Utils.createAddStackViewTraining(self.verticalStackView, Const.dropListTraining[0],  "", "", addPickerView)
        verticalStackView.addArrangedSubview(addStackView)
    }
    
    func createPickerView(_ verticalStackView: UIStackView, _ event: String) -> UIPickerView {
        let addPickerView: UIPickerView = UIPickerView()
        addPickerView.tag = verticalStackView.subviews.count + 1
        addPickerView.delegate = self
        addPickerView.dataSource = self
        addPickerView.selectRow(Const.dropListTraining.firstIndex(of: event)!, inComponent: 0, animated: false)
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
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
}
