//
//  Service.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

struct Service {
  
  let serviceType: String
  let controlURL: String
  let SCPDURL: String
  var actions: [Action]
  
}

extension Service {
  
  mutating func extractActionsFromDescription(xml: AEXMLDocument){
    
    let serviceStateTable = xml.root["serviceStateTable"].children
    
    let stateVariables = serviceStateTable.flatMap {
      StateVariable(element: $0)
      }
    
    let actionList = xml.root["actionList"].children
    
    self.actions = actionList.flatMap {
      Action(element: $0, stateVariables: stateVariables, service: self)
      }
  }
  
}

extension Service {
  
  init?(element: AEXMLElement) {
    guard let serviceType = element["serviceType"].value,
      controlURL = element["controlURL"].value,
      SCPDURL = element["SCPDURL"].value else { return nil }
    self.init(serviceType: serviceType, controlURL: controlURL, SCPDURL: SCPDURL, actions: [])
  }
  
}

extension Service: Hashable, Equatable {
  var hashValue: Int { return serviceType.hashValue ^ controlURL.hashValue ^ SCPDURL.hashValue}
}

func ==(lhs: Service, rhs: Service) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

extension Service: PropertyListReadable {
  
  func propertyListRepresentation() -> NSDictionary {
    let representation:[String:AnyObject] =
    ["serviceType":serviceType, "controlURL":controlURL, "SCPDURL":SCPDURL, "actions":actions.map { $0.propertyListRepresentation() } as NSArray]
    return representation
  }
  
  init?(propertyListRepresentation: NSDictionary?) {
    
    guard let values = propertyListRepresentation,
      serviceType = values["serviceType"] as? String,
      controlURL = values["controlURL"] as? String,
      SCPDURL = values["SCPDURL"] as? String,
      actionsArray = (values["actions"] as? NSArray)
      else { return nil }
    let actions = actionsArray.flatMap { Action(propertyListRepresentation: $0 as? NSDictionary) }
    self.init(serviceType: serviceType, controlURL: controlURL, SCPDURL: SCPDURL, actions: actions)
  }
  
}

