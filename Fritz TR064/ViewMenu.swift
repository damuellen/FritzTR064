//
//  ViewMenu.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 08/11/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

enum ViewMenu: Int {
  
  case Home, Hosts, CallList ,Actions, Settings, Info
  
  var viewController: UIViewController {
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
    switch self {
    case .Home:
      return mainStoryboard.instantiateViewControllerWithIdentifier("Menu")
    case .Hosts:
      return mainStoryboard.instantiateViewControllerWithIdentifier("HostsTVC")
    case .CallList:
      return mainStoryboard.instantiateViewControllerWithIdentifier("CallListTVC")
    case .Actions:
      return mainStoryboard.instantiateViewControllerWithIdentifier("ActionsTVC")
    case .Settings:
      return mainStoryboard.instantiateViewControllerWithIdentifier("SettingsTVC")
    case .Info:
      return mainStoryboard.instantiateViewControllerWithIdentifier("XMLTVC")
    }
  }
  
  var navigationController: UINavigationController? {
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
    switch self {
    case .Home:
      return mainStoryboard.instantiateViewControllerWithIdentifier("MenuNC") as! SideMenuNavigationController
    case .Hosts:
      return mainStoryboard.instantiateViewControllerWithIdentifier("HostsNC") as! SideMenuNavigationController
    case .CallList:
      return mainStoryboard.instantiateViewControllerWithIdentifier("CallListNC") as! SideMenuNavigationController
    case .Actions:
      return mainStoryboard.instantiateViewControllerWithIdentifier("ActionsNC") as! SideMenuNavigationController
    case .Settings:
      return mainStoryboard.instantiateViewControllerWithIdentifier("SettingsNC") as! SideMenuNavigationController
    case .Info:
      return mainStoryboard.instantiateViewControllerWithIdentifier("HostsNC") as! SideMenuNavigationController
    }
  }
  
  var splitViewController: UISplitViewController? {
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
    switch self {
    case .Home:
      return nil
    case .Hosts:
      return nil
    case .CallList:
      return nil
    case .Actions:
      return mainStoryboard.instantiateViewControllerWithIdentifier("ActionsSplitView") as! SplitViewController
    case .Settings:
      return mainStoryboard.instantiateViewControllerWithIdentifier("SettingsSplitView") as! SettingsSplitViewController
    case .Info:
      return nil
    }
  }
  
  var menuLabelText: String {
    switch self {
    case .Home:
      return "Home"
    case .Hosts:
      return "Hosts"
    case .CallList:
      return "CallList"
    case .Actions:
      return "Actions"
    case .Settings:
      return "Settings"
    case .Info:
      return "Info"
    }
  }
}
