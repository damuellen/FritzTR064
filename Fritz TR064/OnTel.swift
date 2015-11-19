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
      return manager.activeDevice?.actions.filter { $0.service.serviceType == serviceType && $0.name == self.rawValue }.first
    }
  }
  
  private static var dataSource: [Call] {
    get { return (manager.soapResponse as? [Call]) ?? [] }
    set { manager.soapResponse = newValue }
  }
  
  static func getCallList(argument: String = "", ignoreCache: Bool = false) {
    var cachedCalls = [Call]()
    if let cachedCallList = FileManager.loadValuesFromDiskCache("CallList") where ignoreCache == false {
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
        if cachedCalls.first?.id != newCalls.first?.id {
          self.dataSource = newCalls
        FileManager.saveValuesToDiskCache(newCalls, name: "CallList")
        }
      }
    }
  }
  
  static func getCallListForDays(days: Int) {
    getCallList("&days=\(days)")
  }
  
  static func getCallListMaxCalls(calls: Int) {
    getCallList("&max=\(calls)")
  }
  
  static func getCallListAfter(id: Int) {
    getCallList("&id=\(id)")
  }
  
  
}