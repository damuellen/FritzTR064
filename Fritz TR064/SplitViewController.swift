//
//  SplitViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 03/11/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
  
  var sideMenu : SideMenu?
  
  override func viewDidLoad() {
    self.delegate = self
    self.preferredDisplayMode = .AllVisible
    let navigationController = self.viewControllers[self.viewControllers.count-1] as! UINavigationController
    navigationController.topViewController!.navigationItem.leftBarButtonItem = self.displayModeButtonItem()
		let tableView = SideMenuTableViewController()
		tableView.sideMenuNavigationController = self
		sideMenu = SideMenu(navigationController: self, menuViewController: tableView, menuPosition:.Left)
    modalTransitionStyle = .CrossDissolve
  }
  
  override func viewWillLayoutSubviews() {
    sideMenu?.needUpdateApperance = true
    sideMenu?.hideSideMenu()
  }
  
  override func viewDidDisappear(animated: Bool) {
    sideMenu = nil
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Split view
	/*
	
	// Asks the delegate to provide the new secondary view controller for the split view interface.
	func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
		
	}
	
	// Asks the delegate if it wants to do the work of displaying a view controller in the secondary position of the split view interface.
	func splitViewController(splitViewController: UISplitViewController, showDetailViewController vc: UIViewController, sender: AnyObject?) -> Bool {
		
	}
	
  */
	
	// Asks the delegate if it wants to do the work of displaying a view controller in the primary position of the split view interface.
	func splitViewController(splitViewController: UISplitViewController, showViewController vc: UIViewController, sender: AnyObject?) -> Bool {
		return true
	}

	// Tells the delegate that the display mode for the split view controller is about to change.
	func splitViewController(svc: UISplitViewController, willChangeToDisplayMode displayMode: UISplitViewControllerDisplayMode) {
		sideMenu?.hideSideMenu()
	}

	// Asks the delegate to adjust the primary view controller and to incorporate the secondary view controller into the collapsed interface.
  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
    return true
  }
  
}
