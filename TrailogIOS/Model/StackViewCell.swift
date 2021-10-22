import UIKit
class StackViewCell: UIStackView {
    let eventLabel = UILabel()
    let weightLabel = UILabel()
    let repsLabel = UILabel()
    init() {
        super.init(frame: CGRect())
        addSubview(eventLabel)
        addSubview(weightLabel)
        addSubview(repsLabel)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
