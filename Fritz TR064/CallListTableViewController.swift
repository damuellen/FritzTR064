//
//  DetailViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class CallListTableViewController: UITableViewController, TR064ServiceObserver {
  
  //let bgView = GradientView(frame: CGRectZero)
  
  var tableData: [Call]? {
    didSet {
      self.tableView.reloadData()
    }
  }
  
  func refreshUI() {
    // self.tableData = TR064Manager.sharedManager.lastResponse!.transformXMLtoCalls().sort(<)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    manager.observer = self
    manager.activeService = OnTel()
    OnTel.getCallListMaxCalls(20)
    tableView.estimatedRowHeight = 100.0
    tableView.rowHeight = UITableViewAutomaticDimension
   // tableView.backgroundView = bgView
  }
  
  override func viewWillAppear(animated: Bool) {
   // bgView.frame = tableView.bounds
  }
  override func viewDidAppear(animated: Bool) {
    delay(5) { [weak self] in
      if self?.tableData == nil {
        self?.alert()
      }
    }
  }

  func alert() {
    self.appearAlertViewWithTitle("Error", message: "No calls found",
      actionTitle: ["Retry"],
      actionBlock: [{OnTel.getCallListMaxCalls(20)}])
  }
}

// MARK: - Table View

extension CallListTableViewController {
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let call = self.tableData![indexPath.row]
    var phone = "tel://"
    switch call.type {
    case .outgoing, .activeOutgoing:
      if call.called.isPhoneNumber {
        phone += call.called
        let url = NSURL(string: phone)!
        UIApplication.sharedApplication().openURL(url)
      }
    default:
      if call.caller.isPhoneNumber {
      phone += call.caller
      let url = NSURL(string: phone)!
      UIApplication.sharedApplication().openURL(url)
      }
    }

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
    cell.configure(call)
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return 64
  }
  
}

