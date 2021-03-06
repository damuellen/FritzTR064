//
//  MasterViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

extension MasterViewController: UISearchResultsUpdating, UISearchBarDelegate {
  
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    if let searchText = searchController.searchBar.text where !searchText.isEmpty {
      filteredData = self.tableData.map { service in
        (service: service.service, actions: filterActionByName(service.actions, filter: searchText)) }
    } else {
      filteredData = tableData
    }
  }
  
  func filterActionByName(actions: [Action], filter: String)-> [Action] {
    return actions.filter { $0.name.lowercaseString.containsString(filter.lowercaseString) }
  }
  
}

class MasterViewController: UITableViewController, UISearchDisplayDelegate, TR064ServiceObserver   {
  
  private var tableData: [(service: Service, actions: [Action])] = [] {
    didSet {
      filteredData = tableData
    }
  }
  private var filteredData: [(service: Service, actions: [Action])] = [] {
    didSet {
      tableView.reloadData()
    }
  }
  
  let bgView = GradientView(frame: CGRectZero)
  
  private let resultSearchController =  UISearchController(searchResultsController: nil)
  var detailViewController: ActionArgumentsVC?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let split = self.splitViewController {
      let controllers = split.viewControllers
      self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ActionArgumentsVC
    }
    setup(tableView)
    
    resultSearchController.searchResultsUpdater = self
    resultSearchController.hidesNavigationBarDuringPresentation = false
    resultSearchController.dimsBackgroundDuringPresentation = false
    resultSearchController.searchBar.searchBarStyle = UISearchBarStyle.Prominent
    resultSearchController.searchBar.sizeToFit()
    resultSearchController.searchBar.delegate = self
  }
  
  func setup(tableView: UITableView) {
    tableView.backgroundView = bgView
    tableView.rowHeight = 44
    tableView.tableHeaderView = resultSearchController.searchBar
    tableView.delegate = self
  }
  
  var services: [Service] { return manager.device?.services ?? [] }
  
  func refreshUI(animated: Bool) {
    self.tableData = services.map { service in
      (service: service, actions: manager[ActionsFrom: service]! )
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    manager.observer = self
    self.refreshUI(true)
    bgView.frame = tableView.bounds
    self.clearsSelectionOnViewWillAppear ?= self.splitViewController?.collapsed
    view.bringSubviewToFront(navigationController!.navigationBar)
    super.viewWillAppear(animated)
  }
  
  @IBAction func showMenu(sender: AnyObject) {
    toggleSideMenuView()
  }
  
  func alert() {
    
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    guard let indexPath = self.tableView.indexPathForSelectedRow else { return }
    let vc = (segue.destinationViewController as! UINavigationController).topViewController as! ActionArgumentsVC
    vc.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
    vc.navigationItem.leftItemsSupplementBackButton = true
    vc.service = self.filteredData[indexPath.section].service
    vc.action = self.filteredData[indexPath.section].actions[indexPath.row]
    vc.showArguments(segue)
    resultSearchController.dismissViewControllerAnimated(true, completion: {})
  }
  
  // MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.filteredData.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.filteredData[section].actions.count
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let cell = tableView.dequeueReusableCellWithIdentifier("Section")
    cell?.backgroundColor = UIColor.blackColor()
    cell?.textLabel?.textColor = UIColor.whiteColor()
    let object = services.map {$0}[section]
    cell?.textLabel!.text = object.serviceType.stringByReplacingOccurrencesOfString("urn:dslforum-org:service:", withString: "")
    return cell
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let service = self.filteredData[indexPath.section].service
    let action = self.filteredData[indexPath.section].actions[indexPath.row]
    if action.needsInput {
      let cell = tableView.dequeueReusableCellWithIdentifier("Input", forIndexPath: indexPath)
      cell.textLabel!.text = action.name  // .stringByReplacingOccurrencesOfString("X_AVM-DE_", withString: "")
      cell.detailTextLabel?.text = service.controlURL
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("Output", forIndexPath: indexPath)
      cell.textLabel!.text = action.name  // .stringByReplacingOccurrencesOfString("X_AVM-DE_", withString: "")
      cell.detailTextLabel?.text = service.controlURL
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.backgroundColor = UIColor.clearColor()
    cell.backgroundView?.backgroundColor = UIColor.clearColor()
    CellAnimator.animateCell(cell, withTransform: CellAnimator.TransformFlip, andDuration: 0.2)
  }
}
