//
//  Action.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

typealias Name = String

let obsoleteActions:[String:[String]] =
["urn:dslforum-org:service:X_AVM-DE_OnTel:1":["GetInfo", "SetEnable", "SetConfig"],
  "urn:X_VoIP-com:serviceId:X_VoIP1:1":["X_AVM-DE_GetClient","X_AVM-DE_SetClient"]]

let serviceURL = "https://fritz.box:49443"

struct Action {
  
  let service: Service
  var url: String {
    return serviceURL + service.controlURL
  }
  var name: String
  var input = [Name: StateVariable]()
  var output = [Name: StateVariable]()
  var needsInput = false
  
  init?(element: AEXMLElement, stateVariables: [StateVariable], service: Service) {
    guard let value = element["name"].value
      else { return nil }
    if let obsoleteActionsOfService = obsoleteActions[service.serviceType] {
      if obsoleteActionsOfService.contains(value) {
        return nil
      }
    }
    self.name = value
    self.service = service
    element["argumentList"].children.forEach { argument in
      let stateVariable = stateVariables.lazy.filter { argument["relatedStateVariable"].value == $0.name }.first!
      switch argument["direction"].value {
      case "in"?:
        self.needsInput = true
        self.input[argument["name"].value!] = stateVariable
      case "out"?:
        self.output[argument["name"].value!] = stateVariable
      default:
        return
      }
    }
  }
  
}

struct StateVariable {
  var name = ""
  var type = ""
  var defaultValue = ""
  init?(element: AEXMLElement) {
    guard let name = element["name"].value,
      datatype = element["dataType"].value
      else { return nil }
    if let defaultValue = element["defaultValue"].value {
      self.defaultValue = defaultValue
    }
    self.name = name
    switch datatype {
    case "string":
      self.type = "String"
    case "ui2":
      self.type = "Int"
    case "boolean":
      self.type = "Bool"
    case "dateTime":
      self.type = "String"
    default:
      self.type = "String"
    }
  }
}

extension Action: Hashable, Equatable {
  var hashValue: Int { return url.hashValue ^ name.hashValue}
}

func ==(lhs: Action, rhs: Action) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

