//
//  Reachibility.swift
//  VoiceIn
//
//  Created by Calvin Jeng on 5/17/16.
//  Copyright © 2016 hsnl. All rights reserved.
//

import Foundation
import ReachabilitySwift

class Networker {
    class func isReach () -> Bool {
        var reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
            if reachability.isReachable() != true {
                return false
            } else {
                return true
            }
        } catch {
            debugPrint("Unable to create Reachability")
            return false
        }
    }
}