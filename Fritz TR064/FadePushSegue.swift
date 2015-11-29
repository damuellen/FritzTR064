//
//  FadePushSegue.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 04/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

let animationDuration = 0.4

class FadePushSegue: UIStoryboardSegue {
  
  override func perform() {
    let source = sourceViewController.navigationController!
    let destination = ((destinationViewController as! UINavigationController).topViewController as! XMLResponseViewController)
    destination.bgView.colors = (sourceViewController as! ActionArgumentsVC).bgView.colors
    let transition = CATransition()
    transition.duration = 0.8
    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    transition.type = kCATransitionFade
    source.navigationController?.view.layer.addAnimation(transition, forKey:kCATransition)
    source.pushViewController(destination, animated: false)
  }
  
}
