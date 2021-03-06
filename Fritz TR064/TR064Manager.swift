//
//  TR064Manager.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 05/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Alamofire

typealias ActionResultPromise = Promise<AFPValue<AEXMLElement>, AFPError>

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
  
  var credential = NSURLCredential(user: account, password: pass, persistence: .None)
  
  private override init(configuration: NSURLSessionConfiguration, serverTrustPolicyManager: ServerTrustPolicyManager?) {
    super.init(configuration: configuration, serverTrustPolicyManager: serverTrustPolicyManager)
  }
  
  subscript(serviceType: String) -> Service? {
    return self.device?.services.lazy.filter { $0.serviceType == serviceType }.first
  }
  
  subscript(serviceType: [String]) -> [Service] {
    return self.device?.services.filter { serviceType.contains($0.serviceType) } ?? []
  }
  
  subscript(serviceType: String) -> [Action]? {
    return self.device?.services.lazy.filter { $0.serviceType == serviceType }.first?.actions
  }
  
  subscript(serviceType: [String]) -> [Action]? {
    return self.device?.services.lazy.filter {  serviceType.contains($0.serviceType) }.flatMap { $0.actions }
  }
  
  subscript(ActionsFrom service: Service) -> [Action]? {
    return self.device?.services.lazy.filter { $0 == service }.first?.actions
  }
  
  /// Sends an request for an action with arguments, and returns a future response.
  func startAction(service: Service, action: Action, arguments: [String] = []) -> ActionResultPromise {
    
    let request = sendRequest(service, action: action, arguments: arguments)
    
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
  private func sendRequest(service: Service, action: Action, arguments: [String] = []) -> Request {
    
    let request = TR064.createRequest(service, action: action)
    request.HTTPBody = TR064.createMessage(service, action: action, arguments: arguments)
    self.session
    return self.request(request).authenticate(usingCredential: credential)  }
  
  func getXMLFromURL(requestURL: String) -> Request? {
    return self.request(.GET, requestURL).validate()
  }
  
  /// Use the URL from the given service to request his actions.
  func requestActionsForService(service: Service) -> Promise<AFPValue<AEXMLDocument>, AFPError> {
    return  self.request(.GET, "https://fritz.box:49443" + service.SCPDURL ).validate().responseXMLPromise()
  }
  
}

protocol TR064ServiceObserver {
  var manager: TR064Manager { get }
  var bgView: GradientView { get }
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

