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
    var contactsId: [String] = []
    
    var groupName: String!
    var groupId: String!
    var isCreateClicked = false
    
    // MARK - It may be from create group view or update group view
    var isFromUpdateView: Bool = false
    let hnkImageCache = Shared.imageCache
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsMultipleSelectionDuringEditing = true
        self.tableView.setEditing(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // NOTE, MARK: - Put here to make swiftOverlays @ self.view.super work!
        if let superview = self.view.superview {
            SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "讀取中...")
        }
        
        getContactList()
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
                
                if let superview = self.view.superview {
                    SwiftOverlays.removeAllOverlaysFromView(superview)
                }
                
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
        if contactArray.count == 0 {
            self.tableView.separatorColor = MaterialColor.white
            self.tableView.backgroundView = AlertBox.generateCenterLabel(self, text: "目前沒有聯絡人")
        } else {
            self.tableView.separatorColor = MaterialColor.grey.lighten2
            self.tableView.backgroundView = nil
        }
        
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
            cell.type.text = ContactTypeText.freeCallText
            cell.type.textColor = MaterialColor.red.base
        } else {
            cell.type.text = userInformation["chargeType"]!! as String == ContactType.Paid.rawValue ? ContactTypeText.paidCallText : ContactTypeText.iconCallText
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! GroupMutipleSelectCell
        
        if (contactsId.contains(cell.id) == false) {
            contactsId.append(cell.id)
            seletedContactArray.append(cell.id)
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! GroupMutipleSelectCell
        contactsId = contactsId.filter { $0 != cell.id }
        seletedContactArray = seletedContactArray.filter { $0 != cell.id }
    }
    
    
    @IBAction func createGroup(sender: UIBarButtonItem!) {
        if contactsId.count == 0 {
            AlertBox.createAlertView(self ,title: "抱歉", body: "請至少選擇一個聯絡人!", buttonValue: "確認")
            return
        }
        
        if self.isFromUpdateView == false {
            // MARK - It is from create action.
            if isCreateClicked == true {
                return
            } else {
                isCreateClicked = true
            }
            
            let createNewGroupRoute = API_URI + latestVersion + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/groups"
            let parameters = [
                "groupName": groupName,
                "contacts": contactsId
            ]
            
            debugPrint(parameters)
            if let superview = self.view.superview {
                SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "建立中，請稍候...")
            }
            
            Alamofire
                .request(.POST, createNewGroupRoute, headers: self.headers, parameters: parameters as? [String : AnyObject], encoding: .JSON)
                .response {
                    request, response, data, error in
                    if response?.statusCode >= 400 {
                        debugPrint(error)
                        AlertBox.createAlertView(self, title: "抱歉", body: "網路出現錯誤，請稍候再嘗試!", buttonValue: "確認")
                        if let superview = self.view.superview {
                            SwiftOverlays.removeAllOverlaysFromView(superview)
                        }
                    } else {
                        debugPrint(response?.statusCode)
                        
                        if let superview = self.view.superview {
                            SwiftOverlays.removeAllOverlaysFromView(superview)
                        }
                    }
                    
                    self.isCreateClicked = false
                    self.navigationController?.popViewControllerAnimated(true)
            }
        } else {
            // MARK - It is from update action.
            let updateGroupRoute = API_URI + latestVersion + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/groups/" + groupId + "/contacts"
            
            let parameters = [
                "contacts": contactsId
            ]
            
            debugPrint(parameters)
            if let superview = self.view.superview {
                SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "更新中，請稍候...")
            }
            
            Alamofire
                .request(.PUT, updateGroupRoute, headers: self.headers, parameters: parameters, encoding: .JSON)
                .response {
                    request, response, data, error in
                    debugPrint(response?.statusCode)
                    if response?.statusCode >= 400 {
                        debugPrint(error)
                        AlertBox.createAlertView(self, title: "抱歉", body: "網路出現錯誤，請稍候再嘗試!", buttonValue: "確認")
                        if let superview = self.view.superview {
                            SwiftOverlays.removeAllOverlaysFromView(superview)
                        }
                    } else {
                        if let superview = self.view.superview {
                            SwiftOverlays.removeAllOverlaysFromView(superview)
                        }
                        
                        self.navigationController?.popViewControllerAnimated(true)
                    }
            }
        }
    }

}
