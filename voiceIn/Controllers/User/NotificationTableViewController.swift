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
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80
    }
    
    override func viewDidAppear(animated: Bool) {
        getNotificationList()
    }
    
    // MARK: GET: Get the contact list.
    private func getNotificationList() {
        self.view.userInteractionEnabled = false
        let getNotificationRoute = API_URI + latestVersion + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/notifications"
        if let superview = self.view.superview {
            SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "讀取中...")
        }
        
        Alamofire
            .request(.GET, getNotificationRoute, headers: headers)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    let jsonResponse = JSON(JSON_RESPONSE)
                    debugPrint(jsonResponse)
                    self.notificationArray = jsonResponse["notifications"]
                    
                    if self.notificationArray.count == 0 {
                        self.tableView.backgroundView = AlertBox.generateCenterLabel(self, text: "目前沒有通知")
                    } else {
                        self.tableView.reloadData()
                        self.tableView.backgroundView = nil
                    }
                case .Failure(let error):
                    debugPrint(error)
                    AlertBox.createAlertView(self, title: "您似乎沒有連上網路", body: "請開啟網路，再下拉畫面以更新", buttonValue: "確認")
                }
                
                if let superview = self.view.superview {
                    SwiftOverlays.removeAllOverlaysFromView(superview)
                }
                
                self.view.userInteractionEnabled = true
        }
    }
    
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        
        cell.nameLabel.numberOfLines = 0
        cell.nameLabel.sizeToFit()
        
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
}
