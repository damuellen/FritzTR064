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
  
  func filterActionByService(actions: [Action], filter: String)-> [Action] {
    return actions.filter { $0.service.serviceType.lowercaseString.containsString(filter.lowercaseString) }
  }
  
}

class MasterViewController: UITableViewController, UISearchDisplayDelegate   {
  
  var tableData = [(service: Service, actions: [Action])]() {
    didSet {
      filteredData = tableData
    }
  }
  var filteredData = [(service: Service, actions: [Action])]() {
    didSet {
      tableView.reloadData()
    }
  }

  let bgView = GradientView(frame: CGRectZero)
  
  var resultSearchController: UISearchController!
  var detailViewController: ActionArgumentsVC?

  override func viewDidLoad() {
    super.viewDidLoad()
    if let split = self.splitViewController {
      let controllers = split.viewControllers
      self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ActionArgumentsVC
    }
    tableView.backgroundView = bgView
    tableView.rowHeight = 44
  }
  
  override func viewWillAppear(animated: Bool) {
    manager.observer = self
    self.refreshUI()
    resultSearchController = { [weak self] in
      let controller = UISearchController(searchResultsController: nil)
      controller.searchResultsUpdater = self
      controller.hidesNavigationBarDuringPresentation = false
      controller.dimsBackgroundDuringPresentation = false
      controller.searchBar.searchBarStyle = UISearchBarStyle.Prominent
      controller.searchBar.sizeToFit()
      controller.searchBar.delegate = self
      self?.tableView.tableHeaderView = controller.searchBar
      return controller
      }()
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
		vc.action = self.filteredData[indexPath.section].actions[indexPath.row]
    vc.showArguments(segue)
    self.resultSearchController?.dismissViewControllerAnimated(true, completion: {})
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
    let object = TR064Manager.sharedManager.services.map {$0}[section]
    cell?.textLabel!.text = object.serviceType.stringByReplacingOccurrencesOfString("urn:dslforum-org:service:", withString: "")
    return cell
  }
    
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let action = self.filteredData[indexPath.section].actions[indexPath.row]
    if action.needsInput {
      let cell = tableView.dequeueReusableCellWithIdentifier("Input", forIndexPath: indexPath)
      cell.textLabel!.text = action.name  // .stringByReplacingOccurrencesOfString("X_AVM-DE_", withString: "")
      cell.detailTextLabel?.text = action.url
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("Output", forIndexPath: indexPath)
      cell.textLabel!.text = action.name  // .stringByReplacingOccurrencesOfString("X_AVM-DE_", withString: "")
      cell.detailTextLabel?.text = action.url
      return cell
    }
  }

}
