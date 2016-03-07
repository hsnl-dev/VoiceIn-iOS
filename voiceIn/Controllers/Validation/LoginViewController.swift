import UIKit
import Material
import Alamofire
import SwiftyJSON
import PhoneNumberKit

class LoginViewController: UIViewController, TextFieldDelegate {
    
    var json: JSON?
    let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
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
        phoneNumberField.titleLabelColor = MaterialColor.grey.darken2
        phoneNumberField.titleLabelActiveColor = MaterialColor.grey.darken2
        phoneNumberField.backgroundColor = UIColor.clearColor()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func sendValidationCodeClicked(sender: UIButton!) {
        print("Sending Validation Code..." + phoneNumberField.text!)
        
        let headers = Network.generateHeader(isTokenNeeded: false)
        var parameters: [String: String!] = [String: String!]()
        
        do {
            let phoneNumber = try PhoneNumber(rawNumber: "+886" + phoneNumberField.text!)
            print(phoneNumber.toE164())
            parameters = [
                "phoneNumber": phoneNumber.toE164()
            ]
        }
        catch {
            print("Generic parser error")
        }
        
        Alamofire.request(.POST, API_END_POINT + "/accounts/validations", parameters: parameters, encoding: .JSON, headers: headers)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_DATA):
                    self.json = JSON(JSON_DATA)
                    self.performSegueWithIdentifier("sendValidationCodeSegue", sender: nil)
                    self.userDefaultData.setValue("+886988779570", forKey: "phoneNumber")
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sendValidationCodeSegue" {
            let destinationController = segue.destinationViewController as! ValidationCodeViewController
            destinationController.userUuid = self.json!["userUuid"].stringValue
            
        }
    }
    
    @IBAction func unwindToLoginPage(segue:UIStoryboardSegue) {
        //MARK: Exit the validation code input page and go back to phone input page.
        //Do something here ...
    }
}
