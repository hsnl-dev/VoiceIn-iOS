import UIKit
import Material
import Alamofire
import SwiftyJSON
import SwiftOverlays
import CoreData
import Haneke
import ReachabilitySwift
import Instructions

class ContactTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating{
    @IBOutlet var cardBarItem: UIBarButtonItem?
    @IBOutlet var addPeopelItem: UIBarButtonItem?

    private var navigationBarView: NavigationBar = NavigationBar()
    let headers = Network.generateHeader(isTokenNeeded: true)
    var resultSearchController = UISearchController()
    
    // MARK: Array of ContactList
    var contactArray: [People] = []
    var filterContactArray: [People] = [People]()
    var navigationTitle: String? = "聯絡簿"
    var getContactRoute: String! = API_URI + latestVersion + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/contacts"
    
    // MARK - For Group related
    var selectedContactId: [String] = []
    var isFromGroupListView: Bool = false
    var groupId: String = ""
    var groupNameTextField: UITextField! = nil
    
    // MARK - Image Cache
    let hnkImageCache = Shared.imageCache
    var profileImage: UIImage? = nil
    
    var reachability: Reachability?
    
    //MARK: - Public properties
    var coachMarksController: CoachMarksController?
    
    let cardText = "這是屬於你的 VoiceIn 個人名片，您可以按分享，將您的名片透過 Line、email ... 等傳給給您的客戶或夥伴，他們即可新增您為聯絡人，不管有沒有安裝 VoiceIn。"
    let addFriendText = "我們提供讓您用相機或從手機相簿中的相片中掃瞄 VoiceIn QR Code 來新增聯絡人的功能。"
    let startText = "歡迎來到 VoiceIn，我們將簡短引導您使用 VoiceIn，讓您更快速地上手!"
    let endText = "立即開始體驗，若您想再看一次引導，可以至個人設定開啟。"
    let nextButtonText = "了解!"
    
    override func viewDidLoad() {
        self.refreshControl?.addTarget(self, action: #selector(ContactTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        super.viewDidLoad()
        
        //MAKR - Init search view contrller
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "搜尋聯絡人..."
            controller.searchBar.tintColor = UIColor.grayColor()
            controller.searchBar.barTintColor = UIColor(red: 245.0/255.0, green:245/255.0, blue: 245.0/255.0, alpha: 1.0)
            
            self.tableView.tableHeaderView = controller.searchBar
            self.tableView.contentOffset = CGPointMake(0, controller.searchBar.frame.size.height);
            return controller
        })()
        
        self.navigationItem.title = navigationTitle
        
