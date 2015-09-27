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

class TR064 {
  var responder: MasterViewController?
  let serviceURL = "http://192.168.178.1:49000"
  let desc = "/tr64desc.xml"
  var services = [Service]() {
    didSet {
      print(services)
    }
  }
  init() {
    getServices()
  }
  func getServices() {
    let requestURL = self.serviceURL + self.desc
    Alamofire.request(.GET, requestURL)
      .responseData { (_, _, data) -> Void in
        guard let xmlRaw = data.value, xml = try? AEXMLDocument.init(xmlData: xmlRaw) else { return }
        self.services = xml.root["device"]["serviceList"].children.map { service in Service(element: service, manager: self) }.flatMap {$0}
    }
  }
  func sendMessage(action: Action, arguments: [String] = []) {
    var soapMessageHeader = "<?xml version=\"1.0\"?>"
    soapMessageHeader += "<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\""
    soapMessageHeader += "s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
    soapMessageHeader += "<s:Body><u:\(action.name) xmlns:u=\"\(action.service.serviceType)\">"
    for (argument, value) in zip(action.input.keys, arguments) {
      soapMessageHeader += "<\(argument)>\(value)</\(argument)>"
    }
    soapMessageHeader += "</u:\(action.name)></s:Body></s:Envelope>"
    let requestBody = soapMessageHeader.dataUsingEncoding(NSUTF8StringEncoding)!
    let request = NSMutableURLRequest(URL: NSURL(string: action.url)!)
    request.addValue("text/xml; charset=utf-8", forHTTPHeaderField:"Content-Type")
    request.addValue("\(action.service.serviceType)#\(action.name)", forHTTPHeaderField: "SOAPAction")
    request.HTTPMethod = "POST"
    request.HTTPBody = requestBody
    let account = "admin"
    let pass = "6473"
    Alamofire.request(request)
      .authenticate(user: account, password: pass)
      .responseData { (_, _, data) -> Void in
        if let xmlRaw = data.value, xml = try? AEXMLDocument.init(xmlData: xmlRaw) {
          print(xml.xmlString)
        }
    }
    
  }
}
