//
//  GroupTableCell.swift
//  VoiceIn
//
//  Created by Calvin Jeng on 4/6/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import UIKit
import Material

class GroupMutipleSelectCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var companyLabel: UILabel!
    @IBOutlet var type: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!
    var id: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsetsZero //or UIEdgeInsetsMake(top, left, bottom, right)
        self.separatorInset = UIEdgeInsetsZero //if you also want to adjust separatorInset
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
