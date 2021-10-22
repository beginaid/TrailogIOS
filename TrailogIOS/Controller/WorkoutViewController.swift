import UIKit
import Firebase
import SVProgressHUD

class WorkoutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    let db = Firestore.firestore()
    var listener: ListenerRegistration?
    var dateArray: [String] = []
    var contentsMap = [String: [String: [String: String]]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.isHidden = true
        self.noDataLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let docRef = Firestore.firestore().collection("workouts_\(uid)")
            listener = docRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: "エラーが発生しました")
                    print(error)
                    return
                }
                self.dateArray = []
                self.contentsMap = [String: [String: [String: String]]]()
                self.tableView.reloadData()
                for document in querySnapshot!.documents {
                    let yearMonthDay = document.documentID
                    let month = yearMonthDay.components(separatedBy: "-")[1]
                    let day = yearMonthDay.components(separatedBy: "-")[2]
                    let monthDay = "\(month)/\(day)"
                    self.dateArray.append(monthDay)
                    self.contentsMap[monthDay] = (document.data()["contents"] as! [String : [String : String]])
                }
                if self.dateArray.count > 0 {
                    self.tableView.isHidden = false
                    self.noDataLabel.isHidden = true
                    self.tableView.reloadData()
                } else {
                    self.noDataLabel.isHidden = false
                    self.tableView.isHidden = true
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener?.remove()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetViewController = self.storyboard!.instantiateViewController(withIdentifier: "EditWorkout") as! EditWorkoutViewController
        targetViewController.date = self.dateArray[indexPath.row]
        targetViewController.contentsMap = self.contentsMap[self.dateArray[indexPath.row]]!
        self.present(targetViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive,
                                        title: "削除") { (action, view, completionHandler) in
            self.showAlert(deleteIndexPath: indexPath)
            completionHandler(true)
        }
        action.backgroundColor = UIColor(named: "AccentColor")
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    func showAlert(deleteIndexPath indexPath: IndexPath) {
        let dialog = UIAlertController(title: "確認",
                                       message: "\(dateArray[indexPath.row])のデータを\n削除しますか？",
                                       preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "削除", style: .default, handler: { (_) in
            SVProgressHUD.show()
            if let user = Auth.auth().currentUser {
                let uid = user.uid
                let date = "2021-" + self.dateArray[indexPath.row].replacingOccurrences(of: "/", with: "-")
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var eventArray: [String] = []
        var minutesArray: [String] = []
        var maxBpmArray: [String] = []
        var avgBpmArray: [String] = []
        for event in self.contentsMap[dateArray[indexPath.row]]!.keys.sorted() {
            eventArray.append(event)
            minutesArray.append(contentsMap[dateArray[indexPath.row]]![event]!["時間"]!)
            maxBpmArray.append(contentsMap[dateArray[indexPath.row]]![event]!["最大心拍"]!)
            avgBpmArray.append(contentsMap[dateArray[indexPath.row]]![event]!["平均心拍"]!)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
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
        dateLabel.text = dateArray[indexPath.row]
        
        stackView.axis = .vertical
        stackView.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor, constant: 10.0).isActive = true
        stackView.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor, constant: -10.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10.0).isActive = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            addStackView.axis = .horizontal
            addStackView.alignment = .fill
            addStackView.distribution = .equalSpacing
            addStackView.translatesAutoresizingMaskIntoConstraints = false
            addStackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            stackView.addArrangedSubview(addStackView)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateArray.count
    }
    
}
