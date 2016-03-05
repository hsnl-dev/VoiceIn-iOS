//
//  ContactTableViewController.swift
//  voiceIn
//
//  Created by Calvin Jeng on 2/18/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import UIKit
import Material
import Alamofire

class ContactTableViewController: UITableViewController {
    private var navigationBarView: NavigationBarView = NavigationBarView()
    let contactArray:[People] = []

    override func viewDidLoad() {
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        super.viewDidLoad()
        prepareView()
    }
    
    func refresh(sender:AnyObject) {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    /// General preparation statements.
    private func prepareView() {
        view.backgroundColor = MaterialColor.white
        navigationBarView.statusBarStyle = .Default
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ContactTableCell
        
        cell.nameLabel.text = "Jony Ive"
        cell.type.text = "免費"
        cell.nickNameLabel.text = "老強尼"
        cell.qrCodeUuid = ""
        cell.callee = "+886975531444"
        
        cell.thumbnailImageView.image = UIImage(named: "jony")
        cell.thumbnailImageView.layer.cornerRadius = 25.0
        cell.thumbnailImageView.clipsToBounds = true
        
        cell.onCallButtonTapped = {
            print(cell.callee)
        }
        
        cell.onFavoriteButtonTapped = {
            print(cell.type.text)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath:NSIndexPath) {
        if editingStyle == .Delete {
        }
    }
}
