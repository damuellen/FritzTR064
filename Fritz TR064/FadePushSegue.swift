//
//  FadePushSegue.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 04/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

let animationDuration = 0.5

class FadePushSegue: UIStoryboardSegue {
  
  override func perform() {
    let source = sourceViewController.navigationController!
    let destination = ((destinationViewController as! UINavigationController).topViewController as! XMLResponseViewController)
    destination.bgView.colors = (sourceViewController as! ActionArgumentsVC).bgView.colors
    let transition = CATransition()
    transition.duration = animationDuration
    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
    transition.type = kCATransitionFade
    source.navigationController?.view.layer.addAnimation(transition, forKey:kCATransition)
    source.pushViewController(destination, animated: false)
  }
  
}

class FadeInTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return animationDuration
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView()
    let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? SideMenuProtocol
    let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
    fromViewController?.sideMenu?.hideSideMenu()
    toView.alpha = 0.0
    containerView?.addSubview(toView)
    UIView.animateWithDuration(animationDuration, delay: 0.0, options: [], animations: {
      toView.alpha = 1.0
      }, completion: { _ in
        transitionContext.completeTransition(true)
    })
  }
}