//
//  ContactTableViewController.swift
//  voiceIn
//
//  Created by Calvin Jeng on 2/18/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import UIKit
import Material

class ContactTableViewController: UITableViewController {
    private var navigationBarView: NavigationBarView = NavigationBarView()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
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
        
        cell.thumbnailImageView.image = UIImage(named: "jony")
        cell.thumbnailImageView.layer.cornerRadius = 25.0
        cell.thumbnailImageView.clipsToBounds = true
        
        cell.onCallButtonTapped = {
            print(cell.type.text)
        }
        
        cell.onFavoriteButtonTapped = {
            print(cell.type.text)
        }
        
        return cell
    }

}
