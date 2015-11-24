//
//  DetailViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class XMLResponseViewController: UITableViewController, UITextFieldDelegate, TR064ServiceObserver {
  
  var tableData: [String:String] {
    get {
      return manager.soapResponse as? [String:String] ?? [String:String]()
    }
  }
  
	let bgView = GradientView(frame: CGRectZero)
  var action: Action?
  
  func refreshUI(animated: Bool) {
    tableView.reloadData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    modalTransitionStyle = .CrossDissolve
    manager.observer = self
    setup(tableView)
  }
  
  func setup(tableView: UITableView) {
    tableView.backgroundView = bgView
    tableView.estimatedRowHeight = 44.0
    tableView.delegate = self
    tableView.scrollsToTop = false
  }

  override func viewWillAppear(animated: Bool) {
    bgView.frame = tableView.bounds
  //  self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(animated: Bool) {
  }
  
  @IBAction func showMenu(sender: AnyObject) {
    toggleSideMenuView()
  }
  
  func alert() {
    self.appearAlertViewWithTitle("Error", message: "No response",
      actionTitle: ["Retry"],
      actionBlock: [{
        if let action = self.action {
        self.manager.startAction(action)
        }
        }])
  }
  
  @IBOutlet weak var text: UITextField!
}

// MARK: - Table View

extension XMLResponseViewController {
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    guard let text = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text else { return }
      UIPasteboard.generalPasteboard().string = text
    if text.containsURL() {
      manager.getXMLFromURL(text)?.responseXMLDocument(TR064.completionHandler)
      if text.containsString("calllist") {
        self.performSegueWithIdentifier("showCallList", sender: self)
      }
    }
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.tableData.count
  }

  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let argument = Array(self.tableData)[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier("Output", forIndexPath: indexPath)
    cell.textLabel?.numberOfLines = 0
    cell.textLabel?.lineBreakMode = .ByWordWrapping
    cell.textLabel!.text = argument.1
    cell.detailTextLabel?.text = argument.0
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return UITableViewAutomaticDimension
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.backgroundColor = UIColor.clearColor()
    cell.backgroundView?.backgroundColor = UIColor.clearColor()
    cell.alpha = 0
    UIView.animateWithDuration(animationDuration) {
      cell.alpha = 1
    }
  }
  
}


