//
//  GroupTableViewController.swift
//  VoiceIn
//
//  Created by Calvin Jeng on 4/6/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import UIKit

class GroupTableViewController: UITableViewController {
    var groupNameTextField: UITextField! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
