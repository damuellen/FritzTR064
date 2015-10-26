//
//  TR064.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Alamofire

typealias ActionResultPromise = Promise<AFPValue<AEXMLElement>, AFPError>

enum TR064Error: ErrorType {
  case MissingService
  case MissingAction
  case NoAnswer
}

struct TR064 {
  
  static let manager = TR064Manager.sharedManager
  static let serviceURL = "http://192.168.178.1:49000"
  static let descURL = "/tr64desc.xml"
  
  static let completionHandler = { (_:NSURLRequest?, _:NSHTTPURLResponse?, XML:Result<AEXMLDocument>) -> Void in
    guard let xml = XML.value else { return }
    manager.lastResponse = xml
    manager.pendingAction = nil
  }
  
  /// Request the tr064desc.xml from the router, and give the founded services to the manager.
  static func requestServices() -> Request {
    application.networkActivityIndicatorVisible = true
    let requestURL = TR064.serviceURL + TR064.descURL
    return Alamofire.request(.GET, requestURL).validate()
  }
  
  static func checkServices(request: Request) {
    request.responseXMLPromise().then {
      manager.services = getServicesFromDescription($0)
      getActionsFor(manager.services)
    }
  }
  
  static func getAvailableServices() {
    checkServices(requestServices())
  }
  
  /// Use the URL from the given service to request his actions, and add them to the manager.
  static func getActionsFor(services: [Service]) {
    let requestURL = TR064.serviceURL
    let actions = services.map {
      return (Alamofire.request(.GET, requestURL + $0.SCPDURL ).validate().responseXMLPromise())
    }
    whenAll(actions).then { xml in
      defer {
        application.networkActivityIndicatorVisible = false
        manager.isReady = true
      }
      for (index,xml) in xml.enumerate() {
        
        let serviceStateTable = xml.value.root["serviceStateTable"].children
        let stateVariables = serviceStateTable.map { StateVariable(element: $0) }.flatMap {$0}
        
        let actionList = xml.value.root["actionList"].children
        manager.actions += actionList.map { Action(element: $0, stateVariables: stateVariables, service:services[index]) }.flatMap {$0}
      }
    }
  }
  
  /// Creates an envelope with the action and it arguments.
  static func createMessage(action: Action, arguments: [String] = []) -> NSData? {
    
    let soapRequest = AEXMLDocument()

    let envelope = soapRequest.addChild(name: "s:Envelope", attributes:
      ["xmlns:s" : "http://schemas.xmlsoap.org/soap/envelope/",
       "s:encodingStyle" : "http://schemas.xmlsoap.org/soap/encoding/"])
    
    let body = envelope.addChild(name: "s:Body")
    
    let actionBody = body.addChild(name: "u:\(action.name)", attributes:
      ["xmlns:u": action.service.serviceType])
    
    for (argument, value) in zip(action.input.keys, arguments) {
      actionBody.addChild(name: argument, value: value)
    }
    
    return soapRequest.xmlString.dataUsingEncoding(NSUTF8StringEncoding)
  }
  
  /// Creates an request for an action.
  static func createRequest(action: Action) -> NSMutableURLRequest {
    let request = NSMutableURLRequest(URL: NSURL(string: action.url)!)
    request.addValue("text/xml; charset=utf-8", forHTTPHeaderField:"Content-Type")
    request.addValue("\(action.service.serviceType)#\(action.name)", forHTTPHeaderField: "SOAPAction")
    request.HTTPMethod = "POST"
    return request
  }
  
  /// Sends an request for an action with arguments.
  static func sendRequest(action: Action, arguments: [String] = []) -> Request {
    manager.pendingAction = (action, arguments)
    let request = createRequest(action)
    request.HTTPBody = createMessage(action, arguments: arguments)
    return Alamofire.request(request).authenticate(user: account, password: pass).validate()
  }
  
  /// Sends an request for an action with arguments, and returns a future response.
  static func startAction(action: Action, arguments: [String] = []) -> ActionResultPromise {
    manager.pendingAction = (action, arguments)
    return sendRequest(action, arguments: arguments).responsePromiseFor(Action: action).then { _ in
    manager.pendingAction = nil
    }
  }
  
  static func getXMLFromURL(requestURL: String) -> Request? {
    return Alamofire.request(.GET, requestURL).validate()
  }
  
  /// Helper function to get known services from tr064desc.xml.
  static func getServicesFromDescription(discription: AFPValue<AEXMLDocument>) -> [Service] {
    let discription = discription.value
    let internetGatewayDevice = discription.root["device"],
    LANDevice = discription.root["device"]["deviceList"].children[0],
    WANDevice = discription.root["device"]["deviceList"].children[1]
    
    let serviceList = internetGatewayDevice["serviceList"].children
     + LANDevice["serviceList"].children
     + WANDevice["serviceList"].children
    
    return serviceList.map { service in Service(element: service) }.flatMap {$0}
  }
  
}
