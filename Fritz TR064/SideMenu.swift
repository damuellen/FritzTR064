//
//  SideMenu.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 30/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

extension SideMenu: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    if let swipe = gestureRecognizer as? UISwipeGestureRecognizer where
      !self.allowLeftSwipe && swipe.direction == .Left
        || !self.allowRightSwipe && swipe.direction == .Right {
          return false
    }
    return true
  }
  
  func handleGesture(gesture: UISwipeGestureRecognizer) {
    switch (self.menuPosition, gesture.direction) {
    case (.Right, UISwipeGestureRecognizerDirection.Left),
    (.Left, UISwipeGestureRecognizerDirection.Right):
      toggleMenu(true)
    default:
      toggleMenu(false)
    }
  }
  
  func addSwipeGestureRecognizer() {
    
    let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleGesture:")
    rightSwipeGestureRecognizer.delegate = self
    rightSwipeGestureRecognizer.direction = .Right
    
    let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleGesture:")
    leftSwipeGestureRecognizer.delegate = self
    leftSwipeGestureRecognizer.direction = .Left
    
    switch menuPosition {
    case .Left:
      self.navigationControllerView.addGestureRecognizer(rightSwipeGestureRecognizer)
      self.sideMenuView.addGestureRecognizer(leftSwipeGestureRecognizer)
    case .Right:
      self.sideMenuView.addGestureRecognizer(rightSwipeGestureRecognizer)
      self.navigationControllerView.addGestureRecognizer(leftSwipeGestureRecognizer)
    }
  }
  
}

class SideMenu : NSObject {
  
  weak var delegate: SideMenuDelegate?
  
  var menuWidth : CGFloat = 180.0 {
    didSet {
      needUpdateApperance = true
      updateFrame()
    }
  }
  
  private var menuPosition = SideMenuPosition.Left
  private let sideMenuView = UIView()
  private var menuViewController: UITableViewController!
  private var animator: UIDynamicAnimator?
  private var navigationControllerView: UIView!
  private var navigationController: UIViewController!
  private var shouldBounce: Bool = true
  private(set) var isMenuOpen: Bool = false
  
  var needUpdateApperance: Bool = false
  var allowLeftSwipe: Bool = true
  var allowRightSwipe: Bool = true
  
  convenience init(navigationController: UIViewController, menuViewController: UITableViewController, menuPosition: SideMenuPosition) {
    self.init(navigationController: navigationController, menuPosition: menuPosition)
    self.menuViewController = menuViewController
    menuViewController.view.frame = self.sideMenuView.bounds
    self.sideMenuView.addSubview(menuViewController.view)
  }
  
  init(navigationController: UIViewController, menuPosition: SideMenuPosition) {
    super.init()
    self.navigationController = navigationController
    self.navigationControllerView = navigationController.view
    self.menuPosition = menuPosition
    self.setupMenuView()
    if navigationController is UISplitViewController {
      let embededNavigationController = ((navigationController as! UISplitViewController).viewControllers.first! as! UINavigationController)
      self.animator = UIDynamicAnimator(referenceView: embededNavigationController.view)
      let navigationBar = embededNavigationController.navigationBar
      embededNavigationController.view.bringSubviewToFront(navigationBar)
    } else {
      self.animator = UIDynamicAnimator(referenceView: navigationControllerView)
    }
    addSwipeGestureRecognizer()
  }
  
  func updateFrame() {
    let menuFrame = CGRectMake(menuPosition.positionX(self),
      navigationControllerView.frame.origin.y,
      menuWidth,
      navigationControllerView.bounds.size.height)
    sideMenuView.frame = menuFrame
  }
  
  private func setupMenuView() {
    updateFrame()
    sideMenuView.backgroundColor = UIColor.clearColor()
    
    sideMenuView.addShadow()
    sideMenuView.layer.shadowOffset = menuPosition.shadowOffset
    sideMenuView.addBlurEffect(.Light)
    switch navigationController {
    case is UISplitViewController:
      (navigationController as! UISplitViewController).viewControllers.first!.view.addSubview(sideMenuView)
    default:
      navigationControllerView.addSubview(sideMenuView)
    }
    
  }
  
  private func updateSideMenuApperanceIfNeeded() {
    if !needUpdateApperance { return }
    
    var frame = sideMenuView.frame
    frame.size.width = menuWidth
    frame.size.height = navigationControllerView.frame.height
    sideMenuView.frame = frame
    sideMenuView.layer.shadowPath = UIBezierPath(rect: sideMenuView.bounds).CGPath
    needUpdateApperance = false
    isMenuOpen = false
    shouldBounce = true
  }
  
