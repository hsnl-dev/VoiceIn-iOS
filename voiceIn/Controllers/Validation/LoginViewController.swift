import UIKit
import Material
import Alamofire
import SwiftyJSON
import PhoneNumberKit

class LoginViewController: UIViewController, TextFieldDelegate {
    
    var json: JSON?
    
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
    
    func enableButton() {
        self.sendValidationCodeButton.enabled = true
        self.sendValidationCodeButton.setTitle("發送認證碼", forState: .Normal)
    }
    
    @IBAction func sendValidationCodeClicked(sender: UIButton!) {
        print("Sending Validation Code..." + phoneNumberField.text!)
        
        if (phoneNumberField.text! == "") {
            self.createAlertView("小提醒", body: "請輸入手機號碼喔!", buttonValue: "確認")
            return
        }
        
        self.sendValidationCodeButton.enabled = false
        self.sendValidationCodeButton.setTitle("10秒後可再發送", forState: .Disabled)
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "enableButton", userInfo: nil, repeats: false)
        
        let headers = Network.generateHeader(isTokenNeeded: false)
        var parameters: [String: String!] = [String: String!]()
        
        do {
            let phoneNumber = try PhoneNumber(rawNumber: "+886" + phoneNumberField.text!)
            print(phoneNumber.toE164())
            parameters = [
                "phoneNumber": phoneNumber.toE164()
            ]
            
            Alamofire.request(.POST, API_END_POINT + "/accounts/validations", parameters: parameters, encoding: .JSON, headers: headers)
                .responseJSON {
                    response in
                    switch response.result {
                    case .Success(let JSON_DATA):
                        self.json = JSON(JSON_DATA)
                        self.performSegueWithIdentifier("sendValidationCodeSegue", sender: nil)
                        UserPref.setUserPref("phoneNumber", value: phoneNumber.toE164())
                    case .Failure(let error):
                        print("Request failed with error: \(error)")
                    }
            }

        }
        catch {
            print("Generic parser error")
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
    
    private func createAlertView(title: String!, body: String!, buttonValue: String!) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonValue, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
