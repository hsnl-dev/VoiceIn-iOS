import UIKit
import Material

class ProviderNickNameCell: MaterialTableViewCell {
    @IBOutlet var nickNameTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsetsZero //or UIEdgeInsetsMake(top, left, bottom, right)
        self.separatorInset = UIEdgeInsetsZero //if you also want to adjust separatorInset
    }
}