  private func toggleMenu(shouldOpen: Bool) {
    if (shouldOpen && delegate?.sideMenuShouldOpSideMenu?() == false) { return }
    updateSideMenuApperanceIfNeeded()
    isMenuOpen = shouldOpen

    let width: CGFloat = navigationControllerView.frame.size.width
    let height: CGFloat = navigationControllerView.frame.size.height

    if animator != nil && shouldBounce {
      
      var gravityDirectionX: CGFloat
      var pushMagnitude: CGFloat
      var boundaryPointX: CGFloat
      var boundaryPointY: CGFloat
      
      switch menuPosition {
      case .Left:
        pushMagnitude = shouldOpen ? 60 : -60
        boundaryPointX = shouldOpen ? menuWidth : -menuWidth-4
        boundaryPointY = 64
        gravityDirectionX = shouldOpen ? 1 : -1
      case .Right:
        pushMagnitude = shouldOpen ? -60 : 60
        boundaryPointX = shouldOpen ? width-menuWidth : width+menuWidth+4
        boundaryPointY = -64
        gravityDirectionX = shouldOpen ? -1 : 1
      }
      
      let collisionBehavior = UICollisionBehavior(items: [sideMenuView])
      collisionBehavior.collisionMode = .Boundaries
      collisionBehavior.addBoundaryWithIdentifier("menuBoundary",
        fromPoint: CGPointMake(boundaryPointX, boundaryPointY),
        toPoint: CGPointMake(boundaryPointX, height))
      
      let gravityBehavior = UIGravityBehavior(items: [sideMenuView])
      gravityBehavior.gravityDirection = CGVectorMake(gravityDirectionX,  0)
      
      let pushBehavior = UIPushBehavior(items: [sideMenuView], mode: UIPushBehaviorMode.Instantaneous)
      pushBehavior.magnitude = pushMagnitude
      
      let menuViewBehavior = UIDynamicItemBehavior(items: [sideMenuView])
      
      animator?.removeAllBehaviors()
      animator?.addBehavior(collisionBehavior)
      animator?.addBehavior(gravityBehavior)
      animator?.addBehavior(pushBehavior)
      animator?.addBehavior(menuViewBehavior)

    } else {
      
      let destFrame: CGRect
 
      switch menuPosition {
      case .Left:
        destFrame = CGRectMake((shouldOpen) ? -2.0 : -menuWidth, 0, menuWidth, sideMenuView.frame.size.height)
      case .Right:
        destFrame = CGRectMake((shouldOpen) ? width-menuWidth : width+2.0, 0, menuWidth, sideMenuView.frame.size.height)
      }
      UIView.animateWithDuration(0.25) { self.sideMenuView.frame = destFrame }
    }
    
    if shouldOpen { delegate?.sideMenuWillOpen?() }
    else { delegate?.sideMenuWillClose?() }
  }
  
  func toggleMenu() {
    if isMenuOpen { toggleMenu(false) }
    else {
      toggleMenu(true)
    }
  }
  
  func showSideMenu() {
    if !isMenuOpen { toggleMenu(true) }
  }
  
  func hideSideMenu() {
    shouldBounce = true
    if isMenuOpen { toggleMenu(false) }
  }
}

@objc public protocol SideMenuDelegate {
  optional func sideMenuWillOpen()
  optional func sideMenuWillClose()
  optional func sideMenuShouldOpSideMenu() -> Bool
}

@objc protocol SideMenuProtocol {
  var sideMenu: SideMenu? { get set }
  optional func setViewController(viewController: UIViewController)
  func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

public enum SideMenuPosition: Int {
  case Left
  case Right
  
  var shadowOffset: CGSize {
    switch self {
    case Left:
      return CGSizeMake(1.5, 1.5)
    case Right:
      return CGSizeMake(-1.5, -1.5)
    }
  }
  
  func positionX(menu: SideMenu) -> CGFloat {
    let width = menu.navigationControllerView.bounds.size.width
    switch self {
    case Left:
      return menu.isMenuOpen
        ? 0
        : -menu.menuWidth-2
    case Right:
      return menu.isMenuOpen
        ? width - menu.menuWidth
        : width+2
    }
  }
}

extension UIViewController {
  
  public func toggleSideMenuView() {
    (splitViewController as? SplitViewController)?.sideMenu?.toggleMenu()
    (navigationController as? SideMenuNavigationController)?.sideMenu?.toggleMenu()
  }
  
}
