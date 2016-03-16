import UIKit
import Material

class QrCodeListCell: MaterialTableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var qrCodeImage: UIImageView!
    var qrCodeUuid: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
