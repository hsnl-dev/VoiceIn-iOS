/**
 Cell class in ContactDetailView
**/
import UIKit
import Material

class SwitchCell: MaterialTableViewCell {
    @IBOutlet var switchButton: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsetsZero //or UIEdgeInsetsMake(top, left, bottom, right)
        self.separatorInset = UIEdgeInsetsZero //if you also want to adjust separatorInset
        switchButton!.addTarget(self, action: Selector("switchIsChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func switchIsChanged(switchButton: UISwitch) {
        if switchButton.on {
            debugPrint("Switch On")
        } else {
            debugPrint("Switch Off")
        }
    }
    
}
