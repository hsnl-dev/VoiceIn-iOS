import UIKit
import Material
import Alamofire
import SwiftOverlays

class ContactDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var userAvatarImage: UIImageView!
    @IBOutlet var timePickerView: UIView!
    @IBOutlet var availableStartTimeDatePicker: UIDatePicker!
    @IBOutlet var availableEndTimeDatePicker: UIDatePicker!
    
    var userInformation: [String: String?] = [String: String?]()
    let headers = Network.generateHeader(isTokenNeeded: true)
    let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var searchController: UISearchController = UISearchController()
    
    private lazy var menuView: MenuView = MenuView()
    let spacing: CGFloat = 16
    let diameter: CGFloat = 56
    let height: CGFloat = 36
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: self-sizing cell setting.
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 70;
        
        prepareView()
        prepareMenuView()
        prepareUserAvatarImage()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.searchController.active = false
    }
    
    func switchIsChanged(switchButton: UISwitch) {
        let qrCodeUuid: String! = self.userInformation["qrCodeUuid"]!
        let updateContactRoute = API_END_POINT + "/accounts/" + self.userDefaultData.stringForKey("userUuid")! + "/contacts/" + qrCodeUuid
        
        if switchButton.on {
            debugPrint("Switch On")
            Alamofire
                .request(.PUT, updateContactRoute, headers: self.headers, parameters: ["isEnable": "True"], encoding: .URLEncodedInURL)
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
                .request(.PUT, updateContactRoute, headers: self.headers, parameters: ["isEnable": "False"], encoding: .URLEncodedInURL)
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
    
    @IBAction func closeTimePickerView(sender: UIButton!) {
        timePickerView.hidden = true
    }
    
    @IBAction func saveTimePeriod() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "H:mm"
        
        let qrCodeUuid: String! = self.userInformation["qrCodeUuid"]!
        let updateContactRoute = API_END_POINT + "/accounts/" + self.userDefaultData.stringForKey("userUuid")! + "/contacts/" + qrCodeUuid
        let availableStartTime: String = dateFormatter.stringFromDate(availableStartTimeDatePicker.date)
        let availableEndTime: String = dateFormatter.stringFromDate(availableEndTimeDatePicker.date)
        
        SwiftOverlays.showCenteredWaitOverlayWithText(self.view.superview!, text: "儲存中...")
        
        Alamofire
            .request(.PUT, updateContactRoute, headers: self.headers, parameters: ["availableStartTime": availableStartTime, "availableEndTime": availableEndTime], encoding: .URLEncodedInURL)
            .response {
                request, response, data, error in
                if error == nil {
                    debugPrint(response)
                    self.userInformation["availableStartTime"] = availableStartTime
                    self.userInformation["availableEndTime"] = availableEndTime
                    SwiftOverlays.removeAllOverlaysFromView(self.view.superview!)
                    self.createAlertView("恭喜!", body: "儲存成功", buttonValue: "確認")
                    self.tableView.reloadData()
                } else {
                    SwiftOverlays.removeAllOverlaysFromView(self.view.superview!)
                    self.createAlertView("抱歉", body: "網路發生錯誤...", buttonValue: "確認")
                }
        }
        
    }
    
    func prepareUserAvatarImage() {
        let photoUuid = userInformation["profilePhotoId"]!
        if photoUuid != "" {
            let getImageApiRoute = API_END_POINT + "/avatars/" + photoUuid!
            Alamofire
                .request(.GET, getImageApiRoute, headers: self.headers, parameters: ["size": "mid"])
                .responseData {
                    response in
                    if response.data != nil {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.userAvatarImage.image = UIImage(data: response.data!)
                            self.userAvatarImage.layer.cornerRadius = 64.0
                            self.userAvatarImage.clipsToBounds = true
                        })
                    }
            }
        }
    }
    
    //MARK: Deal with table selection.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        debugPrint(indexPath)
        if indexPath.section == 0 && indexPath.row == 2 {
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! ContactDetailTableViewCell
            let nickNameChangeAlert = UIAlertController(title: "修改暱稱", message: "請輸入您欲修改的暱稱", preferredStyle: .Alert)
            
            nickNameChangeAlert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.text = cell.textLabel?.text
            })
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            nickNameChangeAlert.addAction(UIAlertAction(title: "儲存", style: .Default, handler: { (action) -> Void in
                let nickNameTextField = nickNameChangeAlert.textFields![0] as UITextField
                let qrCodeUuid: String! = self.userInformation["qrCodeUuid"]!
                let nickName: String! = nickNameTextField.text!
                let updateContactRoute = API_END_POINT + "/accounts/" + self.userDefaultData.stringForKey("userUuid")! + "/contacts/" + qrCodeUuid
                
                debugPrint(updateContactRoute)
                
                SwiftOverlays.showCenteredWaitOverlayWithText(self.view.superview!, text: "儲存暱稱中...")
                
                Alamofire
                    .request(.PUT, updateContactRoute, headers: self.headers, parameters: ["nickName": nickName], encoding: .URLEncodedInURL)
                    .response {
                        request, response, data, error in
                        if error == nil {
                            debugPrint(response)
                            SwiftOverlays.removeAllOverlaysFromView(self.view.superview!)
                            if nickName == "" {
                                cell.valueLabel?.text = "未設定"
                            } else {
                                cell.valueLabel?.text = nickName
                            }
                        } else {
                            SwiftOverlays.removeAllOverlaysFromView(self.view.superview!)
                        }
                }
            }))
            
            nickNameChangeAlert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            // 4. Present the alert.
            self.presentViewController(nickNameChangeAlert, animated: true, completion: nil)
        }
        
        if indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1) {
            timePickerView.hidden = false
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "H:mm"
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
            return "方便通話時間設定"
        default:
            return "Title"
        }
    }
    
    // MARK: row of every section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 3
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
                cell.accessoryType = .None;
            case 1:
                cell.fieldLabel.text = "公司"
                cell.valueLabel.text = userInformation["company"]! as String! != "" ? userInformation["company"]! as String!: "未設定"
                cell.accessoryType = .None;
            case 2:
                cell.fieldLabel.text = "暱稱"
                cell.valueLabel.text = userInformation["nickName"]! as String! != "" ? userInformation["nickName"]! as String!: "未設定"
                cell.accessoryType = .DisclosureIndicator;
            case 3:
                cell.fieldLabel.text = "關於"
                cell.valueLabel.text = userInformation["profile"]! as String! != "" ? userInformation["profile"]! as String!: "未設定"
            default:
                cell.fieldLabel.text = ""
                cell.valueLabel.text = ""
            }
            cell.backgroundColor = UIColor.clearColor()
            return cell
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! ContactDetailTableViewCell
                cell.fieldLabel.text = "開始時間"
                cell.valueLabel.text = userInformation["availableStartTime"]! as String! != "" ? userInformation["availableStartTime"]! as String!: "未設定"
                cell.accessoryType = .DisclosureIndicator;
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! ContactDetailTableViewCell
                cell.fieldLabel.text = "結束時間"
                cell.valueLabel.text = userInformation["availableEndTime"]! as String! != "" ? userInformation["availableEndTime"]! as String!: "未設定"
                cell.accessoryType = .DisclosureIndicator;
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("ToggleCell", forIndexPath: indexPath) as! SwitchCell
                
                if self.userInformation["isEnable"]! == "true" {
                    cell.switchButton.setOn(true, animated: true)
                } else {
                    cell.switchButton.setOn(false, animated: true)
                }
                
                cell.switchButton.addTarget(self, action: Selector("switchIsChanged:"), forControlEvents: UIControlEvents.ValueChanged)
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
        let callService = CallService.init(view: self.view, _self: self)
        debugPrint(self.userDefaultData.stringForKey("phoneNumber")!)
        callService.call(self.userDefaultData.stringForKey("userUuid")!, caller: self.userDefaultData.stringForKey("phoneNumber")!, callee: userInformation["phoneNumber"]!)
    }
    
    private func createAlertView(title: String!, body: String!, buttonValue: String!) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonValue, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
        btn1.tintColor = MaterialColor.blue.accent3
        btn1.pulseColor = nil
        btn1.borderColor = MaterialColor.blue.accent3
        btn1.backgroundColor = MaterialColor.white
        btn1.borderWidth = 1
        btn1.setImage(image, forState: .Normal)
        btn1.setImage(image, forState: .Highlighted)
        btn1.addTarget(self, action: "handleMenu", forControlEvents: .TouchUpInside)
        menuView.addSubview(btn1)
        
        image = UIImage(named: "ic_call_white")?.imageWithRenderingMode(.AlwaysTemplate)
        let btn2: FabButton = FabButton()
        btn2.depth = .None
        btn2.tintColor = MaterialColor.blue.accent3
        btn2.pulseColor = MaterialColor.blue.accent3
        btn2.borderColor = MaterialColor.blue.accent3
        btn2.backgroundColor = MaterialColor.white
        btn2.borderWidth = 1
        btn2.setImage(image, forState: .Normal)
        btn2.setImage(image, forState: .Highlighted)
        btn2.addTarget(self, action: "callButton:", forControlEvents: .TouchUpInside)
        menuView.addSubview(btn2)
        
        image = UIImage(named: "ic_favorite_white")?.imageWithRenderingMode(.AlwaysTemplate)
        let btn3: FabButton = FabButton()
        btn3.depth = .None
        btn3.tintColor = MaterialColor.blue.accent3
        btn3.pulseColor = MaterialColor.blue.accent3
        btn3.borderColor = MaterialColor.blue.accent3
        btn3.backgroundColor = MaterialColor.white
        btn3.borderWidth = 1
        btn3.setImage(image, forState: .Normal)
        btn3.setImage(image, forState: .Highlighted)
        btn3.addTarget(self, action: "handleButton:", forControlEvents: .TouchUpInside)
        menuView.addSubview(btn3)
        
        // image = UIImage(named: "ic_delete_forever_white")?.imageWithRenderingMode(.AlwaysTemplate)
        // let btn4: FabButton = FabButton()
        // btn4.depth = .None
        // btn4.tintColor = MaterialColor.blue.accent3
        // btn4.pulseColor = MaterialColor.blue.accent3
        // btn4.borderColor = MaterialColor.blue.accent3
        // btn4.backgroundColor = MaterialColor.white
        // btn4.borderWidth = 1
        // btn4.setImage(image, forState: .Normal)
        // btn4.setImage(image, forState: .Highlighted)
        // btn4.addTarget(self, action: "handleButton:", forControlEvents: .TouchUpInside)
        // menuView.addSubview(btn4)
        
        // MARK: Initialize the menu and setup the configuration options.
        menuView.menu.direction = .Up
        menuView.menu.baseViewSize = CGSizeMake(diameter, diameter)
        menuView.menu.views = [btn1, btn2, btn3]
        
        view.addSubview(menuView)
        menuView.translatesAutoresizingMaskIntoConstraints = false
        MaterialLayout.size(view, child: menuView, width: diameter, height: diameter)
        MaterialLayout.alignFromBottomLeft(view, child: menuView, bottom: 55, left: (view.bounds.width - diameter - 5))
    }
}
