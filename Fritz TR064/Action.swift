//
//  Action.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

typealias Name = String

let obsoleteActions:[String:[String]] =
["urn:dslforum-org:service:X_AVM-DE_OnTel:1":["GetInfo", "SetEnable", "SetConfig"],
  "urn:X_VoIP-com:serviceId:X_VoIP1:1":["X_AVM-DE_GetClient","X_AVM-DE_SetClient"]]

let serviceURL = "https://fritz.box:49443"

struct Action {
  
  var name: String
  var needsInput = false
  var input = [Name: StateVariable]()
  var output = [Name: StateVariable]()
  
}

extension Action {
  
  init?(element: AEXMLElement, stateVariables: [StateVariable], service: Service) {
    guard let value = element["name"].value
      else { return nil }
    if let obsoleteActionsOfService = obsoleteActions[service.serviceType] {
      if obsoleteActionsOfService.contains(value) {
        return nil
      }
    }
    self.name = value
    element["argumentList"].children.forEach { argument in
      let stateVariable = stateVariables.lazy.filter { argument["relatedStateVariable"].value == $0.name }.first
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
}

extension StateVariable {
  
  init?(element: AEXMLElement) {
    guard let name = element["name"].value,
      datatype = element["dataType"].value,
      defaultValue = element["defaultValue"].value
      else { return nil }
    
    self.defaultValue = defaultValue
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
  var hashValue: Int { return name.hashValue}
}

func ==(lhs: Action, rhs: Action) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

extension StateVariable: PropertyListReadable {
  
  func propertyListRepresentation() -> NSDictionary {
    let representation:[String:AnyObject] =
    ["Name":name, "Type":type, "DefaultValue":defaultValue]
    return representation
  }
  
  init?(propertyListRepresentation: NSDictionary?) {
    
    guard let values = propertyListRepresentation,
      name = values["Name"] as? String,
      type = values["Type"] as? String,
      defaultValue = values["DefaultValue"] as? String
      else { return nil }
    
    self.init(name: name, type: type, defaultValue: defaultValue)
  }
  
}

extension Action: PropertyListReadable {
  
  func propertyListRepresentation() -> NSDictionary {
    
    var inputs: [String:NSDictionary] = [:]
    var outputs: [String:NSDictionary] = [:]
    
    for (name, stateVariable) in input {
      inputs[name] = stateVariable.propertyListRepresentation()
    }
    for (name, stateVariable) in output {
      outputs[name] = stateVariable.propertyListRepresentation()
    }
    let representation:[String:AnyObject] =
    ["Name":name, "NeedsInput":needsInput,
      "Input": inputs, "Output":outputs]
    
    return representation
  }
  
  init?(propertyListRepresentation: NSDictionary?) {
    
    guard let values = propertyListRepresentation,
      name = values["Name"] as? String,
      needsInput = values["NeedsInput"] as? Bool,
      input = values["Input"] as? [String:NSDictionary],
      output = values["Output"] as? [String:NSDictionary]
      else { return nil }
    
    var inputs: [String:StateVariable] = [:]
    var outputs: [String:StateVariable] = [:]
    
    for (name, variables) in input {
      inputs[name] = StateVariable(propertyListRepresentation: variables)
    }
    for (name, variables) in output {
      outputs[name] = StateVariable(propertyListRepresentation: variables)
    }
    self.init(name: name, needsInput: needsInput, input: inputs, output: outputs)
  }

}
