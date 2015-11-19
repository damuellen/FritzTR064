//
//  SideMenuTableViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 30/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class SideMenuTableViewController: UITableViewController {
  
	weak var sideMenuController: SideMenuProtocol? {
		didSet {
			selectedMenuItem = 6
		}
	}
  private var selectedMenuItem: Int = 8
  private var hiddenMenuItem: Int = 8
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup(tableView)
  }

  func setup(tableView: UITableView) {
    tableView.separatorStyle = .None
    tableView.backgroundColor = UIColor.clearColor()
    tableView.backgroundView?.backgroundColor = UIColor.clearColor()
    tableView.scrollsToTop = false
    tableView.showsVerticalScrollIndicator = false
    self.clearsSelectionOnViewWillAppear = false
    let contentInsets = UIEdgeInsetsMake(64, 0, 0, 0)
    tableView.contentInset = contentInsets
    tableView.delegate = self
  }
  
  // MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 7
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    cell.backgroundColor = UIColor.clearColor()
    cell.textLabel?.textColor = UIColor.darkGrayColor()
    let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height))
    selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
    cell.selectedBackgroundView = selectedBackgroundView
    cell.textLabel?.text = ViewMenu(rawValue: indexPath.row)?.menuLabelText ?? "PhoneBook"
    cell.textLabel?.font = UIFont .systemFontOfSize(26)
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 60.0
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    if (indexPath.row == selectedMenuItem) {
      return
    }
    selectedMenuItem = indexPath.row
    if let split = ViewMenu(rawValue: selectedMenuItem)?.splitViewController  {
      self.sideMenuController?.presentViewController(split, animated: true, completion: nil)
      return
    }
    if sideMenuController is UISplitViewController {
      if let navigationController = (ViewMenu(rawValue: selectedMenuItem)?.navigationController) {
        self.sideMenuController?.presentViewController(navigationController, animated: true, completion: nil)
      }
    } else {
      self.sideMenuController?.setViewController!((ViewMenu(rawValue: self.selectedMenuItem)?.viewController)!)
    }
  }
  
}
