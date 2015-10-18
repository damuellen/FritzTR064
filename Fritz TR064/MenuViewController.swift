//
//  MenuViewController
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, TR064ServiceObserver {
  
  @IBOutlet weak var Hosts: UIButton!
  @IBOutlet weak var Actions: UIButton!
  @IBOutlet weak var CallList: UIButton!
  @IBOutlet weak var Button1: UIButton!
  @IBOutlet weak var Button2: UIButton!
  
  @IBOutlet weak var Activity: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    
    if TR064Manager.sharedManager.actions.count == 0 {
    }
    let cornerRadius: CGFloat = 8
    self.Hosts.layer.cornerRadius = cornerRadius
    self.Actions.layer.cornerRadius = cornerRadius
    self.CallList.layer.cornerRadius = cornerRadius
    
    self.view.changeGradientLayerWithColors(UIColor.fieryOrange())
    self.Hosts.changeGradientLayerWithColors(UIColor.mojitoBlast())
    self.Actions.changeGradientLayerWithColors(UIColor.mojitoBlast())
    self.CallList.changeGradientLayerWithColors(UIColor.mojitoBlast())
    self.Button1.changeGradientLayerWithColors(UIColor.haze())
    self.Button2.changeGradientLayerWithColors(UIColor.haze())

    TR064Manager.sharedManager.observer = self
  }
  
  @IBAction func touchedButton(button: UIButton) {
    button.changeGradientLayerWithColors(UIColor.orangeMango())
  }
  
  @IBAction func failButton(button: UIButton) {
    button.changeGradientLayerWithColors(UIColor.mojitoBlast())
  }
  
  func refresh() {
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showCallList" {
      OnTel.sharedService.getCallList()
    }
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

