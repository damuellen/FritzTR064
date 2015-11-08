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
    var tableData = [String:String]()
      xml.root.all!.forEach { element in
        if let value = element.value {
          tableData[element.name] = value }
    }
    
    (Manager.observer as? XMLResponseViewController)?.tableData = tableData
  }
  
  /// Request the tr064desc.xml from the router.
  private static func requestServices() -> Request {
    
    let requestURL = TR064.serviceURL + TR064.descURL
    return Alamofire.request(.GET, requestURL)
  }
  
  private static func addServicesToManager(request: Request) {
    
    request.responseXMLPromise().then {
      manager.services = getServicesFromDescription($0)
      saveValuesToDefaults(manager.services, key: "Services")
      if manager.actions.count == 0 {
        TR064.requestActionsFor(manager.services) => TR064.commitActionsToManager
      }
    }
  }

  static let getAvailableServices: ()->Void = {
    if let services = loadValuesFromDefaults("Services") {
      manager.services = extractValuesFromPropertyListArray(services)
      TR064.requestActionsFor(manager.services) => TR064.commitActionsToManager
      return
    }
    Timeout.scheduledTimer(4, repeats: true) { timer in
      if manager.isReady {
        timer.invalidate()
      }
      TR064.requestServices => TR064.addServicesToManager
    }
  }
  
  /// Use the URL from the given service to request his actions.
  static func requestActionsFor(services: [Service]) -> [Promise<AFPValue<AEXMLDocument>, AFPError>] {
    return services.map {
      return (Alamofire.request(.GET, TR064.serviceURL + $0.SCPDURL ).validate().responseXMLPromise()) }
  }
  
  static func commitActionsToManager(actions: [Promise<AFPValue<AEXMLDocument>, AFPError>]) {
    
    whenAll(actions).then { xml in
      
      defer { manager.isReady = true }
      
      for (index,xml) in xml.enumerate() {
        let serviceStateTable = xml.value.root["serviceStateTable"].children
        let stateVariables = serviceStateTable.map {
          StateVariable(element: $0)
          }.flatMap {$0}
        let actionList = xml.value.root["actionList"].children
        
        manager.actions += actionList.map {
          Action(element: $0, stateVariables: stateVariables, service: manager.services[index])
          }.flatMap {$0}
      }
      }
    whenAny(actions).trap { error in
      defer { manager.isReady = false }
    }
  }
  
  /// Creates an envelope with the action and it arguments.
  private static func createMessage(action: Action, arguments: [String] = []) -> NSData? {
    
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
  private static func createRequest(action: Action) -> NSMutableURLRequest {
    
    let request = NSMutableURLRequest(URL: NSURL(string: action.url)!)
    request.addValue("text/xml; charset=utf-8", forHTTPHeaderField:"Content-Type")
    request.addValue("\(action.service.serviceType)#\(action.name)", forHTTPHeaderField: "SOAPAction")
    request.HTTPMethod = "POST"
    return request
  }
  
  /// Sends an request for an action with arguments.
  static func sendRequest(action: Action, arguments: [String] = []) -> Request {
    
    let request = createRequest(action)
    request.HTTPBody = createMessage(action, arguments: arguments)
    
    return Alamofire.request(request).authenticate(user: account, password: pass).validate()
  }
  
  /// Sends an request for an action with arguments, and returns a future response.
  static func startAction(action: Action, arguments: [String] = []) -> ActionResultPromise {
    
    let request = sendRequest(action, arguments: arguments)
    
    let timer = Timeout.scheduledTimer(4) { _ in manager.observer?.alert() }
    
    request.responseXMLDocument { (_,_,xml) in
   //   manager.lastResponse = xml.value
      timer.invalidate()
      }
    request.responseXMLPromise().trap { _ in
      timer.fire()
    }
    return request.responsePromiseFor(Action: action)
  }
  
  static func getXMLFromURL(requestURL: String) -> Request? {
    return Alamofire.request(.GET, requestURL).validate()
  }
  
  /// Helper function to get known services from tr064desc.xml.
  private static func getServicesFromDescription(discription: AFPValue<AEXMLDocument>) -> [Service] {
    
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

extension AEXMLDocument {
  
  func checkForURLWithAction(action: Action) -> String? {
    var URL: String?
    guard let validResponse = self.checkWithAction(action)
      else { return nil }
    for possibleURL in validResponse.children where possibleURL.value != nil {
      if possibleURL.value!.containsString("http") {
        URL = possibleURL.value!
      }
    }
    return URL
  }
  
  func checkWithAction(action: Action) -> AEXMLElement? {
    let soapResponse = self.root["s:Body"]["u:\(action.name)Response"]
    if soapResponse.name == "AEXMLError" { return nil }
    return soapResponse
  }
}

extension AEXMLElement {
  
  func convertWithAction(action: Action) -> [String:String]? {
    var result = [String:String]()
    for key in action.output.keys {
      if let value = self[key].value {
        result[key] = value
      }
    }
    return result
  }
  
  func checkForURL() -> String? {
    var URL: String?
    for possibleURL in self.children where possibleURL.value != nil {
      URL = possibleURL.value!.getLink()
    }
    return URL
  }
  
}
