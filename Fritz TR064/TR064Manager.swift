//
//  TR064Manager.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 05/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

class TR064Manager {
  
  static let sharedInstance = TR064Manager()
  
  var delegate: TR064ServiceDelegate!
  
  var services = [Service]()  {
    didSet { services.forEach { service in TR064.getActionsFor(service) } }
  }
  
  var actions = [Action]() {
    didSet { delegate.refresh() }
  }
  
  var lastResponse: AEXMLDocument? {
    didSet { delegate.refresh() }
  }
  
  var descXML: AEXMLDocument!
  
  init() {
    TR064.getAvailableServices()
  }

}

