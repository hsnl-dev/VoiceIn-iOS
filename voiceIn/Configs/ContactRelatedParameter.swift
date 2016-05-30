//
//  ContactTableViewParam.swift
//  VoiceIn
//
//  Created by Calvin Jeng on 4/5/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import Foundation

enum ContactType: String {
    case Icon = "0"
    case Free = "1"
    case Paid = "2"
}

struct ContactTypeText {
    static let paidCallText = "付費撥打"
    static let freeCallText = "免費撥打"
    static let iconCallText = "付費撥打-對方無安裝 App"
}
