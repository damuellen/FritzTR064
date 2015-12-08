//
//  DeviceView.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 30/11/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class DeviceViewController: UITableViewController, TR064ServiceObserver {
  
  deinit {
    debugPrint("deinit",self)
  }
  
  @IBOutlet weak var routerIP: UITextField!
  @IBOutlet weak var routerPassword: UITextField!
  @IBOutlet weak var vpnAdresse: UITextField!
  @IBOutlet weak var vpnUser: UITextField!
  @IBOutlet weak var vpnGroup: UITextField!
  @IBOutlet weak var vpnPassword: UITextField!
  @IBOutlet weak var sharedSecret: UITextField!
  @IBOutlet var allTextFields: [UITextField]!
  
  let bgView = GradientView(frame: CGRectZero)
  var manager = TR064Manager.sharedManager
  
  func refreshUI(animated: Bool) {
    
  }
  func alert() {
    
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    setup(tableView)
  }
  
  func setup(tableView: UITableView) {
    tableView.backgroundView = bgView
    tableView.scrollsToTop = false
    tableView.delegate = self
    let contentInsets = UIEdgeInsetsMake(self.topLayoutGuide.length + 5, 0, 0, 0)
    tableView.contentInset = contentInsets
  }
}