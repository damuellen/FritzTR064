//
//  TR064.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

protocol TR064ServiceDelegate {
  func refresh()
}

class TR064 {
  
  static let sharedInstance = TR064()
  
  var serviceDelegate: TR064ServiceDelegate?
  
  let serviceURL = "http://192.168.178.1:49000"
  let descURL = "/tr64desc.xml"
  static let account = "admin"
  static let pass = "6473"
  
  var descXML: AEXMLDocument! {
    didSet {
      Service.discoverServices(descXML)
    }
  }
  
  var services = [Service]() {
    didSet {
      services.forEach { askForActions($0) }
    }
  }
  
  init() {
    getServicesDescription()
  }
  
  func getServicesDescription() {
    let requestURL = serviceURL + descURL
    Alamofire.request(.GET, requestURL)
      .responseData { (_, _, data) -> Void in
        guard data.isSuccess else { return }
        self.descXML = try? AEXMLDocument.init(xmlData: data.value!)
    }
  }
  
  func askForActions(service: Service){
    let requestURL = serviceURL + service.SCPDURL
    Alamofire.request(.GET, requestURL)
      .responseData { (_, _, data) -> Void in
        if let xmlRaw = data.value, xml = try? AEXMLDocument.init(xmlData: xmlRaw) {
          let stateVariables = xml.root["serviceStateTable"].children.map {StateVariable(element: $0)}.flatMap {$0}
          service.actions = xml.root["actionList"].children.map { Action(element: $0, stateVariables: stateVariables, service: service) }.flatMap {$0}
          self.serviceDelegate?.refresh()
        }
    }
  }
  
  class func createSOAPMessageBody(action: Action, arguments: [String] = []) -> NSData? {
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
    print("SEND",soapRequest.xmlString)
    return soapRequest.xmlString.dataUsingEncoding(NSUTF8StringEncoding)
  }
  
  class func createSOAPRequest(action: Action) -> NSMutableURLRequest {
    let request = NSMutableURLRequest(URL: NSURL(string: action.url)!)
    request.addValue("text/xml; charset=utf-8", forHTTPHeaderField:"Content-Type")
    request.addValue("\(action.service.serviceType)#\(action.name)", forHTTPHeaderField: "SOAPAction")
    request.HTTPMethod = "POST"
    return request
  }
  
  class func sendSOAPRequest(action: Action, arguments: [String] = [], block: (AEXMLDocument?)->() ) {
    let request = createSOAPRequest(action)
    request.HTTPBody = createSOAPMessageBody(action, arguments: arguments)
    Alamofire.request(request)
      .authenticate(user: account, password: pass)
      .responseData { (_, _, data) -> Void in
        if data.isSuccess {
          block((try? AEXMLDocument.init(xmlData: data.value!)))
        }
    }
  }
  
  class func checkResponseForURL(XML: AEXMLDocument, action: Action) -> String? {
    var URL: String?
    guard let soapResponse = self.checkActionResponse(XML, action: action) else { return nil }
    for possibleURL in soapResponse.children where possibleURL.value != nil {
      if possibleURL.value!.containsString("http") {
        URL = possibleURL.value!
      }
    }
    return URL
  }
  
  class func getXMLFromURL(requestURL: String, block: (AEXMLDocument?)->() ) {
    print("getXMLFromURL", requestURL)
     Alamofire.request(.GET, requestURL)
      .responseData { (_, _, data) -> Void in
        if data.isSuccess {
          block((try? AEXMLDocument.init(xmlData: data.value!)))
        }
    }
  }
  
  class func checkActionResponse(XML: AEXMLDocument, action: Action) -> AEXMLElement? {
    let soapResponse = XML.root["s:Body"]["u:\(action.name)Response"]
    if soapResponse.name == "AEXMLError" { return nil }
    return soapResponse
  }
  
  class func convertActionResponse(XML: AEXMLDocument, action: Action) -> [String:String]? {
    var result = [String:String]()
    guard let soapResponse = self.checkActionResponse(XML, action: action) else { return nil }
    for key in action.output.keys {
      if let value = soapResponse[key].value {
        result[key] = value
      }
    }
    return result
  }
}

typealias SOAPBody = [String:[String]]


extension AEXMLDocument {
  
  func transformXMLtoCalls() -> [Call] {
    if let callsXML = self.root["Call"].all {
      return callsXML.map { Call.CallFromXML($0) }
    }
    return []
  }
  /*
  func transformXMLtoContacts() -> [Contact] {
    if let contactsXML = self.root["phonebooks"]["phonebook"]["contact"].all {
      return contactsXML.map { Contact.ContactFromXML($0) }
    }
    return []
  }
 */ 
}


