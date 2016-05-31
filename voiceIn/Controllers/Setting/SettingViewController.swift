import UIKit
import Alamofire
import SwiftyJSON
import Haneke

class SettingViewController: UITableViewController {
    @IBOutlet var credit: UILabel? = UILabel()
    let hnkImageCache = Shared.imageCache
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
       refreshCredit(UIButton())
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "setTutorialOnSegue" {
            UserPref()
                    .setUserPref("isFirstLogin", value: "true")
                    .setUserPref("isFirstFetch", value: true)
        }
    }
    
    @IBAction func refreshCredit(sender: UIButton) {
        self.credit?.text = "讀取中"
        
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
    
    @IBAction func logout(sender: UIButton) {
        UserPref.removeAll()
        UserPref()
            .setUserPref("isFirstLogin", value: "true")
            .setUserPref("isFirstFetch", value: true)
            .setUserPref("userUuid", value: nil)
            .setUserPref("token", value: nil)
        hnkImageCache.removeAll()
        
        let rootController = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        UIApplication.sharedApplication().keyWindow?.rootViewController = rootController
    }
    
    @IBAction func closeTheEditProfileModal(segue: UIStoryboardSegue) {
        
    }
    
}
