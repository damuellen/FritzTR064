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
      return manager[serviceType]?.filter { $0.name == self.rawValue }.first
    }
  }
  
  private static var dataSource: [Call] {
    get { return (manager.soapResponse as? [Call]) ?? [] }
    set { manager.soapResponse = newValue }
  }
  
  static func getCallList(argument: String = "", ignoreCache: Bool = false) {
    var cachedCalls: [Call] = []
    if let cachedCallList = try? FileManager.loadCompressedValuesFromDiskCache(manager.device!.uuid + "-callList") where ignoreCache == false {
      cachedCalls = extractValuesFromPropertyListArray(cachedCallList)
      self.dataSource = cachedCalls
    }
    guard let service: Service = manager[serviceType],
      action = knownActions.GetCallList.action
      else { return }
    manager.startAction(service, action: action).then { xml in
      guard let url = xml.value.checkForURL()
        else { return }
      let callList = manager.getXMLFromURL(url + argument)?.responseXMLPromise()
      callList?.then { callList in
        let newCalls = Call.extractCalls(callList.value).map { Call($0) }.flatMap {$0}
        if cachedCalls.first?.id != newCalls.first?.id {
          self.dataSource = newCalls
          do {
            try FileManager.saveCompressedValuesToDiskCache(newCalls, name: manager.device!.uuid + "-callList")
          } catch { debugPrint("Error caching calllist") }
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
