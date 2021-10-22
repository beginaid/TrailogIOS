import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellData(_ cellData: CellData) {
        iconImageView.image = UIImage(named: cellData.imagePath)?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = .white
        iconLabel.text = cellData.eventName
        iconLabel.textColor = .white
    }
    
}
