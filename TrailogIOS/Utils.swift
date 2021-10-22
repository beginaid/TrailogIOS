import UIKit

class Utils: NSObject {
    
    static func getYearMonthDayFromDate(_ date: String, _ year: String) -> String {
        return "\(year)-\(date.replacingOccurrences(of: "/", with: "-"))"
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
    
    static func setButtonStyle(_ button: UIButton) {
        button.backgroundColor = UIColor(named: "AccentColor")
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
    
    static func setTrainingCell(_ cell: UITableViewCell, _ index: Int, _ dateArray: [String], _ eventArray: [String], _ weightArray: [String], _ repsArray: [String]) {
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
        dateLabel.text = dateArray[index]
        
        stackView.axis = .vertical
        stackView.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor, constant: 10.0).isActive = true
        stackView.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor, constant: -10.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10.0).isActive = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            addStackView.axis = .horizontal
            addStackView.alignment = .fill
            addStackView.distribution = .equalSpacing
            addStackView.translatesAutoresizingMaskIntoConstraints = false
            addStackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            stackView.addArrangedSubview(addStackView)
        }
    }
}
