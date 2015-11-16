//
//  Settings.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 28/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

typealias Setting = Settings.defaults

class Settings {
  
  struct defaults {
    
    static let vpnAddress = (key: "server-address", defaultValue: "")
    static let vpnUserName = (key: "vpn-user-name", defaultValue: "")
    static let vpnGroupName = (key: "vpn-group-name", defaultValue: "")
    static let routerAddress = (key: "router-dddress", defaultValue: "http://fritz.box")
    static let routerUserName = (key: "router-user", defaultValue: "admin")
    static let launchedForTheFirstTime = (key: "first-time-launch", defaultValue: "yes")
    
  }
  
  static let userDefaults = NSUserDefaults.standardUserDefaults()

  static func get<T>(value: (key: String, defaultValue: T)) -> T {
    let val: T? = userDefaults.objectForKey(value.key) as? T
    return val ?? value.defaultValue
  }
  
  static func set<T>(key: String, toValue: T) {
    userDefaults.setObject((toValue as! AnyObject), forKey: key)
    userDefaults.synchronize()
  }
}

