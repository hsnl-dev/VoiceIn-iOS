import UIKit
import Alamofire
import SwiftyJSON
import SwiftOverlays

class ProviderInformationViewController: UIViewController {
    var qrCodeUuid: String!
    var nickName: String! = ""
    let headers = Network.generateHeader(isTokenNeeded: true)
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet var tableView: UITableView!
    private var userInformation: [String: String?] = [String: String?]()
    private var row: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: self-sizing cell setting.
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 70;

    }
    
    override func viewDidAppear(animated: Bool) {
        let getInformationApiRoute = API_END_POINT + "/providers/" + qrCodeUuid
        debugPrint(getInformationApiRoute)
        
        // MARK - GET: Get the user's information.
        SwiftOverlays.showCenteredWaitOverlayWithText(self.view, text: "讀取聯絡人中，請稍候...")
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
                    
                    debugPrint("avatar id{0}", jsonResponse["avatarId"].stringValue)
                    // MARK: Retrieve the image
                    
                    if jsonResponse["avatarId"].stringValue != "" {
                        Alamofire
                            .request(.GET, getImageApiRoute, headers: self.headers, parameters: ["size": "mid"])
                            .responseData {
                                response in
                                // MARK: TODO Error handling
                                if response.data != nil {
                                    self.userAvatar.image = UIImage(data: response.data!)
                                }
                        }
                    }
                    
                    self.row = 4
                    self.tableView.reloadData()
                    
                case .Failure(let error):
                    debugPrint(error)
                    let statusCode: Int! = response.response?.statusCode
                    
                    if statusCode != nil {
                        switch statusCode {
                        case 404:
                            AlertBox.createAlertView(self, title: "抱歉!", body: "此為無效的 QRCode.", buttonValue: "確認")
                        default:
                            AlertBox.createAlertView(self, title: "抱歉!", body: "伺服器錯誤或查無此人。", buttonValue: "確認")
                        }
                    }
                }
                
                if let superview = self.view {
                    SwiftOverlays.removeAllOverlaysFromView(superview)
                }
        }
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return row
        case 1:
            return 1
        default:
            return row
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! ContactDetailTableViewCell
            switch indexPath.row {
            case 0:
                cell.fieldLabel.text = "姓名"
                cell.valueLabel.text = userInformation["userName"]!
            case 1:
                cell.fieldLabel.text = "公司"
                cell.valueLabel.text = userInformation["company"]! as String! != "" ? userInformation["company"]! as String! : "未設定"
            case 2:
                cell.fieldLabel.text = "位置"
                cell.valueLabel.text = userInformation["location"]! as String! != "" ? userInformation["location"]! as String! : "未設定"
            case 3:
                cell.fieldLabel.text = "關於"
                cell.valueLabel.text = userInformation["profile"]! as String! != "" ? userInformation["profile"]! as String! : "未設定"
            default:
                cell.fieldLabel.text = ""
                cell.valueLabel.text = ""
            }
            
            cell.backgroundColor = UIColor.clearColor()
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("nickNameCell", forIndexPath: indexPath) as!
            ProviderNickNameCell
            cell.nickNameTextField.addTarget(self, action: #selector(ProviderInformationViewController.textIsChanged(_:)), forControlEvents: UIControlEvents.EditingChanged)
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("nickNameCell", forIndexPath: indexPath) as!
            ProviderNickNameCell
            return cell
        }
    }
    
    func textIsChanged(nickNameField :UITextField) {
        debugPrint(nickNameField.text)
        nickName = nickNameField.text
    }
    
    @IBAction func addNewContact(sender: UIButton!) {
        UserPref.setUserPref("isFirstFetch", value: true)
        let userUuid = UserPref.getUserPrefByKey("userUuid")
        let addNewContactApiRoute = API_END_POINT + "/accounts/" + userUuid + "/contacts/" + qrCodeUuid
        
        let parameters = [
            "isEnable": true,
            "chargeType": 1,
            "availableStartTime": "00:00",
            "availableEndTime": "23:59",
            "nickName": nickName as String
        ]
        
        debugPrint(parameters)
        SwiftOverlays.showCenteredWaitOverlayWithText(self.view, text: "新增聯絡人中，請稍候...")
        /**
        POST: Add new contact.
        **/
        Alamofire
            .request(.POST, addNewContactApiRoute, parameters: parameters as? [String : AnyObject], encoding: .JSON, headers: headers)
            .validate()
            .response { request, response, data, error in
                if error == nil {
                    //MARK: error is nil, nothing happened! All is well :)
                    let mainTabController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainTabViewController") as! UITabBarController
                    
                    self.presentViewController(mainTabController, animated: true, completion: nil)
                } else {
                    debugPrint(error)
                    debugPrint(response?.statusCode)
                    let statusCode: Int! = (response?.statusCode)!
                    switch statusCode {
                    case 404:
                        AlertBox.createAlertView(self, title: "抱歉!", body: "此為無效的 QRCode.", buttonValue: "確認")
                    case 304:
                        AlertBox.createAlertView(self, title: "抱歉!", body: "您已擁有此聯絡人", buttonValue: "確認")
                    default:
                        AlertBox.createAlertView(self, title: "抱歉!", body: "網路或伺服器錯誤，請稍候再嘗試", buttonValue: "確認")
                    }
                }
                
                if let superview = self.view {
                    SwiftOverlays.removeAllOverlaysFromView(superview)
                }
        }
    }
    
}
