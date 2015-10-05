//
//  MasterViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

protocol TR064ResponseDelegate {
  func refresh()
}
protocol TR064ServiceDelegate {
  func refresh()
}

extension MasterViewController: TR064ServiceDelegate {
  
  func refresh() {
    var result = [(service: Service, actions: [Action])]()
    result = TR064Manager.sharedInstance.services.map { service in
      (service: service, actions: TR064Manager.sharedInstance.actions.filter { $0.service == service })
    }
    self.tableData = result
    self.filteredData = result
    self.tableView.reloadData()
  }
  
}

class MasterViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating  {
  
  var tableData = [(service: Service, actions: [Action])]()
  var filteredData = [(service: Service, actions: [Action])]()
  var resultSearchController = UISearchController()
  var detailViewController: DetailViewController? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    TR064Manager.sharedInstance.delegate = self
    if let split = self.splitViewController {
      let controllers = split.viewControllers
      self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
    resultSearchController = {
      let controller = UISearchController(searchResultsController: nil)
      controller.searchResultsUpdater = self
      controller.hidesNavigationBarDuringPresentation = false
      controller.dimsBackgroundDuringPresentation = false
      controller.searchBar.searchBarStyle = UISearchBarStyle.Prominent
      controller.searchBar.scopeButtonTitles = ["Name", "Service"]
      controller.searchBar.sizeToFit()
      controller.searchBar.delegate = self
      self.tableView.tableHeaderView = controller.searchBar
      return controller
      }()
  }
  
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    filteredData.removeAll(keepCapacity: false)
    guard let searchText = searchController.searchBar.text else { return }
    switch searchController.searchBar.selectedScopeButtonIndex {
    case 1:
      filteredData = self.tableData.map { service in (service: service.service, actions: filterActionByService(service.actions, filter: searchText)) }
    default:
      filteredData = self.tableData.map { service in (service: service.service, actions: filterActionByName(service.actions, filter: searchText)) }
    }
    tableView.reloadData()
  }
  
  func filterActionByName(actions: [Action], filter: String)-> [Action] {
    return actions.filter { $0.name.lowercaseString.containsString(filter.lowercaseString) || filter == "" }
  }
  
  func filterActionByService(actions: [Action], filter: String)-> [Action] {
    return actions.filter { $0.service.serviceType.lowercaseString.containsString(filter.lowercaseString) }
  }
  
  
  override func viewWillAppear(animated: Bool) {
    self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
    super.viewWillAppear(animated)
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
    let action: Action
    if !resultSearchController.active {
      action = self.filteredData[indexPath.section].actions[indexPath.row]
    }else {
      action = self.tableData[indexPath.section].actions[indexPath.row]
    }
    let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
    controller.action = action
    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
    controller.navigationItem.leftItemsSupplementBackButton = true
    if segue.identifier == "showOutput" {
      controller.showOutputArguments()
    }
    if segue.identifier == "showInput" {
      controller.showInputArguments()
    }
    self.resultSearchController.dismissViewControllerAnimated(true, completion: {})
  }
  
  // MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.tableData.count
    // return TR064.sharedInstance.services.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if !resultSearchController.active {
      return self.tableData[section].actions.count
    } else {
      return self.filteredData[section].actions.count
    }
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let cell = tableView.dequeueReusableCellWithIdentifier("Section")
    cell?.backgroundColor = UIColor.blackColor()
    cell?.textLabel?.textColor = UIColor.whiteColor()
    let object = TR064Manager.sharedInstance.services[section]
    cell?.textLabel!.text = object.serviceType.stringByReplacingOccurrencesOfString("urn:dslforum-org:service:", withString: "")
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let action = self.tableData[indexPath.section].actions[indexPath.row]
    if action.needsInput {
      let cell = tableView.dequeueReusableCellWithIdentifier("Input", forIndexPath: indexPath)
      cell.textLabel!.text = action.name.stringByReplacingOccurrencesOfString("X_AVM-DE_", withString: "")
      cell.detailTextLabel?.text = action.url
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("Output", forIndexPath: indexPath)
      cell.textLabel!.text = action.name.stringByReplacingOccurrencesOfString("X_AVM-DE_", withString: "")
      cell.detailTextLabel?.text = action.url
      return cell
    }
  }
  
}
