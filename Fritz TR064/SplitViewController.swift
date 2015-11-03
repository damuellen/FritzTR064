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
    
    let tableView = SideMenuTableViewController()
    tableView.sideMenuNavigationController = self
    sideMenu = SideMenu(navigationController: self, menuViewController: tableView, menuPosition:.Left)
    sideMenu?.allowLeftSwipe = true
    
    self.delegate = self
    self.preferredPrimaryColumnWidthFraction = 0.5
    let navigationController = self.viewControllers[self.viewControllers.count-1] as! UINavigationController
    navigationController.topViewController!.navigationItem.leftBarButtonItem = self.displayModeButtonItem()
    navigationController.view.bringSubviewToFront(navigationController.navigationBar)
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
  }

  // MARK: - Split view
  
  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
    return true
  }
  
}
