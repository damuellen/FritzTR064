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
  
  @IBOutlet weak var ButtonCenter: NSLayoutConstraint!

  override func viewDidLoad() {
    manager.observer = self
    manager.activeService = nil
    configureUI()
  }

  override func viewDidAppear(animated: Bool) {
    if !manager.isReady {
      SwiftSpinner.showWithDelay(1.5, title: "It's taking longer than expected", animated: true)
      SwiftSpinner.showWithDelay(5, title: "Still trying to connect", animated: true)
    }
    if manager.isReady {
      refreshUI()
    }
  }
  
  func alert() {
    TR064.getAvailableServices()
    //  self.appearAlertViewWithTitle("Error", message: "No Services found",
    //    actionTitle: ["Retry"],
    //    actionBlock: [{ TR064.getAvailableServices() }])
  }
  
  func configureUI() {
    self.view.addOrChangeGradientLayerWithColors(UIColor.beach())
  }
  
  func refreshUI() {
    for view in self.view.subviews where view is UIButton {
      (view as! UIButton).enabled = true
      (view as! UIButton).hidden = false
    }
    SwiftSpinner.hide()
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "DeviceInfo" {
      manager.observer = segue.destinationViewController as? XMLResponseViewController
      manager.activeService = DeviceInfo()
      DeviceInfo.getDeviceLog()
    }
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

  

