//
//  DeviceInfo.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 18/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

class DeviceInfo: TR064Service {
  
  weak var observer: XMLResponseViewController!
  
  static let serviceType = "urn:dslforum-org:service:DeviceInfo:1"
  
  enum expectedActions: String {
    case getInfo = "GetInfo"
    
    var action: Action? {
      return TR064Manager.sharedManager.actions.filter { $0.service.serviceType == serviceType && $0.name == self.rawValue }.first
    }
  }
  
  var entries = [String:String]() {
    didSet {
      observer?.tableData = entries
    }
  }
  
}