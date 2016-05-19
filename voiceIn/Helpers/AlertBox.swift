//
//  AlertBox.swift
//  VoiceIn
//
//  Created by Calvin Jeng on 5/12/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import Foundation
import UIKit
import Material

class AlertBox {
    // MAKR - Create a AlertView.
    class func createAlertView(_self: UIViewController ,title: String!, body: String!, buttonValue: String!) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonValue, style: UIAlertActionStyle.Default, handler: nil))
        _self.presentViewController(alert, animated: true, completion: nil)
    }
    
    class func generateCenterLabel(_self: UITableViewController, text: String) -> UILabel {
        let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, _self.tableView.bounds.size.width, _self.tableView.bounds.size.height))
        noDataLabel.text = text
        noDataLabel.font.fontWithSize(24)
        noDataLabel.textColor = MaterialColor.grey.darken2
        noDataLabel.textAlignment = NSTextAlignment.Center
        
        return noDataLabel
    }
}