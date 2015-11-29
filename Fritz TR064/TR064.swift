//
//  TR064.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Alamofire

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
    var isCachedOnDisk: Bool = false
    
    var name: String {
      didSet {
        self.modelType = checkModelType(name)
      }
    }
    
    weak var manager: TR064Manager! = TR064Manager.sharedManager
    
    var services: [Service] = []
    
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
      do {
        if let services = try FileManager.loadCompressedValuesFromDiskCache(uuid + "-services") {
          self.services = extractValuesFromPropertyListArray(services)
          self.isCachedOnDisk = true
          return true
        }
      } catch FileError.FileNotFound {
        return false
      } catch {
        return false
      }
      return false
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
    
  }// Device End
  
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
  
  private static func extractServicesFromTR064Description(discription: AFPValue<AEXMLDocument>) -> [AEXMLElement] {
    
    let discription = discription.value
    
    let internetGatewayDevice = discription.root["device"],
    LANDevice = discription.root["device"]["deviceList"].children[0],
    WANDevice = discription.root["device"]["deviceList"].children[1]
    
    let serviceList = internetGatewayDevice["serviceList"].children
      + LANDevice["serviceList"].children
      + WANDevice["serviceList"].children
    
    return serviceList
  }
  
  private static func extractServicesFromIGDDescription(discription: AFPValue<AEXMLDocument>) -> [AEXMLElement] {
    
    let discription = discription.value
    
    let serviceList = discription.root["device"]["deviceList"]["device"]["serviceList"].children
      + discription.root["device"]["deviceList"]["device"]["deviceList"]["device"]["serviceList"].children
    
    return serviceList
  }
  
  static func findDevice() {
    let resultServices = requestServicesDescriptions()
    
    whenAll(resultServices).then { services in
      
      manager.device = Device(discription: services.first!)
      if !manager.device!.fetchCachedObjects() {
        let UPNPServicesDescription = services.first!
        checkUPNPServices(UPNPServicesDescription)
        
        if let TR064ServicesDescription = services.last where services.count > 1 {
          checkTR064Services(TR064ServicesDescription)
        }
      }
    }
  }
  
  private static func requestServicesDescriptions() -> [Promise<AFPValue<AEXMLDocument>, AFPError>] {
    
    return [manager.request(.GET, Device.URL + descURLs[1]).responseXMLPromise(),
      manager.request(.GET, Device.URL + descURLs[0]).responseXMLPromise()]
  }
  
  private static func checkTR064Services(response: AFPValue<AEXMLDocument>) {
    
    let serviceElements = extractServicesFromTR064Description(response)
    
    for service in serviceElements {
      
      guard var service = Service(element: service) else { return }
      
      let actions = manager.requestActionsForService(service)
      
      actions.then { xml in
        service.extractActionsFromDescription(xml.value)
        manager.device?.services += [service]
      }
    }
  }
  
  private static func checkUPNPServices(response: AFPValue<AEXMLDocument>) {
    
    let serviceElements = extractServicesFromIGDDescription(response)
    
    for service in serviceElements {
      
      guard var service = Service(element: service) else { return }
      
      let actions = manager.requestActionsForService(service)
      
      actions.then { xml in
        service.extractActionsFromDescription(xml.value)
        manager.device?.services += [service]
      }
    }
  }
  
  static let getAvailableServices: ()->Void = {
    TR064.findDevice()
    Timeout.scheduledTimer(5, repeats: true) { timer in
      if let device = manager.device {
        if !device.isCachedOnDisk {
          try! print(FileManager.saveCompressedValuesToDiskCache(device.services, name: device.uuid + "-services"))
          timer.invalidate()
        }
      } else {
        manager.observer?.alert()
      }
    }
  }
  
  /// Creates an envelope with the action and it arguments.
  static func createMessage(service: Service, action: Action, arguments: [String] = []) -> NSData? {
    
    let soapRequest = AEXMLDocument()
    
    let envelope = soapRequest.addChild(name: "s:Envelope", attributes:
      ["xmlns:s" : "http://schemas.xmlsoap.org/soap/envelope/",
        "s:encodingStyle" : "http://schemas.xmlsoap.org/soap/encoding/"])
    
    let body = envelope.addChild(name: "s:Body")
    
    let actionBody = body.addChild(name: "u:\(action.name)", attributes:
      ["xmlns:u": service.serviceType])
    
    for (argument, value) in zip(action.input.keys, arguments) {
      actionBody.addChild(name: argument, value: value)
    }
    
    return soapRequest.xmlString.dataValue
  }
  
  /// Creates an request for an action.
  static func createRequest(service: Service, action: Action) -> NSMutableURLRequest {
    
    let request = NSMutableURLRequest(URL: NSURL(string: TR064.Device.URL + service.controlURL)!)
    request.addValue("text/xml; charset=utf-8", forHTTPHeaderField:"Content-Type")
    request.addValue("\(service.serviceType)#\(action.name)", forHTTPHeaderField: "SOAPAction")
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
