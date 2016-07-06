import UIKit
import Alamofire
import SwiftyJSON
import SwiftOverlays
import Haneke

class SettingViewController: UITableViewController {
    @IBOutlet var credit: UILabel? = UILabel()
    @IBOutlet var pointLabel: UILabel? = UILabel()

    let hnkImageCache = Shared.imageCache
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
       refreshCredit(UIButton())
    }
    
    @IBAction func refreshCredit(sender: UIButton) {
        self.credit?.text = "讀取中"
        
        let text = "重新整理中..."
        
        if let superview = self.view.superview {
            SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: text)
        }
        
        let getInformationApiRoute = API_END_POINT + "/accounts/" + UserPref.getUserPrefByKey("userUuid")
        let headers = Network.generateHeader(isTokenNeeded: true)
        let parameters = [
            "field" : "credit"
        ]
        Alamofire
            .request(.GET, getInformationApiRoute, headers: headers, parameters: parameters, encoding: .URLEncodedInURL)
            .responseJSON {
                response in
                sender.setTitle("重新整理", forState: .Normal)
                
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    let jsonResponse = JSON(JSON_RESPONSE)
                    debugPrint(jsonResponse)
                    
                    if jsonResponse["credit"].stringValue == "-1" {
                        self.credit?.text = "0.0.1"
                        self.pointLabel?.text = "版本號碼"
                    } else {
                        self.pointLabel?.text = "剩餘秒數"
                        self.credit?.text = jsonResponse["credit"].stringValue
                    }
                    
                case .Failure(let error):
                    self.credit?.text = "讀取失敗"
                    debugPrint(error)
                }
                
                if let superview = self.view.superview {
                    SwiftOverlays.removeAllOverlaysFromView(superview)
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 2 && row == 1 {
            debugPrint("2-1 cell clicked.")
            UserPref()
                .setUserPref("isFirstLogin", value: "true")
                .setUserPref("isFirstFetch", value: true)
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.switchToRootViewController()
        }
    }
    
    @IBAction func closeTheEditProfileModal(segue: UIStoryboardSegue) {
        
    }
    
}
