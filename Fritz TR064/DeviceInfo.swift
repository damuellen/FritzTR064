//
//  DeviceInfo.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 18/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

class DeviceInfo: TR064Service {
  
  static let sharedService = DeviceInfo()
  weak var observer: XMLResponseViewController!
  
  let serviceType = "urn:dslforum-org:service:DeviceInfo:1"
  
  enum expectedActions: String {
    case getInfo = "GetInfo"
    
    var action: Action? {
      return DeviceInfo.sharedService.actions.filter { $0.name == self.rawValue }.first
    }
  }
  
  var entries = [String:String]() {
    didSet {
      observer?.tableData = entries
    }
  }
  
}