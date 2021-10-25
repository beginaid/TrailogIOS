import UIKit
import SVProgressHUD
import Firebase

class Utils: NSObject {
    
    static let db = Firestore.firestore()
    
    static func setEventTextField(_ eventTextField: UITextField, _ pickerView: UIPickerView, _ placeholder: String) {
        eventTextField.inputView = pickerView
        eventTextField.text = placeholder
    }
    
    static func showError(_ displayWords: String) {
        SVProgressHUD.showError(withStatus: displayWords)
    }

    static func showSuccess(_ displayWords: String) {
        SVProgressHUD.showSuccess(withStatus: displayWords)
    }
    
    static func createAlertConfiguration(_ viewController: UIViewController, _ indexPath: IndexPath, _ date: String, _ event: String) -> UISwipeActionsConfiguration {
        let action = UIContextualAction(style: .destructive,
                                        title: "削除") { (action, view, completionHandler) in
            self.showAlert(viewController, indexPath, date, event)
            completionHandler(true)
        }
        action.backgroundColor = UIColor(named: "AccentColor")
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }

    static func showAlert(_ viewController: UIViewController, _ indexPath: IndexPath, _ date: String, _ event: String) {
        let dialog = UIAlertController(title: "確認",
                                       message: "\(date)のデータを\n削除しますか？",
                                       preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "削除", style: .default, handler: { (_) in
            SVProgressHUD.show()
            if let user = Auth.auth().currentUser {
                let uid = user.uid
                let date = Utils.getYearMonthDayFromDate(date)
                self.db.collection("\(event)_\(uid)").document(date).delete() { err in
                    if let err = err {
                        SVProgressHUD.dismiss()
                        Utils.showError(Const.errorDefault)
                        print(err)
                    } else {
                        SVProgressHUD.dismiss()
                        Utils.showSuccess(Const.successDelete)
                        viewController.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }))
        dialog.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        viewController.present(dialog, animated: true, completion: nil)
    }
    
    static func createTableViewCell(_ tableView: UITableView, _ indexPath: IndexPath, _ data: CellData) -> TableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.identifierCell, for: indexPath) as! TableViewCell
        cell.backgroundColor = UIColor(named: "LightBlack")
        cell.setCellData(data)
        return cell
    }
    
    static func present(_ identifier: String, _ viewController: UIViewController){
        let targetViewController = viewController.storyboard!.instantiateViewController(withIdentifier: identifier)
        viewController.present(targetViewController, animated: true, completion: nil)
    }
    
    static func updateRootWindow(_ storyboard: UIStoryboard, _ identifier: String) {
        let mainViewController = storyboard.instantiateViewController(withIdentifier: identifier)
        let keywindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        keywindow!.rootViewController = mainViewController
    }
    
    static func getYearMonthDayFromDate(_ date: String) -> String {
        return "\(Const.year)-\(date.replacingOccurrences(of: "/", with: "-"))"
    }
    
    static func getDateFromYearMonthDay(_ yearMonthDay: String) -> String {
        let month = yearMonthDay.components(separatedBy: "-")[1]
        let day = yearMonthDay.components(separatedBy: "-")[2]
        return "\(month)/\(day)"
    }
    
    static func setTabBarStyle(_ tabBar: UITabBar){
        tabBar.tintColor = UIColor(named: "AccentColor")
        tabBar.barTintColor = .black
    }
    
