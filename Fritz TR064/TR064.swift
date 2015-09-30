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
  
  var pendingRequest = false
  
  var lastResponseXML: AEXMLDocument? {
    didSet {
      if lastResponseXML != nil {
        print(lastResponseXML?.xmlString)
      }
    }
  }
  
  var descXML: AEXMLDocument? {
    didSet {
      if descXML != nil {
        Service.discoverServices(descXML!)
      }
    }
  }
  
  var services = [Service]() {
    didSet {
      services.forEach { getActions($0) }
    }
  }
  
  init() {
    getServicesDescription()
  }
  
  func getServicesDescription() {
    let requestURL = self.serviceURL + self.descURL
    Alamofire.request(.GET, requestURL)
      .responseData { (_, _, data) -> Void in
        guard data.isSuccess else { return }
        self.descXML = try? AEXMLDocument.init(xmlData: data.value!)
    }
  }
  
  func createSOAPMessageBody(action: Action, arguments: [String] = []) -> NSData? {
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
  
  func createSOAPRequest(action: Action) -> NSMutableURLRequest {
    let request = NSMutableURLRequest(URL: NSURL(string: action.url)!)
    request.addValue("text/xml; charset=utf-8", forHTTPHeaderField:"Content-Type")
    request.addValue("\(action.service.serviceType)#\(action.name)", forHTTPHeaderField: "SOAPAction")
    request.HTTPMethod = "POST"
    return request
  }
  
  func sendSOAPRequest(action: Action, arguments: [String] = [], block: ()->() ) {
    let request = createSOAPRequest(action)
    request.HTTPBody = createSOAPMessageBody(action)
    let account = "admin"
    let pass = "6473"
    Alamofire.request(request)
      .authenticate(user: account, password: pass)
      .responseData { (_, _, data) -> Void in
        if data.isSuccess {
          self.lastResponseXML = try? AEXMLDocument.init(xmlData: data.value!)
          if let URL = self.checkSOAPResponseForURL(action) {
            self.getXMLFromURL(URL, block: block)
          } else {
            block()
          }
        }
    }
  }
  
  func checkSOAPResponseForURL(action: Action) -> String? {
    guard let soapResponse = self.lastResponseXML?.root["s:Body"]["u:\(action.name)Response"] else { return nil }
    guard let possibleURL = soapResponse.children[0].value else { return nil }
    guard possibleURL.containsString("http") else { return nil }
    return possibleURL
  }
  
  func getActions(service: Service){
    let requestURL = self.serviceURL + service .SCPDURL
    Alamofire.request(.GET, requestURL)
      .responseData { (_, _, data) -> Void in
        if let xmlRaw = data.value, xml = try? AEXMLDocument.init(xmlData: xmlRaw) {
          let stateVariables = xml.root["serviceStateTable"].children.map {StateVariable(element: $0)}.flatMap {$0}
          service.actions = xml.root["actionList"].children.map { Action(element: $0, stateVariables: stateVariables, service: service) }.flatMap {$0}
          self.serviceDelegate?.refresh()
        }
    }
  }
  
  func getXMLFromURL(requestURL: String, block: ()->() ) {
    pendingRequest = true
    Alamofire.request(.GET, requestURL)
      .responseData { (_, _, data) -> Void in
        if data.isSuccess {
          self.lastResponseXML = try? AEXMLDocument.init(xmlData: data.value!)
          block()
        }
    }
  }
  
  class func handleResponse(action: Action) -> [String:String] {
    let XML = TR064.sharedInstance.lastResponseXML
    var result = [String: String]()
    if let callsXML = XML?.root["Call"].all {
      let calls = callsXML.map { Call.CallFromXML($0) }
      calls.forEach { result[String($0.id)] = $0.name }
    } else {
      if let soapResponse = XML?.root["s:Body"]["u:\(action.name)Response"] {
        for key in action.output.keys {
          if let value = soapResponse[key].value {
            result[key] = value
          }
        }
      }
    }
    return result
  }
  
}



