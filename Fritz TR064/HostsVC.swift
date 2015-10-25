//
//  DetailViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class HostsVC: UITableViewController, TR064ServiceObserver {
    
  var tableData = [Host]() {
    didSet {
      self.tableView.reloadData()
    }
  }

  var action: Action!

  func refreshUI() {
    
  }
  
  let bgView = GradientView(frame: CGRectZero)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    manager.observer = self
    manager.activeService = Hosts()
    Hosts.getAllHosts()
    tableView.estimatedRowHeight = 44.0
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.backgroundView = bgView
  }

  override func viewWillAppear(animated: Bool) {
    bgView.frame = view.bounds
  }
  
  override func viewDidAppear(animated: Bool) {
    delay(5) { [weak self] in
      if self?.tableData.count == 0 {
        self?.alert()
      }
    }
  }
  
  func alert() {
    self.appearAlertViewWithTitle("Error", message: "No hosts found",
      actionTitle: ["Retry"],
      actionBlock: [{Hosts.getAllHosts()}])
  }
  
  @IBOutlet weak var text: UITextField!

  // MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableData.count
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! HostCell
		let host = tableData[indexPath.row]
		cell.configure(host)
    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
 
		let host = tableData[indexPath.row]
    
    appearAlertViewWithTitle(host.hostName, message: host.macAddress,
      actionTitle: ["Wake up", "VNC"],
      actionBlock: [{ Hosts.wakeHost(host.macAddress) },
        { appDelegate.vpnStayConnected = true
          UIApplication.sharedApplication().openURL(NSURL(string: "vnc://" + host.ip)!) }])
  }
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 52
	}
}
