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
            let docRef = Firestore.firestore().collection("\(Const.firebaseCollectionWorkout)_\(user.uid)")
            listener = docRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    Utils.showError(Const.errorDefault)
                    print(error)
                    return
                }
                self.dateArray = []
                self.contentsMap = [String: [String: [String: String]]]()
                self.tableView.reloadData()
                for document in querySnapshot!.documents {
                    let date = Utils.getDateFromYearMonthDay(document.documentID)
                    self.dateArray.append(date)
                    self.contentsMap[date] = (document.data()[Const.firebaseFieldContents] as! [String : [String : String]])
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
        let targetViewController = self.storyboard!.instantiateViewController(withIdentifier: Const.identifierEditWorkout) as! EditWorkoutViewController
        targetViewController.date = self.dateArray[indexPath.row]
        targetViewController.contentsMap = self.contentsMap[self.dateArray[indexPath.row]]!
        self.present(targetViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return Utils.createAlertConfiguration(self, indexPath, self.dateArray[indexPath.row], Const.firebaseCollectionWorkout)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.identifierWorkoutCell, for: indexPath)
        Utils.setWorkoutCell(cell, indexPath, self.dateArray, contentsMap)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateArray.count
    }
    
}
