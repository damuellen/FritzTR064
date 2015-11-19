//
//  Settings.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 28/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation


class Settings {
  
  static var externalURL: String? {
    get {
      return Settings.get("vpn-addrese")
    }
    set {
      Settings.set("vpn-addrese", toValue: newValue)
    }
  }
  
  static var useVPN: Bool {
    get {
    return Settings.get("use-VPN") ?? true
    }
    set {
      Settings.set("use-VPN", toValue: newValue)
    }
  }
  
  static var useSSL: Bool {
    get {
    return Settings.get("use-SSL") ?? true
    }
    set {
      Settings.set("use-SSL", toValue: newValue)
    }
  }
  
  static var internalRouterURL: String? {
    return Settings.get("router-addrese")
  }
  
  static let userDefaults = NSUserDefaults.standardUserDefaults()
  
  static func get<T>(key: String) -> T? {
    let val: T? = userDefaults.objectForKey(key) as? T
    return val
  }
  
  static func set<T>(key: String, toValue: T) {
    userDefaults.setObject((toValue as! AnyObject), forKey: key)
    userDefaults.synchronize()
  }
  
}

