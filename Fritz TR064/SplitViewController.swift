//
//  SplitViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 03/11/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate, SideMenuProtocol {
  
  var sideMenu : SideMenu?
  
  override func viewDidLoad() {
    self.delegate = self
    self.preferredPrimaryColumnWidthFraction = 0.5
    let navigationController = self.viewControllers[self.viewControllers.count-1] as! UINavigationController
    navigationController.topViewController!.navigationItem.leftBarButtonItem = self.displayModeButtonItem()
    navigationController.view.bringSubviewToFront(navigationController.navigationBar)
		let tableView = SideMenuTableViewController()
		tableView.sideMenuNavigationController = self
		sideMenu = SideMenu(navigationController: self, menuViewController: tableView, menuPosition:.Left)
  }
  
  override func viewWillLayoutSubviews() {
    sideMenu?.needUpdateApperance = true
    sideMenu?.hideSideMenu()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // MARK: - Navigation
  
  func setContentViewController(contentViewController: UIViewController) {
    sideMenu?.toggleMenu()
    contentViewController.navigationItem.hidesBackButton = true
    let transition = CATransition()
    transition.duration = 0.5
    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    transition.type = kCATransitionFade
    //transition.subtype = kCATransitionFromTop
    self.view.subviews.first?.layer.addAnimation(transition, forKey:kCATransition)
    self.viewControllers = [contentViewController]
		//showDetailViewController(<#T##vc: UIViewController##UIViewController#>, sender: <#T##AnyObject?#>)
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
		view.bringSubviewToFront((primaryViewController as! UINavigationController).navigationBar)
    return true
  }
  
}
