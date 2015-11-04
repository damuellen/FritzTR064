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
    guard let serviceType = element["serviceType"].value,
      controlURL = element["controlURL"].value,
      SCPDURL = element["SCPDURL"].value else { return nil }
    self.init(serviceType: serviceType, controlURL: controlURL, SCPDURL: SCPDURL)
   }

  init(serviceType: String, controlURL: String, SCPDURL: String) {
    self.serviceType = serviceType
    self.controlURL = controlURL
    self.SCPDURL = SCPDURL
  }

}

extension Service: Hashable, Equatable {
  var hashValue: Int { return serviceType.hashValue ^ controlURL.hashValue ^ SCPDURL.hashValue}
}

func ==(lhs: Service, rhs: Service) -> Bool {
  return lhs.hashValue == rhs.hashValue
}

protocol PropertyListReadable {
  func propertyListRepresentation() -> NSDictionary
  init?(propertyListRepresentation: NSDictionary?)
}

extension Service: PropertyListReadable {
  
  func propertyListRepresentation() -> NSDictionary {
    let representation:[String:AnyObject] =
    ["serviceType":serviceType, "controlURL":controlURL, "SCPDURL":SCPDURL]
    return representation
  }
  
  init?(propertyListRepresentation: NSDictionary?) {
    
    guard let values = propertyListRepresentation
      else { return nil }
    
    guard let serviceType = values["serviceType"] as? String,
      controlURL = values["controlURL"] as? String,
      SCPDURL = values["SCPDURL"] as? String
      else { return nil }
    
    self.init(serviceType: serviceType, controlURL: controlURL, SCPDURL: SCPDURL)
  }
  
}
