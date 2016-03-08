import UIKit
import Alamofire
import SwiftyJSON

class ProviderInformationViewController: UIViewController {
    var qrCodeUuid: String!
    let headers = Network.generateHeader(isTokenNeeded: true)
    let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet var tableView: UITableView!
    private var userInformation: [String: String?] = [String: String?]()
    private var row: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let getInformationApiRoute = API_END_POINT + "/providers/" + qrCodeUuid
        debugPrint(getInformationApiRoute)
        
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
                    self.userInformation["userName"] = jsonResponse["name"].stringValue
                    self.userInformation["company"] = jsonResponse["company"].stringValue
                    self.userInformation["profile"] = jsonResponse["profile"].stringValue
                    self.userInformation["location"] = jsonResponse["location"].stringValue
                    
                    let getImageApiRoute = API_END_POINT + "/avatars/" + jsonResponse["avatarId"].stringValue
                    
                    // MARK: Retrieve the image
                    Alamofire
                        .request(.GET, getImageApiRoute, headers: self.headers, parameters: ["size": "mid"])
                        .responseData {
                            response in
                            if response.data != nil {
                                self.userAvatar.image = UIImage(data: response.data!)
                            }
                    }

                    self.row = 4
                    self.tableView.reloadData()
                    
                case .Failure(let error):
                    self.createAlertView("抱歉!", body: "網路或伺服器錯誤，請稍候再嘗試", buttonValue: "確認")
                    debugPrint(error)
                }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return row
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! ContactDetailTableViewCell

        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = "姓名"
            cell.valueLabel.text = userInformation["userName"]!
        case 1:
            cell.fieldLabel.text = "公司"
            cell.valueLabel.text = userInformation["company"] != nil ? userInformation["company"]! as String! : "未設定"
        case 2:
            cell.fieldLabel.text = "位置"
            cell.valueLabel.text = userInformation["location"] != nil ? userInformation["location"]! as String! : "未設定"
        case 3:
            cell.fieldLabel.text = "關於"
            cell.valueLabel.text = userInformation["profile"] != nil ? userInformation["profile"]! as String! : "未設定"
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }
        
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
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
                    debugPrint(error)
                }
        }
    }

}
