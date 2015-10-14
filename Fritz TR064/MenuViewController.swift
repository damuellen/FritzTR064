//
//  MenuViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit


class MenuViewController: UIViewController, TR064ServiceObserver {
  
  @IBOutlet weak var Hosts: UIButton!
  
  @IBOutlet weak var Actions: UIButton!
  
  override func viewDidLoad() {
    Hosts.enabled = false
    Actions.enabled = false
    TR064Manager.sharedManager.observer = self
  }
  
  func refresh() {
    Hosts.enabled = true
    Actions.enabled = true
  }
  
}

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
  
  override func viewDidLoad() {
    self.delegate = self
    let navigationController = self.viewControllers[self.viewControllers.count-1] as! UINavigationController
    navigationController.topViewController!.navigationItem.leftBarButtonItem = self.displayModeButtonItem()
  }

  // MARK: - Split view
  
  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
    return true
  }

}