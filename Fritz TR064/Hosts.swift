//
//  Hosts.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 08/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

class Hosts: TR064Service {
  
  static let serviceType = "urn:dslforum-org:service:Hosts:1"
  
  private enum knownActions: String {
    case GetHostNumberOfEntries
    case GetSpecificHostEntry
    case GetGenericHostEntry
    case SetHostNameByMACAdress
    case WakeOnLANByMACAddress = "X_AVM-DE_WakeOnLANByMACAddress"
    
    var action: Action? {
      return manager[serviceType]?.filter { $0.name == self.rawValue }.first
    }
  }
  
  private static var dataSource: [Host] {
    get { return (manager.soapResponse as? [Host]) ?? [] }
    set { manager.soapResponse = newValue }
  }
  
  static func setHostName(name: String, ByMACAdress mac: String) {
    if let service: Service = manager[serviceType],
      action = knownActions.SetHostNameByMACAdress.action {
      manager.startAction(service, action: action, arguments: [name, mac])
    }
  }
  
  static func getHostNumberOfEntries() -> ActionResultPromise? {
    guard let service: Service = manager[serviceType],
      action = knownActions.GetHostNumberOfEntries.action else {
      return nil
    }
    return manager.startAction(service, action: action)
  }
  
  static func getHost(index: Int) -> ActionResultPromise? {
    guard let service: Service = manager[serviceType],
      action = knownActions.GetGenericHostEntry.action else {
      return nil
    }
    return manager.startAction(service, action: action, arguments: ["\(index)"])
  }

  static func getAllHosts() {
    var cachedHosts = [Host]()
    if let cachedHostList = try? FileManager.loadValuesFromDiskCache("Hosts") {
      cachedHosts = extractValuesFromPropertyListArray(cachedHostList)
      self.dataSource = cachedHosts
    }
    guard let HostNumberOfEntries = getHostNumberOfEntries() else { return }
    HostNumberOfEntries.then { xml in
      var hosts = [ActionResultPromise]()
      if let action = knownActions.GetHostNumberOfEntries.action,
        response = xml.value.convertWithAction(action),
        result = response.values.first,
        number = Int(result) {
        for n in 0..<number {
          if let host = self.getHost(n) {
            hosts.append(host)
          }
        }
      }
      guard let action = knownActions.GetGenericHostEntry.action else { return }
      whenAll(hosts).then { hosts in
        let newHosts = hosts.flatMap { $0.value.convertWithAction(action) }.map { Host(host: $0) }
        if cachedHosts.count < newHosts.count {
          self.dataSource = newHosts
          try! FileManager.saveValuesToDiskCache(newHosts, name: "Hosts")
        }
      }
    }
  }
  
  static func wakeHost(MAC: String) {
    guard let service: Service = manager[serviceType],
      action = knownActions.WakeOnLANByMACAddress.action else { return }
    manager.startAction(service, action: action, arguments: [MAC])
  }
  
}
  