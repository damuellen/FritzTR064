//
//  Service.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

struct Service {
  
  let serviceType: String
  let controlURL: String
  var SCPDURL: String
  
  init?(element: AEXMLElement) {
    if let serviceType = element["serviceType"].value, controlURL = element["controlURL"].value, SCPDURL = element["SCPDURL"].value {
      self.init(serviceType: serviceType, controlURL: controlURL, SCPDURL: SCPDURL)
    } else { return nil }
   }

  init(serviceType: String, controlURL: String, SCPDURL: String) {
    self.serviceType = serviceType
    self.controlURL = controlURL
    self.SCPDURL = SCPDURL
  }
  

}

extension Service: Equatable { }

func ==(lhs: Service, rhs: Service) -> Bool {
  return lhs.serviceType == rhs.serviceType
}