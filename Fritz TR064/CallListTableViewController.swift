//
//  DetailViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class CallListTableViewController: UITableViewController, UITextFieldDelegate {
  
  var tableData: [Call]? {
    didSet {
      self.tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.estimatedRowHeight = 100.0
    tableView.rowHeight = UITableViewAutomaticDimension
    self
  }
  
  override func viewWillAppear(animated: Bool) {
    self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
    super.viewWillAppear(animated)
  }
  
  @IBOutlet weak var text: UITextField!
  // MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableData != nil {
      return self.tableData!.count } else { return 0 }
  }
 
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let call = self.tableData![indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier("CallCell", forIndexPath: indexPath) as! CallCell
    cell.called.text = call.called
    cell.caller.text = call.caller
    cell.name.text = call.name
    cell.port.text = call.port
    cell.device.text = call.device
    let dateFormatter = NSDateFormatter.sharedInstance
    dateFormatter.dateStyle = .ShortStyle
    cell.date.text = dateFormatter.stringFromDate(call.date!)
    cell.duration.text = "\(call.duration)"
    switch call.type {
    case .activeIncoming:
      cell.backgroundColor = UIColor.redColor()
    case .activeOutgoing:
      cell.backgroundColor = UIColor.blueColor()
    case .incoming:
      cell.backgroundColor = UIColor.greenColor()
    case .missed:
      cell.backgroundColor = UIColor.grayColor()
    case .outgoing:
      cell.backgroundColor = UIColor.orangeColor()
    case .rejectedIncoming:
      cell.backgroundColor = UIColor.brownColor()
    case .error:
      cell.backgroundColor = UIColor.blackColor()
    }
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return 100
  }
  
}


