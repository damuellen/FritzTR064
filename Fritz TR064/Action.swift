//
//  Action.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

struct Action {
  let service: Service
  var url: String {
    return service.manager.serviceURL + service.controlURL
  }
  var name: String
  var input = [String: StateVariable]()
  var output = [String: StateVariable]()
  var needsInput = false
  init?(element: AEXMLElement, stateVariables: [StateVariable], service: Service) {
    self.service = service
    guard let value = element["name"].value else { return nil }
    self.name = value
    element["argumentList"].children.forEach { argument in
      let stateVariable = stateVariables.lazy.filter { argument["relatedStateVariable"].value == $0.name }.first!
      switch argument["direction"].value {
      case "in"?:
        self.needsInput = true
        self.input[argument["name"].value!] = stateVariable
      case "out"?:
        print(argument["name"].value!)
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
      datatype = element["dataType"].value else { return nil }
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