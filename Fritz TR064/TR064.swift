//
//  TR064.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Alamofire

struct TR064 {
  
  static let manager = TR064Manager.sharedInstance
  static let serviceURL = "http://192.168.178.1:49000"
  static let descURL = "/tr64desc.xml"
  static let account = "admin"
  static let pass = "6473"
  
  static func getAvailableServices() {
    let requestURL = TR064.serviceURL + TR064.descURL
    Alamofire.request(.GET, requestURL)
      .responseData { (_, _, data) -> Void in
        if data.isSuccess {
          if let XML = data.value {
            manager.descXML = try? AEXMLDocument.init(xmlData: XML)
            manager.services = TR064.getServicesFromXML(TR064Manager.sharedInstance.descXML)
          }
        }
    }
  }
  
  static func getActionsFor(service: Service) {
    let requestURL = TR064.serviceURL + service.SCPDURL
    Alamofire.request(.GET, requestURL)
      .responseData { (_, _, data) -> Void in
        if let xmlRaw = data.value, xml = try? AEXMLDocument.init(xmlData: xmlRaw) {
          let stateVariables = xml.root["serviceStateTable"].children.map {StateVariable(element: $0)}.flatMap {$0}
          let actions = xml.root["actionList"].children.map { Action(element: $0, stateVariables: stateVariables, service: service) }.flatMap {$0}
          manager.actions += actions
        }
    }
  }
  
  static func createSOAPMessageBody(action: Action, arguments: [String] = []) -> NSData? {
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
  
  static func createSOAPRequest(action: Action) -> NSMutableURLRequest {
    let request = NSMutableURLRequest(URL: NSURL(string: action.url)!)
    request.addValue("text/xml; charset=utf-8", forHTTPHeaderField:"Content-Type")
    request.addValue("\(action.service.serviceType)#\(action.name)", forHTTPHeaderField: "SOAPAction")
    request.HTTPMethod = "POST"
    return request
  }
  
  static func sendSOAPRequest(action: Action, arguments: [String] = [], block: ()->() ) {
    let request = createSOAPRequest(action)
    request.HTTPBody = createSOAPMessageBody(action, arguments: arguments)
    Alamofire.request(request)
      .authenticate(user: account, password: pass)
      .responseData { (_, _, data) -> Void in
        if data.isSuccess {
          if let XML = data.value {
            manager.lastResponse = try? AEXMLDocument.init(xmlData: XML) }
          block()
        }
    }
  }
  
  static func checkResponseForURL(XML: AEXMLDocument, action: Action) -> String? {
    var URL: String?
    guard let soapResponse = self.checkActionResponse(XML, action: action) else { return nil }
    for possibleURL in soapResponse.children where possibleURL.value != nil {
      if possibleURL.value!.containsString("http") {
        URL = possibleURL.value!
      }
    }
    return URL
  }
  
  static func getXMLFromURL(requestURL: String, block: ()->() ) {
    print("getXMLFromURL", requestURL)
    Alamofire.request(.GET, requestURL)
      .responseData { (_, _, data) -> Void in
        if data.isSuccess {
          if let XML = data.value {
            manager.lastResponse = try? AEXMLDocument.init(xmlData: XML) }
          block()
        }
    }
  }
  
  static func checkActionResponse(XML: AEXMLDocument, action: Action) -> AEXMLElement? {
    let soapResponse = XML.root["s:Body"]["u:\(action.name)Response"]
    if soapResponse.name == "AEXMLError" { return nil }
    return soapResponse
  }
  
  static func convertActionResponse(XML: AEXMLDocument, action: Action) -> [String:String]? {
    var result = [String:String]()
    guard let soapResponse = self.checkActionResponse(XML, action: action) else { return nil }
    for key in action.output.keys {
      if let value = soapResponse[key].value {
        result[key] = value
      }
    }
    return result
  }
  
  static func getServicesFromXML(discription: AEXMLDocument) -> [Service] {
    let internetGatewayDevice = discription.root["device"],
    LANDevice = discription.root["device"]["deviceList"].children[0],
    WANDevice = discription.root["device"]["deviceList"].children[1]
    
    var serviceList = internetGatewayDevice["serviceList"].children
    serviceList += LANDevice["serviceList"].children
    serviceList += WANDevice["serviceList"].children
    
    return serviceList.map { service in Service(element: service) }.flatMap {$0}
  }
  
}




