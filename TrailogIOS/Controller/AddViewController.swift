import UIKit

class AddViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var cellDataArray: [CellData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = Const.rgbLightBlack
        tableView.register(UINib(nibName: Const.identifierTableViewCell, bundle: nil), forCellReuseIdentifier: Const.identifierCell)
        cellDataArray.append(CellData(imagePath: Const.addWeightEN, eventName: Const.addWeightJP))
        cellDataArray.append(CellData(imagePath: Const.addTrainingEN, eventName: Const.addTrainingJP))
        cellDataArray.append(CellData(imagePath: Const.addWorkoutEN, eventName: Const.addWorkoutJP))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return Utils.createTableViewCell(tableView, indexPath, cellDataArray[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Const.heightAddMenuCell)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            Utils.present(Const.identifierAddWeight, self)
        } else if indexPath.row == 1{
            Utils.present(Const.identifierAddTraining, self)
        } else if indexPath.row == 2{
            Utils.present(Const.identifierAddWorkout, self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
