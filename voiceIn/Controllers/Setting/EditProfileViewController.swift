import UIKit
import Eureka
import Material
import Alamofire
import SwiftyJSON
import ALCameraViewController
import SwiftOverlays
import ReachabilitySwift
import Haneke

class EditProfileViewController: FormViewController {
    let headers = Network.generateHeader(isTokenNeeded: true)
    
    @IBOutlet weak var refreshButton: UIButton!
    // MARK: The API Information.
    
    private var navigationBarView: NavigationBar = NavigationBar()
    private var isUserSelectPhoto: Bool! = false
    private var isSaveClicked = false
    let hnkImageCache = Shared.imageCache
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInformation()
        
        // MARK: Update the wrong position.
        //        var frame: CGRect = view.frame;
        //        frame.origin.y = 60;
        //        frame.origin.x = 0;
        //        self.tableView?.frame = frame
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
                    
                    self.refreshButton.hidden = true
                    self.removeAllOverlays()
                    self.prepareInputForm(jsonResponse)
                case .Failure(let error):
                    self.refreshButton.hidden = false
                    self.refreshButton.alpha = 0.8
                    self.removeAllOverlays()
                    AlertBox.createAlertView(self, title: "您似乎沒有連上網路", body: "請開啟網路，再點更新按鈕以更新。", buttonValue: "確認")
                    debugPrint(error)
                }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        var reachability: Reachability
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            debugPrint("Unable to create Reachability")
            return
        }
        
        self.view.bringSubviewToFront(self.refreshButton)
        
        if reachability.isReachable() != true {
            debugPrint("Network is not connected!")
            self.refreshButton.hidden = false
            self.refreshButton.alpha = 0.8
        } else {
            self.refreshButton.hidden = true
        }
    }
    
    func prepareInputForm(userInformation: SwiftyJSON.JSON) {
        debugPrint(userInformation)
        self.refreshButton.hidden = true
        
        form.removeAll()
        form +++
            Section("")
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
                    row.value = dateFormatter.dateFromString(userInformation["availableStartTime"].stringValue)
            }
            
            <<< TimeInlineRow(){
                $0.title = "結束時間"
                $0.value = NSDate()
                $0.tag = "availableEndTime"
                }.cellSetup {
                    cell, row in
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    row.value = dateFormatter.dateFromString(userInformation["availableEndTime"].stringValue)
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
    
    @IBAction func saveButtonClicked(sender: UIButton!) {
        if isSaveClicked == true {
            return
        } else {
            isSaveClicked = true
        }
        
        
        let formValues = form.values()
        let userUuid = UserPref.getUserPrefByKey("userUuid")
        let updateInformationApiRoute = API_END_POINT + "/accounts/" + userUuid
        let uploadAvatarApiRoute = API_END_POINT + "/accounts/" + userUuid + "/avatar"
        let dateFormatter = NSDateFormatter()
        
        var avatarImageFile = UIImageJPEGRepresentation(UIImage(named: "user")!, 0.6)
        
        if let avarFormValue = formValues["avatar"] {
            avatarImageFile = UIImageJPEGRepresentation((avarFormValue as? UIImage)!, 0.6)
        }
        
        dateFormatter.dateFormat = "HH:mm"
        
        if !isFormValuesValid(formValues) {
            // Form is not valid
            isSaveClicked = false
            return
        }
        
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
            "deviceKey": UserPref.getUserPrefByKey("deviceKey") as String! == nil ? "simulator" : UserPref.getUserPrefByKey("deviceKey") as String!
        ]
        
        debugPrint("PUT: " + updateInformationApiRoute)
        let text = "儲存中\n成功將自動關閉此視窗"
        
        if let superview = self.view.superview {
            SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: text)
        }
        
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
                    
                    if self.isUserSelectPhoto == false {
                        if let superview = self.view.superview {
                            SwiftOverlays.removeAllOverlaysFromView(superview)
                        }
                        
                        self.isSaveClicked = false
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
        }
        
        /**
        POST: Upload avatar image.
        **/
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
                                print("photo success")
                                self.hnkImageCache.set(value: UIImage(data: avatarImageFile!)!, key: "profilePhoto")
                                
                                if let superview = self.view.superview {
                                    SwiftOverlays.removeAllOverlaysFromView(superview)
                                }
                                
                                self.isSaveClicked = false
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }
                        case .Failure(let encodingError):
                            if let superview = self.view.superview {
                                SwiftOverlays.removeAllOverlaysFromView(superview)
                            }
                            
                            self.isSaveClicked = false
                            AlertBox.createAlertView(self ,title: "抱歉!", body: "出現網路或伺服器錯誤", buttonValue: "確認")
                            print(encodingError)
                        }
                })
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
    
    @IBAction func refreshTheView(sender: UIButton!) {
        print("refresh the view")
        getUserInformation()
    }
}
