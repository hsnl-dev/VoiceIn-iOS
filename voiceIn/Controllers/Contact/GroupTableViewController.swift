//
//  GroupTableViewController.swift
//  VoiceIn
//
//  Created by Calvin Jeng on 4/6/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftOverlays

class GroupTableViewController: UITableViewController {
    var groupNameTextField: UITextField! = nil
    let headers = Network.generateHeader(isTokenNeeded: true)
    var groupArray: JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        getGroupList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: GET: Get the contact list.
    private func getGroupList() {
        SwiftOverlays.showCenteredWaitOverlayWithText(self.tableView!, text: "讀取中...")
        let getInformationApiRoute = API_URI + versionV1 + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/groups"
        
        Alamofire
            .request(.GET, getInformationApiRoute, headers: headers)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    let jsonResponse = JSON(JSON_RESPONSE)
                    self.groupArray = jsonResponse["groups"]
                    self.tableView.reloadData()
                case .Failure(let error):
                    debugPrint(error)
                    // MARK - TODO Error Handling
                }
                SwiftOverlays.removeAllOverlaysFromView(self.tableView!)
        }
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groupArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! GroupTableCell

        cell.groupName.text = groupArray[indexPath.row]["groupName"].stringValue
        cell.id = groupArray[indexPath.row]["groupId"].stringValue
        debugPrint(cell.groupName.text)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let contactListController = self.storyboard?.instantiateViewControllerWithIdentifier("ContactViewController") as! ContactTableViewController
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! GroupTableCell
        
        let getInformationApiRoute = API_URI + versionV1 + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/groups/" + cell.id + "/contacts"
        debugPrint(getInformationApiRoute)
        contactListController.getContactRoute = getInformationApiRoute
        contactListController.isFromGroupListView = true
        contactListController.navigationTitle = cell.groupName.text
        self.navigationController?.pushViewController(contactListController, animated: true)
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

    @IBAction func showCreateGroupNameModal(sender: AnyObject) {
        let groupNameBox = UIAlertController(title: "請輸入分類名稱", message: "", preferredStyle: .Alert)
        groupNameBox.addTextFieldWithConfigurationHandler(configureGroupNameTextField)
        groupNameBox.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        groupNameBox.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler:{
            (UIAlertAction) in
                debugPrint("Item : \(self.groupNameTextField.text)")
                let mutipleSelectContactViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MutipleSelectContactView") as! UINavigationController
                self.presentViewController(mutipleSelectContactViewController, animated: true, completion: nil)
            
        }))
        self.presentViewController(groupNameBox, animated: true, completion: {
            debugPrint("completion block")
        })
    }
    
    private func configureGroupNameTextField(textField: UITextField!) {
        textField.placeholder = "分類名稱"
        groupNameTextField = textField
    }
    
    @IBAction func closeTheMutipleSelectionView(segue: UIStoryboardSegue) {
        debugPrint("closeTheMutipleSelectionView")
    }

}