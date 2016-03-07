import UIKit
import Material
import Alamofire
import SwiftyJSON
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
        prepareView()
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

        cell.nameLabel.text = userInformation["userName"]!
        cell.type.text = "免費"
        cell.nickNameLabel.text = userInformation["nickName"] != nil ? userInformation["nickName"]! as String? : "未設定暱稱"
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
            
            let callApiRoute = API_END_POINT + "/accounts/" + self.userDefaultData.stringForKey("userUuid")! + "/calls"
            let parameters = [
                "caller": self.userDefaultData.stringForKey("phoneNumber")!,
                "callee": cell.callee! as String
            ]
            let delay = 1.2 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            
            self.createAlertView("為您撥號中...", body: "幾秒後系統即將來電，請放心接聽", buttonValue: "確認")
            
            dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            Alamofire.request(.POST, callApiRoute, encoding: .JSON, headers: self.headers, parameters: parameters).response {
                request, response, data, error in
                if error != nil {
                    debugPrint(error)
                    
                    self.createAlertView("抱歉!", body: "無法撥打成功請稍候再試。", buttonValue: "確認")
                    self.view.userInteractionEnabled = true
                    self.refreshControl?.endRefreshing()
                }
            }
        }
        
        cell.onFavoriteButtonTapped = {
            print(cell.type.text)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath:NSIndexPath) {
        if editingStyle == .Delete {
            let deleteAlert = UIAlertController(title: "注意!", message: "確定要刪除此筆聯絡人?", preferredStyle: UIAlertControllerStyle.Alert)
            
            deleteAlert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: {action in
                print("deleting...")
                let deleteApiRoute = API_END_POINT + "/accounts/" + self.userDefaultData.stringForKey("userUuid")! + "/contacts/" + (tableView.cellForRowAtIndexPath(indexPath) as! ContactTableCell).qrCodeUuid!
                Alamofire.request(.DELETE, deleteApiRoute, encoding: .JSON, headers: self.headers).response {
                    request, response, data, error in
                    if error == nil {
                        debugPrint(error)
                        print(indexPath.row)
                        self.contactArray.removeAtIndex(indexPath.row)
                        self.tableView.reloadData()
                        debugPrint(self.contactArray)
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
                    
                    self.tableView.reloadData()
                    self.view.userInteractionEnabled = true
                    self.refreshControl?.endRefreshing()
                case .Failure(let error):
                    debugPrint(error)
                    
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
