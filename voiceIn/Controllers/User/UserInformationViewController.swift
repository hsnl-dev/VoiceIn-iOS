import UIKit
import Eureka
import Material
import Alamofire
import SwiftyJSON
import ALCameraViewController
import SwiftOverlays

class UserInformationViewController: FormViewController {
    let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    // MARK: The API Information.
    
    private var navigationBarView: NavigationBarView = NavigationBarView()
    private var isUserSelectPhoto: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareInputForm()
        prepareNavigationBar()
    }
    
    func prepareInputForm() {
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
                    
                    let cameraViewController = ALCameraViewController(croppingEnabled: true, allowsLibraryAccess: true)
                        { (image) -> Void in
                            SelectImageRow.defaultCellUpdate = { cell, row in
                                cell.accessoryView?.layer.cornerRadius = 32
                                cell.accessoryView?.frame = CGRectMake(0, 0, 64, 64)
                            }
                            if image != nil {
                                row.value = image
                                row.updateCell()
                            }
                            self.isUserSelectPhoto = true
                            self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    self.presentViewController(cameraViewController, animated: true, completion: nil)
                })
            
            <<< EmailRow() {
                $0.title = "您的姓名*:"
                $0.placeholder = ""
                $0.tag = "userName"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }
            
            <<< EmailRow() {
                $0.title = "您的職稱:"
                $0.placeholder = ""
                $0.tag = "jobTitle"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }
            
            <<< EmailRow() {
                $0.title = "所屬公司:"
                $0.placeholder = ""
                $0.tag = "company"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }
            
            <<< EmailRow() {
                $0.title = "您的信箱"
                $0.value = ""
                $0.tag = "email"
            }
            
            <<< EmailRow() {
                $0.title = "位置:"
                $0.placeholder = "台北, 台灣"
                $0.tag = "location"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }
            
            +++ Section(header: "方便通話時段", footer: "您可以隨時設定您方便的通話同段")
            
            <<< TimeInlineRow(){
                $0.title = "開始時間"
                $0.value = NSDate()
                $0.tag = "availableStartTime"
            }
            
            <<< TimeInlineRow(){
                $0.title = "結束時間"
                $0.value = NSDate()
                $0.tag = "availableEndTime"
            }
            
            +++ Section("關於您")
            
            <<< TextAreaRow() {
                $0.placeholder = "介紹您自己，讓大家更能夠瞭解您。"
                $0.tag = "profile"
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
        saveButton.addTarget(self, action: "saveButtonClicked:", forControlEvents: .TouchUpInside)
        
        navigationBarView.statusBarStyle = .LightContent
        navigationBarView.backgroundColor = MaterialColor.blue.base
        navigationBarView.titleLabel = titleLabel
        navigationBarView.rightControls = [saveButton]
        
        view.addSubview(navigationBarView)
    }
    
    func saveButtonClicked(sender: UIButton!) {
        let contactTableView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainTabViewController") as! UITabBarController
        let headers = Network.generateHeader(isTokenNeeded: true)
        let formValues = form.values()
        let avatarImageFile = UIImageJPEGRepresentation((formValues["avatar"] as? UIImage)!, 1)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        if !isFormValuesValid(formValues) {
            // Form is not valid
            return
        }
        
        let parameters = [
            "userName": formValues["userName"] as? String != nil ? formValues["userName"] as? String : "",
            "profile": formValues["profile"] as? String != nil ? formValues["profile"] as? String : "",
            "location": formValues["location"] as? String != nil ? formValues["location"] as? String : "",
            "company": formValues["company"] as? String != nil ? formValues["company"] as? String : "",
            "availableStartTime": dateFormatter.stringFromDate((formValues["availableStartTime"] as? NSDate)!),
            "availableEndTime": dateFormatter.stringFromDate((formValues["availableEndTime"] as? NSDate)!),
            "phoneNumber": userDefaultData.stringForKey("phoneNumber") as String!
        ]
        let userUuid = userDefaultData.stringForKey("userUuid")!
        let updateInformationApiRoute = API_END_POINT + "/accounts/" + userUuid
        let uploadAvatarApiRoute = API_END_POINT + "/accounts/" + userUuid + "/avatar"
        let generateQrcodeApiRoute = API_END_POINT + "/accounts/" + userUuid + "/qrcode"
        
        print(dateFormatter.stringFromDate((formValues["availableStartTime"] as? NSDate)!))
        print("PUT: " + updateInformationApiRoute)
        let text = "儲存中..."
        self.showWaitOverlayWithText(text)
        
        /**
        PUT: Update the user's information.
        **/
        Alamofire
            .request(.PUT, updateInformationApiRoute, parameters: parameters, encoding: .JSON, headers: headers)
            .validate()
            .response { request, response, data, error in
                if error == nil && !self.isUserSelectPhoto {
                    //MARK: error is nil, nothing happened! All is well :)
                } else {
                    print(error)
                    self.createAlertView("抱歉!", body: "網路或伺服器錯誤，請稍候再嘗試", buttonValue: "確認")
                    self.removeAllOverlays()
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
                                
                            }
                        case .Failure(let encodingError):
                            self.createAlertView("抱歉!", body: "網路或伺服器錯誤，請稍候再嘗試", buttonValue: "確認")
                            self.removeAllOverlays()
                            print(encodingError)
                        }
                })
        }
        
        /**
        POST: Generate QRCode
        **/
        Alamofire
            .request(.POST, generateQrcodeApiRoute, headers: headers).response {
                request, response, data, error in
                if error == nil {
                    print("Generate QR Code Successfully!")
                    self.removeAllOverlays()
                    self.presentViewController(contactTableView, animated: true, completion: nil)
                } else {
                    self.createAlertView("抱歉!", body: "網路或伺服器錯誤，請稍候再嘗試", buttonValue: "確認")
                    self.removeAllOverlays()
                }
        }
    }
    
    /**
     MARK: Function to validate if there are any bad values.
     @param: formValues
     @return: true if valid, false if unvalid.
     **/
    private func isFormValuesValid(formValues: [String: Any?]!) -> Bool {
        if formValues["userName"] as? String == nil {
            createAlertView("小提醒", body: "請輸入您的大名喔", buttonValue: "確認")
            return false
        }
        
        let availableStartTime: NSDate! = formValues["availableStartTime"] as? NSDate
        let availableEndTime: NSDate! = formValues["availableEndTime"] as? NSDate
        
        if (availableStartTime.isGreaterThanDate(availableEndTime)) {
            createAlertView("小提醒", body: "你所選定的時間區間不合理喔", buttonValue: "確認")
            return false
        }
        
        return true
    }
    
    private func createAlertView(title: String!, body: String!, buttonValue: String!) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonValue, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
