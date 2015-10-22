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
  
  var services = [Service]()  {
    didSet { services.forEach { service in
      TR064.getActionsFor(service) }
    }
  }
  
  var actions = [Action]() {
    didSet {
      observer?.refreshUI() }
  }
  
  var isReady: Bool {
    return actions.count > 0
  }
  
  var lastResponse: AEXMLDocument? {
    didSet { observer?.refreshUI() }
  }
  
  subscript(name: String) -> Action? {
    return self.actions.filter { $0.name == name }.first
  }

  init() {
    delay(5) {
      if !self.isReady {
        self.observer?.alert()
      }
    }
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
  var manager: TR064Manager { get }
  static var serviceType: String { get }
}

extension TR064Service {
  var manager: TR064Manager { return TR064Manager.sharedManager }
}

extension MasterViewController: TR064ServiceObserver {
  
  func refreshUI() {
    var result = [(service: Service, actions: [Action])]()
    result = TR064Manager.sharedManager.services.map { service in
      (service: service, actions: TR064Manager.sharedManager.actions.filter { $0.service == service })
    }
    self.tableData = result
  }
  
}

