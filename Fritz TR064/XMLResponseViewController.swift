//
//  DetailViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class XMLResponseViewController: UITableViewController, UITextFieldDelegate {
  
  var tableData: [String:String]! {
    didSet {
      self.tableView.reloadData()
    }
  }
  var action: Action!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.estimatedRowHeight = 44.0
    tableView.rowHeight = UITableViewAutomaticDimension
    
  }
  
  override func viewWillAppear(animated: Bool) {
    self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
    super.viewWillAppear(animated)
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showCallList" {
      let controller = ((segue.destinationViewController as! UINavigationController).topViewController as! CallListTableViewController)
      controller.tableData = TR064Manager.sharedInstance.lastResponse!.transformXMLtoCalls().sort(<)
    }
  }
  
  @IBOutlet weak var text: UITextField!
  // MARK: - Table View
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let text = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text {
      UIPasteboard.generalPasteboard().string = text }
    guard let XML = TR064Manager.sharedInstance.lastResponse, URL = TR064.checkResponseForURL(XML, action: self.action) else { return }
    TR064.getXMLFromURL(URL, block: { if URL.containsString("calllist") { self.performSegueWithIdentifier("showCallList", sender: self) } })
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


