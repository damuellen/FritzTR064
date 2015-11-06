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
  var selectedMenuItem: Int = 8
  var hiddenMenuItem: Int = 8

  enum SideMenu: Int {
    
    case Hosts, CallList ,Actions, Settings, Info
    
    var viewController: UIViewController {
      let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
      switch self {
      case .Hosts:
        return mainStoryboard.instantiateViewControllerWithIdentifier("HostsTVC")
      case .CallList:
        return mainStoryboard.instantiateViewControllerWithIdentifier("CallListTVC")
      case .Actions:
        return mainStoryboard.instantiateViewControllerWithIdentifier("ActionsTVC")
      case .Settings:
        return mainStoryboard.instantiateViewControllerWithIdentifier("SettingsTVC")
      case .Info:
        return mainStoryboard.instantiateViewControllerWithIdentifier("XMLTVC")
      }
    }
    
    var navigationController: UINavigationController? {
      let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
      switch self {
      case .Hosts:
        return mainStoryboard.instantiateViewControllerWithIdentifier("HostsNC") as? SideMenuNavigationController
      case .CallList:
        return mainStoryboard.instantiateViewControllerWithIdentifier("CallListNC") as? SideMenuNavigationController
      case .Actions:
        return mainStoryboard.instantiateViewControllerWithIdentifier("ActionsNC") as? SideMenuNavigationController
      case .Settings:
        return mainStoryboard.instantiateViewControllerWithIdentifier("SettingsNC") as? SideMenuNavigationController
      case .Info:
        return mainStoryboard.instantiateViewControllerWithIdentifier("HostsNC") as? SideMenuNavigationController
      }
    }
    
    var splitViewController: UISplitViewController? {
      let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
      switch self {
      case .Hosts:
        return nil
      case .CallList:
        return nil
      case .Actions:
        return mainStoryboard.instantiateViewControllerWithIdentifier("SplitView") as? SplitViewController
      case .Settings:
        return nil
      case .Info:
        return nil
      }
    }
    
    var menuLabelText: String {
      switch self {
      case .Hosts:
        return "Hosts"
      case .CallList:
        return "CallList"
      case .Actions:
        return "Actions"
      case .Settings:
        return "Settings"
      case .Info:
        return "Info"
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorStyle = .None
    tableView.backgroundColor = UIColor.clearColor()
    tableView.backgroundView?.backgroundColor = UIColor.clearColor()
    tableView.scrollsToTop = false
    tableView.showsVerticalScrollIndicator = false
    self.clearsSelectionOnViewWillAppear = false
    //  let navBarHeight =  sideMenuNavigationController.navigationBar.frame.size.height ?? 44
    let contentInsets = UIEdgeInsetsMake(64, 0, 0, 0)
    tableView.contentInset = contentInsets
   // tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedMenuItem, inSection: 0), animated: false, scrollPosition: .Middle)
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
    cell.textLabel?.text = SideMenu(rawValue: indexPath.row)?.menuLabelText ?? "PhoneBook"
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
    
    if let split = SideMenu(rawValue: selectedMenuItem)?.splitViewController  {
      self.sideMenuController?.presentViewController(split, animated: true, completion: nil)
      return
    }
    if sideMenuController is SplitViewController {
     // self.sideMenuController?.sideMenu?.animator = nil
      if let navigationController = (SideMenu(rawValue: selectedMenuItem)?.navigationController) {
        self.sideMenuController?.presentViewController(navigationController, animated: true, completion: nil)
      }
    } else {
      self.sideMenuController?.setViewController!((SideMenu(rawValue: self.selectedMenuItem)?.viewController)!)
    }
  }
  
}
