import UIKit

class AddViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var cellDataArray: [CellData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "LightBlack")
        
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        let cellDataAddWeight = CellData(imagePath: "weight", eventName: "体重追加")
        let cellDataAddTraining = CellData(imagePath: "training", eventName: "筋トレ追加")
        let cellDataAddWorkout = CellData(imagePath: "workout", eventName: "有酸素追加")
        cellDataArray.append(cellDataAddWeight)
        cellDataArray.append(cellDataAddTraining)
        cellDataArray.append(cellDataAddWorkout)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor(named: "LightBlack")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        cell.backgroundColor = UIColor(named: "LightBlack")
        cell.setCellData(cellDataArray[indexPath.row])
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let targetViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddWeight")
            self.present(targetViewController, animated: true, completion: nil)
        } else if indexPath.row == 1{
            let targetViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddTraining")
            self.present(targetViewController, animated: true, completion: nil)
        } else if indexPath.row == 2{
            let targetViewController = self.storyboard!.instantiateViewController(withIdentifier: "AddWorkout")
            self.present(targetViewController, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
