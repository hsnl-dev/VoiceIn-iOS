//
//  FavoriteContactTableViewController.swift
//  VoiceIn
//
//  Created by Calvin Jeng on 4/5/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import UIKit
import Material
import Alamofire
import SwiftyJSON
import SwiftOverlays
import CoreData
import Haneke
import ReachabilitySwift

class FavoriteContactTableViewController: UITableViewController {
    
    private var navigationBarView: NavigationBar = NavigationBar()
    let headers = Network.generateHeader(isTokenNeeded: true)
    var resultSearchController = UISearchController()
    
    // MARK: Array of ContactList
    var contactArray: [People] = []
    // MARK - Image Cache
    let hnkImageCache = Shared.imageCache
    
    override func viewDidLoad() {
        self.refreshControl?.addTarget(self, action: #selector(FavoriteContactTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        super.viewDidLoad()
        prepareView()
    }
    
    override func viewDidAppear(animated: Bool) {
        if let superview = self.view.superview {
            SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "讀取中...")
        }
        
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
    
    // MARK: - the number of row in a section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactArray.count
    }
    
    // MARK: Brain to show contactlist.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ContactTableCell
        var photoUuid = ""
        var getImageApiRoute: String?
        
        
        // MARK: When searchbar is inactive, do this block!
        if indexPath.row > contactArray.count - 1 {
            return cell
        }
        
        var userInformation: [String: String?] = contactArray[indexPath.row].data
        let nickName = userInformation["nickName"]! as String?
        let providerIsEnable = userInformation["providerIsEnable"]!!
        
        photoUuid = (userInformation["profilePhotoId"]! as String?)!
        
        if nickName == "" {
            cell.nameLabel.text = userInformation["userName"]!
        } else {
            cell.nameLabel.text = nickName
        }
        
        // MARK - Set the images to indicate if the user is busy or not.
        if providerIsEnable == "false" {
            let phoneImgage: UIImage? = UIImage(named: "ic_phone_locked_white")
            cell.callButton.setImage(phoneImgage, forState: .Normal)
            cell.callButton.backgroundColor = MaterialColor.black
            cell.isProviderEnable = false
        } else {
            let phoneImgage: UIImage? = UIImage(named: "ic_call_white")
            cell.callButton.setImage(phoneImgage, forState: .Normal)
            cell.callButton.backgroundColor = MaterialColor.blue.accent3
            cell.isProviderEnable = true
        }
        
        if userInformation["chargeType"]!! as String == ContactType.Free.rawValue {
            cell.type.text = ContactTypeText.freeCallText
            cell.type.textColor = MaterialColor.red.base
        } else {
            cell.type.text = userInformation["chargeType"]!! as String == ContactType.Paid.rawValue ? ContactTypeText.paidCallText : ContactTypeText.iconCallText
            cell.type.textColor = MaterialColor.teal.darken4
        }
        
        cell.favoriteButton.backgroundColor = MaterialColor.red.darken1
        cell.isLike = true
        
        cell.companyLabel.text = userInformation["company"]! as String? != "" ? userInformation["company"]! as String? : "未設定單位"
        cell.id = userInformation["id"]!
        cell.callee = userInformation["phoneNumber"]!
        
        // MARK - Set the photo of users.
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
        
        cell.onCallButtonTapped = {
            if cell.isProviderEnable == false {
                AlertBox.createAlertView(self ,title: "抱歉!", body: "對方為忙碌狀態\n請查看對方可通話時段。", buttonValue: "確認")
                return
            }
            let callService = CallService.init(view: self.view, _self: self)
            callService.call(UserPref.getUserPrefByKey("userUuid"), caller: UserPref.getUserPrefByKey("phoneNumber"), callee: cell.callee! as String, contactId: cell.id)
        }
        
        cell.onFavoriteButtonTapped = {
            debugPrint(indexPath)
            
            let contactId = cell.id
            let updateContactRoute = API_URI + latestVersion + "/accounts/" + contactId! + "/contacts/"
            
            debugPrint("Tap favorite false!")
            cell.favoriteButton.backgroundColor = MaterialColor.red.accent1
            cell.isLike = false
            
            Alamofire.request(.PUT, updateContactRoute, headers: self.headers, parameters: ["like": "False"], encoding: .URLEncodedInURL)
                .response {
                    request, response, data, error in
                    if error != nil {
                        debugPrint(response)
                        cell.favoriteButton.backgroundColor = MaterialColor.red.darken1
                        cell.isLike = true
                        AlertBox.createAlertView(self ,title: "發生了錯誤!", body: "抱歉，請再次嘗試一次...", buttonValue: "確認")
                    } else {
                        self.tableView.beginUpdates()
                        self.contactArray.removeAtIndex(indexPath.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        self.tableView.endUpdates()
                    }
            }
            
        }
        
        return cell
    }
    
    // MARK: GET: Get the contact list.
    private func getContactList() {
        let getInformationApiRoute = API_URI + latestVersion + "/accounts/" + UserPref.getUserPrefByKey("userUuid") + "/contacts"
        
        Alamofire
            .request(.GET, getInformationApiRoute, headers: headers, parameters: ["filter": "like"], encoding: .URLEncodedInURL)
            .responseJSON {
                response in
                switch response.result {
                case .Success(let JSON_RESPONSE):
                    let jsonResponse = JSON(JSON_RESPONSE)
                    debugPrint(jsonResponse.count)
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
                    
                    if self.contactArray.count > 0 {
                        self.tableView.backgroundView = nil
                        self.tableView.separatorColor = MaterialColor.grey.lighten2
                    } else {
                        self.tableView.backgroundView = AlertBox.generateCenterLabel(self, text: "點聯絡人右邊的愛心加入常用喔")
                        self.tableView.separatorColor = MaterialColor.white
                    }
                    
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
    
    func refresh(sender: AnyObject) {
        if Networker.isReach() != true {
            debugPrint("Network is not connected!")
            AlertBox.createAlertView(self ,title: "您似乎沒有連上網路", body: "請開啟網路，再下拉畫面以更新。", buttonValue: "確認")
            self.refreshControl?.endRefreshing()
        } else {
            if let superview = self.view.superview {
                SwiftOverlays.showCenteredWaitOverlayWithText(superview, text: "讀取中...")
            }
            
            getContactList()
        }
    }
    
    // MARK: Trigger when user click the row of contact, show detail.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        debugPrint("Perform segue")
        if segue.identifier == "DetailViewSegue" {
            if  let indexPath = tableView.indexPathForSelectedRow,
                let destinationViewController = segue.destinationViewController as? ContactDetailViewController {
                destinationViewController.userInformation = contactArray[indexPath.row].data
                destinationViewController.searchController = self.resultSearchController
            }
        }
    }
}
