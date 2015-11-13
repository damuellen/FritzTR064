//
//  SettingsSplitViewController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 08/11/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class SettingsSplitViewController: UISplitViewController, UISplitViewControllerDelegate, UIViewControllerTransitioningDelegate, SideMenuProtocol {
  
  var sideMenu : SideMenu?
  
  override func viewDidLoad() {
    self.delegate = self
    if UIDevice().isIpad {
      self.preferredDisplayMode = .AllVisible
    }
    let tableView = SideMenuTableViewController()
    tableView.sideMenuController = self
    sideMenu = SideMenu(navigationController: self, menuViewController: tableView, menuPosition:.Left)
    transitioningDelegate = self
  }
  
  override func viewDidLayoutSubviews() {
    sideMenu?.needUpdateApperance = true
    sideMenu?.hideSideMenu()
  }
  
  override func viewDidDisappear(animated: Bool) {
    sideMenu = nil
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return TransitionsController()
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

