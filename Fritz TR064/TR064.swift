//
//  TR064.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Alamofire

struct TR064 {
  
  static let manager = TR064Manager.sharedManager
  static let serviceURL = "http://192.168.178.1:49000"
  static let descURL = "/tr64desc.xml"
  static let completionHandler = { (_:NSURLRequest?, _:NSHTTPURLResponse?, XML:Result<AEXMLDocument>) -> Void in
    guard let xml = XML.value else { return }
    manager.lastResponse = xml
  }

  static func getAvailableServices() {
    let requestURL = TR064.serviceURL + TR064.descURL
    Alamofire.request(.GET, requestURL)
      .validate()
      .responseXMLDocument { (_, _, XML) -> Void in
          if let xml = XML.value {
            manager.services = TR064.getServicesFromXML(xml)
          }else {
            delay(2) { getAvailableServices() }
          }
    }
  }
  
  static func getActionsFor(service: Service) {
    let requestURL = TR064.serviceURL + service.SCPDURL
    Alamofire.request(.GET, requestURL)
      .validate()
      .responseXMLDocument { (_, _, XML) -> Void in
      guard let xml = XML.value else { return }
      let stateVariables = xml.root["serviceStateTable"].children.map {StateVariable(element: $0)}.flatMap {$0}
      let actions = xml.root["actionList"].children.map { Action(element: $0, stateVariables: stateVariables, service: service) }.flatMap {$0}
      manager.actions += actions
    }
  }

  static func createMessageBody(action: Action, arguments: [String] = []) -> NSData? {
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
  
  static func createRequest(action: Action) -> NSMutableURLRequest {
    let request = NSMutableURLRequest(URL: NSURL(string: action.url)!)
    request.addValue("text/xml; charset=utf-8", forHTTPHeaderField:"Content-Type")
    request.addValue("\(action.service.serviceType)#\(action.name)", forHTTPHeaderField: "SOAPAction")
    request.HTTPMethod = "POST"
    return request
  }
  
  static func sendRequest(action: Action, arguments: [String] = []) -> Request {
    let request = createRequest(action)
    request.HTTPBody = createMessageBody(action, arguments: arguments)
    return Alamofire.request(request).authenticate(user: account, password: pass).validate()
  }
  
  static func getXMLFromURL(requestURL: String) -> Request? {
    return Alamofire.request(.GET, requestURL).validate()
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

extension Request {
  public static func XMLResponseSerializer() -> GenericResponseSerializer<AEXMLDocument> {
    return GenericResponseSerializer { request, response, data in
      guard let validData = data else {
        let failureReason = "Data could not be serialized. Input data was nil."
        let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
        return .Failure(data, error)
      }
      do {
        let XML = try AEXMLDocument(xmlData: validData)
        return .Success(XML)
      } catch {
        return .Failure(data, error as NSError)
      }
    }
  }
  
  static func XMLResponseSerializerFor(action: Action) -> GenericResponseSerializer<AEXMLElement> {
    return GenericResponseSerializer { request, response, data in
      guard let validData = data else {
        let failureReason = "Data could not be serialized. Input data was nil."
        let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
        return .Failure(data, error)
      }
      do {
        let XML = try AEXMLDocument(xmlData: validData)
        if let validXML = XML.checkResponseOf(Action: action) {
          return .Success(validXML)
        }else {
          let failureReason = "XML is no valid response for action."
          let error = Error.errorWithCode(.ContentTypeValidationFailed, failureReason: failureReason)
          return .Failure(data, error)
        }
      } catch {
        return .Failure(data, error as NSError)
      }
    }
  }
  

  public func responseXMLDocument(completionHandler: (NSURLRequest?, NSHTTPURLResponse?, Result<AEXMLDocument>) -> Void) -> Self {
    return response(responseSerializer: Request.XMLResponseSerializer(), completionHandler: completionHandler)
  }
}
