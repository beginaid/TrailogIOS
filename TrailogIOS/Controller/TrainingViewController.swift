import UIKit
import Firebase
import SVProgressHUD

class TrainingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        self.tableView.isHidden = true
        self.noDataLabel.isHidden = true
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            let docRef = Firestore.firestore().collection("trainings_\(uid)")
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
                    let date = Utils.getDateFromYearMonthDay(document.documentID)
                    self.dateArray.append(date)
                    self.contentsMap[date] = (document.data()["contents"] as! [String : [String : String]])
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
        let targetViewController = self.storyboard!.instantiateViewController(withIdentifier: "EditTraining") as! EditTrainingViewController
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
                let date = Utils.getYearMonthDayFromDate(self.dateArray[indexPath.row], "2021")
                self.db.collection("trainings_\(user.uid)").document(date).delete() { err in
                    if let err = err {
                        SVProgressHUD.dismiss()
                        SVProgressHUD.showError(withStatus: "エラーが発生しました")
                        print(err)
                    } else {
                        SVProgressHUD.dismiss()
                        SVProgressHUD.showSuccess(withStatus: "筋トレ削除完了")
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
        var weightArray: [String] = []
        var repsArray: [String] = []
        for event in self.contentsMap[dateArray[indexPath.row]]!.keys.sorted() {
            eventArray.append(event)
            weightArray.append(contentsMap[dateArray[indexPath.row]]![event]!["負荷"]!)
            repsArray.append(contentsMap[dateArray[indexPath.row]]![event]!["回数"]!)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrainingCell", for: indexPath)
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        Utils.setTrainingCell(cell, indexPath.row, dateArray, eventArray, weightArray, repsArray)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dateArray.count
    }
    
}


