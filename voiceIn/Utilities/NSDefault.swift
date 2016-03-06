//
//  NSDefault.swift
//  VoiceIn
//
//  Created by Calvin Jeng on 3/5/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import UIKit

public class NSDefault: NSObject {    
    static public func updateUserInformation(userInformation userInformation: [String: String?]) -> Bool {
        let userDefaultData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaultData.setValue(userInformation["userName"]!, forKey: "userName")
        userDefaultData.setValue(userInformation["profile"]!, forKey: "profile")
        userDefaultData.setValue(userInformation["location"]!, forKey: "location")
        userDefaultData.setValue(userInformation["company"]!, forKey: "company")
        userDefaultData.setValue(userInformation["availableStartTime"]!, forKey: "availableStartTime")
        userDefaultData.setValue(userInformation["availableEndTime"]!, forKey: "availableEndTime")
        userDefaultData.setValue(userInformation["phoneNumber"]!, forKey: "phoneNumber")
        userDefaultData.setValue(userInformation["qrCodeUuid"]!, forKey: "qrCodeUuid")
        return true
    }
}
