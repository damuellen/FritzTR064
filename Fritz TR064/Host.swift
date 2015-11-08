//
//  Host.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 25/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

struct Host {
	
	let macAddress: String
	let active: Bool
	let ip: String?
	let leaseTime: Int
	let hostName: String
	let addressSource: String
	let interfaceType: String
	
	init(host: [String: String]) {
		macAddress = host["NewMACAddress"]!
		active = host["NewActive"]! == "1"
		ip = host["NewIPAddress"]
		leaseTime = Int(host["NewLeaseTimeRemaining"]!)!
		hostName = host["NewHostName"]!
		addressSource = host["NewAddressSource"]!
		interfaceType = host["NewInterfaceType"]!
	}
	
}

extension Host: Equatable { }

func ==(lhs: Host, rhs: Host) -> Bool {
	return lhs.macAddress == rhs.macAddress
}

extension Host: PropertyListReadable {
  
  func propertyListRepresentation() -> NSDictionary {
    let representation:[String:AnyObject] =
    ["macAddress":macAddress, "active":active, "ip":ip ?? "", "leaseTime":leaseTime, "hostName":hostName, "addressSource":addressSource, "interfaceType":interfaceType]
    return representation
  }
  
  init?(propertyListRepresentation: NSDictionary?) {
    
    guard let values = propertyListRepresentation
      else { return nil }
    
    guard let macAddress = values["macAddress"] as? String,
      active = values["active"] as? Bool,
      ip = values["ip"] as? String,
    leaseTime = values["leaseTime"] as? Int,
    hostName = values["hostName"] as? String,
    addressSource = values["addressSource"] as? String,
    interfaceType = values["interfaceType"] as? String
      else { return nil }
    
    self.macAddress = macAddress
    self.active = active
    self.ip = ip
    self.leaseTime = leaseTime
    self.hostName = hostName
    self.addressSource = addressSource
    self.interfaceType = interfaceType
  }
  
}
