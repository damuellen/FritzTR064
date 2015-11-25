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
    
    enum modelName: String {
      case AVM3490
      case AVM7272
      case AVM7360
      case AVM7490
    }
    
    func checkModelType(name: String?) -> TR064.Device.modelName? {
      guard let name = name else { return nil }
      if name.containsString("3490") {
        return .AVM3490
      } else if name.containsString("7272") {
        return .AVM7272
      } else if name.containsString("7360") {
        return .AVM7360
      } else if name.containsString("7490") {
        return .AVM7490
      } else {
        return .AVM7360
      }
    }
    
    var modelType: modelName? {
      didSet {
        manager.observer?.refreshUI(true)
      }
    }
    var uuid: String
    
    
    var name: String {
      didSet {
        self.modelType = checkModelType(name)
      }
    }
    
    weak var manager: TR064Manager! = TR064Manager.sharedManager
    var services: [Service] = []
    
    var actions: [Action] = []
    
    init(discription: AFPValue<AEXMLDocument>) {
      let prefix = NSCharacterSet(charactersInString: "uuid:")
      let name = discription.value.root["device"]["friendlyName"].stringValue,
      uuid = discription.value.root["device"]["UDN"].stringValue.stringByTrimmingCharactersInSet(prefix)
      debugPrint("name: ",name)
      debugPrint("uuid: ",uuid)
      self.name = name
      self.uuid = uuid
    }
    
    func fetchCachedObjects() -> Bool {
      if let services = try? FileManager.loadValuesFromDiskCache(uuid + "-services"),
        actions = try? FileManager.loadValuesFromDiskCache(uuid + "-actions") {
          
          self.services = extractValuesFromPropertyListArray(services)
          self.actions = extractValuesFromPropertyListArray(actions)
          return true
      }
      return false
    }
    
    /// Helper function to get known services from tr064desc.xml.
    func extractServicesFromDescription(discription: AFPValue<AEXMLDocument>) -> [Service] {
      
      let discription = discription.value
      
      let internetGatewayDevice = discription.root["device"],
      LANDevice = discription.root["device"]["deviceList"].children[0],
      WANDevice = discription.root["device"]["deviceList"].children[1]
      
      let serviceList = internetGatewayDevice["serviceList"].children
        + LANDevice["serviceList"].children
        + WANDevice["serviceList"].children
      
      let services = serviceList.map { service in Service(element: service) }.flatMap {$0}
      self.services += services
      return services
    }
    
    func extractServicesFromInternetGatewayDescription(discription: AFPValue<AEXMLDocument>) -> [Service] {
      
      let discription = discription.value
      
      let serviceList = discription.root["device"]["deviceList"]["device"]["serviceList"].children
        + discription.root["device"]["deviceList"]["device"]["deviceList"]["device"]["serviceList"].children
      
      let services = serviceList.map { service in Service(element: service) }.flatMap {$0}
      self.services += services
      return services
    }
    
    func commitActionsToDevice(action: (Promise<AFPValue<AEXMLDocument>, AFPError>), service: Service) {
      
      action.then { xml in
        
        let serviceStateTable = xml.value.root["serviceStateTable"].children
        let stateVariables = serviceStateTable.map {
          StateVariable(element: $0)
          }.flatMap {$0}
        let actionList = xml.value.root["actionList"].children
        let actions = actionList.map {
          Action(element: $0, stateVariables: stateVariables, service: service)
          }.flatMap {$0}
        self.actions += actions
        }.trap { error in
          self.manager.observer?.alert()
      }
    }
    
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
    
    let UPNPServicesDescriptionRequest = requests.removeFirst()
 //   TR064.checkUPNPServices(UPNPServicesDescriptionRequest)
    if let TR064ServicesDescriptionRequest = requests.first {
      TR064.checkTR064Services(TR064ServicesDescriptionRequest)
    }
  }
  
  private static func requestServicesDescriptions() -> [Request] {

    var requests: [Request] = []
    requests.append(manager.request(.GET, Device.URL + descURLs[1]))
    requests.append(manager.request(.GET, Device.URL + descURLs[0]))
    return requests
  }
  
  private static func checkTR064Services(request: Request) {
    
    request.responseXMLPromise().trap({ error in
      manager.observer?.alert()
    }).then { xml in
      if manager.device == nil {
        manager.device = Device(discription: xml)
        if !manager.device!.fetchCachedObjects() {
          let services = manager.device!.extractServicesFromDescription(xml)
          var allActions: [Promise<AFPValue<AEXMLDocument>, AFPError>] = []
          for service in services {
            let actions = manager.requestActionsFor(service)
            allActions.append(actions)
            manager.device!.commitActionsToDevice(actions, service: service)
          }
          whenAllFinalized(allActions).delay(1).then {
            try! FileManager.saveValuesToDiskCache(manager.device!.services, name: manager.device!.uuid + "-services")
            try! FileManager.saveValuesToDiskCache(manager.device!.actions, name: manager.device!.uuid + "-actions")
          }
        }
      }
    }
  }
  
  private static func checkUPNPServices(request: Request) {
    
    request.validate().responseXMLPromise().trap({ error in
      manager.observer?.alert()
    }).then { xml in
      if manager.device == nil {
        manager.device = Device(discription: xml)
        if !manager.device!.fetchCachedObjects() {
          let services = manager.device!.extractServicesFromInternetGatewayDescription(xml)
          var allActions: [Promise<AFPValue<AEXMLDocument>, AFPError>] = []
          for service in services {
            let actions = manager.requestActionsFor(service)
            allActions.append(actions)
            manager.device!.commitActionsToDevice(actions, service: service)
          }
        }
      }
    }
  }
  
  static let getAvailableServices: ()->Void = {
    TR064.findDevice()
    Timeout.scheduledTimer(5, repeats: true) { timer in
      if manager.device != nil {
        timer.invalidate()
      } else {
        manager.observer?.alert()
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
    
    return soapRequest.xmlString.dataValue
  }
  
  /// Creates an request for an action.
  static func createRequest(action: Action) -> NSMutableURLRequest {
    
    let request = NSMutableURLRequest(URL: NSURL(string: action.url)!)
    request.addValue("text/xml; charset=utf-8", forHTTPHeaderField:"Content-Type")
    request.addValue("\(action.service.serviceType)#\(action.name)", forHTTPHeaderField: "SOAPAction")
    request.HTTPMethod = "POST"
    return request
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
