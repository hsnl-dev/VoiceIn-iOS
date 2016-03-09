import UIKit
import Material
import Alamofire
import SwiftyJSON
import SwiftSpinner
import EZLoadingActivity
//import SnapKit

class ContactTableViewController: UITableViewController {
    private var navigationBarView: NavigationBarView = NavigationBarView()
    let headers = Network.generateHeader(isTokenNeeded: true)
    let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: Array of ContactList
    var contactArray: [People] = []

    override func viewDidLoad() {
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        super.viewDidLoad()
        SwiftSpinner.show("讀取中...", animated: true)
        prepareView()
    }
    
    override func viewDidAppear(animated: Bool) {
        contactArray = []
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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ContactTableCell
        
        if indexPath.row > contactArray.count - 1 {
            return cell
        }
        
        var userInformation: [String: String?] = contactArray[indexPath.row].data
        var getImageApiRoute: String?
        let photoUuid = userInformation["profilePhotoId"]! as String?
        let nickName = userInformation["nickName"]! as String?
        
        if nickName == "" {
            cell.nameLabel.text = userInformation["userName"]!
        } else {
            cell.nameLabel.text = nickName
        }
        
        cell.companyLabel.text = userInformation["company"]! as String? != "" ? userInformation["company"]! as String? : "未設定單位"
        cell.qrCodeUuid = userInformation["qrCodeUuid"]!
        cell.callee = userInformation["phoneNumber"]!
        
        if photoUuid != "" {
            getImageApiRoute = API_END_POINT + "/avatars/" + photoUuid!
            
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
        } else {
            cell.thumbnailImageView.image = UIImage(named: "user")
            cell.thumbnailImageView.layer.cornerRadius = 25.0
            cell.thumbnailImageView.clipsToBounds = true
        }
        
        cell.onCallButtonTapped = {
            debugPrint(cell.callee)
            let callService = CallService.init(view: self.view, _self: self)
            callService.call(self.userDefaultData.stringForKey("userUuid")!, caller: self.userDefaultData.stringForKey("phoneNumber")!, callee: cell.callee! as String)
        }
        
        cell.onFavoriteButtonTapped = {
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath:NSIndexPath) {
        if editingStyle == .Delete {
            let deleteAlert = UIAlertController(title: "注意!", message: "確定要刪除此筆聯絡人?", preferredStyle: UIAlertControllerStyle.Alert)
            
            deleteAlert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: {action in
                print("deleting...")
                EZLoadingActivity.show("刪除中", disableUI: true)
                
                let deleteApiRoute = API_END_POINT + "/accounts/" + self.userDefaultData.stringForKey("userUuid")! + "/contacts/" + (tableView.cellForRowAtIndexPath(indexPath) as! ContactTableCell).qrCodeUuid!
                Alamofire.request(.DELETE, deleteApiRoute, encoding: .JSON, headers: self.headers).response {
                    request, response, data, error in
                    if error == nil {
                        debugPrint(error)
                        self.tableView.beginUpdates()
                        EZLoadingActivity.hide()
                        self.contactArray.removeAtIndex(indexPath.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        self.tableView.endUpdates()
                        debugPrint(self.contactArray)
                    } else {
                        EZLoadingActivity.hide()
                    }
                }
            }))
            
            deleteAlert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(deleteAlert, animated: true, completion: nil)
        }
    }
    
    /**
     GET: Get the user's information.
     **/
    private func getContactList() {
        self.view.userInteractionEnabled = false
        let getInformationApiRoute = API_END_POINT + "/accounts/" + userDefaultData.stringForKey("userUuid")! + "/contacts"
        
        Alamofire
            .request(.GET, getInformationApiRoute, headers: headers)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    let jsonResponse = JSON(JSON_RESPONSE)
                    debugPrint(jsonResponse)
                    
                    for var index = 0; index < jsonResponse.count; ++index {
                        var contactInformation: [String: String?] = [String: String?]()
                        var people: People!
                        var keyValuePair = Array(jsonResponse[index])
                        
                        for var indexKeys = 0; indexKeys < keyValuePair.count; ++indexKeys {
                            debugPrint(jsonResponse[index][keyValuePair[indexKeys].0])
                            contactInformation[keyValuePair[indexKeys].0] = jsonResponse[index][keyValuePair[indexKeys].0].stringValue
                        }
                        
                        people = People(userInformation: contactInformation)
                        self.contactArray.append(people)
                    }
                    
                    self.contactArray = self.contactArray.reverse()
                    SwiftSpinner.hide()
                    
                    self.tableView.reloadData()
                    self.view.userInteractionEnabled = true
                    self.refreshControl?.endRefreshing()
                case .Failure(let error):
                    debugPrint(error)
                    
                    SwiftSpinner.hide()
                    self.createAlertView("您似乎沒有連上網路", body: "請開啟網路，再下拉畫面以更新", buttonValue: "確認")
                    self.view.userInteractionEnabled = true
                    self.refreshControl?.endRefreshing()
                }
        }
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
            return
        }
        
        // MARK: Initialize the array.
        contactArray = []
        getContactList()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailViewSegue" {
            if  let indexPath = tableView.indexPathForSelectedRow,
                let destinationViewController = segue.destinationViewController as? ContactDetailViewController {
                    destinationViewController.userInformation = contactArray[indexPath.row].data
            }
        }
    }
    
    private func createAlertView(title: String!, body: String!, buttonValue: String!) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonValue, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
