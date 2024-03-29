import UIKit
import Material
import Alamofire
import Haneke
import SwiftOverlays

class ContactDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var userAvatarImage: UIImageView!
    @IBOutlet var timePickerView: UIView!
    @IBOutlet var availableStartTimeDatePicker: UIDatePicker!
    @IBOutlet var availableEndTimeDatePicker: UIDatePicker!
    
    var userInformation: [String: String?] = [String: String?]()
    let headers = Network.generateHeader(isTokenNeeded: true)
    var searchController: UISearchController = UISearchController()
    
    private lazy var menuView: MenuView = MenuView()
    let spacing: CGFloat = 16
    let diameter: CGFloat = 56
    let height: CGFloat = 36
    
    // MARK - Image Cache
    let hnkImageCache = Shared.imageCache
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: self-sizing cell setting.
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 70;
        
        if userInformation["chargeType"]! == ContactType.Icon.rawValue {
            self.navigationItem.setRightBarButtonItems(nil, animated: true)
        }
        
        prepareView()
        prepareMenuView()
        prepareUserAvatarImage()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.searchController.active = false
    }
    
    func switchIsChanged(switchButton: UISwitch) {
        let contactId: String! = self.userInformation["id"]!
        let updateContactRoute = API_URI + latestVersion + "/accounts/" + contactId + "/contacts/"
        
        if switchButton.on {
            debugPrint("Switch On")
            Alamofire
                .request(.PUT, updateContactRoute, headers: self.headers, parameters: ["isEnable": "False"], encoding: .URLEncodedInURL)
                .response {
                    request, response, data, error in
                    if error == nil {
                        debugPrint(response)
                        self.userInformation["isEnable"] = "true"
                    } else {
                        self.userInformation["isEnable"] = "false"
                    }
            }
            
        } else {
            debugPrint("Switch Off")
            Alamofire
                .request(.PUT, updateContactRoute, headers: self.headers, parameters: ["isEnable": "True"], encoding: .URLEncodedInURL)
                .response {
                    request, response, data, error in
                    if error == nil {
                        debugPrint(response)
                        self.userInformation["isEnable"] = "false"
                    } else {
                        self.userInformation["isEnable"] = "true"
                    }
            }
        }
    }
    
    func AvailableSwitchIsChanged(switchButton: UISwitch) {
        let contactId: String! = self.userInformation["id"]!
        let updateContactRoute = API_URI + latestVersion + "/accounts/" + contactId + "/contacts/"
        
        if switchButton.on {
            debugPrint("Switch On")
            Alamofire
                .request(.PUT, updateContactRoute, headers: self.headers, parameters: ["isHigherPriorityThanGlobal": "True"], encoding: .URLEncodedInURL)
                .response {
                    request, response, data, error in
                    if error == nil {
                        debugPrint(response)
                        self.userInformation["isHigherPriorityThanGlobal"] = "true"
                    } else {
                        self.userInformation["isHigherPriorityThanGlobal"] = "false"
                    }
            }
            
        } else {
            debugPrint("Switch Off")
            Alamofire
                .request(.PUT, updateContactRoute, headers: self.headers, parameters: ["isHigherPriorityThanGlobal": "False"], encoding: .URLEncodedInURL)
                .response {
                    request, response, data, error in
                    if error == nil {
                        debugPrint(response)
                        self.userInformation["isHigherPriorityThanGlobal"] = "false"
                    } else {
                        self.userInformation["isHigherPriorityThanGlobal"] = "true"
                    }
            }
        }
        
    }
    
    @IBAction func pingMessage(sender: UITabBarItem) {
        let messageBox = UIAlertController(title: "傳傳", message: "您可以傳簡短的訊息給對方\n通知中心可以查看紀錄喔", preferredStyle: .Alert)
        
        messageBox.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "請輸入您要說的話。"
        })
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        messageBox.addAction(UIAlertAction(title: "傳送", style: .Default, handler: { (action) -> Void in
            let messageTextField = messageBox.textFields![0] as UITextField
            let content: String! = messageTextField.text!
            let contactId: String! = self.userInformation["id"]!
            let sendMessageRoute = API_URI + latestVersion + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/ping/" + contactId
            
            debugPrint(sendMessageRoute)
            
            if content.trim() == "" {
                AlertBox.createAlertView(self, title: "抱歉", body: "請輸入內容", buttonValue: "好")
                
                if let superview = self.view.superview {
                    SwiftOverlays.removeAllOverlaysFromView(superview)
                }
                
                return
            }
            
            if let superview = self.view.superview {
                SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "傳送中...")
            }
            
            Alamofire
                .request(.POST, sendMessageRoute, headers: self.headers, parameters: ["content": content], encoding: .JSON)
                .response {
                    request, response, data, error in
                    
                    if let superview = self.view.superview {
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                    
                    if response?.statusCode == 200 {
                        AlertBox.createAlertView(self, title: "成功!", body: "已經傳送給對方了。", buttonValue: "好")
                    } else {
                        AlertBox.createAlertView(self, title: "抱歉..", body: "傳送失敗，請再嘗試一次。", buttonValue: "好")
                    }
                }
        }))
        
        messageBox.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        // 4. Present the alert.
        self.presentViewController(messageBox, animated: true, completion: nil)

    }
    
    @IBAction func closeTimePickerView(sender: UIButton!) {
        timePickerView.hidden = true
    }
    
    @IBAction func saveTimePeriod() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let contactId: String! = self.userInformation["id"]!
        let updateContactRoute = API_URI + latestVersion + "/accounts/" + contactId + "/contacts/"
        let availableStartTime: String = dateFormatter.stringFromDate(availableStartTimeDatePicker.date)
        let availableEndTime: String = dateFormatter.stringFromDate(availableEndTimeDatePicker.date)
        
        if let superview = self.view.superview {
            SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "儲存中...")
        }
        
        Alamofire
            .request(.PUT, updateContactRoute, headers: self.headers, parameters: ["availableStartTime": availableStartTime, "availableEndTime": availableEndTime], encoding: .URLEncodedInURL)
            .response {
                request, response, data, error in
                if error == nil {
                    debugPrint(response)
                    self.userInformation["availableStartTime"] = availableStartTime
                    self.userInformation["availableEndTime"] = availableEndTime
                    
                    if let superview = self.view.superview {
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                    
                    AlertBox.createAlertView(self ,title: "恭喜!", body: "儲存成功", buttonValue: "確認")
                    let indexPathStart = NSIndexPath(forRow: 1, inSection: 1)
                    let indexPathEnd = NSIndexPath(forRow: 2, inSection: 1)

                    self.tableView.beginUpdates()
                    self.tableView.reloadRowsAtIndexPaths([indexPathStart, indexPathEnd], withRowAnimation: .Automatic)
                    self.tableView.endUpdates()
                } else {
                    if let superview = self.view.superview {
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                    AlertBox.createAlertView(self ,title: "抱歉", body: "網路發生錯誤...", buttonValue: "確認")
                }
        }
        
    }
    
    func prepareUserAvatarImage() {
        let photoUuid = userInformation["profilePhotoId"]!
        
        
        if photoUuid != "" {
            hnkImageCache.fetch(key: photoUuid!).onSuccess { avatarImage in
                debugPrint("Cache Image used. \(photoUuid)")
                self.userAvatarImage.layer.cornerRadius = 64.0
                self.userAvatarImage.clipsToBounds = true
                self.userAvatarImage.hnk_setImage(avatarImage, key: photoUuid!)
                }.onFailure { _ in
                    debugPrint("failed")
                    let getImageApiRoute = API_END_POINT + "/avatars/" + photoUuid!
                    Alamofire
                        .request(.GET, getImageApiRoute, headers: self.headers, parameters: ["size": "mid"])
                        .responseData {
                            response in
                            debugPrint("The status code is \(response.response?.allHeaderFields) \n \(response.request?.allHTTPHeaderFields)")
                            if response.data != nil {
                                dispatch_async(dispatch_get_main_queue(), {
                                    let avatarImage = UIImage(data: response.data!)
                                    UIView.transitionWithView(self.userAvatarImage,
                                        duration: 0.5,
                                        options: .TransitionCrossDissolve,
                                        animations: { self.userAvatarImage.image = avatarImage },
                                        completion: nil
                                    )
                                    
                                    self.userAvatarImage.layer.cornerRadius = 64.0
                                    self.userAvatarImage.clipsToBounds = true
                                    self.hnkImageCache.set(value: avatarImage!, key: photoUuid!)
                                })
                            }
                            
                    }
            }
        }
    }
    
    //MARK: Deal with table selection.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        debugPrint(indexPath)
        if indexPath.section == 0 && indexPath.row == 4 {
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! ContactDetailTableViewCell
            let nickNameChangeAlert = UIAlertController(title: "修改暱稱", message: "請輸入您欲修改的暱稱", preferredStyle: .Alert)
            
            nickNameChangeAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.text = cell.textLabel?.text
            })
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            nickNameChangeAlert.addAction(UIAlertAction(title: "儲存", style: .Default, handler: { (action) -> Void in
                let nickNameTextField = nickNameChangeAlert.textFields![0] as UITextField
                let nickName: String! = nickNameTextField.text!
                let contactId: String! = self.userInformation["id"]!
                let updateContactRoute = API_URI + latestVersion + "/accounts/" + contactId + "/contacts/"
                
                debugPrint(updateContactRoute)
                
                if let superview = self.view.superview {
                    SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "儲存暱稱中...")
                }
                
                Alamofire
                    .request(.PUT, updateContactRoute, headers: self.headers, parameters: ["nickName": nickName], encoding: .URLEncodedInURL)
                    .response {
                        request, response, data, error in
                        if error == nil {
                            debugPrint(response)
                            
                            if let superview = self.view.superview {
                                SwiftOverlays.removeAllOverlaysFromView(superview)
                            }
                            
                            if nickName == "" {
                                cell.valueLabel?.text = "未設定"
                            } else {
                                cell.valueLabel?.text = nickName
                            }
                        } else {
                            // MARK: TODO Error handling
                            if let superview = self.view.superview {
                                SwiftOverlays.removeAllOverlaysFromView(superview)
                            }
                        }
                }
            }))
            
            nickNameChangeAlert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            // 4. Present the alert.
            self.presentViewController(nickNameChangeAlert, animated: true, completion: nil)
        }
        
        if indexPath.section == 1 && (indexPath.row == 1 || indexPath.row == 2) {
            timePickerView.hidden = false
            let dateFormatter = NSDateFormatter()
            // MARK: 24Hr two digit. such as 23:11
            dateFormatter.dateFormat = "HH:mm"
            availableStartTimeDatePicker.setDate(dateFormatter.dateFromString(userInformation["availableStartTime"]! as String!)!, animated: true)
            availableEndTimeDatePicker.setDate(dateFormatter.dateFromString(userInformation["availableEndTime"]! as String!)!, animated: true)
        }
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    // MARK: Title for section.
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case 0:
            return "好友資訊"
        case 1:
            return "設定可通話時段"
        default:
            return "Title"
        }
    }
    
    // MARK: row of every section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 8
        case 1:
            return 4
        default:
            return 0
        }
    }
    
    // MARK: Load the data to table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! ContactDetailTableViewCell
            switch indexPath.row {
            case 0:
                cell.fieldLabel.text = "姓名"
                cell.valueLabel.text = userInformation["userName"]!
                self.navigationItem.title = userInformation["userName"]!
                cell.accessoryType = .None;
            case 1:
                cell.fieldLabel.text = "公司"
                cell.valueLabel.text = userInformation["company"]! as String! != "" ? userInformation["company"]! as String!: "未設定"
                cell.accessoryType = .None;
            case 2:
                cell.fieldLabel.text = "職稱"
                cell.valueLabel.text = userInformation["jobTitle"]! as String! != "" ? userInformation["jobTitle"]! as String!: "未設定"
                cell.accessoryType = .None;
            case 3:
                cell.fieldLabel.text = "聯絡方式"
                cell.valueLabel.text = userInformation["email"]! as String! != "" ? userInformation["email"]! as String!: "未設定"
                cell.accessoryType = .None;
            case 4:
                cell.fieldLabel.text = "暱稱"
                cell.valueLabel.text = userInformation["nickName"]! as String! != "" ? userInformation["nickName"]! as String!: "未設定"
                cell.accessoryType = .DisclosureIndicator;
            case 5:
                cell.fieldLabel.text = "關於"
                cell.valueLabel.text = userInformation["profile"]! as String! != "" ? userInformation["profile"]! as String!: "未設定"
                cell.accessoryType = .None;
            case 6:
                cell.fieldLabel.text = "對方狀態"
                cell.valueLabel.text = userInformation["providerIsEnable"]! as String! == "true" ? "可撥打" : "不可撥打"
                cell.accessoryType = .None;
            case 7:
                cell.fieldLabel.text = "對方可通話時段"
                cell.valueLabel.text = userInformation["providerAvailableStartTime"]! as String! + " - " + userInformation["providerAvailableEndTime"]!! as String!
                cell.accessoryType = .None;
            default:
                cell.fieldLabel.text = ""
                cell.valueLabel.text = ""
            }
            cell.backgroundColor = UIColor.clearColor()
            return cell
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("ToggleCell", forIndexPath: indexPath) as! SwitchCell
                cell.labelText.text = "以下方可通話時間為主"
                if self.userInformation["isHigherPriorityThanGlobal"]! == "true" {
                    cell.switchButton.setOn(true, animated: true)
                } else {
                    cell.switchButton.setOn(false, animated: true)
                }
                
                cell.switchButton.addTarget(self, action: #selector(ContactDetailViewController.AvailableSwitchIsChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! ContactDetailTableViewCell
                cell.fieldLabel.text = "設定開始時間"
                cell.valueLabel.text = userInformation["availableStartTime"]! as String! != "" ? userInformation["availableStartTime"]! as String!: "未設定"
                cell.accessoryType = .DisclosureIndicator;
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! ContactDetailTableViewCell
                cell.fieldLabel.text = "設定結束時間"
                cell.valueLabel.text = userInformation["availableEndTime"]! as String! != "" ? userInformation["availableEndTime"]! as String!: "未設定"
                cell.accessoryType = .DisclosureIndicator;
                return cell
            case 3:
                let cell = tableView.dequeueReusableCellWithIdentifier("ToggleCell", forIndexPath: indexPath) as! SwitchCell
                if self.userInformation["isEnable"]! == "false" {
                    cell.switchButton.setOn(true, animated: true)
                } else {
                    cell.switchButton.setOn(false, animated: true)
                }
                
                cell.switchButton.addTarget(self, action: #selector(ContactDetailViewController.switchIsChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
                return cell
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("ToggleCell", forIndexPath: indexPath)
                return cell
            }
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("ToggleCell", forIndexPath: indexPath)
            return cell
        }
    }
    
    // MARK: Handle the menuView touch event.
    internal func handleButton(button: UIButton) {
        print("Hit Button \(button.tag)")
    }
    
    internal func callButton(button: UIButton) {
        // MARK & NOTE : !! to unwrap double optional value.
        if self.userInformation["providerIsEnable"]!! as String == "true" {
            let callService = CallService.init(view: self.view, _self: self)
            let id: String! = self.userInformation["id"]!
            
            debugPrint(UserPref.getUserPrefByKey("phoneNumber"))
            callService.call(UserPref.getUserPrefByKey("userUuid"), caller: UserPref.getUserPrefByKey("phoneNumber"), callee: userInformation["phoneNumber"]!, contactId: id)
        } else {
            AlertBox.createAlertView(self ,title: "抱歉!", body: "對方為忙碌狀態\n請查看對方可通話時段。", buttonValue: "確認")
            return
        }
    }
    
    // MARK: Handle the menuView touch event.
    internal func handleMenu() {
        if menuView.menu.opened {
            menuView.menu.close()
            (menuView.menu.views?.first as? MaterialButton)?.animate(MaterialAnimation.rotate(duration: 0))
        } else {
            menuView.menu.open() { (v: UIView) in
                (v as? MaterialButton)?.pulse()
            }
            (menuView.menu.views?.first as? MaterialButton)?.animate(MaterialAnimation.rotate(duration: 0.125))
        }
    }
    
    // MARK: General preparation statements are placed here.
    private func prepareView() {
        view.backgroundColor = MaterialColor.white
        timePickerView.hidden = true
        timePickerView.layer.shadowColor = UIColor.blackColor().CGColor
        timePickerView.layer.shadowOffset = CGSizeZero
        timePickerView.layer.shadowOpacity = 0.5
        timePickerView.layer.shadowRadius = 5
        timePickerView.layer.cornerRadius = 10.0
        timePickerView.clipsToBounds = true
        timePickerView.layer.borderColor = UIColor.grayColor().CGColor
        timePickerView.layer.borderWidth = 0.5
        timePickerView.layer.borderColor = UIColor.grayColor().CGColor
    }
    
    // MARK: Prepares the MenuView example.
    private func prepareMenuView() {
        var image: UIImage? = UIImage(named: "ic_menu_white")?.imageWithRenderingMode(.AlwaysTemplate)
        let btn1: FabButton = FabButton()
        btn1.depth = .None
        btn1.tintColor = MaterialColor.white
        btn1.pulseColor = MaterialColor.lightBlue.base
        btn1.borderColor = MaterialColor.grey.darken2
        btn1.backgroundColor = MaterialColor.grey.darken2
        btn1.borderWidth = 1
        btn1.setImage(image, forState: .Normal)
        btn1.setImage(image, forState: .Highlighted)
        btn1.addTarget(self, action: #selector(ContactDetailViewController.handleMenu), forControlEvents: .TouchUpInside)
        menuView.addSubview(btn1)
        
        let isProviderEnable = self.userInformation["providerIsEnable"]!!
        debugPrint("isProviderEnale: " + isProviderEnable)
        
        let btn2: FabButton = FabButton()
        
        if isProviderEnable == "true" {
            image = UIImage(named: "ic_call_white")?.imageWithRenderingMode(.AlwaysTemplate)
        } else {
            image = UIImage(named: "ic_phone_locked_white")?.imageWithRenderingMode(.AlwaysTemplate)
        }
        
        btn2.depth = .None
        btn2.tintColor = MaterialColor.white
        btn2.pulseColor = MaterialColor.grey.base
        btn2.borderColor = MaterialColor.grey.darken2
        btn2.backgroundColor = MaterialColor.grey.darken2
        btn2.borderWidth = 1
        btn2.setImage(image, forState: .Normal)
        btn2.setImage(image, forState: .Highlighted)
        btn2.addTarget(self, action: #selector(ContactDetailViewController.callButton(_:)), forControlEvents: .TouchUpInside)
        menuView.addSubview(btn2)
        
        image = UIImage(named: "ic_favorite_white")?.imageWithRenderingMode(.AlwaysTemplate)
        let btn3: FabButton = FabButton()
        btn3.depth = .None
        btn3.tintColor = MaterialColor.white
        btn3.pulseColor = MaterialColor.grey.base
        btn3.borderColor = MaterialColor.grey.lighten1
        btn3.backgroundColor = MaterialColor.grey.lighten1
        btn3.borderWidth = 1
        btn3.setImage(image, forState: .Normal)
        btn3.setImage(image, forState: .Highlighted)
        btn3.addTarget(self, action: #selector(ContactDetailViewController.handleButton(_:)), forControlEvents: .TouchUpInside)
        //menuView.addSubview(btn3)
        
        // MARK: Initialize the menu and setup the configuration options.
        menuView.menu.direction = .Up
        menuView.menu.baseViewSize = CGSizeMake(diameter, diameter)
        menuView.menu.views = [btn1, btn2]
        
        view.addSubview(menuView)
        menuView.translatesAutoresizingMaskIntoConstraints = false
        MaterialLayout.size(view, child: menuView, width: diameter, height: diameter)
        MaterialLayout.alignFromBottomLeft(view, child: menuView, bottom: 5, left: (view.bounds.width - diameter - 4))
    }
}
