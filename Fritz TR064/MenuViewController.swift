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
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    SwiftSpinner.showWithDelay(1, title: "It's taking longer than expected", animated: true)
    if manager.isReady {
      refreshUI()
    }
  }
  
  func alert() {
    SwiftSpinner.show("No Services found").addTapHandler({
      TR064.getAvailableServices()
      SwiftSpinner.show("May be this time")
      }, subtitle: "Press to retry")
    
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
    UIView.animateWithDuration(0.5, delay: 0, options: [.CurveEaseIn], animations:  {
      for element in self.view.subviews where element is UIButton {
        element.alpha = 1
      }
    }, completion: nil)
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "DeviceInfo" {
      manager.observer = segue.destinationViewController as? TR064ServiceObserver
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
    let controller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    for (actionTitle, actionBlock) in zip(actionTitle, actionBlock) {
      controller.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default)
        { (action:UIAlertAction!) -> Void in actionBlock() })
    }
    controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    self.presentViewController(controller, animated: true, completion: nil)
  }
  
}
