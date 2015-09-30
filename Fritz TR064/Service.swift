//
//  Service.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation
import Alamofire

class Service {
  let manager: TR064
  let serviceType: String
  let controlURL: String
  let SCPDURL: String
  var actions = [Action]()
  
  convenience init?(element: AEXMLElement, manager: TR064) {
    if let serviceType = element["serviceType"].value, controlURL = element["controlURL"].value, SCPDURL = element["SCPDURL"].value {
      self.init(serviceType: serviceType, controlURL: controlURL, SCPDURL: SCPDURL, manager: manager)
    } else { return nil }
  }
  
  init(serviceType: String, controlURL: String, SCPDURL: String, manager: TR064) {
    self.serviceType = serviceType
    self.controlURL = controlURL
    self.SCPDURL = SCPDURL
    self.manager = manager
  }

  class func discoverServices(discription: AEXMLDocument) {
    let internetGatewayDevice = discription.root["device"],
    LANDevice = discription.root["device"]["deviceList"].children[0],
    WANDevice = discription.root["device"]["deviceList"].children[1]
    
    var serviceList = internetGatewayDevice["serviceList"].children
    serviceList += LANDevice["serviceList"].children
    serviceList += WANDevice["serviceList"].children
    
    TR064.sharedInstance.services = serviceList.map { service in
      Service(element: service, manager: TR064.sharedInstance) }.flatMap {$0}
  }
}

