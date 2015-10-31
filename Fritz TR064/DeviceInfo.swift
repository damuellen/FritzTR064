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
  
  private enum knownActions: String {
    case GetInfo
    case GetDeviceLog
    
    var action: Action? {
      return TR064Manager.sharedManager.actions.filter { $0.service.serviceType == serviceType && $0.name == self.rawValue }.first
    }
  }
  
  private static var dataSource: [String: String] {
    get { return ((manager.observer as! XMLResponseViewController).tableData) }
    set { (observer as? XMLResponseViewController)?.tableData = newValue }
  }
  
  class func getInfo() -> ActionResultPromise? {
    guard let action = knownActions.GetInfo.action else {
      return nil
    }
    return TR064.startAction(action).then { xml in
      self.dataSource = xml.value.convertWithAction(action)!
    }
  }
  
  class func getDeviceLog() -> ActionResultPromise? {
    guard let action = knownActions.GetDeviceLog.action else {
      return nil
    }
    return TR064.startAction(action).then { xml in
      self.dataSource = xml.value.convertWithAction(action)!
    }
  }
  
}