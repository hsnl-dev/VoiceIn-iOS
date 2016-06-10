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

class HistoryTableViewController: UITableViewController {
    private var navigationBarView: NavigationBar = NavigationBar()
    let headers = Network.generateHeader(isTokenNeeded: true)
    var historyArray: JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        if let superview = self.view.superview {
            SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "讀取中...")
        }
        
        if UserPref.getUserPrefByKey("historyCount") != nil && UserPref.getUserPrefByKey("historyCount") == "1" {
            let tabItem = self.tabBarController?.tabBar.items![3]
            tabItem!.badgeValue = nil
            UserPref().setUserPref("historyCount", value: "0").syncAll()
        }
        
        getHistoryList()
    }
    
    // MARK: GET: Get the contact list.
    private func getHistoryList() {
        let getHistoryRoute = API_URI + latestVersion + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/history"
        
        Alamofire
            .request(.GET, getHistoryRoute, headers: headers)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    let jsonResponse = JSON(JSON_RESPONSE)
                    
                    debugPrint(jsonResponse)
                    self.historyArray = jsonResponse["record"]
                    
                    if self.historyArray.count == 0 {
                        self.tableView.separatorColor = MaterialColor.white
                        self.tableView.backgroundView = AlertBox.generateCenterLabel(self, text: "目前沒有通話紀錄")
                    } else {
                        self.tableView.separatorColor = MaterialColor.grey.lighten2
                        self.tableView.reloadData()
                        self.tableView.backgroundView = nil
                    }
                case .Failure(let error):
                    debugPrint(error)
                    AlertBox.createAlertView(self ,title: "您似乎沒有連上網路", body: "請開啟網路，再下拉畫面以更新", buttonValue: "確認")
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
        return historyArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! HistoryTableCell
        let dateFormatter = NSDateFormatter()
        let time: String? = historyArray[indexPath.row]["reqTime"].stringValue
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        cell.nameLabel.text = historyArray[indexPath.row]["anotherNickName"].stringValue == "" ? historyArray[indexPath.row]["anotherName"].stringValue : historyArray[indexPath.row]["anotherNickName"].stringValue
            
        cell.statusLabel.text = generateHistoryText(historyArray[indexPath.row]["type"].stringValue, startTime: time, hangup: historyArray[indexPath.row]["answer"].stringValue)
        
        debugPrint(time)
        
        cell.detailTimeLabel.text = dateFormatter.stringFromDate((NSDate(timeIntervalSince1970: NSTimeInterval(time!)!/1000)))
        
        switch historyArray[indexPath.row]["type"].stringValue {
        case "outgoing":
            cell.callStatusImage.image = UIImage(named: "ic_call_made")
            break;
        case "incoming":
            cell.callStatusImage.image = UIImage(named: "ic_call_received")
            break;
        default:
            break;
        }
        
        cell.contactId = historyArray[indexPath.row]["contactId"].stringValue
        cell.textLabel?.textColor = MaterialColor.grey.lighten2
        
        if historyArray[indexPath.row]["answer"].stringValue == "false" {
            cell.statusLabel?.textColor = MaterialColor.red.base
            cell.callStatusImage.image = UIImage(named: "ic_call_missed")
        }
        
        return cell
    }
    
    private func generateHistoryText(type: String!, startTime: String?, hangup: String!) -> String! {
        var timeAgo: String!
        
        if startTime == "-1" {
            timeAgo = ""
        } else {
            let time = (NSDate(timeIntervalSince1970: NSTimeInterval(startTime!)!/1000)).timeAgo()
            timeAgo = "於\(time)"
        }
        
        if type == "outgoing" {
            let isHangupText: String! = hangup == "true" ? "有接通" : "未接通"
            return "\(timeAgo)撥出 - \(isHangupText)"
        } else {
            let isHangupText: String! = hangup == "true" ? "有接通" : "未接通"
            return "\(timeAgo)撥入 - \(isHangupText)"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! HistoryTableCell
        let callService = CallService.init(view: self.view, _self: self)
        callService.call(UserPref.getUserPrefByKey("userUuid"), caller: UserPref.getUserPrefByKey("phoneNumber"), callee: "", contactId: cell.contactId)
    }
}
