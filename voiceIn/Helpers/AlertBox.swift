//
//  AlertBox.swift
//  VoiceIn
//
//  Created by Calvin Jeng on 5/12/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import Foundation
import UIKit

class AlertBox {
    // MAKR - Create a AlertView.
    class func createAlertView(_self: UIViewController ,title: String!, body: String!, buttonValue: String!) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonValue, style: UIAlertActionStyle.Default, handler: nil))
        _self.presentViewController(alert, animated: true, completion: nil)
    }
}