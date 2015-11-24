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

  @IBOutlet weak var Fritzbox: FritzButton!
  
  @IBOutlet weak var VPNState: UISwitch!

  @IBOutlet weak var ButtonCenter: NSLayoutConstraint!

  @IBOutlet var Buttons: [UIButton]!
  
  override func viewDidLoad() {
    manager.observer = self
    manager.activeService = nil
    self.view.addOrChangeGradientLayerWithColors(UIColor.randomNiceColors(2))
    self.Buttons.forEach({$0.alpha = 0})
  }

  override func viewDidAppear(animated: Bool) {
    if manager.device != nil {
      refreshUI(false)
    }
  }
  
  func alert() {
    let addButton = UIBarButtonItem(title: "Search Device", style: .Plain, target: self, action: "retry")
    self.navigationItem.leftBarButtonItem = addButton
  }
  
  func retry() {
    TR064.findDevice()
  }
  
  func refreshUI(animated: Bool) {
    
    for view in self.view.subviews where view is UIButton {
      (view as! UIButton).enabled = true
    }
    
    self.navigationItem.leftBarButtonItem = nil
    SwiftSpinner.hide()
    
    Fritzbox.modelType = FritzButton.modelName.AVM7360

    if animated {
      self.Fritzbox.transform = CGAffineTransformMakeScale(5, 5)
      Fritzbox.setTemplate()
      UIView.animateWithDuration(animationDuration, animations: {
        self.Buttons.forEach({$0.alpha = 1})
        self.Fritzbox.transform = CGAffineTransformMakeScale(1, 1)
        }, completion: { _ in
          self.alwaysAnimated()})
    } else {
      self.alwaysAnimated()
    }
  }
  
  func alwaysAnimated() {
    Fritzbox.setOriginal()
    UIView.animateWithDuration(0.3) {
      self.Buttons.forEach({$0.alpha = 1})
    }
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

  

