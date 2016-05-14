import UIKit
import Material
import Alamofire
import SwiftyJSON
import PhoneNumberKit
import BWWalkthrough

class LoginViewController: UIViewController, TextFieldDelegate, BWWalkthroughViewControllerDelegate {
    
    var json: JSON?
    
    // MARK: TextField.
    @IBOutlet weak var phoneNumberField: TextField!
    
    // MARK: Button
    @IBOutlet weak var sendValidationCodeButton: RaisedButton!
    @IBOutlet var backgroundImageView: UIImageView!
    var isWalkThrough: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showWalkthrough()
        prepareView()
        prepareField()
        blurBackgroundImage()
        
        //MARK: Set up send validation button.
        sendValidationCodeButton.setTitle("發送驗證碼", forState: .Normal)
        sendValidationCodeButton.titleLabel!.font = RobotoFont.mediumWithSize(15)
        sendValidationCodeButton.backgroundColor = MaterialColor.blue.base
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if isWalkThrough == false {
            showWalkthrough()
            isWalkThrough = true
        }
    }
    
    func showWalkthrough() {
        debugPrint("showWalkThrough")
        // Get view controllers and build the walkthrough
        let stb = UIStoryboard(name: "Introduction", bundle: nil)
        let walkthrough = stb.instantiateViewControllerWithIdentifier("walk") as! BWWalkthroughViewController
        let page_zero = stb.instantiateViewControllerWithIdentifier("walk0")
        let page_one = stb.instantiateViewControllerWithIdentifier("walk1")
        let page_two = stb.instantiateViewControllerWithIdentifier("walk2")
        let page_three = stb.instantiateViewControllerWithIdentifier("walk3")
        let page_four = stb.instantiateViewControllerWithIdentifier("walk4")

        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.addViewController(page_one)
        walkthrough.addViewController(page_two)
        walkthrough.addViewController(page_three)
        walkthrough.addViewController(page_four)
        walkthrough.addViewController(page_zero)
        
        self.presentViewController(walkthrough, animated: true, completion: nil)
    }
    
    
    // MARK: - Walkthrough delegate -
    
    func walkthroughPageDidChange(pageNumber: Int) {
        print("Current Page \(pageNumber)")
    }
    
    @IBAction func walkthroughCloseButtonPressed(segue: UIStoryboardSegue) {
        print("walkthroughCloseButtonPressed:")
        self.dismissViewControllerAnimated(true, completion: nil)
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
        phoneNumberField.delegate = self
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
            AlertBox.createAlertView(self, title: "小提醒", body: "請輸入手機號碼喔!", buttonValue: "確認")
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
                        AlertBox.createAlertView(self, title: "小提醒", body: "請記得開啟網路喔!", buttonValue: "確認")
                        self.enableButton()
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
}
