//
//  Service.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation
import Alamofire

class Service {
  let manager: TR064
  let serviceType: String
  let controlURL: String
  let SCPDURL: String
  var actions = [Action]()
  
  convenience init?(element: AEXMLElement, manager: TR064) {
    if let serviceType = element["serviceType"].value, controlURL = element["controlURL"].value, SCPDURL = element["SCPDURL"].value {
      self.init(serviceType: serviceType, controlURL: controlURL, SCPDURL: SCPDURL, manager: manager)
    } else { return nil }
  }
  init(serviceType: String, controlURL: String, SCPDURL: String, manager: TR064) {
    self.serviceType = serviceType
    self.controlURL = controlURL
    self.SCPDURL = SCPDURL
    self.manager = manager
  }
  func getActions(){
    let requestURL = self.manager.serviceURL + self.SCPDURL
    Alamofire.request(.GET, requestURL)
      .responseData { (_, _, data) -> Void in
        if let xmlRaw = data.value, xml = try? AEXMLDocument.init(xmlData: xmlRaw) {
          let stateVariables = xml.root["serviceStateTable"].children.map {StateVariable(element: $0)}.flatMap {$0}
          self.actions = xml.root["actionList"].children.map { Action(element: $0, stateVariables: stateVariables, service: self) }.flatMap {$0}
          self.manager.serviceDelegate?.refresh()
        }
    }
  }
}