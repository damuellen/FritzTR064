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

  func refresh() {
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    TR064Manager.sharedManager.observer = self
    Hosts.sharedService.observer = self
    Hosts.sharedService.getAllHosts()
    tableView.estimatedRowHeight = 44.0
    tableView.rowHeight = UITableViewAutomaticDimension
  }
  
  func appearAlertViewController(message: String, block: () -> Void){
    let alert:UIAlertController = UIAlertController(title: "Wake on LAN", message: ("\n" + message), preferredStyle: .ActionSheet)
    let action = UIAlertAction(title: "Wake", style: UIAlertActionStyle.Default) { (action:UIAlertAction!) -> Void in block() }
    alert.addAction(action)
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    presentViewController(alert, animated: true, completion: nil)
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
    let hostMAC = Hosts.sharedService.entries[indexPath.section]["NewMACAddress"]!
    let hostName = Hosts.sharedService.entries[indexPath.section]["NewHostName"]!
    self.appearAlertViewController(hostName) {
      Hosts.sharedService.wakeHost(hostMAC)
    }
  }
  
}
