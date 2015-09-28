//
//  DetailViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

protocol SOAPDelegate {
  var response : [String] { get set }
  var currentAction: Action? { get set }
  func sendCurrentAction()
  func showOutputArguments()
  func showInputArguments()
}

class DetailViewController: UITableViewController, SOAPDelegate {

  var response = [String]()
  var currentAction: Action?
  var needsInput = false

  func sendCurrentAction() {
    if currentAction?.needsInput == true { return }
    guard let action = self.currentAction else { return }
    action.service.manager.sendSOAPRequest(action, arguments: [], block: { responseDict in
      self.response = responseDict.values.flatMap {$0}
      self.navigationItem.title = "Response"
      self.tableView.reloadData()
      self.currentAction = nil
    })
  }
  
  func showOutputArguments() {
    needsInput = false
    guard let action = self.currentAction else { return }
    self.response = action.output.keys.map { $0 }
    self.tableView.reloadData()
  }
  
  func showInputArguments() {
    needsInput = true
    guard let action = self.currentAction else { return }
    self.response = action.input.values.map { stateVariable in stateVariable.defaultValue }
    self.tableView.reloadData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.estimatedRowHeight = 44.0
    tableView.rowHeight = UITableViewAutomaticDimension
  }

  override func viewWillAppear(animated: Bool) {
    self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
    super.viewWillAppear(animated)
  }

  // MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (self.response.count)
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    let object = self.response[indexPath.row]
    cell.textLabel?.numberOfLines = 0
    cell.textLabel?.lineBreakMode = .ByWordWrapping
    cell.textLabel!.text = object
    return cell
  }

  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return self.needsInput
  }
  
}

