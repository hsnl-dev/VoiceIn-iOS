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
import SwiftSpinner
import SwiftOverlays
import CoreData

class GroupMutipleSelectTableViewController: UITableViewController {
    
    private var navigationBarView: NavigationBarView = NavigationBarView()
    let headers = Network.generateHeader(isTokenNeeded: true)
    var contactArray: [People] = []
    var groupName: String!
    
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
                    
                    self.tableView.reloadData()
                case .Failure(let error):
                    debugPrint(error)
                    
                    self.createAlertView("您似乎沒有連上網路", body: "請開啟網路，再下拉畫面以更新", buttonValue: "確認")
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
        let selectedPaths = self.tableView.indexPathsForSelectedRows!
        let createNewGroupRoute = API_URI + versionV1 + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/groups"
        var contactsId: [String] = [String]()
        
        for selectedPath in selectedPaths {
            let selectedCell = self.tableView.cellForRowAtIndexPath(selectedPath) as! GroupMutipleSelectCell
            contactsId.append(selectedCell.id)
        }
        
        let parameters = [
            "groupName": groupName,
            "contacts": contactsId
        ]
        
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
    }
    
    private func createAlertView(title: String!, body: String!, buttonValue: String!) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonValue, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
