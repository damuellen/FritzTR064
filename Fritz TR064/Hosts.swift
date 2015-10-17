//
//  Hosts.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 08/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

class Hosts {
  
  static let sharedHosts = Hosts()
  
  var observer: HostsVC!
  
  static let actions = TR064Manager.sharedManager.actions
    .filter { $0.service.serviceType == "urn:dslforum-org:service:Hosts:1" }
    .filter { Hosts.expectedActionNames(rawValue: $0.name) != nil }
  
  enum expectedActionNames: String {
    case getHostNumberOfEntries = "GetHostNumberOfEntries"
    case getSpecificHostEntry = "GetSpecificHostEntry"
    case getGenericHostEntry = "GetGenericHostEntry"
    case setHostNameByMACAdress = "SetHostNameByMACAdress"
    case wakeOnLANByMACAddress = "X_AVM-DE_WakeOnLANByMACAddress"
  }
  
  var entries = [[String:String]]() {
    didSet {
      observer.tableData = entries
    }
  }
  
  subscript(name: expectedActionNames) -> Action {
    return Hosts.actions.filter { $0.name == name.rawValue }.first!
  }
  
  func getHostNumberOfEntries() -> ActionResultPromise {
    let action = self[.getHostNumberOfEntries]
    return TR064.startAction(action)
  }
  
  func getHost(index: Int) -> ActionResultPromise {
    let action = self[.getGenericHostEntry]
    return TR064.startAction(action, arguments: ["\(index)"])
  }
  
  func getAllHosts() {
    getHostNumberOfEntries().then { xml in
      var hosts = [ActionResultPromise]()
      if let number = Int((xml.value.convertResponseWithAction(self[.getHostNumberOfEntries])?.values.first!)!) {
        for n in 0..<number {
          hosts.append(self.getHost(n))
        }
      }
      whenAll(hosts).then { hosts in
        self.entries = hosts.map {
          $0.value.convertResponseWithAction(self[.getGenericHostEntry])
          }.flatMap {$0}
      }
    }
  }
  
  func wakeHost(MAC: String) {
    TR064.startAction(self[.wakeOnLANByMACAddress], arguments: [MAC])
  }
  
}
  