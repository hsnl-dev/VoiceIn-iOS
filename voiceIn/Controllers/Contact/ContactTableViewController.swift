import UIKit
import Material
import Alamofire
import SwiftyJSON
import SwiftSpinner
import SwiftOverlays
import CoreData
//import SnapKit

class ContactTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating{
    private var navigationBarView: NavigationBarView = NavigationBarView()
    let headers = Network.generateHeader(isTokenNeeded: true)
    var resultSearchController = UISearchController()
    
    // MARK: Array of ContactList
    var contactArray: [People] = []
    var filterContactArray: [People] = [People]()
    
    override func viewDidLoad() {
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        super.viewDidLoad()
        
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
        
        SwiftSpinner.show("讀取中...", animated: true)
        prepareView()
    }
    
    override func viewDidAppear(animated: Bool) {
        SwiftOverlays.showCenteredWaitOverlayWithText(self.view.superview!, text: "讀取中...")
        getContactList()
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
        
        if self.resultSearchController.active {
            // MARK: When searchbar is active, do this block!
            if indexPath.row > filterContactArray.count - 1 {
                return cell
            }
            
            var userInformation: [String: String?] = filterContactArray[indexPath.row].data
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
                cell.favoriteButton.backgroundColor = MaterialColor.red.accent1
            }
            
            if userInformation["chargeType"]!! as String == ContactType.Free.rawValue {
                cell.type.text = "免費"
                cell.type.textColor = MaterialColor.red.base
            } else {
                cell.type.text = userInformation["chargeType"]!! as String == ContactType.Paid.rawValue ? "付費" : "付費-由無 App 客戶產生"
                cell.type.textColor = MaterialColor.teal.darken4
            }
            
            cell.companyLabel.text = userInformation["company"]! as String? != "" ? userInformation["company"]! as String? : "未設定單位"
            cell.id = userInformation["id"]!
            cell.callee = userInformation["phoneNumber"]!
        } else {
            // MARK: When searchbar is inactive, do this block!
            if indexPath.row > contactArray.count - 1 {
                return cell
            }
            
            var userInformation: [String: String?] = contactArray[indexPath.row].data
            let nickName = userInformation["nickName"]! as String?
            let providerIsEnable = userInformation["providerIsEnable"]!!
            let isThisContactLike = userInformation["isLike"]!!
            
            photoUuid = (userInformation["profilePhotoId"]! as String?)!
            
            if nickName == "" {
                cell.nameLabel.text = userInformation["userName"]!
            } else {
                cell.nameLabel.text = nickName
            }
            
            // MARK - Set the images to indicate if the user is busy or not.
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
                cell.favoriteButton.backgroundColor = MaterialColor.red.accent1
            }
            
            if userInformation["chargeType"]!! as String == ContactType.Free.rawValue {
                cell.type.text = "免費"
                cell.type.textColor = MaterialColor.red.base
            } else {
                cell.type.text = userInformation["chargeType"]!! as String == ContactType.Paid.rawValue ? "付費" : "付費-由無 App 客戶產生"
                cell.type.textColor = MaterialColor.teal.darken4
            }
            
