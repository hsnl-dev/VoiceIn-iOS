//
//  HistoryTableCell.swift
//  VoiceIn
//
//  Created by Calvin Jeng on 4/12/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import UIKit
import Material

class HistoryTableCell: MaterialTableViewCell {
    @IBOutlet var callStatusImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var detailTimeLabel: UILabel!
    var contactId: String!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
