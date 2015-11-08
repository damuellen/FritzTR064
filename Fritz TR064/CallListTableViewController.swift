//
//  DetailViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class CallListTableViewController: UITableViewController, TR064ServiceObserver {
  
  let bgView = GradientView(frame: CGRectZero)
  var messageLabel: UILabel?
  
  var tableData = [Call]() {
    didSet {
      self.reloadDataShowAnimated()
      self.refreshControl?.endRefreshing()
    }
  }
  
  func refreshUI() {
    refreshControl?.beginRefreshing()
    OnTel.getCallListMaxCalls(30)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    manager.observer = self
    manager.activeService = OnTel()
    setup(tableView)
    self.refreshControl = UIRefreshControl()
    self.refreshControl!.addTarget(self, action: "refreshUI", forControlEvents: .ValueChanged)
  }
  
  func setup(tableView: UITableView) {
    tableView.backgroundView = bgView
    tableView.rowHeight = 64
    tableView.delegate = self
  }
  
  
  override func viewWillAppear(animated: Bool) {
    bgView.frame = tableView.bounds
  }
  
  override func viewDidAppear(animated: Bool) {
    delay(0.2) { self.refreshUI() }
  }
  
  @IBAction func showMenu(sender: AnyObject) {
    toggleSideMenuView()
  }
  
  func alert() {
    self.appearAlertViewWithTitle("Error", message: "No calls found",
      actionTitle: ["Retry"],
      actionBlock: [{OnTel.getCallListMaxCalls(20)}])
  }
  
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if tableData.count > 0 {
      return 1
    } else {
      return 0
    }
  }
  
  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    if UIDevice().isIphone {
      
      let closure = { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
        let call = self.tableData[indexPath.row]
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
      return [UITableViewRowAction(style: .Default, title: "Call", handler: closure)]
      
    } else {
      return []
    }
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    
    // Intentionally blank. Required to use UITableViewRowActions
  }
  
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.tableData.count
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let call = self.tableData[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier("CallCell", forIndexPath: indexPath) as! CallCell
    cell.configureCellWith(call)
    return cell
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    CellAnimator.animateCell(cell, withTransform: CellAnimator.TransformScale, andDuration: 0.2)
  }
}
