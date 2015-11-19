//
//  DetailViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class CallListTableViewController: UITableViewController, TR064ServiceObserver {
  
  private let bgView = GradientView(frame: CGRectZero)
  private var messageLabel: UILabel?
  private var filter = false
  private var reloading = false
  
  var tableData: [Call] {
    get {
      let calls = manager.soapResponse as? [Call] ?? []
      if filter {
        return calls.filter { $0.duration == 0 }
      } else {
        return calls
      }
    }
  }
  
  func refreshUI() {
    refreshControl?.beginRefreshing()
    self.reloadDataShowAnimated()
    self.refreshControl?.endRefreshing()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    manager.observer = self
    manager.activeService = OnTel()
    setup(tableView)
  }
  
  func setup(tableView: UITableView) {
    tableView.backgroundView = bgView
    tableView.rowHeight = 64
    tableView.delegate = self
  }
  
  @IBAction func callFilterChanged(sender: AnyObject) {
    filter.toggle()
    animateCallCells()
  }
  
  override func viewWillAppear(animated: Bool) {
    bgView.frame = tableView.bounds
  }
  
  override func viewDidAppear(animated: Bool) {
    delay(0.2) { OnTel.getCallListForDays(90) }
  }
  
  @IBAction func showMenu(sender: AnyObject) {
    toggleSideMenuView()
  }
  
  func alert() {
    self.appearAlertViewWithTitle("Error", message: "No calls found",
      actionTitle: ["Retry"],
      actionBlock: [{ OnTel.getCallListForDays(90) }])
  }
  
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if tableData.isEmpty {
      return 0
    } else {
      return 1
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
    if !reloading { CellAnimator.animateCell(cell, withTransform: CellAnimator.TransformScale, andDuration: 0.2) }
  }
}

extension CallListTableViewController {
  
  func animateCallCells() {
    
    let visibleCellsBeforeReload = (self.tableView.visibleCells as! [CallCell])
    let beforeIndicies = visibleCellsBeforeReload.map { $0.id }
    reloading.toggle()
    tableView.reloadData()
    tableView.setContentOffset(self.tableView.contentOffset, animated: true)
    let visibleCellsAfterReload = self.tableView.visibleCells as! [CallCell]
    let afterIndicies = visibleCellsAfterReload.map { $0.id }
    
    let tableHeight: CGFloat = self.tableView.bounds.size.height
    
    for (rowAfter,(cell,id)) in zip(visibleCellsAfterReload,afterIndicies).enumerate() {
      
      if let i = beforeIndicies.indexOf(id) {
        let y = visibleCellsBeforeReload[i].center.y - cell.center.y
        cell.transform = CGAffineTransformMakeTranslation(0, +y)
      } else {
        cell.alpha = 0
        if rowAfter >= beforeIndicies.intersection(afterIndicies).count {
          cell.transform = CGAffineTransformMakeTranslation(0, +tableHeight)
        } else {
          cell.transform = CGAffineTransformMakeTranslation(0, -tableHeight)
        }
      }
    }
    reloading.toggle()
    UIView.animateWithDuration(animationDuration) {
      visibleCellsAfterReload.forEach { $0.transform = CGAffineTransformIdentity
        $0.alpha = 1 }
    }
    
  }
  
}