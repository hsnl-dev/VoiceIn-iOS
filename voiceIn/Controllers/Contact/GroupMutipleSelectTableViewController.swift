//
//  GroupMutipleSelectTableViewController.swift
//  VoiceIn
//
//  Created by Calvin Jeng on 4/8/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import UIKit
import Material
import Alamofire
import SwiftyJSON
import Haneke
import SwiftOverlays
import CoreData

class GroupMutipleSelectTableViewController: UITableViewController {
    
    private var navigationBarView: NavigationBar = NavigationBar()
    let headers = Network.generateHeader(isTokenNeeded: true)
    var contactArray: [People] = []
    var seletedContactArray: [String] = []
    var groupName: String!
    var groupId: String!
    
    // MARK - It may be from create group view or update group view
    var isFromUpdateView: Bool = false
    let hnkImageCache = Shared.imageCache
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getContactList()
        self.tableView.allowsMultipleSelectionDuringEditing = true
        self.tableView.setEditing(true, animated: true)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: GET: Get the contact list.
    private func getContactList() {
        
        let getInformationApiRoute = API_URI + latestVersion + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/contacts"
        
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
                    
                    self.tableView.reloadData()
                case .Failure(let error):
                    debugPrint(error)
                    
                    AlertBox.createAlertView(self ,title: "您似乎沒有連上網路", body: "請開啟網路，再下拉畫面以更新", buttonValue: "確認")
                }
                
                self.view.userInteractionEnabled = true
                self.refreshControl?.endRefreshing()
        }
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contactArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GroupMutipleSelectCell
        var photoUuid = ""
        var getImageApiRoute: String?


        if indexPath.row > contactArray.count - 1 {
            return cell
        }
        
        var userInformation: [String: String?] = contactArray[indexPath.row].data
        let nickName = userInformation["nickName"]! as String?
        
        photoUuid = (userInformation["profilePhotoId"]! as String?)!
        
        if nickName == "" {
            cell.nameLabel.text = userInformation["userName"]!
        } else {
            cell.nameLabel.text = nickName
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
        
        // MARK - De-Select the cell and select the already selected contacts.
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if seletedContactArray.contains(cell.id) == true {
            self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
        
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
        cell.selectionStyle = .Gray;

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func createGroup(sender: UIButton!) {
        let selectedPaths = self.tableView.indexPathsForSelectedRows
        
        if selectedPaths == nil {
            AlertBox.createAlertView(self ,title: "抱歉", body: "請至少選擇一個聯絡人!", buttonValue: "確認")
            return
        }
        
        var contactsId: [String] = []
        
        for selectedPath in selectedPaths! {
            let selectedCell = self.tableView.cellForRowAtIndexPath(selectedPath) as! GroupMutipleSelectCell
            contactsId.append(selectedCell.id)
        }
        
        if self.isFromUpdateView == false {
            let createNewGroupRoute = API_URI + latestVersion + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/groups"
            let parameters = [
                "groupName": groupName,
                "contacts": contactsId
            ]
            
            debugPrint(parameters)
            Alamofire
                .request(.POST, createNewGroupRoute, headers: self.headers, parameters: parameters as? [String : AnyObject], encoding: .JSON)
                .response {
                    request, response, data, error in
                    if response?.statusCode >= 400 {
                        debugPrint(error)
                    } else {
                        debugPrint(response?.statusCode)
                        UIApplication.sharedApplication().statusBarHidden = false;
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
            }
        } else {
            let updateGroupRoute = API_URI + latestVersion + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/groups/" + groupId + "/contacts"
            let parameters = [
                "contacts": contactsId
            ]
            
            debugPrint(parameters)
            Alamofire
                .request(.PUT, updateGroupRoute, headers: self.headers, parameters: parameters, encoding: .JSON)
                .response {
                    request, response, data, error in
                    debugPrint(response?.statusCode)
                    if response?.statusCode >= 400 {
                        debugPrint(error)
                    } else {
                        UIApplication.sharedApplication().statusBarHidden = false;
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
            }
        }
    }

}
