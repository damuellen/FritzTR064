//
//  SettingsVC.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 25/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {
  
  @IBOutlet weak var routerIP: UITextField!
  @IBOutlet weak var routerPassword: UITextField!
  @IBOutlet weak var vpnAdresse: UITextField!
  @IBOutlet weak var vpnUser: UITextField!
  @IBOutlet weak var vpnGroup: UITextField!
  @IBOutlet weak var vpnPassword: UITextField!
  @IBOutlet weak var sharedSecret: UITextField!
  @IBOutlet var allTextFields: [UITextField]!
  
  let bgView = GradientView(frame: CGRectZero)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.backgroundView = bgView
    tableView.scrollsToTop = false
    keyboardResizeObserver()
    allTextFields.forEach { textfield in
      textfield.delegate = self
    }
  }
  
  @IBAction func showMenu(sender: AnyObject) {
    toggleSideMenuView()
  }
  
  override func viewWillAppear(animated: Bool) {
    bgView.frame = view.frame

  }
  
  @IBAction func saveSettings(sender: AnyObject) {
    Settings.set(Setting.vpnAddress.key, toValue: vpnAdresse.text!)
    Settings.set(Setting.routerAddress.key, toValue: routerIP.text!)
    Settings.set(Setting.vpnUserName.key, toValue: vpnUser.text!)
    Settings.set(Setting.vpnGroupName.key, toValue: vpnGroup.text!)
    Settings.set(Setting.launchedForTheFirstTime.key, toValue: "NO")
  }
  
  override func viewDidAppear(animated: Bool) {
    self.vpnAdresse.text = Settings.get(Setting.vpnAddress)
    self.routerIP.text = Settings.get(Setting.routerAddress)
    self.vpnUser.text = Settings.get(Setting.vpnUserName)
    self.vpnGroup.text = Settings.get(Setting.vpnGroupName)
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.backgroundColor = UIColor.clearColor()
    cell.backgroundView?.backgroundColor = UIColor.clearColor()
  }
  
}

extension SettingsVC: UITextFieldDelegate {
  
  func keyboardResizeObserver(){
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
  }
  
  func keyboardWillShow(notification: NSNotification) {
    let info = notification.userInfo!
    let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size
    let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! Double
    let contentInsets: UIEdgeInsets
    contentInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, (keyboardSize.height + 10), 0)
    
    UIView.animateWithDuration(duration) {
      self.tableView.contentInset = contentInsets
      self.tableView.scrollIndicatorInsets = contentInsets
      
    }
  }
  
  func keyboardWillHide(notification: NSNotification) {
    let info = notification.userInfo!
    let duration = info[UIKeyboardAnimationDurationUserInfoKey] as! Double
    let contentInsets: UIEdgeInsets
    contentInsets = UIEdgeInsetsMake(topLayoutGuide.length, 0, 0, 0)

    UIView.animateWithDuration(duration) {
      self.tableView.contentInset = contentInsets
      self.tableView.scrollIndicatorInsets = contentInsets
    }
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    self.view.endEditing(true)
    return true
  }
  
}