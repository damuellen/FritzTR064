//
//  DetailViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class XMLResponseViewController: UITableViewController, UITextFieldDelegate, TR064ServiceObserver {
  
  var tableData = [String:String]() {
    didSet {
      self.tableView.reloadData()
    }
  }
  
	let bgView = GradientView(frame: CGRectZero)
  var action: Action!
  
  func refreshUI() {
    if let actionResponse = manager.lastResponse?.checkWithAction(self.action),
      validResponse = actionResponse.convertWithAction(self.action) {
        self.tableData = validResponse
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    manager.observer = self
    tableView.estimatedRowHeight = 44.0
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.backgroundView = bgView
  }
  
  override func viewWillAppear(animated: Bool) {
    bgView.frame = tableView.bounds
  //  self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
    super.viewWillAppear(animated)
  }
  
  func alert() {
    fatalError()
  }
  
  @IBOutlet weak var text: UITextField!
}

// MARK: - Table View

extension XMLResponseViewController {
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let text = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text {
      UIPasteboard.generalPasteboard().string = text
    }
    guard let XML = TR064Manager.sharedManager.lastResponse, URL = XML.checkForURLWithAction(self.action) else { return }
    TR064.getXMLFromURL(URL)?.responseXMLDocument(TR064.completionHandler)
    if URL.containsString("calllist") {
			self.performSegueWithIdentifier("showCallList", sender: self)
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
    let argument = self.tableData.lazy.map {$0}[indexPath.row]
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
  
}


