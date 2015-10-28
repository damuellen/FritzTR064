//
//  SettingsVC.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 25/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {
	
	@IBOutlet weak var routerIP: UITextField!
	@IBOutlet weak var routerPassword: UITextField!
	@IBOutlet weak var vpnAdresse: UITextField!
	@IBOutlet weak var vpnUser: UITextField!
	@IBOutlet weak var vpnGroup: UITextField!
	@IBOutlet weak var vpnPassword: UITextField!
	@IBOutlet weak var sharedSecret: UITextField!
	@IBOutlet var allTextFields: [UITextField]!
  
  let bgView = GradientView(frame: CGRectZero)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundView = bgView
  }
  
  override func viewWillAppear(animated: Bool) {
    bgView.frame = view.frame
  }
  
}
