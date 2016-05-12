import UIKit
import Material
import Alamofire
import SwiftyJSON

class ValidationCodeViewController: UIViewController, UITextFieldDelegate {
    
    private var navigationBarView: NavigationBar = NavigationBar()

    @IBOutlet weak var validationCodeField: UITextField!
    @IBOutlet weak var checkValidationButton: RaisedButton!
    @IBOutlet weak var backButton: FabButton!
    @IBOutlet var backgroundImageView: UIImageView!
    
    // MARK: UserUuid genrated from server.
    var userUuid: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareButton()
        prepareField()
        blurBackgroundImage()
        
        print(self.userUuid)
        
        UserPref.setUserPref("userUuid", value: self.userUuid)
    }
    
    private func prepareView() {
        view.backgroundColor = MaterialColor.white
        
        //MARK: Set the status bar to light.
        navigationBarView.statusBarStyle = .LightContent
    }
    
    private func blurBackgroundImage() {
        //MARK: Set up blur image background.
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
    }
    
    private func prepareButton() {
        checkValidationButton.setTitle("確認", forState: .Normal)
        checkValidationButton.titleLabel!.font = RobotoFont.mediumWithSize(15)
        checkValidationButton.backgroundColor = MaterialColor.blueGrey.base
        
        let backImage: UIImage? = UIImage(named: "ic_arrow_back_white")
        self.backButton.setImage(backImage, forState: .Normal)
        self.backButton.setImage(backImage, forState: .Highlighted)
        self.backButton.tintColor = UIColor.whiteColor()
        self.backButton.backgroundColor = MaterialColor.teal.darken2
    }
    
    private func prepareField() {
        //MARK: Do any additional setup after loading the view.
        validationCodeField.clearButtonMode = .WhileEditing
        validationCodeField.placeholder = "認證碼"
        validationCodeField.font = RobotoFont.regularWithSize(20)
        validationCodeField.textColor = MaterialColor.black
        
        //MARK: Set textField Padding
        let validationFieldLeftView: UIView = UIView(frame: CGRectMake(0, 0, 10, 10))
        validationCodeField.leftViewMode = .Always
        validationCodeField.leftView = validationFieldLeftView
        validationCodeField.delegate = self
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func createAlertView(title: String!, body: String!, buttonValue: String!) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonValue, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func validationButtonClicked(sender: UIButton!) {
        print("Check if the validation code is correct or not.")
        
        let headers = Network.generateHeader(isTokenNeeded: false)
        let parameters = [
            "userUuid": UserPref.getUserPrefByKey("userUuid"),
            "code": validationCodeField.text as String!
        ]
        
        print(parameters)
        
        Alamofire.request(.POST, API_END_POINT + "/accounts/tokens", parameters: parameters, encoding: .JSON, headers: headers)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_DATA):
                    /**
                    API Calling Successfully!
                    **/
                    let json = JSON(JSON_DATA)
                    let token = json["token"]
                    
                    if token != nil {
                        
                        // MARK: User input the right code, save the token and show information view.
                        UserPref.setUserPref("token", value: json["token"].stringValue)
                        
                        let userInformationController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("UserInformationStoryboard") as! UserInformationViewController
                        self.presentViewController(userInformationController, animated: true, completion: nil)
                    } else {
                         //MARK: User input the wrong code, pop out the alert window.
                        self.createAlertView("抱歉", body: "您的認證碼輸入錯誤，請再確認一次", buttonValue: "確認")
                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    self.createAlertView("抱歉", body: "網路或認證碼錯誤。", buttonValue: "確認")
                }
        }
    }
    
}
