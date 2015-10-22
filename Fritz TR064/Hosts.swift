//
//  Hosts.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 08/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

class Hosts: TR064Service {
  
  static let serviceType = "urn:dslforum-org:service:Hosts:1"
  
  enum expectedActions: String {
    case GetHostNumberOfEntries
    case GetSpecificHostEntry
    case GetGenericHostEntry
    case SetHostNameByMACAdress
    case WakeOnLANByMACAddress = "X_AVM-DE_WakeOnLANByMACAddress"
    
    var action: Action? {
      return TR064Manager.sharedManager.actions.filter { $0.service.serviceType == serviceType && $0.name == self.rawValue }.first
    }
  }

  var entries: [[String:String]] {
    get { return ((manager.observer as? HostsVC)?.tableData)! }
    set { (manager.observer as? HostsVC)?.tableData = newValue }
  }
  
  func setHostName(name: String, ByMACAdress mac: String) {
    if let action = expectedActions.SetHostNameByMACAdress.action {
      TR064.startAction(action, arguments: [name, mac])
    }
  }
  
  func getHostNumberOfEntries() -> ActionResultPromise? {
    guard let action = expectedActions.GetHostNumberOfEntries.action else {
      return nil
    }
    return TR064.startAction(action)
  }
  
  func getHost(index: Int) -> ActionResultPromise? {
    guard let action = expectedActions.GetGenericHostEntry.action else {
      return nil
    }
     return TR064.startAction(action, arguments: ["\(index)"])
  }

  func getAllHosts() {
    guard let HostNumberOfEntries = getHostNumberOfEntries() else { return }
    HostNumberOfEntries.then { xml in
      var hosts = [ActionResultPromise]()
      if let action = expectedActions.GetHostNumberOfEntries.action,
        response = xml.value.convertWithAction(action),
        result = response.values.first,
        number = Int(result) {
        for n in 0..<number {
          if let host = self.getHost(n) {
            hosts.append(host)
          }
        }
      }
      guard let action = expectedActions.GetGenericHostEntry.action else { return }
      whenAll(hosts).then { hosts in
        self.entries = hosts.map {
          $0.value.convertWithAction(action)
          }.flatMap {$0}
      }
    }
  }
  
  func wakeHost(MAC: String) {
    guard let action = expectedActions.WakeOnLANByMACAddress.action else { return }
    TR064.startAction(action, arguments: [MAC])
  }
  
}
  