//
//  TR064Manager.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 05/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//


import Alamofire

class TR064Manager: Manager {
  
  static let sharedManager: TR064Manager = TR064Manager(
      configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
      serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
  
  static let serverTrustPolicies: [String: ServerTrustPolicy] = [NSURL(string: "https://fritz.box:49443")!.host!: .DisableEvaluation ]

  var observer: TR064ServiceObserver?

  var activeService: TR064Service?
  
  var activeDevice: TR064.Device?
  
  var isReady: Bool = false {
    didSet {
      observer?.refreshUI()
    }
  }
  
  var soapResponse: Any? {
    didSet {
      observer?.refreshUI()
    }
  }
  
  var passphrase: String?
  
  private override init(configuration: NSURLSessionConfiguration, serverTrustPolicyManager: ServerTrustPolicyManager?) {
    super.init(configuration: configuration, serverTrustPolicyManager: serverTrustPolicyManager)
  }
  
  subscript(ServiceName: String) -> [Action]? {
    return self.activeDevice?.actions.lazy.filter { $0.name == ServiceName }
  }
  
  subscript(ActionsFrom service: Service) -> [Action]? {
    return self.activeDevice?.actions.lazy.filter { $0.service == service }
  }
  
}

protocol TR064ServiceObserver {
  var manager: TR064Manager { get }
  func refreshUI()
  func alert()
}

extension TR064ServiceObserver {
  var manager: TR064Manager { return TR064Manager.sharedManager }
}

protocol TR064Service {
  static var manager: TR064Manager { get }
  static var serviceType: String { get }
}

extension TR064Service {
  static var manager: TR064Manager { return TR064Manager.sharedManager }
  static var observer: TR064ServiceObserver? { return TR064Manager.sharedManager.observer }
}

