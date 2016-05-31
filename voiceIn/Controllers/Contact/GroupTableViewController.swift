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
import Material

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
    
    // MARK: GET: Get the Group list.
    private func getGroupList() {
        if let superview = self.view.superview {
            SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "讀取中...")
        }
        let getInformationApiRoute = API_URI + latestVersion + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/groups"
        
        Alamofire
            .request(.GET, getInformationApiRoute, headers: headers)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    let jsonResponse = JSON(JSON_RESPONSE)
                    self.groupArray = jsonResponse["groups"]
                    
                    if self.groupArray.count == 0 {
                        self.tableView.backgroundView = AlertBox.generateCenterLabel(self, text: "請點右上角加號來新增群組!")
                        self.tableView.separatorColor = MaterialColor.white
                    } else {
                        self.tableView.reloadData()
                        self.tableView.backgroundView = nil
                        self.tableView.separatorColor = MaterialColor.grey.lighten2
                    }
                    
                case .Failure(let error):
                    debugPrint(error)
                    AlertBox.createAlertView(self, title: "抱歉", body: "伺服器忙碌中，請稍候再嘗試。", buttonValue: "確認")
                }
                
                if let superview = self.view.superview {
                    SwiftOverlays.removeAllOverlaysFromView(superview)
                }
        }
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! GroupTableCell

        cell.groupName.text = groupArray[indexPath.row]["groupName"].stringValue
        cell.groupNum.text = "有\(groupArray[indexPath.row]["contactCount"].stringValue)個聯絡人"
        cell.id = groupArray[indexPath.row]["groupId"].stringValue
        debugPrint(cell.groupName.text)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let contactListController = self.storyboard?.instantiateViewControllerWithIdentifier("ContactViewController") as! ContactTableViewController
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! GroupTableCell
        
        let getInformationApiRoute = API_URI + latestVersion + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/groups/" + cell.id + "/contacts"
        debugPrint(getInformationApiRoute)
        
        contactListController.getContactRoute = getInformationApiRoute
        contactListController.isFromGroupListView = true
        contactListController.navigationTitle = cell.groupName.text
        contactListController.groupId = cell.id
        
        self.navigationController?.pushViewController(contactListController, animated: true)
    }
    
    // MARK: Deletion
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath:NSIndexPath) {
        if editingStyle == .Delete {
            let deleteAlert = UIAlertController(title: "注意!", message: "確定要刪除此分類?", preferredStyle: UIAlertControllerStyle.Alert)
            
            deleteAlert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: {action in
                debugPrint("Deleting a row...")
                if let superview = self.view.superview {
                    SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "刪除中...")
                }
                
                let deleteApiRoute = API_URI + latestVersion + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/groups/" + (tableView.cellForRowAtIndexPath(indexPath) as! GroupTableCell).id!
                
                Alamofire
                    .request(.DELETE, deleteApiRoute, encoding: .JSON, headers: self.headers)
                    .response {
                        request, response, data, error in
                        if error == nil {
                            self.tableView.beginUpdates()
                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                            self.groupArray.arrayObject?.removeLast()
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


    @IBAction func showCreateGroupNameModal(sender: AnyObject) {
        let groupNameBox = UIAlertController(title: "請輸入分類名稱", message: "", preferredStyle: .Alert)
        groupNameBox.addTextFieldWithConfigurationHandler(configureGroupNameTextField)
        groupNameBox.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        groupNameBox.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler:{
            (UIAlertAction) in
                debugPrint("Item : \(self.groupNameTextField.text)")
                let mutipleSelectContactViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MutipleSelectContactView") as! GroupMutipleSelectTableViewController
            
                mutipleSelectContactViewController.groupName = self.groupNameTextField.text
                self.navigationController?.pushViewController(mutipleSelectContactViewController, animated: true)            
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
        UIApplication.sharedApplication().statusBarHidden = false;
    }

}
