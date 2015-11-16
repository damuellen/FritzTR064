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
let reachability = try? Reachability(hostname: NSURL(string: "https://fritz.box:49443")!.host!)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var vpnConnection: NEVPNConnection?
  var vpnStayConnected = false
  var alert: UIAlertController?

  func setup() {
    print(reachability?.currentReachabilityStatus)
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
				delay(0.5) { TR064.getAvailableServices() }
        print(getIFAddresses())
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

  //// add to swift bridge #include <ifaddrs.h>
  func getIFAddresses() -> [String] {
    var addresses = [String]()
    
    // Get list of all interfaces on the local machine:
    var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
    if getifaddrs(&ifaddr) == 0 {
      
      // For each interface ...
      for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
        let flags = Int32(ptr.memory.ifa_flags)
        var addr = ptr.memory.ifa_addr.memory
        
        // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
        if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
          if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
            
            // Convert interface address to a human readable string:
            var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
            if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
              nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                if let address = String.fromCString(hostname) {
                  addresses.append(address)
                }
            }
          }
        }
      }
      freeifaddrs(ifaddr)
    }
    
    return addresses
  }


var isRunningSimulator: Bool = {
  return TARGET_OS_SIMULATOR != 0
}()
