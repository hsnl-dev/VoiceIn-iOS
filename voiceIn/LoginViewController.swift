import UIKit
import Material
import Alamofire

class LoginViewController: UIViewController, TextFieldDelegate {
    
    // MARK: The API Information.
    let API_END_POINT = "https://voicein-web-service.us-west-2.elasticbeanstalk.com/api/v1"
    let headers = [
        "apiKey": "f4c34db9-c4f8-4356-9442-51ece7adca67",
    ]
    
    // MARK: TextField.
    @IBOutlet weak var phoneNumberField: TextField!
    
    // MARK: Button
    @IBOutlet weak var sendValidationCodeButton: RaisedButton!
    @IBOutlet var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        prepareField()
        blurBackgroundImage()
        
        //MARK: Set up send validation button.
        sendValidationCodeButton.setTitle("發送驗證碼", forState: .Normal)
        sendValidationCodeButton.titleLabel!.font = RobotoFont.mediumWithSize(15)
    }
    
    private func blurBackgroundImage() {
        //MARK: Set up blur image background.
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
    }
    
    private func prepareView() {
        view.backgroundColor = MaterialColor.white
    }
    
    // MARK: Prepares the name TextField.
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sendValidationCodeSegue" {
            print("Sending Validation Code..." + phoneNumberField.text!)
            
            let parameters = [
                "phoneNumber": "+886988779570"
            ]
            
//            Alamofire.request(.POST, API_END_POINT + "/accounts/validations", parameters: parameters, encoding: .JSON, headers: headers)
//                .responseJSON {
//                    response in
//                        debugPrint(response)
//                }
            
        }
    }
    
    @IBAction func unwindToLoginPage(segue:UIStoryboardSegue) {
        //MARK: Exit the validation code input page and go back to phone input page.
        //Do something here ...
    }
}
