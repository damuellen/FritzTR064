//
//  TransitionManager.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 08/11/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class TransitionsController: NSObject, UIViewControllerAnimatedTransitioning {
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    if UIDevice().isIphone {
      animateFade(transitionContext)
    }
    if UIDevice().isIpad {
      switch random(3) {
      case 1:
        animateSlideOut(transitionContext)
      case 2:
        animateSpring(transitionContext)
      default:
        animateZoomIn(transitionContext)
      }
    }
  }
  
  func animateSlideOut(transitionContext: UIViewControllerContextTransitioning) {
    let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!,
      toView = transitionContext.viewForKey(UITransitionContextToViewKey)!,
      container = transitionContext.containerView()!,
      duration = transitionDuration(transitionContext)
    
      toView.center.y += fromView.bounds.size.height
      toView.transform = CGAffineTransformMakeScale(Zoom.minimum, Zoom.minimum)
      container.addSubview(toView)
    
      UIView.animateWithDuration(duration, animations: {
        toView.center.y -= fromView.bounds.size.height
        fromView.center.y -= fromView.bounds.size.height
        fromView.transform = CGAffineTransformMakeScale(Zoom.minimum, Zoom.minimum)
        toView.transform = CGAffineTransformIdentity
        }, completion: { finished in
          transitionContext.completeTransition(finished)
      })
  }
  
  func animateSpring(transitionContext: UIViewControllerContextTransitioning) {
    let container = transitionContext.containerView()!,
    fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!,
    toView = transitionContext.viewForKey(UITransitionContextToViewKey)!,
    offScreenRight = CGAffineTransformMakeTranslation(container.frame.width, 0),
    offScreenLeft = CGAffineTransformMakeTranslation(-container.frame.width, 0)
    
    toView.transform = offScreenRight
    container.addSubview(toView)
    
    UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.2, options: [], animations: {
      fromView.transform = offScreenLeft
      toView.transform = CGAffineTransformIdentity
      }, completion: { finished in
        transitionContext.completeTransition(finished)
    })
  }
  
  func animateFade(transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView(),
    toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
    
    toView.alpha = 0.1
    containerView?.addSubview(toView)
    
    UIView.animateWithDuration(animationDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
      toView.alpha = 1.0
      }, completion: { finished in
        transitionContext.completeTransition(finished)
    })
  }
  
  private struct Zoom {
    static let minimum: CGFloat = 0.2, maximum: CGFloat = 4.0
  }
  
  func animateZoomIn(transitionContext: UIViewControllerContextTransitioning) {
    let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!,
    toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!,
    containerView = transitionContext.containerView()!,
    toView = toViewController.view,
    fromView = fromViewController.view,
    duration = self.transitionDuration(transitionContext)
    
    containerView.addSubview(toView)
    toView.frame = containerView.bounds
    
    toView.alpha = 0.2
    toView.transform = CGAffineTransformMakeScale(Zoom.minimum, Zoom.minimum)
    
    UIView.animateWithDuration(duration, delay:0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { 
      toView.alpha = 1
      toView.transform = CGAffineTransformIdentity
      fromView.alpha = 0.2
      fromView.transform = CGAffineTransformMakeScale(Zoom.maximum, Zoom.maximum)
      }) { finished in
        fromView.transform = CGAffineTransformIdentity
        transitionContext.completeTransition(finished)
    }
  }
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return animationDuration
  }
  
}