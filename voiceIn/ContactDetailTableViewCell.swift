//
//  ContactDetailTableViewCell.swift
//  VoiceIn
//
//  Created by Calvin Jeng on 3/5/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import UIKit

class ContactDetailTableViewCell: UITableViewCell {
    @IBOutlet var fieldLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsetsZero //or UIEdgeInsetsMake(top, left, bottom, right)
        self.separatorInset = UIEdgeInsetsZero //if you also want to adjust separatorInset
    }

}