    static func getDateFromDatePicker(_ datePicker: UIDatePicker) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return dateFormatter.string(from: datePicker.date)
    }
    
    static func setModalView(_ modalView: UIView) {
        modalView.backgroundColor = .white
        modalView.layer.cornerRadius = 15
    }
    
    static func setButtonStyle(_ button: UIButton, _ color: String) {
        button.backgroundColor = UIColor(named: color)
        button.layer.cornerRadius = 3.0
    }
    
    static func setHyperTextStyle(_ textView: UITextView) {
        let baseString = textView.text!
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attributedString = NSMutableAttributedString(string: baseString,
                                                         attributes: [.paragraphStyle: paragraph])
        attributedString.addAttribute(.font,
                                      value: UIFont.systemFont(ofSize: 17),
                                      range: NSString(string: baseString).range(of: baseString))
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSString(string: baseString).range(of: baseString))
        attributedString.addAttribute(.link,
                                      value: "Signup",
                                      range: NSString(string: baseString).range(of: baseString))
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.attributedText = attributedString
    }
    
    static func setTrainingCell(_ cell: UITableViewCell, _ indexPath: IndexPath, _ dateArray: [String], _ contentsMap: [String: [String: [String: String]]]) {
        var eventArray: [String] = []
        var weightArray: [String] = []
        var repsArray: [String] = []
        for event in contentsMap[dateArray[indexPath.row]]!.keys.sorted() {
            eventArray.append(event)
            weightArray.append(contentsMap[dateArray[indexPath.row]]![event]!["負荷"]!)
            repsArray.append(contentsMap[dateArray[indexPath.row]]![event]!["回数"]!)
        }
        let stackView = createVerticalStackView(cell, dateArray[indexPath.row])
        for i in 0..<eventArray.count {
            let addStackView: UIStackView = UIStackView()
            let eventLabel = UILabel()
            let weightLabel = UILabel()
            let repsLabel = UILabel()
            addStackView.addArrangedSubview(eventLabel)
            addStackView.addArrangedSubview(weightLabel)
            addStackView.addArrangedSubview(repsLabel)
            
            eventLabel.text = "\(eventArray[i])"
            weightLabel.text = "\(weightArray[i]) kg"
            repsLabel.text = "\(repsArray[i]) 回"
            eventLabel.textAlignment = NSTextAlignment.left
            weightLabel.textAlignment = NSTextAlignment.right
            repsLabel.textAlignment = NSTextAlignment.right
            eventLabel.widthAnchor.constraint(equalTo: addStackView.widthAnchor, multiplier: 0.5).isActive = true
            weightLabel.widthAnchor.constraint(equalTo: addStackView.widthAnchor, multiplier: 0.25).isActive = true
            repsLabel.widthAnchor.constraint(equalTo: addStackView.widthAnchor, multiplier: 0.25).isActive = true
            setHorizontalStackView(addStackView)
            stackView.addArrangedSubview(addStackView)
        }
    }

    static func setWorkoutCell(_ cell: UITableViewCell, _ indexPath: IndexPath, _ dateArray: [String], _ contentsMap: [String: [String: [String: String]]]) {
        var eventArray: [String] = []
        var minutesArray: [String] = []
        var maxBpmArray: [String] = []
        var avgBpmArray: [String] = []
        for event in contentsMap[dateArray[indexPath.row]]!.keys.sorted() {
            eventArray.append(event)
            minutesArray.append(contentsMap[dateArray[indexPath.row]]![event]!["時間"]!)
            maxBpmArray.append(contentsMap[dateArray[indexPath.row]]![event]!["最大心拍"]!)
            avgBpmArray.append(contentsMap[dateArray[indexPath.row]]![event]!["平均心拍"]!)
        }
        let stackView = createVerticalStackView(cell, dateArray[indexPath.row])
        for i in 0..<eventArray.count {
            let addStackView: UIStackView = UIStackView()
            let eventLabel = UILabel()
            let minutesLabel = UILabel()
            let maxBpmLabel = UILabel()
            let avgBpmLabel = UILabel()
            addStackView.addArrangedSubview(eventLabel)
            addStackView.addArrangedSubview(minutesLabel)
            addStackView.addArrangedSubview(maxBpmLabel)
            addStackView.addArrangedSubview(avgBpmLabel)
            
            eventLabel.text = "\(eventArray[i])"
            minutesLabel.text = "\(minutesArray[i]) min"
            maxBpmLabel.text = "Max \(maxBpmArray[i]) bpm"
            avgBpmLabel.text = "Avg \(avgBpmArray[i]) bpm"
            eventLabel.textAlignment = NSTextAlignment.left
            minutesLabel.textAlignment = NSTextAlignment.right
            maxBpmLabel.textAlignment = NSTextAlignment.right
            avgBpmLabel.textAlignment = NSTextAlignment.right
            eventLabel.widthAnchor.constraint(equalTo: addStackView.widthAnchor, multiplier: 0.2).isActive = true
            minutesLabel.widthAnchor.constraint(equalTo: addStackView.widthAnchor, multiplier: 0.2).isActive = true
            maxBpmLabel.widthAnchor.constraint(equalTo: addStackView.widthAnchor, multiplier: 0.3).isActive = true
            avgBpmLabel.widthAnchor.constraint(equalTo: addStackView.widthAnchor, multiplier: 0.3).isActive = true
            setHorizontalStackView(addStackView)
            stackView.addArrangedSubview(addStackView)
        }
    }
    
    static func setHorizontalStackView(_ addStackView: UIStackView) {
        addStackView.axis = .horizontal
        addStackView.alignment = .fill
        addStackView.distribution = .equalSpacing
        addStackView.spacing = 4
        addStackView.translatesAutoresizingMaskIntoConstraints = false
        addStackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    static func createVerticalStackView(_ cell: UITableViewCell, _ date: String) -> UIStackView {
        let dateLabel = UILabel()
        let stackView: UIStackView = UIStackView()
        cell.contentView.addSubview(dateLabel)
        cell.contentView.addSubview(stackView)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor, constant: 10.0).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor, constant: -10.0).isActive = true
        dateLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10.0).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -10.0).isActive = true
        dateLabel.numberOfLines = 0
        dateLabel.font = UIFont.systemFont(ofSize: 25)
        dateLabel.text = date
        
        stackView.axis = .vertical
        stackView.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor, constant: 10.0).isActive = true
        stackView.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor, constant: -10.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10.0).isActive = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    static func createAddStackView(_ verticalStackView: UIStackView, _ eventPlaceholder: String,  _ weightPlaceholder: String,  _ repsPlaceholder: String, _ addPickerView: UIPickerView) -> UIStackView {
        let addStackView: UIStackView = UIStackView()
        let addEventTextField = PickerTextField ()
        let addWeightTextField = DoneTextField()
        let addRepsTextField = DoneTextField()
        addStackView.addArrangedSubview(addEventTextField)
        addStackView.addArrangedSubview(addWeightTextField)
        addStackView.addArrangedSubview(addRepsTextField)
        
        let attributes = [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 16)]
        addEventTextField.attributedPlaceholder = NSAttributedString(string: "種目", attributes: attributes)
        addEventTextField.borderStyle = .roundedRect
        setEventTextField(addEventTextField, addPickerView, eventPlaceholder)
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
        
        setHorizontalStackView(addStackView)
        return addStackView
    }
        
}
