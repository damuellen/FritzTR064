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
  
  static let hostsActions = TR064Manager.sharedManager.actions.filter { $0.service.serviceType == "urn:dslforum-org:service:Hosts:1" }
  static var expectedActionNames = ["GetHostNumberOfEntries","GetSpecificHostEntry","GetGenericHostEntry","SetHostNameByMACAdress","WakeOnLANByMACAddress"]
  var foundedActions = { hostsActions.filter { expectedActionNames.contains($0.name) } }()
  
  var entries = [[String:String]]() {
    didSet {
      observer.tableData = entries
    }
  }
  
  var expectedActionsFound: Bool {
    return Hosts.expectedActionNames.count == self.foundedActions.count
  }
  
  subscript(name: String) -> Action {
    return self.foundedActions.filter { $0.name == name }.first!
  }
  
  func getHostNumberOfEntries() -> ActionResultPromise {
    return TR064.startAction(self["GetHostNumberOfEntries"])
  }
  
  func getHost(index: Int) -> ActionResultPromise  {
    return TR064.startAction(self["GetGenericHostEntry"], arguments: ["\(index)"])
  }
  
  func getAllHosts() {
    getHostNumberOfEntries().then { xml in
      var hosts = [ActionResultPromise]()
      if let number = Int((xml.value.convertResponseWithAction(self["GetHostNumberOfEntries"])?.values.first!)!) {
        for n in 0..<number {
          hosts.append(self.getHost(n))
        }
      }
      whenAll(hosts).then { hosts in
        self.entries = hosts.map {
          $0.value.convertResponseWithAction(self["GetGenericHostEntry"])
          }.flatMap {$0}
      }
    }
  }
  
}
  