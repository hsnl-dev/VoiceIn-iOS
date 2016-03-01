//
//  UserInformationViewController.swift
//  voiceIn
//
//  Created by Calvin Jeng on 3/1/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import UIKit
import Eureka
import Material

class UserInformationViewController: FormViewController {
    
    private var navigationBarView: NavigationBarView = NavigationBarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 32
            cell.accessoryView?.frame = CGRectMake(0, 0, 64, 64)
        }

        form +++
            Section(header: "", footer: "")
            +++ Section("")
            +++ Section(header: "基本資料", footer: "")
            
            <<< ImageRow(){
                $0.title = "您的大頭貼"
                $0.cell.height = {
                    let height: CGFloat = 70.0
                    return height
                }
            }
            
            <<< NameRow() {
                    $0.title = "您的姓名:"
                    $0.placeholder = "必填"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }
            
            <<< NameRow() {
                    $0.title = "您的職稱:"
                    $0.placeholder = ""
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }
            
            <<< NameRow() {
                    $0.title = "所屬公司:"
                    $0.placeholder = ""
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }
            
            <<< EmailRow() {
                $0.title = "您的信箱"
                $0.value = ""
            }
            
            <<< NameRow() {
                    $0.title = "位置:"
                    $0.placeholder = "台北, 台灣"
                }
                .cellSetup { cell, row in
                    cell.imageView?.image = UIImage(named: "plus_image")
            }
            
            +++ Section(header: "方便通話時段", footer: "您可以隨時設定您方便的通話同段")
            
            <<< TimeInlineRow(){
                $0.title = "開始時間"
                $0.value = NSDate()
            }
            
            <<< TimeInlineRow(){
                $0.title = "結束時間"
                $0.value = NSDate()
            }
            
            +++ Section("關於您")
            
            <<< TextAreaRow() { $0.placeholder = "介紹您自己，讓大家更能夠瞭解您。" }
        
        // Title label.
        let titleLabel: UILabel = UILabel()
        titleLabel.text = "您的個人資料"
        titleLabel.textAlignment = .Center
        titleLabel.textColor = MaterialColor.white
        titleLabel.font = RobotoFont.regularWithSize(17)
        
        // Search button.
        let image = UIImage(named: "ic_save_white")
        let saveButton: FlatButton = FlatButton()
        saveButton.pulseColor = MaterialColor.white
        saveButton.pulseScale = false
        saveButton.setImage(image, forState: .Normal)
        saveButton.setImage(image, forState: .Highlighted)
        saveButton.addTarget(self, action: "saveButtonClicked:", forControlEvents: .TouchUpInside)
        
        navigationBarView.statusBarStyle = .LightContent
        
        navigationBarView.backgroundColor = MaterialColor.blue.base
        navigationBarView.titleLabel = titleLabel
        navigationBarView.rightControls = [saveButton]
        
        view.addSubview(navigationBarView)
    }
    
    func saveButtonClicked(sender: UIButton!) {
        print("Click save.")
        // TODO: Requst to save the user's information.
        
        let contactTableView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainTabViewController") as! UITabBarController
        self.presentViewController(contactTableView, animated: true, completion: nil)
    }
}
