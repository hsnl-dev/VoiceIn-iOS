import UIKit
import Eureka
import Material
import Alamofire
import SwiftyJSON
import EZLoadingActivity
import ALCameraViewController

class SettingViewController: FormViewController {
    let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    let headers = Network.generateHeader(isTokenNeeded: true)
    
    @IBOutlet weak var refreshButton: UIButton!
    // MARK: The API Information.
    
    private var navigationBarView: NavigationBarView = NavigationBarView()
    private var isUserSelectPhoto: Bool! = false

    override func viewDidLoad() {
        super.viewDidLoad()
        EZLoadingActivity.show("讀取中...", disableUI: true)
        let getInformationApiRoute = API_END_POINT + "/accounts/" + userDefaultData.stringForKey("userUuid")!
        /**
        GET: Get the user's information.
        **/
        Alamofire
            .request(.GET, getInformationApiRoute, headers: headers)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    EZLoadingActivity.hide()
                    let jsonResponse = JSON(JSON_RESPONSE)
                    self.prepareInputForm(jsonResponse)
                case .Failure(let error):
                    EZLoadingActivity.hide()
                    self.createAlertView("您似乎沒有連上網路", body: "請開啟網路，再點更新按鈕以更新。", buttonValue: "確認")
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
        
        // MARK: Update to the original position.
        var frame: CGRect = view.frame;
        frame.origin.y = 0;
        frame.origin.x = 0;
        self.tableView?.frame = frame
    }
    
    func prepareInputForm(userInformation: JSON) {
        debugPrint(userInformation)
        
        SelectImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 0
            cell.accessoryView?.frame = CGRectMake(0, 0, 64, 64)
        }
        
        form.removeAll()
        form +++
            Section(header: "基本資料", footer: "* 記號表示為必填")
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
                        dateFormatter.dateFormat = "H:mm:"
                        row.value = dateFormatter.dateFromString(userInformation["availableStartTime"].stringValue)
            }
            
            <<< TimeInlineRow(){
                $0.title = "結束時間"
                $0.value = NSDate()
                $0.tag = "availableEndTime"
                }.cellSetup {
                    cell, row in
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "H:mm:"
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
                if response.data != nil {
                    SelectImageRow.defaultCellUpdate = { cell, row in
                        cell.accessoryView?.layer.cornerRadius = 32
                        cell.accessoryView?.frame = CGRectMake(0, 0, 64, 64)
                    }
                    self.form.rowByTag("avatar")?.baseValue = UIImage(data: response.data!)
                    self.form.rowByTag("avatar")?.updateCell()
                }

        }
        
        // MARK: Update the wrong position.
        var frame: CGRect = view.frame;
        frame.origin.y = 60;
        frame.origin.x = 0;
        self.tableView?.frame = frame
    }
    
    @IBAction func saveButtonClicked(sender: UIButton!) {
        let formValues = form.values()
        let avatarImageFile = UIImageJPEGRepresentation((formValues["avatar"] as? UIImage)!, 1)
        let updateInformationApiRoute = API_END_POINT + "/accounts/" + userDefaultData.stringForKey("userUuid")!
        let uploadAvatarApiRoute = API_END_POINT + "/accounts/" + userDefaultData.stringForKey("userUuid")! + "/avatar"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "H:mm"
        
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
        
        debugPrint("PUT: " + updateInformationApiRoute)
        
        /**
        PUT: Update the user's information.
        **/
        Alamofire
            .request(.PUT, updateInformationApiRoute, parameters: parameters, encoding: .JSON, headers: headers)
            .validate()
            .response { request, response, data, error in
                if error == nil && !self.isUserSelectPhoto {
                    //MARK: error is nil, nothing happened! All is well :)
                    debugPrint("Success!")
                    self.createAlertView("恭喜!", body: "儲存成功", buttonValue: "確認")
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
                                self.createAlertView("恭喜!", body: "儲存成功", buttonValue: "確認")
                                return
                            }
                        case .Failure(let encodingError):
                            print(encodingError)
                            return
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
    
    @IBAction func refreshTheView(sender: UIButton!) {
        print("refresh the view")
        self.viewDidLoad()
        self.viewDidAppear(true)
    }
}
