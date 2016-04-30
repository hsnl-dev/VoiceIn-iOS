//
//  GroupTableCell.swift
//  VoiceIn
//
//  Created by Calvin Jeng on 4/6/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import UIKit
import Material

class GroupTableCell: MaterialTableViewCell {
    @IBOutlet var groupName: UILabel!
    @IBOutlet var groupNum: UILabel!
    var id: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
