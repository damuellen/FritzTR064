//
//  Hosts.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 08/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation
import Alamofire

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
  
  func getHostNumberOfEntries() -> Promise<AFPValue<AEXMLDocument>, AFPError> {
    let getHostNumberOfEntries = self.foundedActions.lazy.filter { $0.name == "GetHostNumberOfEntries" }.first!
    return TR064.sendRequest(getHostNumberOfEntries).responseXMLPromise()
  }

  func getHost(index: Int) -> Promise<AFPValue<AEXMLDocument>, AFPError>  {
    let getGenericHostEntry = self.foundedActions.lazy.filter { $0.name == "GetGenericHostEntry" }.first!
    return TR064.sendRequest(getGenericHostEntry, arguments: ["\(index)"]).responseXMLPromise()
  }

  func getAllHosts() {
    var hosts = [Promise<AFPValue<AEXMLDocument>, AFPError>]()
    var action = self.foundedActions.lazy.filter { $0.name == "GetHostNumberOfEntries" }.first!
    getHostNumberOfEntries().then { XML in
      if let number = Int((XML.value.checkResponseOf(Action: action)?.convertResponseWith(Action: action)?.values.first)!) {
        for n in 0..<number {
          hosts.append(self.getHost(n))
        }
      }
    }
    action = self.foundedActions.lazy.filter { $0.name == "GetGenericHostEntry" }.first!
    whenAll(hosts).then { hosts in
      self.entries = hosts.map {
        $0.value.checkResponseOf(Action: action)?.convertResponseWith(Action: action)
        }.flatMap {$0}
    }
  }
  
}
  