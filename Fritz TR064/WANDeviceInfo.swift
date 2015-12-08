//
//  WANDeviceInfo.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 01/12/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

class WANInterfaceConfig: TR064Service {
  
  weak var observer: XMLResponseViewController!
  
  static let serviceType = "urn:dslforum-org:service:WANCommonInterfaceConfig:1"
  
  private enum knownActions: String {
    case GetTotalBytesSent
    case GetTotalBytesReceived
    
    var action: Action? {
      return manager[serviceType]?.filter { $0.name == self.rawValue }.first
    }
  }
  
  private static var dataSource: [String: String] {
    get { return manager.soapResponse as! [String: String] }
    set { manager.soapResponse = newValue }
  }
  
  static func getTotalBytesSent() -> ActionResultPromise? {
    guard let service: Service = manager[serviceType],
      action = knownActions.GetTotalBytesSent.action
      else { return nil }
    return manager.startAction(service, action: action)
  }
  
  static func getTotalBytesReceived() -> ActionResultPromise? {
    guard let service: Service = manager[serviceType],
      action = knownActions.GetTotalBytesReceived.action
      else { return nil }
    return manager.startAction(service, action: action)
  }
  
}

class WANIPConnection: TR064Service {
  
  weak var observer: XMLResponseViewController!
  
  static let serviceType = "urn:dslforum-org:service:WANIPConnection:1"
  
  private enum knownActions: String {
    case GetStatusInfo
    case GetExternalIPAddress
    
    var action: Action? {
      return manager[serviceType]?.filter { $0.name == self.rawValue }.first
    }
  }
  
  private static var dataSource: [String: String] {
    get { return manager.soapResponse as! [String: String] }
    set { manager.soapResponse = newValue }
  }
  
  static func getStatusInfo() -> ActionResultPromise? {
    guard let service: Service = manager[serviceType],
      action = knownActions.GetStatusInfo.action
      else { return nil }
    return manager.startAction(service, action: action)
  }
  
  static func getExternalIPAddress() -> ActionResultPromise? {
    guard let service: Service = manager[serviceType],
      action = knownActions.GetExternalIPAddress.action
      else { return nil }
    return manager.startAction(service, action: action)
  }
  
  
}
