import UIKit

class PickerTextField: DoneTextField{
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
}
