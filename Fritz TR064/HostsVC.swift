//
//  DetailViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class HostsVC: UITableViewController, TR064ServiceObserver {
    
  var tableData = [[String:String]]() {
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
  
  @IBAction func returnFromSegueActions(sender: UIStoryboardSegue){
    
  }
  
  func alert() {
    self.appearAlertViewWithTitle("Error", message: "No hosts found",
      actionTitle: ["Retry"],
      actionBlock: [{Hosts.getAllHosts()}])
  }
  
  @IBOutlet weak var text: UITextField!

  // MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return tableData.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableData[section].count
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let cell = tableView.dequeueReusableCellWithIdentifier("Section")
    cell?.backgroundColor = UIColor.blackColor()
    cell?.textLabel?.textColor = UIColor.whiteColor()
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 10
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
		cell.textLabel?.text = Array(self.tableData[indexPath.section].values)[indexPath.row]
		cell.detailTextLabel?.text = Array(self.tableData[indexPath.section].keys)[indexPath.row]
    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let entry = indexPath.section
    let hostMAC = tableData[entry]["NewMACAddress"]!
    let hostName = tableData[entry]["NewHostName"]!
    let hostIP = tableData[entry]["NewIPAddress"]!
    
    appearAlertViewWithTitle(hostName, message: hostMAC,
      actionTitle: ["Wake up", "VNC"],
      actionBlock: [{ Hosts.wakeHost(hostMAC) },
        { appDelegate.vpnStayConnected = true
          UIApplication.sharedApplication().openURL(NSURL(string: "vnc://" + hostIP)!) }])
  }
}
