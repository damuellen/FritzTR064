//
//  FadePushSegue.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 04/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class FadePushSegue: UIStoryboardSegue {
  
  override func perform() {
    let source = sourceViewController.navigationController!
    let destination = ((destinationViewController as! UINavigationController).topViewController as! XMLResponseViewController)
    destination.bgView.colors = (sourceViewController as! ActionArgumentsVC).bgView.colors
    let transition = CATransition()
    transition.duration = 1.0
    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    transition.type = kCATransitionFade
    source.navigationController?.view.layer.addAnimation(transition, forKey:kCATransition)
    source.pushViewController(destination, animated: false)
  }
  
}

class FadeInTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.5
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView()
    let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
    toView.alpha = 0.0
    containerView?.addSubview(toView)
    UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
      toView.alpha = 1.0
      }, completion: { _ in
        transitionContext.completeTransition(true)
    })
  }
}