//
//  SideMenuNavigationController.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 30/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class SideMenuNavigationController: UINavigationController, UIViewControllerTransitioningDelegate, SideMenuProtocol {
  
  var sideMenu: SideMenu?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    transitioningDelegate = self
    let tableView = SideMenuTableViewController()
    tableView.sideMenuController = self
    sideMenu = SideMenu(navigationController: self, menuViewController: tableView, menuPosition:.Left)
  }
  
  override func viewWillAppear(animated: Bool) {
    view.bringSubviewToFront(navigationBar)
  }
  
  override func viewDidLayoutSubviews() {
    sideMenu?.needUpdateApperance = true
    sideMenu?.hideSideMenu()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return TransitionsController()
  }
  
  // MARK: - Navigation
  
  func setViewController(viewController: UIViewController) {
    viewController.navigationItem.hidesBackButton = true
    let transition = CATransition()
    transition.duration = animationDuration
    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    transition.type = kCATransitionFade
    //transition.subtype = kCATransitionFromTop
    self.view.subviews.first?.layer.addAnimation(transition, forKey:kCATransition)
    self.viewControllers = [viewController]
  }
  
}
