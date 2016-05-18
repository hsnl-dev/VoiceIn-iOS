import UIKit
import Eureka
import Material
import Alamofire
import SwiftyJSON
import ALCameraViewController
import SwiftOverlays
import Haneke

class UserInformationViewController: FormViewController {
    // MARK: The API Information.
    let headers = Network.generateHeader(isTokenNeeded: true)

    private var navigationBarView: NavigationBar = NavigationBar()
    private var isUserSelectPhoto: Bool! = false
    let hnkImageCache = Shared.imageCache

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationBar()
        getUserInformation()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBarView.frame = CGRectMake(0, 0, view.bounds.width, MaterialDevice.landscape ? .iPad == MaterialDevice.type ? 64 : navigationBarView.intrinsicContentSize().height : 64)
    }

    
    func getUserInformation() {
        /**
         GET: Get the user's information.
         **/
        let text = "讀取中..."
        self.showWaitOverlayWithText(text)
        
        let getInformationApiRoute = API_END_POINT + "/accounts/" + UserPref.getUserPrefByKey("userUuid")
        Alamofire
            .request(.GET, getInformationApiRoute, headers: headers)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    let jsonResponse = JSON(JSON_RESPONSE)
                    
                    self.removeAllOverlays()
                    self.prepareInputForm(jsonResponse)
                case .Failure(let error):
                    self.removeAllOverlays()
                    AlertBox.createAlertView(self ,title: "您似乎沒有連上網路", body: "請開啟網路，再點更新按鈕以更新。", buttonValue: "確認")
                    debugPrint(error)
                }
        }
        
    }
    
    func prepareInputForm(userInformation: SwiftyJSON.JSON) {
        form.removeAll()
        form +++
            Section(header: "", footer: "")
            +++ Section("")
            +++ Section(header: "基本資料", footer: "* 記號表示為必填")
            <<< SelectImageRow(){
                $0.title = "您的大頭貼"
                $0.cell.height = {
                    let height: CGFloat = 70.0
                    return height
                }
                $0.tag = "avatar"
                $0.value = UIImage(named: "add-user")
                }.onCellSelection({ (cell, row) -> () in
                    let cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true)
                    { image, asset in
                        SelectImageRow.defaultCellUpdate = { cell, row in
                            cell.accessoryView?.layer.cornerRadius = 32
                            cell.accessoryView?.frame = CGRectMake(0, 0, 64, 64)
                        }
                        
                        if image != nil {
                            row.value = image
                            row.updateCell()
                        }
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    self.isUserSelectPhoto = true
                    self.presentViewController(cameraViewController, animated: true, completion: nil)
                }).cellSetup {
                    cell, row in
                    print("image cell setup!")
            }
            
            <<< EmailRow() {
                $0.title = "您的姓名*:"
                $0.placeholder = ""
                $0.tag = "userName"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
                    row.value = userInformation["userName"].stringValue
            }
            
            <<< EmailRow() {
                $0.title = "您的職稱:"
                $0.placeholder = ""
                $0.tag = "jobTitle"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
                    row.value = userInformation["jobTitle"].stringValue
            }
            
            <<< EmailRow() {
                $0.title = "所屬公司:"
                $0.placeholder = ""
                $0.tag = "company"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
                    row.value = userInformation["company"].stringValue
            }
            
            <<< EmailRow() {
                $0.title = "您的信箱"
                $0.value = ""
                $0.tag = "email"
                }.cellSetup{
                    cell, row in
                    row.value = userInformation["email"].stringValue
            }
            
            
            <<< EmailRow() {
                $0.title = "位置:"
                $0.placeholder = "台北, 台灣"
                $0.tag = "location"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
                    row.value = userInformation["location"].stringValue
            }
            
            +++ Section(header: "方便通話時段", footer: "您可以隨時設定您方便的通話同段")
            
            <<< TimeInlineRow(){
                $0.title = "開始時間"
                $0.value = NSDate()
                $0.tag = "availableStartTime"
                }.cellSetup {
                    cell, row in
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    row.value = dateFormatter.dateFromString(userInformation["availableStartTime"].stringValue == "" ? "12:00" : userInformation["availableStartTime"].stringValue)
            }
            
            <<< TimeInlineRow(){
                $0.title = "結束時間"
                $0.value = NSDate()
                $0.tag = "availableEndTime"
                }.cellSetup {
                    cell, row in
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    row.value = dateFormatter.dateFromString(userInformation["availableEndTime"].stringValue == "" ? "17:00" : userInformation["availableEndTime"].stringValue)
            }
            
            
            +++ Section("關於您")
            
            <<< TextAreaRow() {
                $0.placeholder = "介紹您自己，讓大家更能夠瞭解您。"
                $0.tag = "profile"
                }.cellSetup {
                    cell, row in
                    row.value = userInformation["profile"].stringValue
        }
        
        let getImageApiRoute = API_END_POINT + "/avatars/" + userInformation["profilePhotoId"].stringValue
        
        Alamofire
            .request(.GET, getImageApiRoute, headers: self.headers, parameters: ["size": "small"])
            .responseData {
                response in
                SelectImageRow.defaultCellUpdate = { cell, row in
                    cell.accessoryView?.layer.cornerRadius = 32
                    cell.accessoryView?.frame = CGRectMake(0, 0, 64, 64)
                }
                
                if response.data != nil && response.response?.statusCode == 200 {
                    self.removeAllOverlays()
                    self.form.rowByTag("avatar")?.baseValue = UIImage(data: response.data!)
                    self.form.rowByTag("avatar")?.updateCell()
                } else {
                    self.removeAllOverlays()
                }
        }
    }
    
    func prepareNavigationBar() {
        // Title label.
        let titleLabel: UILabel = UILabel()
        titleLabel.text = "您的個人資料"
        titleLabel.textAlignment = .Center
        titleLabel.textColor = MaterialColor.white
        titleLabel.font = RobotoFont.regularWithSize(17)
        
        // Search button.
        let image = UIImage(named: "ic_save_white")
        let saveButton: FlatButton = FlatButton()
        saveButton.pulseColor = MaterialColor.white
        saveButton.pulseScale = false
        saveButton.setImage(image, forState: .Normal)
        saveButton.setImage(image, forState: .Highlighted)
        saveButton.addTarget(self, action: #selector(UserInformationViewController.saveButtonClicked(_:)), forControlEvents: .TouchUpInside)

        view.addSubview(navigationBarView)

        let item: UINavigationItem = UINavigationItem()
        
        navigationBarView.statusBarStyle = .LightContent
        navigationBarView.backgroundColor = MaterialColor.blue.base
        item.titleLabel = titleLabel
        item.rightControls = [saveButton]
        navigationBarView.pushNavigationItem(item, animated: true)

    }
    
    func saveButtonClicked(sender: UIButton!) {
        // MARK - Form is not valid
        let formValues = form.values()
        if !isFormValuesValid(formValues) {
            return
        }
        
        let contactTableView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainTabViewController") as! UITabBarController
        let avatarImageFile = UIImageJPEGRepresentation((formValues["avatar"] as? UIImage)!, 1)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let parameters = [
            "userName": formValues["userName"] as? String != nil ? formValues["userName"] as? String : "",
            "profile": formValues["profile"] as? String != nil ? formValues["profile"] as? String : "",
            "location": formValues["location"] as? String != nil ? formValues["location"] as? String : "",
            "company": formValues["company"] as? String != nil ? formValues["company"] as? String : "",
            "jobTitle": formValues["jobTitle"] as? String != nil ? formValues["jobTitle"] as? String : "",
            "email": formValues["email"] as? String != nil ? formValues["email"] as? String : "",
            "availableStartTime": dateFormatter.stringFromDate((formValues["availableStartTime"] as? NSDate)!),
            "availableEndTime": dateFormatter.stringFromDate((formValues["availableEndTime"] as? NSDate)!),
            "phoneNumber": UserPref.getUserPrefByKey("phoneNumber") as String!,
            "deviceOS": "ios",
            "deviceKey": UserPref.getUserPrefByKey("deviceKey") as String! != nil ? UserPref.getUserPrefByKey("deviceKey") as String! : "simulator"
        ]
        
        let userUuid = UserPref.getUserPrefByKey("userUuid")
        
        // MARK: API Route
        let updateInformationApiRoute = API_END_POINT + "/accounts/" + userUuid
        let uploadAvatarApiRoute = API_END_POINT + "/accounts/" + userUuid + "/avatar"
        let generateQrcodeApiRoute = API_END_POINT + "/accounts/" + userUuid + "/qrcode"
        
        print(dateFormatter.stringFromDate((formValues["availableStartTime"] as? NSDate)!))
        print("PUT: " + updateInformationApiRoute)
        let text = "儲存中..."
        self.showWaitOverlayWithText(text)
        
        
        // MARK: PUT: Update the user's information.
        Alamofire
            .request(.PUT, updateInformationApiRoute, parameters: parameters, encoding: .JSON, headers: headers)
            .validate()
            .response { request, response, data, error in
                if error == nil && !self.isUserSelectPhoto {
                    //MARK: error is nil, nothing happened! All is well :)
                    UserPref.setUserPref("userName", value: parameters["userName"])
                    UserPref.setUserPref("profile", value: parameters["profile"])
                    UserPref.setUserPref("location", value: parameters["location"])
                    UserPref.setUserPref("jobTitle", value: parameters["jobTitle"])
                    UserPref.setUserPref("email", value: parameters["email"])
                    UserPref.setUserPref("company", value: parameters["company"])
                    UserPref.setUserPref("token", value: UserPref.getUserPrefByKey("tempToken"))                    
                } else if error != nil {
                    print(error)
                    AlertBox.createAlertView(self ,title: "抱歉!", body: "網路或伺服器錯誤，請稍候再嘗試", buttonValue: "確認")
                    self.removeAllOverlays()
                }
        }
        

        // MARK: POST: Upload avatar image.
        if isUserSelectPhoto == true {
            Alamofire
                .upload(.POST, uploadAvatarApiRoute, headers: headers,
                    multipartFormData:
                    { multipartFormData in
                        multipartFormData.appendBodyPart(data: avatarImageFile!, name: "photo", mimeType: "image/jpeg")
                    },
                    encodingCompletion: {
                        encodingResult in
                        switch encodingResult {
                        case .Success(let upload, _, _):
                            upload.response { response in
                                print("上傳成功。")
                                self.hnkImageCache.set(value: UIImage(data: avatarImageFile!)!, key: "profilePhoto")
                            }
                        case .Failure(let encodingError):
                            AlertBox.createAlertView(self ,title: "抱歉!", body: "網路或伺服器錯誤，請稍候再嘗試", buttonValue: "確認")
                            print(encodingError)
                            return
                        }
                        
                        self.removeAllOverlays()
                })
        }
        
        // MARK - POST: Generate QRCode
        Alamofire
            .request(.POST, generateQrcodeApiRoute, headers: headers)
            .response {
                request, response, data, error in
                if error == nil {
                    print("Generate QR Code Successfully!")
                    self.presentViewController(contactTableView, animated: true, completion: nil)
                } else {
                    AlertBox.createAlertView(self ,title: "抱歉!", body: "網路或伺服器錯誤，請稍候再嘗試", buttonValue: "確認")
                }
                self.removeAllOverlays()
            }
    }
    
    /**
     MARK: Function to validate if there are any bad values.
     @param: formValues
     @return: true if valid, false if unvalid.
     **/
    private func isFormValuesValid(formValues: [String: Any?]!) -> Bool {
        let userName = formValues["userName"] as? String
        
        if  userName == nil || userName?.trim() == "" {
            AlertBox.createAlertView(self ,title: "小提醒", body: "請輸入您的大名喔", buttonValue: "確認")
            return false
        }
        
        let availableStartTime: NSDate! = formValues["availableStartTime"] as? NSDate
        let availableEndTime: NSDate! = formValues["availableEndTime"] as? NSDate
        
        if (availableStartTime.isGreaterThanDate(availableEndTime)) {
            AlertBox.createAlertView(self ,title: "小提醒", body: "你所選定的時間區間不合理喔", buttonValue: "確認")
            return false
        }
        
        return true
    }
    
}
