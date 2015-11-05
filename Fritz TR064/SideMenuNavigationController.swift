//
//  SideMenuNavigationController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 30/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class SideMenuNavigationController: UINavigationController, SideMenuProtocol {
  
  var sideMenu: SideMenu?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    modalTransitionStyle = .CrossDissolve
    let tableView = SideMenuTableViewController()
    tableView.sideMenuController = self
    sideMenu = SideMenu(navigationController: self, menuViewController: tableView, menuPosition:.Left)
  }
  
  override func viewWillAppear(animated: Bool) {
    view.bringSubviewToFront(navigationBar)
  }
  
  override func viewDidLayoutSubviews() {
    sideMenu?.needUpdateApperance = true
    if sideMenu!.isMenuOpen { sideMenu?.hideSideMenu() }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
// MARK: - Navigation
  
  func setContentViewController(contentViewController: UIViewController) {
    contentViewController.navigationItem.hidesBackButton = true
    let transition = CATransition()
    transition.duration = 0.5
    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    transition.type = kCATransitionFade
    //transition.subtype = kCATransitionFromTop
    self.view.subviews.first?.layer.addAnimation(transition, forKey:kCATransition)
    self.viewControllers = [contentViewController]
  }
  
}
