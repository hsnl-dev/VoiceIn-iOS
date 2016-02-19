import UIKit
import Material

class LoginViewController: UIViewController, TextFieldDelegate {
    // TextField.
    @IBOutlet weak var phoneNumberField: TextField!
    
    // Button
    @IBOutlet weak var sendValidationCodeButton: RaisedButton!
    @IBOutlet var backgroundImageView:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        prepareField()
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        sendValidationCodeButton.setTitle("發送驗證碼", forState: .Normal)
        sendValidationCodeButton.titleLabel!.font = RobotoFont.mediumWithSize(15)
    }
    
    private func prepareView() {
        view.backgroundColor = MaterialColor.white
    }
    
    /// Prepares the name TextField.
    private func prepareField() {
        phoneNumberField.clearButtonMode = .WhileEditing
        phoneNumberField.placeholder = "您的電話號碼"

        phoneNumberField.font = RobotoFont.regularWithSize(20)
        phoneNumberField.textColor = MaterialColor.grey.darken3
        phoneNumberField.borderStyle = UITextBorderStyle.None;
        phoneNumberField.titleLabel = UILabel()
        phoneNumberField.titleLabel!.font = RobotoFont.mediumWithSize(12)
        phoneNumberField.titleLabelColor = MaterialColor.grey.base
        phoneNumberField.titleLabelActiveColor = MaterialColor.grey.darken2
        phoneNumberField.backgroundColor = UIColor.clearColor()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func unwindToLoginPage(segue:UIStoryboardSegue) {
        
    }
}
