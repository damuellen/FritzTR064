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
