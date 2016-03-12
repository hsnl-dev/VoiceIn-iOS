/**
 Cell class in ContactDetailView
 **/
import UIKit
import Material
import Alamofire

class SwitchCell: MaterialTableViewCell {
    @IBOutlet var switchButton: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsetsZero //or UIEdgeInsetsMake(top, left, bottom, right)
        self.separatorInset = UIEdgeInsetsZero //if you also want to adjust separatorInset
    }
}
