//
//  DetailViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit


typealias Argument = (name: String, value: String)

protocol SOAPDelegate {
  var currentTransmission: Action? { get set }
}

class DetailViewController: UITableViewController, UITextFieldDelegate, SOAPDelegate {
  
  var tableData = (input: [Argument](),output: [Argument]()) {
    didSet {
      self.tableView.reloadData()
    }
  }
  var currentTransmission: Action?
  var needsInput = false {
    didSet {
      self.tableView.reloadData()
    }
  }
  
  var actionOutput: SOAPBody!
  var arguments = [String]() {
    didSet {
      print(arguments.count)
    }
  }
  
  func sendCurrentAction() {
    guard let action = self.currentTransmission else { return }
    
    if currentTransmission?.needsInput == true {
      guard currentTransmission?.input.count == self.arguments.count else { return }
    }
    action.service.manager.sendSOAPRequest(action, arguments: self.arguments, block: {
      self.actionOutput = TR064.returnLastResponseForAction(action)
      self.tableData.output = self.actionOutput.flatMap {(name: $0.0, value: $0.1.first!)}
      //  self.tableData.input = action.input.map { (name: $0.0, value: $0.1.defaultValue) }
      self.tableData.input.removeAll()
      
      self.navigationItem.title = "Response"
      self.currentTransmission = nil
    })
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    arguments.removeAll()
    for n in 0..<currentTransmission!.input.count {
      arguments.append((tableView.cellForRowAtIndexPath(NSIndexPath(forRow: n, inSection: 0)) as! TableViewInputCell).textField.text!)
    }
    self.navigationItem.rightBarButtonItem?.enabled = true
    return false
  }
  
  func showOutputArguments() {
    needsInput = false
    guard let action = self.currentTransmission else { return }
    self.tableData.output = action.output.keys.map { ($0.stringByReplacingOccurrencesOfString("New", withString: ""),"") }
    self.navigationItem.title = action.name
  }
  
  func showInputArguments() {
    needsInput = true
    guard let action = self.currentTransmission else { return }
    self.tableData.input = action.input.map { (name: $0.0, value: $0.1.defaultValue) }
    self.tableData.output = action.output.keys.map { ($0.stringByReplacingOccurrencesOfString("New", withString: ""),"") }
    self.navigationItem.rightBarButtonItem?.enabled = false
    self.navigationItem.title = action.name
  }
  
  func checkInputArguments() {
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let addButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "sendCurrentAction")
    self.navigationItem.rightBarButtonItem = addButton
    tableView.estimatedRowHeight = 44.0
    tableView.rowHeight = UITableViewAutomaticDimension
  }
  
  override func viewWillAppear(animated: Bool) {
    self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
    super.viewWillAppear(animated)
  }
  
  @IBOutlet weak var text: UITextField!
  // MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    var numberOfSections: Int = 0
    if tableData.input.count > 0 { numberOfSections += 1 }
    if tableData.output.count > 0 { numberOfSections += 1 }
    return numberOfSections
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      if tableData.input.count > 0 { return self.tableData.input.count }
      else { return self.tableData.output.count }
    case 1:
      return self.tableData.output.count
    default:
      return 0
    }
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let cell = tableView.dequeueReusableCellWithIdentifier("Section")
    cell?.backgroundColor = UIColor.blackColor()
    cell?.textLabel?.textColor = UIColor.whiteColor()
    if section == 0 && self.tableData.input.count > 0{
      cell?.textLabel!.text = "needed Input"
      return cell
    }else if self.currentTransmission != nil {
      cell?.textLabel!.text = "expected Output"
      return cell
    }else {
      cell?.textLabel!.text = "current Output"
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var argument: Argument
    if indexPath.section == 0 && self.tableData.input.count > 0 {
      argument = self.tableData.input[indexPath.row]
      let cell = tableView.dequeueReusableCellWithIdentifier("Input", forIndexPath: indexPath) as! TableViewInputCell
      cell.textField.delegate = self
      cell.textField.text = argument.value
      cell.label.text = argument.name
      return cell
    }else {
      argument = self.tableData.output[indexPath.row]
      let cell = tableView.dequeueReusableCellWithIdentifier("Output", forIndexPath: indexPath)
      cell.textLabel?.numberOfLines = 0
      cell.textLabel?.lineBreakMode = .ByWordWrapping
      if currentTransmission == nil {
        cell.textLabel!.text = argument.value
        cell.detailTextLabel?.text = argument.name
      }else {
        cell.textLabel!.text = argument.name
        cell.detailTextLabel?.text = ""
      }
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == 0 && self.tableData.input.count > 0 {
      return 74
    }else {
      return UITableViewAutomaticDimension
    }
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }
  
}