            cell.companyLabel.text = userInformation["company"]! as String? != "" ? userInformation["company"]! as String? : "未設定單位"
            cell.id = userInformation["id"]!
            cell.callee = userInformation["phoneNumber"]!
        }
        
        // MARK - Setting the user photo.
        cell.thumbnailImageView.image = UIImage(named: "user")
        cell.thumbnailImageView.layer.cornerRadius = 25.0
        cell.thumbnailImageView.clipsToBounds = true
        
        if photoUuid != "" {
            getImageApiRoute = API_END_POINT + "/avatars/" + photoUuid            
            Alamofire
                .request(.GET, getImageApiRoute!, headers: self.headers, parameters: ["size": "small"])
                .responseData {
                    response in
                    if response.data != nil {
                        dispatch_async(dispatch_get_main_queue(), {
                            cell.thumbnailImageView.image = UIImage(data: response.data!)
                            cell.thumbnailImageView.layer.cornerRadius = 25.0
                            cell.thumbnailImageView.clipsToBounds = true
                        })
                    }
                    
            }
        }
        
        cell.onCallButtonTapped = {
            if cell.isProviderEnable == false {
                self.createAlertView("抱歉!", body: "對方為忙碌狀態\n請查看對方可通話時段。", buttonValue: "確認")
                return
            }
            let callService = CallService.init(view: self.view, _self: self)
            callService.call(UserPref.getUserPrefByKey("userUuid"), caller: UserPref.getUserPrefByKey("phoneNumber"), callee: cell.callee! as String, contactId: cell.id)
        }
        
        cell.onFavoriteButtonTapped = {
            let contactId = cell.id
            let updateContactRoute = API_URI + versionV2 + "/accounts/" + contactId! + "/contacts/"

            if cell.isLike == true {
                debugPrint("Tap favorite false!")
                cell.favoriteButton.backgroundColor = MaterialColor.red.accent1
                cell.isLike = false
                
                Alamofire.request(.PUT, updateContactRoute, headers: self.headers, parameters: ["like": "False"], encoding: .URLEncodedInURL)
                    .response {
                        request, response, data, error in
                        if error != nil {
                            debugPrint(response)
                            cell.favoriteButton.backgroundColor = MaterialColor.red.darken1
                            cell.isLike = true
                            self.createAlertView("發生了錯誤!", body: "抱歉，請再次嘗試一次...", buttonValue: "確認")
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
                            cell.favoriteButton.backgroundColor = MaterialColor.red.accent1
                            cell.isLike = false
                            self.createAlertView("發生了錯誤!", body: "抱歉，請再次嘗試一次...", buttonValue: "確認")
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
                SwiftOverlays.showCenteredWaitOverlayWithText(self.view.superview!, text: "刪除中...")
                
                let deleteApiRoute = API_URI + versionV2 + "/accounts/" + (tableView.cellForRowAtIndexPath(indexPath) as! ContactTableCell).id! + "/contacts/"
                
                Alamofire.request(.DELETE, deleteApiRoute, encoding: .JSON, headers: self.headers).response {
                    request, response, data, error in
                    if error == nil {
                        self.tableView.beginUpdates()
                        SwiftOverlays.removeAllOverlaysFromView(self.view.superview!)
                        self.contactArray.removeAtIndex(indexPath.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        self.tableView.endUpdates()
                    } else {
                        SwiftOverlays.removeAllOverlaysFromView(self.view.superview!)
                    }
                }
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(deleteAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: GET: Get the contact list.
    private func getContactList() {
        
        let getInformationApiRoute = API_URI + versionV2 + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/contacts"
        
        Alamofire
            .request(.GET, getInformationApiRoute, headers: headers)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    let jsonResponse = JSON(JSON_RESPONSE)
                    debugPrint(jsonResponse)
                    self.contactArray = []
                    
                    for index in 0 ..< jsonResponse.count {
                        var contactInformation: [String: String?] = [String: String?]()
                        var people: People!
                        var keyValuePair = Array(jsonResponse[index])
                        
                        for indexKeys in 0 ..< keyValuePair.count {
                            contactInformation[keyValuePair[indexKeys].0] = jsonResponse[index][keyValuePair[indexKeys].0].stringValue
                        }
                        
                        people = People(userInformation: contactInformation)
                        self.contactArray.append(people)
                    }
                    
                    self.contactArray = self.contactArray.reverse()
                    
                    SwiftSpinner.hide()
                    self.tableView.reloadData()
                case .Failure(let error):
                    debugPrint(error)
                    
                    SwiftSpinner.hide()
                    self.createAlertView("您似乎沒有連上網路", body: "請開啟網路，再下拉畫面以更新", buttonValue: "確認")
                }
                
                SwiftOverlays.removeAllOverlaysFromView(self.view.superview!)
                self.refreshControl?.endRefreshing()
        }
    }
    
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
    
    func refresh(sender: AnyObject) {
        var reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            debugPrint("Unable to create Reachability")
            return
        }
        
        if reachability.isReachable() != true {
            debugPrint("Network is not connected!")
            self.createAlertView("您似乎沒有連上網路", body: "請開啟網路，再下拉畫面以更新。", buttonValue: "確認")
            self.refreshControl?.endRefreshing()
            self.view.userInteractionEnabled = true
        } else {
            getContactList()
        }
    }
    
    // MARK: Trigger when user click the row of contact, show detail.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailViewSegue" {
            if  let indexPath = tableView.indexPathForSelectedRow,
                let destinationViewController = segue.destinationViewController as? ContactDetailViewController {
                    destinationViewController.userInformation = contactArray[indexPath.row].data
                    destinationViewController.searchController = self.resultSearchController
            }
        }
    }
    
    private func createAlertView(title: String!, body: String!, buttonValue: String!) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonValue, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
