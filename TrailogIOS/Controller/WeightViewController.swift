import UIKit
import Charts
import Firebase
import SVProgressHUD

class WeightViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var noDataLabel: UILabel!
    let db = Firestore.firestore()
    var listener: ListenerRegistration?
    var dateArray: [String] = []
    var weightArray: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChart.delegate = self
        self.noDataLabel.isHidden = true
        self.lineChart.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SVProgressHUD.show()
        if let user = Auth.auth().currentUser {
            let docRef = Firestore.firestore().collection("\(Const.firebaseCollectionWeight)_\(user.uid)")
            listener = docRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    Utils.showError(Const.errorDefault)
                    print(error)
                    return
                }
                self.dateArray = []
                self.weightArray = []
                for document in querySnapshot!.documents {
                    let date = Utils.getDateFromYearMonthDay(document.documentID)
                    self.dateArray.append(date)
                    self.weightArray.append((document.data()[Const.weightEN] as! NSString).doubleValue)
                }
                if self.dateArray.count > 0 {
                    self.lineChart.isHidden = false
                    self.noDataLabel.isHidden = true
                    self.setLineGraph()
                } else {
                    self.noDataLabel.isHidden = false
                    self.lineChart.isHidden = true
                }
                SVProgressHUD.dismiss()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let dataSet = lineChart.data?.dataSets[highlight.dataSetIndex] {
            let sliceIndex = dataSet.entryIndex(entry: entry)
            let date = self.dateArray[sliceIndex]
            let weight = self.weightArray[sliceIndex]
            let editDeleteWeightViewController = (self.storyboard?.instantiateViewController(withIdentifier: Const.identifierEditDeleteWeight)) as! editDeleteWeightViewController
            editDeleteWeightViewController.date = date
            editDeleteWeightViewController.weight = String(weight)
            self.present(editDeleteWeightViewController, animated: true, completion: nil)
        }
    }
    
    func setLineGraph() {
        var entry = [ChartDataEntry]()
        for (i, d) in self.weightArray.enumerated(){
            entry.append(ChartDataEntry(x: Double(i), y: d))
        }
        let dataset = LineChartDataSet(entries: entry, label: Const.weightEN)
        dataset.drawValuesEnabled = false
        dataset.lineWidth = 2
        dataset.setColor(UIColor(named: Const.colorAccent)!)
        dataset.circleRadius = 6
        dataset.drawCircleHoleEnabled = false
        dataset.highlightColor = .clear
        dataset.setCircleColor(UIColor(named: Const.colorAccent)!)
        
        lineChart.xAxis.labelPosition = .bottom
        lineChart.rightAxis.enabled = false
        lineChart.legend.enabled = false
        lineChart.xAxis.labelFont = Const.systemFont
        lineChart.leftAxis.labelFont = Const.systemFont
        lineChart.xAxis.labelCount = self.dateArray.count
        lineChart.xAxis.granularityEnabled = true
        lineChart.xAxis.granularity = 1.0
        lineChart.xAxis.labelRotationAngle = -60.0
        lineChart.xAxis.labelRotatedHeight = 50
        lineChart.leftAxis.axisMaximum = self.weightArray.max()! + 1
        lineChart.leftAxis.axisMinimum = self.weightArray.min()! - 1
        lineChart.xAxis.valueFormatter = ChartFormatter(date: self.dateArray)
        lineChart.data = LineChartData(dataSet: dataset)
    }
    
    class ChartFormatter: NSObject, IAxisValueFormatter {
        var xAxisValues: [String] = []
        init(date: [String]) {
            super.init()
            self.xAxisValues = date
        }        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let index = Int(value)
            if (xAxisValues.count <= index || value < 0){
                return ""
            } else {
                return xAxisValues[index]
            }
        }
        
    }
    
}