        if isFromGroupListView == true {
            // MARK - it is from the group list tab
            self.navigationItem.setRightBarButtonItems(nil, animated: true)
            let button = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(ContactTableViewController.showEditActionSheet(_:)))
            self.navigationItem.rightBarButtonItem = button
            self.navigationItem.leftBarButtonItem = nil
        } else {
            // MARK - TODO Not from the Group List tab ...
            // MARK - Set up instruction
            self.coachMarksController = CoachMarksController()
            self.coachMarksController?.allowOverlayTap = true
            self.navigationItem.title = "VoiceIn"
            self.tableView.separatorColor = MaterialColor.grey.lighten2
        }
        
        UserPref.updateTheDeviceKey()
        prepareView()
    }
    
    override func viewDidAppear(animated: Bool) {
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContactTableViewController.reachabilityChanged(_:)),name: ReachabilityChangedNotification, object: reachability)
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        self.tableView.separatorColor = MaterialColor.grey.lighten2
        // MARK - Get the contact list.
        if let superview = self.view.superview {
            SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "讀取中...")
        }
        
        getContactList(getContactRoute)
        
        let isFirstLogin = UserPref.getUserPrefByKey("isFirstLogin")
        // MARK - It is from the contact view, not group view
        if (isFromGroupListView == false && (isFirstLogin == nil || isFirstLogin == "true")) {
            self.coachMarksController?.startOn(self)
            UserPref.setUserPref("isFirstLogin", value: "false")
        }
    }
    
    // MARK - Triggered when the network state changed.
    func reachabilityChanged(note: NSNotification) {
        
        let reachability = note.object as! Reachability
        dispatch_async(dispatch_get_main_queue()) {
            if reachability.isReachable() {
                let isOfflinecardPreset = UserPref.getUserPrefByKey("isOfflineCardPresent")
                debugPrint("Network Enable")
                
                // MARK - isOfflinecardPreset: Flag to record if the offline card is presented or not.
                if isOfflinecardPreset != nil && isOfflinecardPreset == "true" {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    UserPref()
                        .setUserPref("isOfflineCardPresent", value: "false")
                        .syncAll()
                }
                
            } else {
                print("Network not reachable")
                
                UserPref()
                    .setUserPref("isOfflineCardPresent", value: "true")
                    .setUserPref("isFirstFetch", value: true)
                    .syncAll()
                
                let vcardViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("vCardViewController") as! vCardViewController
                self.presentViewController(vcardViewController, animated: true, completion: nil)
            }
        }
    }
    
    
    deinit {
        reachability!.stopNotifier()
        NSNotificationCenter
            .defaultCenter()
            .removeObserver(self, name: ReachabilityChangedNotification, object: reachability)
    }
    
    // MARK: General preparation statements.
    private func prepareView() {
        view.backgroundColor = MaterialColor.white
        navigationBarView.statusBarStyle = .Default
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - the number of row in a section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.active {
            return filterContactArray.count
        } else {
            return contactArray.count
        }
    }
    
    // MARK: Brain to show contactlist.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ContactTableCell
        var photoUuid = ""
        var getImageApiRoute: String?
        var userInformation: [String: String?]
        
        if self.resultSearchController.active {
            // MARK: When searchbar is active, do this block!
            if indexPath.row > filterContactArray.count - 1 {
                return cell
            }
            userInformation = filterContactArray[indexPath.row].data
        } else {
            // MARK: When searchbar is inactive, do this block!
            if indexPath.row > contactArray.count - 1 {
                return cell
            }
            userInformation = contactArray[indexPath.row].data
        }
        
        let nickName = userInformation["nickName"]! as String?
        let providerIsEnable = userInformation["providerIsEnable"]!!
        let isThisContactLike = userInformation["isLike"]!!
        
        photoUuid = (userInformation["profilePhotoId"]! as String?)!
        
        if nickName == "" {
            cell.nameLabel.text = userInformation["userName"]!
        } else {
            cell.nameLabel.text = nickName
        }
        
        if providerIsEnable == "false" {
            let phoneImgage: UIImage? = UIImage(named: "ic_phone_locked_white")
            cell.callButton.setImage(phoneImgage, forState: .Normal)
            cell.callButton.backgroundColor = MaterialColor.black
            cell.isProviderEnable = false
        } else {
            let phoneImgage: UIImage? = UIImage(named: "ic_call_white")
            cell.callButton.setImage(phoneImgage, forState: .Normal)
            cell.callButton.backgroundColor = MaterialColor.blue.accent3
            cell.isProviderEnable = true
        }
        
        if isThisContactLike == "true" {
            cell.isLike = true
            cell.favoriteButton.backgroundColor = MaterialColor.red.darken1
        } else {
            cell.isLike = false
            cell.favoriteButton.backgroundColor = MaterialColor.grey.lighten1
        }
        
        if userInformation["chargeType"]!! as String == ContactType.Free.rawValue {
            cell.type.text = ContactTypeText.freeCallText
            cell.type.textColor = MaterialColor.red.base
        } else {
            cell.type.text = userInformation["chargeType"]!! as String == ContactType.Paid.rawValue ? ContactTypeText.paidCallText : ContactTypeText.iconCallText
            cell.type.textColor = MaterialColor.teal.darken4
        }
        
        cell.companyLabel.text = userInformation["company"]! as String? != "" ? userInformation["company"]! as String? : "未設定單位"
        cell.id = userInformation["id"]!
        cell.callee = userInformation["phoneNumber"]!
        
        // MARK - Setting the user photo.
        cell.thumbnailImageView.image = UIImage(named: "user")
        cell.thumbnailImageView.layer.cornerRadius = 25.0
        cell.thumbnailImageView.clipsToBounds = true
        
        if photoUuid != "" {
            hnkImageCache.fetch(key: photoUuid).onSuccess { avatarImage in
                debugPrint("Cache Image used. \(photoUuid)")
                cell.thumbnailImageView.layer.cornerRadius = 25.0
                cell.thumbnailImageView.clipsToBounds = true
                cell.thumbnailImageView.hnk_setImage(avatarImage, key: photoUuid)
            }.onFailure { _ in
                debugPrint("failed")
                getImageApiRoute = API_END_POINT + "/avatars/" + photoUuid
                Alamofire
                    .request(.GET, getImageApiRoute!, headers: self.headers, parameters: ["size": "mid"])
                    .responseData {
                        response in
                        debugPrint("The status code is \(response.response?.allHeaderFields) \n \(response.request?.allHTTPHeaderFields)")
                        if response.data != nil {
                            dispatch_async(dispatch_get_main_queue(), {
                                let avatarImage = UIImage(data: response.data!)
                                UIView.transitionWithView(cell.thumbnailImageView,
                                    duration: 0.5,
                                    options: .TransitionCrossDissolve,
                                    animations: { cell.thumbnailImageView.image = avatarImage },
                                    completion: nil
                                )
                                
                                cell.thumbnailImageView.layer.cornerRadius = 25.0
                                cell.thumbnailImageView.clipsToBounds = true
                                self.hnkImageCache.set(value: avatarImage!, key: photoUuid)
                            })
                        }
                        
                }
            }
        }
        
        // MARK - Set up the ation of button
        cell.onCallButtonTapped = {
            if cell.isProviderEnable == false {
                AlertBox.createAlertView(self ,title: "抱歉!", body: "對方為忙碌狀態\n請查看對方可通話時段。", buttonValue: "確認")
                return
            }
            let callService = CallService.init(view: self.view, _self: self)
            callService.call(UserPref.getUserPrefByKey("userUuid"), caller: UserPref.getUserPrefByKey("phoneNumber"), callee: cell.callee! as String, contactId: cell.id)
        }
        
        cell.onFavoriteButtonTapped = {
            let contactId = cell.id
            let updateContactRoute = API_URI + latestVersion + "/accounts/" + contactId! + "/contacts/"

            if cell.isLike == true {
                debugPrint("Tap favorite false!")
                cell.favoriteButton.backgroundColor = MaterialColor.grey.lighten1
                cell.isLike = false
                
                Alamofire.request(.PUT, updateContactRoute, headers: self.headers, parameters: ["like": "False"], encoding: .URLEncodedInURL)
                    .response {
                        request, response, data, error in
                        if error != nil {
                            debugPrint(response)
                            cell.favoriteButton.backgroundColor = MaterialColor.red.darken1
                            cell.isLike = true
                            AlertBox.createAlertView(self ,title: "發生了錯誤!", body: "抱歉，請再次嘗試一次...", buttonValue: "確認")
                        }
                }
            } else {
                debugPrint("Tap favorite true")
                cell.favoriteButton.backgroundColor = MaterialColor.red.darken1
                cell.isLike = true
                
                Alamofire.request(.PUT, updateContactRoute, headers: self.headers, parameters: ["like": "True"], encoding: .URLEncodedInURL)
                    .response {
                        request, response, data, error in
                        if error != nil {
                            cell.favoriteButton.backgroundColor = MaterialColor.grey.lighten1
                            cell.isLike = false
                            AlertBox.createAlertView(self ,title: "發生了錯誤!", body: "抱歉，請再次嘗試一次...", buttonValue: "確認")
                        }
                }
            }
        }
        
        return cell
    }
    
    // MARK: Deletion
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath:NSIndexPath) {
        if editingStyle == .Delete {
            let deleteAlert = UIAlertController(title: "注意!", message: "確定要刪除此筆聯絡人?", preferredStyle: UIAlertControllerStyle.Alert)
            
            deleteAlert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: {action in
                debugPrint("Deleting a row...")
                if let superview = self.view.superview {
                    SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "刪除中...")
                }
                let deleteApiRoute = API_URI + latestVersion + "/accounts/" + (tableView.cellForRowAtIndexPath(indexPath) as! ContactTableCell).id! + "/contacts/"
                
                Alamofire.request(.DELETE, deleteApiRoute, encoding: .JSON, headers: self.headers).response {
                    request, response, data, error in
                    if error == nil {
                        self.tableView.beginUpdates()
                        self.contactArray.removeAtIndex(indexPath.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        self.tableView.endUpdates()
                    } else {
                        debugPrint(error)
                    }
                    
                    if let superview = self.view.superview {
                        SwiftOverlays.removeAllOverlaysFromView(superview)
                    }
                }
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(deleteAlert, animated: true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if isFromGroupListView == false {
            return .Delete
        } else {
            return .None
        }
    }
    
    // MARK - Group related function.
    func showEditActionSheet(sender: UIButton) {
        // 1
        let optionMenu = UIAlertController(title: nil, message: "您想要 ..", preferredStyle: .ActionSheet)
        
        // 2
        let renameAction = UIAlertAction(title: "更改分類名稱", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.showUpdateGroupNameModal()
        })
        let editContact = UIAlertAction(title: "編輯此分類成員", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.editContactTapped()
        })
        
        //
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(renameAction)
        optionMenu.addAction(editContact)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func editContactTapped() {
        let mutipleSelectContactViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MutipleSelectContactView") as! GroupMutipleSelectTableViewController
        
        // MARK - Initialize the selected array cause it is modal view.
        selectedContactId = []
        
        mutipleSelectContactViewController.isFromUpdateView = true
        mutipleSelectContactViewController.groupId = groupId
        
        for contact in contactArray {
            selectedContactId.append(contact.data["id"]!!)
        }
        
        debugPrint(selectedContactId)
        
        mutipleSelectContactViewController.seletedContactArray = selectedContactId
        self.navigationController?.pushViewController(mutipleSelectContactViewController, animated: true)
    }
    
    func showUpdateGroupNameModal() {
        let groupNameBox = UIAlertController(title: "請輸入分類名稱", message: "", preferredStyle: .Alert)
        groupNameBox.addTextFieldWithConfigurationHandler(configureGroupNameTextField)
        groupNameBox.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        groupNameBox.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler:{
            (UIAlertAction) in
            debugPrint("Item : \(self.groupNameTextField.text)")
            let updateGroupRoute = API_URI + versionV1 + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/groups/" + self.groupId + "/contacts"
            
            Alamofire
                .request(.PUT, updateGroupRoute, headers: self.headers, parameters: ["groupName" : self.groupNameTextField.text!], encoding: .URLEncodedInURL)
                .response {
                    request, response, data, error in
                    debugPrint(response?.statusCode)
                    if response?.statusCode >= 400 {
                        debugPrint(error)
                    } else {
                        self.navigationItem.title = self.groupNameTextField.text!
                    }
            }
            
            
        }))
        self.presentViewController(groupNameBox, animated: true, completion: {
            debugPrint("completion block")
        })
    }
    
    private func configureGroupNameTextField(textField: UITextField!) {
        textField.placeholder = "分類名稱"
        groupNameTextField = textField
    }
    
    // MARK: GET: Get the contact list.
    private func getContactList(getInformationApiRoute: String!) {
        
        let isFirstFetch = UserPref.getUserPrefByKey("isFirstFetch")

        debugPrint("is First Fetch? \(isFirstFetch) \(getInformationApiRoute)")
        let parameters = isFirstFetch == "1" ? ["conditional": "false"] : ["conditional": "true"]
        
        Alamofire
            .request(.GET, getInformationApiRoute, headers: headers, parameters: parameters, encoding: .URLEncodedInURL)
            .responseJSON {
                response in
                
                if let superview = self.view.superview {
                    SwiftOverlays.removeAllOverlaysFromView(superview)
                }
                
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    let jsonResponse = JSON(JSON_RESPONSE)
                    debugPrint(jsonResponse)
                    
                    if self.isFromGroupListView == true {
                        self.contactArray = []
                    }
                    
                    for index in 0 ..< jsonResponse.count {
                        var contactInformation: [String: String?] = [String: String?]()
                        var people: People!
                        var keyValuePair = Array(jsonResponse[index])
                        var isReplaced = false
                        
                        for indexKeys in 0 ..< keyValuePair.count {
                            contactInformation[keyValuePair[indexKeys].0] = jsonResponse[index][keyValuePair[indexKeys].0].stringValue
                        }
                        
                        people = People(userInformation: contactInformation)
                        
                        // MARK - Replace the updated contact
                        self.contactArray = self.contactArray.map { (n) -> People in
                            if n.data["id"]! == people.data["id"]! {
                                debugPrint("isReplaced \(n.data["id"]) - \(n.data["userName"])")
                                isReplaced = true
                                return people
                            } else {
                                return n
                            }
                            }.filter({
                                $0.data["userName"]! != ""
                            })
                        
                        // MARK - ignore the deleted contact, the cell deleted so the id will not match.
                        if people.data["userName"]! == "" {
                            continue
                        }
                        
                        // MARK - It's a new contact, insert to the top!
                        if isReplaced == false {
                            self.contactArray.insert(people, atIndex: 0)
                        }
                    }
                    
                    UserPref.setUserPref("isFirstFetch", value: false)
                    
                    if self.contactArray.count == 0 {
                        
                        if  self.isFromGroupListView == false {
                            if let superview = self.view.superview {
                                SwiftOverlays.showTextOverlay(superview, text: "您目前沒有聯絡人喔\n分享名片或加好友吧")
                            }
                        } else {
                            if let superview = self.view.superview {
                                SwiftOverlays.showTextOverlay(superview, text: " 本群組沒有聯絡人\n點編輯新增吧")
                            }
                        }
                        
                        self.tableView.separatorColor = MaterialColor.white
                    }
                    
                    self.tableView.reloadData()
                case .Failure(let error):
                    debugPrint(error)
                    AlertBox.createAlertView(self ,title: "您似乎沒有連上網路", body: "請開啟網路，再下拉畫面以更新", buttonValue: "確認")
                }
                

                self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK - Update the searching result.
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = resultSearchController.searchBar.text {
            filterContactArray.removeAll(keepCapacity: false)
            filterContentForSearchText(searchText)
            tableView.reloadData()
        }
    }
    
    // MARK - Search the contact list.
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filterContactArray = contactArray.filter { contact in
            let contactData = contact.data
            if contactData["userName"]!!.lowercaseString.containsString(searchText.lowercaseString) != false {
                return contactData["userName"]!!.lowercaseString.containsString(searchText.lowercaseString)
            } else {
                return contactData["nickName"]!!.lowercaseString.containsString(searchText.lowercaseString)
            }
        }
        
        tableView.reloadData()
    }
    
    // MARK - Pull down to refresh
    func refresh(sender: AnyObject) {
        
        if let superview = self.view.superview {
            SwiftOverlays.removeAllOverlaysFromView(superview)
        }
        
        if Networker.isReach() != true {
            debugPrint("Network is not connected!")
            AlertBox.createAlertView(self ,title: "您似乎沒有連上網路", body: "請開啟網路，再下拉畫面以更新。", buttonValue: "確認")
            self.refreshControl?.endRefreshing()
        } else {
            hnkImageCache.removeAll()
            if let superview = self.view.superview {
                SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "讀取中...")
            }
            
            getContactList(getContactRoute)
        }
    }
    
    // MARK: Trigger when user click the row of contact, show detail.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let superview = self.view.superview {
            SwiftOverlays.removeAllOverlaysFromView(superview)
        }
        
        if segue.identifier == "DetailViewSegue" {
            if  let indexPath = tableView.indexPathForSelectedRow,
                let destinationViewController = segue.destinationViewController as? ContactDetailViewController {                
                    destinationViewController.userInformation = contactArray[indexPath.row].data
                    destinationViewController.searchController = self.resultSearchController
            }
        }
    }
    
    @IBAction func closeToTableViewController(segue: UIStoryboardSegue!) {
        
    }
}
