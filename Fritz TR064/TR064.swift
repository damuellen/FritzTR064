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
  let desc = "/tr64desc.xml"
  var services = [Service]() {
    didSet {
      services.forEach { $0.getActions() }
      }
  }

  init() {
      getServices()
  }
  
  func getServices() {
    let requestURL = self.serviceURL + self.desc
    Alamofire.request(.GET, requestURL)
      .responseData { (_, response, data) -> Void in
        guard response?.statusCode == 200 else { return }
        guard let xmlRaw = data.value, xml = try? AEXMLDocument.init(xmlData: xmlRaw) else { return }
        self.services = xml.root["device"]["serviceList"].children.map { service in
          Service(element: service, manager: self) }.flatMap {$0}
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
  
  func sendSOAPRequest(action: Action, arguments: [String] = [], block: ([String:String])->()) {
    let request = createSOAPRequest(action)
    request.HTTPBody = createSOAPMessageBody(action)
    let account = "admin"
    let pass = "6473"
    Alamofire.request(request)
      .authenticate(user: account, password: pass)
      .responseData { (_, _, data) -> Void in
        if data.isSuccess {
        guard let xmlRaw = data.value, xml = try? AEXMLDocument.init(xmlData: xmlRaw) else { return }
        let responseDict = self.handleResponseForAction(xml, action: action)
        block(responseDict)
        }
    }
  }
 
  func handleResponseForAction(response: AEXMLDocument, action: Action) -> [String:String] {
    var result = [String: String]()
    print(response.xmlString)
    let soapResponse = response.root["s:Body"]["u:\(action.name)Response"]
    for key in action.output.keys {
      if let value = soapResponse[key].value {
        result[key] = value
      }
    }
    return result
  }
  
}
