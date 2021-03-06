//
//  DetailViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

typealias Argument = (name: String, value: String)

class ActionArgumentsVC: UITableViewController, UITextFieldDelegate {
  
  var tableData = (input: [Argument](),output: [Argument]()) {
    didSet {
      self.tableView.reloadData()
    }
  }
  
  let bgView = GradientView(frame: CGRectZero)
  
  var action: Action!
  var service: Service!
  
  var needsInput = false {
    didSet {
      self.tableView.reloadData()
    }
  }
  var arguments = [String]()
  
  func sendAction() {
    self.performSegueWithIdentifier("sendAction", sender: self)
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    arguments.removeAll()
    for n in 0..<action!.input.count {
      let path = NSIndexPath(forRow: n, inSection: 0)
      let value = (tableView.cellForRowAtIndexPath(path) as! TableViewInputCell).textField.text!
      arguments.append(value)
    }
    self.navigationItem.rightBarButtonItem?.enabled = true
    return false
  }
  
  func showArguments(segue: UIStoryboardSegue) {
    switch segue.identifier  {
    case "showInput"?:
      needsInput = true
      self.navigationItem.rightBarButtonItem?.enabled = false
    default:
      needsInput = false
    }
    guard let action = self.action
      else { return }
    self.tableData.input = action.input.map { (name: $0.0, value: $0.1.defaultValue) }
    self.tableData.output = action.output.keys.map { ($0.stringByReplacingOccurrencesOfString("New", withString: ""),"") }
    self.navigationItem.title = action.name
    self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
  }
  
  func checkInputArguments() {
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup(tableView)
    let addButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "sendAction")
    self.navigationItem.rightBarButtonItem = addButton
  }
  
  func setup(tableView: UITableView) {
    tableView.backgroundView = bgView
    tableView.delegate = self
  }
  
  override func viewWillAppear(animated: Bool) {
    bgView.frame = tableView.bounds
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //   bgView.removeFromSuperview()
    if segue.identifier == "sendAction" {
      let controller = ((segue.destinationViewController as! UINavigationController).topViewController as! XMLResponseViewController)
      controller.action = self.action
      TR064Manager.sharedManager.startAction(service, action: action, arguments: arguments).then { xml in
        if let result = xml.value.convertWithAction(self.action) {
          TR064Manager.sharedManager.soapResponse = result
        }
      }
    }
  }
  
  @IBOutlet weak var text: UITextField!
  
  // MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    var numberOfSections: Int = 0
    if !tableData.input.isEmpty { numberOfSections += 1 }
    if !tableData.output.isEmpty { numberOfSections += 1 }
    return numberOfSections
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      if !tableData.input.isEmpty { return self.tableData.input.count }
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
    }else if self.action != nil {
      cell?.textLabel!.text = "expected Output"
      return cell
    }else {
      cell?.textLabel!.text = "current Output"
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var argument: Argument
    if indexPath.section == 0 && self.tableData.input.count > 0 {
      argument = self.tableData.input[indexPath.row]
      let cell = tableView.dequeueReusableCellWithIdentifier("InputArgument", forIndexPath: indexPath) as! TableViewInputCell
      cell.textField.delegate = self
      cell.textField.text = argument.value
      cell.label.text = argument.name
      return cell
    }else {
      argument = self.tableData.output[indexPath.row]
      let cell = tableView.dequeueReusableCellWithIdentifier("OutputArgument", forIndexPath: indexPath)
      cell.textLabel?.numberOfLines = 0
      cell.textLabel?.lineBreakMode = .ByWordWrapping
      cell.textLabel?.text = argument.name
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return indexPath.section == 0 && self.tableData.input.count > 0 ? 74 : UITableViewAutomaticDimension
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.backgroundColor = UIColor.clearColor()
    cell.backgroundView?.backgroundColor = UIColor.clearColor()
    CellAnimator.animateCell(cell, withTransform: CellAnimator.TransformWave, andDuration: animationDuration)
  }
  
}
