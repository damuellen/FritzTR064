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
  
  static let serverTrustPolicies = [
    NSURL(string: "https://fritz.box:49443")!.host!: ServerTrustPolicy.DisableEvaluation]

  var observer: TR064ServiceObserver?
  var activeService: TR064Service?
  
  var device: TR064.Device? {
    didSet {
      observer?.refreshUI(true)
    }
  }

  var soapResponse: Any? {
    didSet {
      observer?.refreshUI(true)
    }
  }
  
  var passphrase: String?
  
  private override init(configuration: NSURLSessionConfiguration, serverTrustPolicyManager: ServerTrustPolicyManager?) {
    super.init(configuration: configuration, serverTrustPolicyManager: serverTrustPolicyManager)
  }
  
  subscript(ServiceName: String) -> [Action]? {
    return self.device?.actions.lazy.filter { $0.name == ServiceName }
  }
  
  subscript(ActionsFrom service: Service) -> [Action]? {
    return self.device?.actions.lazy.filter { $0.service == service }
  }
  
  /// Sends an request for an action with arguments, and returns a future response.
  func startAction(action: Action, arguments: [String] = []) -> ActionResultPromise {
    
    let request = sendRequest(action, arguments: arguments)
    
    let timer = Timeout.scheduledTimer(4) { _ in self.observer?.alert() }
    
    request.responseXMLDocument { (_,_,xml) in
      timer.invalidate()
    }
    request.responseXMLPromise().trap { _ in
      timer.fire()
    }
    return request.responsePromiseFor(Action: action)
  }
  
  /// Sends an request for an action with arguments.
  private func sendRequest(action: Action, arguments: [String] = []) -> Request {
    
    let request = TR064.createRequest(action)
    request.HTTPBody = TR064.createMessage(action, arguments: arguments)
    
    return self.request(request).authenticate(user: account, password: pass).validate()
  }
  
  func getXMLFromURL(requestURL: String) -> Request? {
    return self.request(.GET, requestURL).validate()
  }
  
  /// Use the URL from the given service to request his actions.
  func requestActionsFor(service: Service) -> Promise<AFPValue<AEXMLDocument>, AFPError> {
    return  self.request(.GET, "https://fritz.box:49443" + service.SCPDURL ).validate().responseXMLPromise()
  }
  
}

protocol TR064ServiceObserver {
  var manager: TR064Manager { get }
  func refreshUI(animated: Bool)
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

