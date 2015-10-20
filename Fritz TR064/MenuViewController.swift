//
//  MenuViewController
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class BackgroundGradientView: UIView {
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.sublayers?.filter(isGradientLayer).forEach { $0.frame = self.bounds }
  }
}

class MenuViewController: UIViewController, TR064ServiceObserver {
  
  @IBOutlet weak var Hosts: UIButton!
  @IBOutlet weak var Actions: UIButton!
  @IBOutlet weak var CallList: UIButton!
  @IBOutlet weak var Button1: UIButton!
  @IBOutlet weak var Button2: UIButton!
  
  @IBOutlet weak var Activity: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    
    let cornerRadius: CGFloat = 8
    self.Hosts.layer.cornerRadius = cornerRadius
    self.Actions.layer.cornerRadius = cornerRadius
    self.CallList.layer.cornerRadius = cornerRadius
    self.view.changeGradientLayerWithColors(UIColor.randomNiceColors(3))
    self.Hosts.changeGradientLayerWithColors(UIColor.randomNiceColors(3))
    self.Actions.changeGradientLayerWithColors(UIColor.randomNiceColors(3))
    self.CallList.changeGradientLayerWithColors(UIColor.randomNiceColors(3))
    self.Button1.changeGradientLayerWithColors(UIColor.randomNiceColors(3))
    self.Button2.changeGradientLayerWithColors(UIColor.randomNiceColors(3))

    TR064Manager.sharedManager.observer = self
  }
  override func viewWillAppear(animated: Bool) {
    self.Hosts.alpha = 0.1
    self.Actions.alpha = 0.1
    self.CallList.alpha = 0.1
    self.Button1.alpha = 0.1
    self.Button2.alpha = 0.1
    if TR064Manager.sharedManager.actions.count != 0 {
      self.refresh()
    }
  }
  
  @IBAction func touchedButton(button: UIButton) {
    button.changeGradientLayerWithColors(UIColor.orangeMango())
  }
  
  @IBAction func failButton(button: UIButton) {
    button.changeGradientLayerWithColors(UIColor.mojitoBlast())
  }
  
  func refresh() {
    self.Hosts.enabled = true
    self.Actions.enabled = true
    self.CallList.enabled = true
    self.Button1.enabled = true
    self.Button2.enabled = true
    UIView.animateWithDuration(1) {
      self.Hosts.alpha = 1
      self.Actions.alpha = 1
      self.CallList.alpha = 1
      self.Button1.alpha = 0.5
      self.Button2.alpha = 0.5
    }
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showCallList" {
      OnTel.sharedService.getCallListMaxCalls(20)
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

