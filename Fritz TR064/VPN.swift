//
//  VPN.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 05/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation
import NetworkExtension

func VPN()->NEVPNConnection {
  
  NEVPNManager.sharedManager().loadFromPreferencesWithCompletionHandler { _ in
    let p = NEVPNProtocolIPSec()
    
    p.useExtendedAuthentication = true
    p.serverAddress = server
    p.disconnectOnSleep = true
    p.localIdentifier = "vpn"
    p.username = username
    p.passwordReference = Keychain.persistentRefForKey("passwordvpn")
    p.authenticationMethod = NEVPNIKEAuthenticationMethod.SharedSecret
    p.sharedSecretReference = Keychain.persistentRefForKey("secret")
    
    NEVPNManager.sharedManager().enabled = true
    NEVPNManager.sharedManager().protocolConfiguration = p
    NEVPNManager.sharedManager().localizedDescription = "VPN"
    
    NEVPNManager.sharedManager().saveToPreferencesWithCompletionHandler { _ in
      let _ = try? NEVPNManager.sharedManager().connection.startVPNTunnel()
    }
  }
  return NEVPNManager.sharedManager().connection
}
