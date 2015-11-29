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
      return manager[serviceType]?.filter { $0.name == self.rawValue }.first
    }
  }
  
  private static var dataSource: [String: String] {
    get { return manager.soapResponse as! [String: String] }
    set { manager.soapResponse = newValue }
  }
  
  static func getInfo() -> ActionResultPromise? {
    guard let service: Service = manager[serviceType],
      action = knownActions.GetInfo.action
      else { return nil }
    return manager.startAction(service, action: action).then { xml in
      self.dataSource = xml.value.convertWithAction(action)!
    }
  }
  
  static func getDeviceLog() -> ActionResultPromise? {
    guard let service: Service = manager[serviceType],
      action = knownActions.GetDeviceLog.action
      else { return nil }
    return manager.startAction(service, action: action).then { xml in
      self.dataSource = xml.value.convertWithAction(action)!
    }
  }
  
}