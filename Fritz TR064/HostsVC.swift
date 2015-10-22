//
//  DetailViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class HostsVC: UITableViewController, UITextFieldDelegate, TR064ServiceObserver {
    
  var tableData = [[String:String]]() {
    didSet {
      self.tableView.reloadData()
    }
  }

  var action: Action!

  func refreshUI() {
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    manager.observer = self
    manager.activeService = Hosts()
    (manager.activeService as! Hosts).getAllHosts()
    tableView.estimatedRowHeight = 44.0
    tableView.rowHeight = UITableViewAutomaticDimension
  }

  override func viewDidAppear(animated: Bool) {
    delay(5) {
      if self.tableData.count == 0 {
        self.alert()
      }
    }
  }
  
  func alert() {
    self.appearAlertViewWithTitle("Error", message: "No hosts found",
      actionTitle: ["Retry"],
      actionBlock: [{(self.manager.activeService as! Hosts).getAllHosts()}])
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
    return 20
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    cell.textLabel?.text = self.tableData[indexPath.section].values.map{$0}[indexPath.row]
    cell.detailTextLabel?.text = self.tableData[indexPath.section].keys.map{$0}[indexPath.row]
    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let entry = indexPath.section
    let hostMAC = tableData[entry]["NewMACAddress"]!
    let hostName = tableData[entry]["NewHostName"]!
    let hostIP = tableData[entry]["NewIPAddress"]!
    
    appearAlertViewWithTitle(hostName, message: hostMAC,
      actionTitle: ["Wake up", "VNC"],
      actionBlock: [{ (self.manager.activeService as! Hosts).wakeHost(hostMAC) },
        { appDelegate.vpnStayConnected = true
          UIApplication.sharedApplication().openURL(NSURL(string: "vnc://" + hostIP)!) }])
  }
}
