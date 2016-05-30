import UIKit
import Alamofire
import SwiftyJSON

class SettingViewController: UITableViewController {
    @IBOutlet var credit: UILabel? = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        let getInformationApiRoute = API_END_POINT + "/accounts/" + UserPref.getUserPrefByKey("userUuid")
        let headers = Network.generateHeader(isTokenNeeded: true)
        let parameters = [
            "field" : "credit"
        ]
        Alamofire
            .request(.GET, getInformationApiRoute, headers: headers, parameters: parameters, encoding: .URLEncodedInURL)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    let jsonResponse = JSON(JSON_RESPONSE)
                    debugPrint(jsonResponse)
                    self.credit?.text = jsonResponse["credit"].stringValue
                
                case .Failure(let error):
                    self.credit?.text = "讀取失敗"
                    debugPrint(error)
                }
        }

        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "setTutorialOnSegue" {
            UserPref()
                    .setUserPref("isFirstLogin", value: "true")
                    .setUserPref("isFirstFetch", value: true)
        }
    }
    
    @IBAction func logout(sender: UIButton) {
        UserPref()
            .setUserPref("isFirstLogin", value: "true")
            .setUserPref("isFirstFetch", value: true)
            .setUserPref("userUuid", value: nil)
            .setUserPref("token", value: nil)
        let rootController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        UIApplication.sharedApplication().keyWindow?.rootViewController = rootController
    }
    
    @IBAction func closeTheEditProfileModal(segue: UIStoryboardSegue) {
        
    }
    
}
