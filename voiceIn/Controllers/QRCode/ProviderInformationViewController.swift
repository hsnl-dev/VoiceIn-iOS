import UIKit
import Alamofire
import SwiftyJSON

class ProviderInformationViewController: UIViewController {
    var qrCodeUuid: String!
    let headers = Network.generateHeader(isTokenNeeded: true)
    let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var profile: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let getInformationApiRoute = API_END_POINT + "/providers/" + qrCodeUuid

        /**
        GET: Get the user's information.
        **/
        Alamofire
            .request(.GET, getInformationApiRoute, headers: headers)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    let jsonResponse = JSON(JSON_RESPONSE)
                    debugPrint(jsonResponse)
                    self.userName.text = jsonResponse["name"].stringValue
                    self.company.text = jsonResponse["company"].stringValue
                    self.profile.text = jsonResponse["profile"].stringValue
                    self.location.text = jsonResponse["location"].stringValue

                    let getImageApiRoute = API_END_POINT + "/avatars/" + jsonResponse["avatarId"].stringValue
                    Alamofire
                        .request(.GET, getImageApiRoute, headers: self.headers, parameters: ["size": "small"])
                        .responseData {
                            response in
                            if response.data != nil {
                                self.userAvatar.image = UIImage(data: response.data!)
                            }
                    }
                case .Failure(let error):
                    self.createAlertView("抱歉!", body: "網路或伺服器錯誤，請稍候再嘗試", buttonValue: "確認")
                    debugPrint(error)
                }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createAlertView(title: String!, body: String!, buttonValue: String!) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonValue, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func addNewContact(sender: UIButton!) {
        let userUuid = userDefaultData.stringForKey("userUuid")!
        let addNewContactApiRoute = API_END_POINT + "/accounts/" + userUuid + "/contacts/" + qrCodeUuid
        let parameters = [
            "isEnable": true,
            "chargeType": 1,
            "availableStartTime": "00:00",
            "availableEndTime": "00:00",
            "nickName": ""
        ]
        /**
        POST: Add new contact.
        **/
        Alamofire
            .request(.POST, addNewContactApiRoute, parameters: parameters, encoding: .JSON, headers: headers)
            .validate()
            .response { request, response, data, error in
                if error == nil {
                    //MARK: error is nil, nothing happened! All is well :)
                    let mainTabController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainTabViewController") as! UITabBarController

                    self.presentViewController(mainTabController, animated: true, completion: nil)
                } else {
                    print(error)
                }
        }
    }

}
