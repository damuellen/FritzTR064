//
//  SideMenuNavigationController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 30/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class SideMenuNavigationController: UINavigationController, SideMenuProtocol {
  
  var sideMenu : SideMenu?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(animated: Bool) {
    let tableView = SideMenuTableViewController()
    tableView.sideMenuNavigationController = self
    sideMenu = SideMenu(navigationController: self, menuViewController: tableView, menuPosition:.Left)
    sideMenu?.allowLeftSwipe = true
    view.bringSubviewToFront(navigationBar)
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
  
}
