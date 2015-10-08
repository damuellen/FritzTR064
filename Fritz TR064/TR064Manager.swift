//
//  TR064Manager.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 05/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

class TR064Manager {
  
  static let sharedInstance = TR064Manager()
  
  var observer: TR064ServiceObserver!

  var services = [Service]()  {
    didSet { services.forEach { service in TR064.getActionsFor(service) } }
  }
  
  var actions = [Action]() {
    didSet { observer.refresh() }
  }
  
  var lastResponse: AEXMLDocument? {
    didSet { observer.refresh() }
  }

    
  init() {
    TR064.getAvailableServices()
  }
  
}

protocol TR064ServiceObserver {
  func refresh()
}

extension MasterViewController: TR064ServiceObserver {
  
  func refresh() {
    var result = [(service: Service, actions: [Action])]()
    result = TR064Manager.sharedInstance.services.map { service in
      (service: service, actions: TR064Manager.sharedInstance.actions.filter { $0.service == service })
    }
    self.tableData = result
    self.filteredData = result
    self.tableView.reloadData()
  }
  
}