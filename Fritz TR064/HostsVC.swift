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
      self.reloadDataShowAnimated()
      self.refreshControl?.endRefreshing()
      tableView.separatorStyle = .SingleLine
    }
  }

  var action: Action!
  
  func refreshUI() {
    refreshControl?.beginRefreshing()
    Hosts.getAllHosts()
  }
  
  let bgView = GradientView(frame: CGRectZero)
    
  override func viewDidLoad() {
    super.viewDidLoad()
    manager.observer = self
    manager.activeService = Hosts()
    tableView.estimatedRowHeight = 64.0
    tableView.rowHeight = 64
    tableView.backgroundView = bgView
    tableView.separatorStyle = .None
    self.refreshControl = UIRefreshControl()
    self.refreshControl!.addTarget(self, action: "refreshUI", forControlEvents: .ValueChanged)
  }

  override func viewWillAppear(animated: Bool) {
    bgView.frame = view.frame
  }
  
  override func viewDidAppear(animated: Bool) {
    self.refreshUI()
  }
  
  @IBAction func showMenu(sender: AnyObject) {
    toggleSideMenuView()
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
          Hosts.wakeHost(host.macAddress)
          delay(2) { UIApplication.sharedApplication().openURL(NSURL(string: "vnc://" + host.ip!)!) } }])
  }
	
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.backgroundColor = UIColor.clearColor()
    cell.backgroundView?.backgroundColor = UIColor.clearColor()
  }
}
