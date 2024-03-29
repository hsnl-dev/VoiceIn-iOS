//
//  ContactTableCell.swift
//  voiceIn
//
//  Created by Calvin Jeng on 2/19/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import UIKit
import Material

class ContactTableCell: MaterialTableViewCell{
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var companyLabel: UILabel!
    @IBOutlet var type: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet weak var callButton: FabButton!
    @IBOutlet weak var favoriteButton: FabButton!
    var onCallButtonTapped: (() -> Void)? = nil
    var onFavoriteButtonTapped: (() -> Void)? = nil
    var callee: String?
    var id: String?
    var isProviderEnable: Bool!
    var isLike: Bool! = false
    var peopleInfo: People? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.contentView.layer.borderColor = UIColor.lightGrayColor().CGColor
        //self.contentView.layer.borderWidth = 1
        self.callButton.tintColor = UIColor.whiteColor()
        
        let favoriteImgage: UIImage? = UIImage(named: "ic_favorite_white")
        self.favoriteButton.setImage(favoriteImgage, forState: .Normal)
        self.favoriteButton.tintColor = UIColor.whiteColor()
        
        self.layoutMargins = UIEdgeInsetsZero //or UIEdgeInsetsMake(top, left, bottom, right)
        self.separatorInset = UIEdgeInsetsZero //if you also want to adjust separatorInset
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func callButtonClicked(sender: FabButton) {
        print(sender.tag)
        if let onCallButtonTapped = self.onCallButtonTapped {
            onCallButtonTapped()
        }
    }
    
    @IBAction func favoriteButtonClicked(sender: FabButton) {
        print(sender.tag)
        if let onFavoriteButtonTapped = self.onFavoriteButtonTapped {
            onFavoriteButtonTapped()
        }
    }
    
}
