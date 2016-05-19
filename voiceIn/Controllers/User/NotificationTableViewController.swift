//
//  HistoryTableViewController.swift
//  VoiceIn
//
//  Created by Calvin Jeng on 4/12/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import UIKit
import Material
import Alamofire
import SwiftyJSON
import SwiftOverlays
import NSDate_TimeAgo

class NotificationTableViewController: UITableViewController {
    private var navigationBarView: NavigationBar = NavigationBar()
    let headers = Network.generateHeader(isTokenNeeded: true)
    var notificationArray: JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        getNotificationList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: GET: Get the contact list.
    private func getNotificationList() {
        self.view.userInteractionEnabled = false
        let getNotificationRoute = API_URI + latestVersion + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/notifications"
        SwiftOverlays.showCenteredWaitOverlayWithText(self.view.superview!, text: "讀取中...")
        
        Alamofire
            .request(.GET, getNotificationRoute, headers: headers)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    let jsonResponse = JSON(JSON_RESPONSE)
                    debugPrint(jsonResponse)
                    self.notificationArray = jsonResponse["notifications"]
                    self.tableView.reloadData()
                case .Failure(let error):
                    debugPrint(error)
                    AlertBox.createAlertView(self, title: "您似乎沒有連上網路", body: "請開啟網路，再下拉畫面以更新", buttonValue: "確認")
                }
                
                SwiftOverlays.removeAllOverlaysFromView(self.view.superview!)
                self.view.userInteractionEnabled = true
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if notificationArray.count == 0 {
            let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
            noDataLabel.text = "目前沒有通知"
            noDataLabel.font.fontWithSize(24)
            noDataLabel.textColor = MaterialColor.grey.darken2
            noDataLabel.textAlignment = NSTextAlignment.Center
            self.tableView.backgroundView = noDataLabel
        } else {
            self.tableView.backgroundView = nil
        }
        
        return notificationArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! HistoryTableCell
        let dateFormatter = NSDateFormatter()
        let time: String! = notificationArray[indexPath.row]["createdAt"].stringValue
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        cell.nameLabel.text = notificationArray[indexPath.row]["notificationContent"].stringValue
        
        cell.statusLabel.text = generateNotificationText(time)
        
        cell.contactId = notificationArray[indexPath.row]["contactId"].stringValue
        
        cell.detailTimeLabel.text = dateFormatter.stringFromDate((NSDate(timeIntervalSince1970: NSTimeInterval(time!)!/1000)))
        
        return cell
    }
    
    private func generateNotificationText(createAt: String?) -> String! {
        var timeAgo: String!
        
        if createAt == "-1" {
            timeAgo = ""
        } else {
            let time = (NSDate(timeIntervalSince1970: NSTimeInterval(createAt!)!/1000)).timeAgo()
            timeAgo = "於\(time)"
        }
        
        return timeAgo
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! HistoryTableCell
        let callService = CallService.init(view: self.view, _self: self)
        callService.call(UserPref.getUserPrefByKey("userUuid"), caller: UserPref.getUserPrefByKey("phoneNumber"), callee: "", contactId: cell.contactId)
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
    
}
