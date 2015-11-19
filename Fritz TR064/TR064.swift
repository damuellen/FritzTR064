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
  
  class Device {
    
    static let activeURL = Settings.internalRouterURL ?? "fritz.box"
    static let activePort = Settings.useSSL ? ":49443" : ":4900"
    static let activeProtocol = Settings.useSSL ? "https://" : "http://"
    static let URL = activeProtocol + activeURL + activePort
    
    var name: String!
    var services: [Service] = []
    var actions: [Action] = []
  }
  
  static let manager = TR064Manager.sharedManager
  static let descURLs = ["/tr64desc.xml", "/igddesc.xml"]
  
  static let completionHandler = { (_:NSURLRequest?, _:NSHTTPURLResponse?, XML:Result<AEXMLDocument>) -> Void in
    guard let xml = XML.value else { return }
    var values: [String:String] = [:]
      xml.root.all!.forEach { element in
        if let value = element.value {
          values[element.name] = value }
    }
    manager.soapResponse = values
  }
  
  static func findDevice() {
    var requests = requestServicesDescriptions()
    manager.activeDevice = Device()
    let UPNPServicesDescriptionRequest = requests.removeFirst()
    TR064.checkUPNPServices(UPNPServicesDescriptionRequest)
    if let TR064ServicesDescriptionRequest = requests.first {
      TR064.checkTR064Services(TR064ServicesDescriptionRequest)
    }
  }
  
  /// Request the tr064desc.xml from the router.
  private static func requestServicesDescriptions() -> [Request] {
    manager.passphrase = "dsf"
    var requests: [Request] = []
    requests.append(manager.request(.GET, Device.URL + descURLs[1]))
    if manager.passphrase != nil {
      requests.append(manager.request(.GET, Device.URL + descURLs[0]))
    }
    return requests
  }
  
  private static func checkTR064Services(request: Request) {
    
    request.responseXMLPromise().then { xml in
      let device = manager.activeDevice!
      device.services += extractServicesFromDescription(xml)
     // saveValuesToDefaults(manager.services, key: "Services")
      if device.actions.isEmpty {
        TR064.requestActionsFor(device) => TR064.commitActionsToActiveDevice
      }
    }
  }
  
  private static func checkUPNPServices(request: Request) {
    
    request.responseXMLPromise().then { xml in
      let device = manager.activeDevice!
      device.services += extractServicesFromInternetGatewayDescription(xml)
    //  saveValuesToDefaults(manager.services, key: "Services")
      if device.actions.isEmpty {
        TR064.requestActionsFor(device) => TR064.commitActionsToActiveDevice
      }
    }
  }
  
  static let getAvailableServices: ()->Void = {
    if let services = loadValuesFromDefaults("Service") {
      manager.activeDevice = Device()
      manager.activeDevice!.services = extractValuesFromPropertyListArray(services)
   //   TR064.requestActionsFor(device.services) => TR064.commitActionsToManager
      return
    } else {
      TR064.findDevice()
    }
    Timeout.scheduledTimer(5, repeats: true) { timer in
      if manager.isReady {
        timer.invalidate()
      } else {
        manager.observer?.alert()
      }
    }
  }
  
  /// Use the URL from the given service to request his actions.
  static func requestActionsFor(device: Device) -> [Promise<AFPValue<AEXMLDocument>, AFPError>] {
    return device.services.map {
      return TR064Manager.sharedManager.request(.GET, "https://fritz.box:49443" + $0.SCPDURL ).validate().responseXMLPromise() }
  }
  
  static func commitActionsToActiveDevice(actions: [Promise<AFPValue<AEXMLDocument>, AFPError>]) {
    
    whenAll(actions).then { xml in
      
      defer { manager.isReady = true }
      for (index,xml) in xml.enumerate() {
        let serviceStateTable = xml.value.root["serviceStateTable"].children
        let stateVariables = serviceStateTable.map {
          StateVariable(element: $0)
          }.flatMap {$0}
        let actionList = xml.value.root["actionList"].children
        
        manager.activeDevice!.actions += actionList.map {
          Action(element: $0, stateVariables: stateVariables, service: manager.activeDevice!.services[index])
          }.flatMap {$0}
      }
    }.trap { error in
       manager.observer?.alert()
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
    
    return TR064Manager.sharedManager.request(request).authenticate(user: account, password: pass).validate()
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
    return manager.request(.GET, requestURL).validate()
  }
  
  /// Helper function to get known services from tr064desc.xml.
  private static func extractServicesFromDescription(discription: AFPValue<AEXMLDocument>) -> [Service] {
    
    let discription = discription.value
    
    let internetGatewayDevice = discription.root["device"],
    LANDevice = discription.root["device"]["deviceList"].children[0],
    WANDevice = discription.root["device"]["deviceList"].children[1]
    
    let serviceList = internetGatewayDevice["serviceList"].children
     + LANDevice["serviceList"].children
     + WANDevice["serviceList"].children
    
    return serviceList.map { service in Service(element: service) }.flatMap {$0}
  }
  
  private static func extractServicesFromInternetGatewayDescription(discription: AFPValue<AEXMLDocument>) -> [Service] {
    
    let discription = discription.value
    manager.activeDevice?.name = discription.root["device"]["friendlyName"].value
    let internetGatewayDevice = discription.root["device"]["deviceList"]["device"]
    
    let serviceList = internetGatewayDevice["serviceList"].children
      + internetGatewayDevice["deviceList"]["device"]["serviceList"].children

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
