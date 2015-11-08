//
//  OnTel.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 17/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

class OnTel: TR064Service {
  
  static let serviceType = "urn:dslforum-org:service:X_AVM-DE_OnTel:1"
  
  private enum knownActions: String {
    case GetCallList
    
    var action: Action? {
      return TR064Manager.sharedManager.actions.filter { $0.service.serviceType == serviceType && $0.name == self.rawValue }.first
    }
  }
  
  private static var dataSource: [Call] {
    get { return (TR064Manager.sharedManager.observer as! CallListTableViewController).tableData }
    set { (TR064Manager.sharedManager.observer as? CallListTableViewController)?.tableData = newValue }
  }
  
  class func getCallList(argument: String = "", ignoreCache: Bool = false) {
    var cachedCalls = [Call]()
    if let cachedCallList = loadValuesFromDiskCache("CallList") where ignoreCache == false {
      cachedCalls = extractValuesFromPropertyListArray(cachedCallList)
      self.dataSource = cachedCalls
    }
    guard let action = knownActions.GetCallList.action
      else { return }
    TR064.startAction(action).then { xml in
      guard let url = xml.value.checkForURL()
        else { return }
      let callList = TR064.getXMLFromURL(url + argument)?.responseXMLPromise()
      callList?.then { callList in
        let newCalls = Call.extractCalls(callList.value).map { Call($0) }.flatMap {$0}
        if cachedCalls.count < newCalls.count {
          self.dataSource = newCalls
        saveValuesToDiskCache(newCalls, name: "CallList")
        }
      }
    }
  }
  
  class func getCallListForDays(days: Int) {
    getCallList("&days=\(days)")
  }
  
  class func getCallListMaxCalls(calls: Int) {
    getCallList("&max=\(calls)")
  }
  
}