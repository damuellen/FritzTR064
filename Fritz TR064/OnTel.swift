//
//  OnTel.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 17/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

class OnTel: TR064Service {
  
  static let sharedService = OnTel()
  weak var observer: CallListTableViewController!
  
  let serviceType = "urn:dslforum-org:service:X_AVM-DE_OnTel:1"
  
  enum expectedActions: String {
    case GetCallList
    
    var action: Action? {
      return OnTel.sharedService.actions.filter { $0.name == self.rawValue }.first
    }
  }
  
  var entries = [Call]() {
    didSet {
      observer.tableData = entries
    }
  }
  
  func getCallList(argument: String = "") {
    guard let action = expectedActions.GetCallList.action else { return }
    TR064.startAction(action).then { xml in
      guard let url = xml.value.checkForURL() else { return }
      let callList = TR064.getXMLFromURL(url + argument)?.responseXMLPromise()
      callList?.then { callList in
        self.entries = callList.value.transformXMLtoCalls()
      }
    }
  }
  
  func getCallListForDays(days: Int) {
    getCallList("&days=\(days)")
  }
  
  func getCallListMaxCalls(calls: Int) {
    getCallList("&max=\(calls)")
  }
  
}