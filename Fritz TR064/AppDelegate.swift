//
//  AppDelegate.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit
import NetworkExtension

let application = UIApplication.sharedApplication()
let appDelegate = application.delegate! as! AppDelegate
let rootViewController = application.windows.first!.rootViewController
let reachability = try? Reachability.reachabilityForInternetConnection()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var vpnConnection: NEVPNConnection?
  var vpnStayConnected = false
  var alert: UIAlertController?

  func setup() {
    if isRunningSimulator {
      TR064.getAvailableServices()
    }else {
      switch reachability!.currentReachabilityStatus {
      case .ReachableViaWWAN:
        vpnConnection = VPN()
      case .ReachableViaWiFi:
        TR064.getAvailableServices()
      case .NotReachable: break
      }
    }
  }
  
  var id: AnyObject?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    storeCredentials() // private file
    setup()
    
    id = NSNotificationCenter.defaultCenter().addObserverForName(
      NEVPNStatusDidChangeNotification, object: nil, queue: nil) { _ in
				delay(0.2) { TR064.getAvailableServices() }
      NSNotificationCenter.defaultCenter().removeObserver(self.id!)
      self.id = nil
    }
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    if !vpnStayConnected {
      vpnConnection?.stopVPNTunnel()
    }
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    if reachability!.isReachableViaWWAN() {
    do { try vpnConnection?.startVPNTunnel() } catch { debugPrint("Did not reconnect") }
    }
    vpnStayConnected = false
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    vpnConnection?.stopVPNTunnel()
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

}

var isRunningSimulator: Bool = {
  return TARGET_OS_SIMULATOR != 0
}()
