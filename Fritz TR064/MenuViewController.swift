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
  
  @IBOutlet weak var Hosts: NiceButton!
  @IBOutlet weak var Actions: NiceButton!
  @IBOutlet weak var CallList: NiceButton!
  @IBOutlet weak var Button1: NiceButton!
  @IBOutlet weak var Button2: NiceButton!

  override func viewDidLoad() {
    manager.observer = self
    manager.activeService = nil
    configureUI()
  }
  
  override func viewWillAppear(animated: Bool) {
    if manager.isReady {
      refreshUI()
    }
  }

  override func viewDidAppear(animated: Bool) {
    if !manager.isReady {
      SwiftSpinner.showWithDelay(1.5, title: "It's taking longer than expected", animated: true)
      SwiftSpinner.showWithDelay(5, title: "Still trying to connect", animated: true)
    }
    
  }
  
  func alert() {
    TR064.getAvailableServices()
    //  self.appearAlertViewWithTitle("Error", message: "No Services found",
    //    actionTitle: ["Retry"],
    //    actionBlock: [{ TR064.getAvailableServices() }])
  }
  
  func configureUI() {
    
    let subview = UIView(frame: self.view.frame)
    subview.backgroundColor = UIColor.whiteColor()
    subview.alpha = 0.5
    self.view.addOrChangeGradientLayerWithColors(UIColor.beach())
    for button in self.view.subviews where button is UIButton {
      button.hidden = true
      button.alpha = 0.0
    }
  }
  
  func refreshUI() {
    for element in self.view.subviews where element is UIButton {
      (element as! UIButton).enabled = true
      (element as! UIButton).hidden = false
    }
    SwiftSpinner.hide()
    UIView.animateWithDuration(0.5, delay: 0.2, options: [.CurveEaseIn], animations:  {
      for element in self.view.subviews where element is UIButton {
        element.alpha = 1
      }
    }, completion: nil)
  }
  
  override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
    self.view.addOrChangeGradientLayerWithColors(UIColor.orangeMango())
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "DeviceInfo" {
      manager.observer = segue.destinationViewController as? TR064ServiceObserver
      manager.activeService = DeviceInfo()
      DeviceInfo.getDeviceLog()
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
extension UIViewController {

  func appearAlertViewWithTitle(title: String, message: String, actionTitle: [String], actionBlock: [() -> Void]) {
    appDelegate.alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    for (actionTitle, actionBlock) in zip(actionTitle, actionBlock) {
      appDelegate.alert!.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default)
        { (action:UIAlertAction!) -> Void in actionBlock() })
    }
    appDelegate.alert!.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    self.presentViewController(appDelegate.alert!, animated: true, completion: { appDelegate.alert = nil} )
  }
  
}

  

