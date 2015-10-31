//
//  TR064Manager.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 05/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

/// Handler for the founded actions, and XML response of the last request.

class TR064Manager {
  
  static let sharedManager = TR064Manager()
  
  var observer: TR064ServiceObserver?

  var activeService: TR064Service?
  
  var services = [Service]()
  
  var actions = [Action]()
  
  var isReady: Bool = false {
    didSet {
      observer?.refreshUI()
    }
  }

 // var lastResponse: AEXMLDocument? {
 //   didSet {
 //     observer?.refreshUI()
 //  }
 // }

  subscript(ServiceName: String) -> [Action] {
    return self.actions.filter { $0.name == ServiceName }
  }
  
  subscript(ActionsFrom service: Service) -> [Action] {
    return self.actions.filter { $0.service == service }
  }
    
}

let Manager = TR064Manager.sharedManager

protocol TR064ServiceObserver {
  var manager: TR064Manager { get }
  func refreshUI()
  func alert()
}

extension TR064ServiceObserver {
  var manager: TR064Manager { return Manager }
}

protocol TR064Service {
  static var serviceType: String { get }
}

extension TR064Service {
  static var manager: TR064Manager { return Manager }
  static var observer: TR064ServiceObserver? { return Manager.observer }
  
  static func alert() {
    manager.observer?.alert()
  }
}

extension MasterViewController: TR064ServiceObserver {
  
  func refreshUI() {
    var result = [(service: Service, actions: [Action])]()
    result = Manager.services.map { service in
      (service: service, actions: Manager[ActionsFrom: service] )
    }
    self.tableData = result
  }
  
}

