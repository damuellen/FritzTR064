//
//  Hosts.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 08/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

class Hosts: TR064Service {
  
  static let sharedHosts = Hosts()
  weak var observer: HostsVC?
  
  let serviceType = "urn:dslforum-org:service:Hosts:1"
  
  enum expectedActions: String {
    case getHostNumberOfEntries = "GetHostNumberOfEntries"
    case getSpecificHostEntry = "GetSpecificHostEntry"
    case getGenericHostEntry = "GetGenericHostEntry"
    case setHostNameByMACAdress = "SetHostNameByMACAdress"
    case wakeOnLANByMACAddress = "X_AVM-DE_WakeOnLANByMACAddress"
  }
  
  var entries = [[String:String]]() {
    didSet {
      observer?.tableData = entries
    }
  }
  
  subscript(name: expectedActions) -> Action? {
    return self.actions.filter { $0.name == name.rawValue }.first
  }
  
  func setHostName(name: String, ByMACAdress mac: String) {
    guard let action = self[.getHostNumberOfEntries] else { return }
    TR064.startAction(action, arguments: [name, mac])
  }
  
  func getHostNumberOfEntries() -> ActionResultPromise? {
    guard let action = self[.getHostNumberOfEntries] else {
      return nil
    }
    return TR064.startAction(action)
  }
  
  func getHost(index: Int) -> ActionResultPromise? {
    guard let action = self[.getGenericHostEntry] else {
      return nil
    }
    return TR064.startAction(action, arguments: ["\(index)"])
  }

  func getAllHosts() {
    getHostNumberOfEntries()?.then { xml in
      var hosts = [ActionResultPromise]()
      if let action = self[.getHostNumberOfEntries],
        response = xml.value.convertWithAction(action),
        result = response.values.first,
        number = Int(result) {
        for n in 0..<number {
          if let host = self.getHost(n) {
            hosts.append(host)
          }
        }
      }
      whenAll(hosts).then { hosts in
        self.entries = hosts.map {
          $0.value.convertWithAction(self[.getGenericHostEntry]!)
          }.flatMap {$0}
      }
    }
  }
  
  func wakeHost(MAC: String) {
    guard let action = self[.wakeOnLANByMACAddress] else { return }
    TR064.startAction(action, arguments: [MAC])
  }
  
}
  