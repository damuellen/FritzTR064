//
//  MasterViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, TR064ServiceDelegate {

  var detailViewController: DetailViewController? = nil
  var objects: [Action] {
    return TR064.sharedInstance.services.map { $0.actions }.flatMap {$0}
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    TR064.sharedInstance.serviceDelegate = self
    //Do any additional setup after loading the view, typically from a nib.
    //let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "updateTable")
    //self.navigationItem.rightBarButtonItem = addButton
    if let split = self.splitViewController {
        let controllers = split.viewControllers
        self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
  }

  func refresh() {
      self.tableView.reloadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
    super.viewWillAppear(animated)
  }

  // MARK: - Segues

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let action = TR064.sharedInstance.services[indexPath.section].actions[indexPath.row]
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
            controller.sendAction(action)
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
  }

  // MARK: - Table View

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return TR064.sharedInstance.services.count
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return TR064.sharedInstance.services[section].actions.count
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let cell = tableView.dequeueReusableCellWithIdentifier("Section")
    let object = TR064.sharedInstance.services[section]
    cell?.textLabel!.text = object.serviceType.stringByReplacingOccurrencesOfString("urn:dslforum-org:service:", withString: "")
    return cell
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

    let object = TR064.sharedInstance.services[indexPath.section].actions[indexPath.row]
    cell.textLabel!.text = object.name.stringByReplacingOccurrencesOfString("X_AVM-DE_", withString: "")
    return cell
  }

  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return false
  }
  
}
