//
//  NiceButton.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 26/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class NiceButton: UIButton {
  
  var blurEffectView: UIVisualEffectView!
  
  override func awakeFromNib() {
    self.layer.cornerRadius = 8
    self.layer.masksToBounds = true
    addBlurEffect(.ExtraLight, addVibrancy: true).contentView.addSubview(self.titleLabel!)
  }
  
  private func tintedIconButton(iconNamed iconName: String) -> UIButton {
    let iconImage = UIImage(named: iconName)!.imageWithRenderingMode(.AlwaysTemplate)
    let borderImage = UIImage(named: "ButtonRoundRect")!.imageWithRenderingMode(.AlwaysTemplate)
    
    let button = UIButton(frame: CGRect(origin: CGPointZero, size: borderImage.size))
    button.setBackgroundImage(borderImage, forState: .Normal)
    button.setImage(iconImage, forState: .Normal)
    return button
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    UIView.animateWithDuration(0.2, delay: 0,
      usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],
      animations: {
        self.transform = CGAffineTransformMakeScale(0.95, 0.95)
      }, completion: { _ in
      //  self.addOrChangeGradientLayerWithColors(UIColor.orangeMango())
    })
    super.touchesBegan(touches, withEvent: event)
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
   // self.superview?.addOrChangeGradientLayerWithColors(UIColor.randomNiceColors(2))
    super.touchesMoved(touches, withEvent: event)
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    (self.layer.sublayers?.first as? CAGradientLayer)?.removeFromSuperlayer()
    UIView.animateWithDuration(0.2) {
      self.transform = CGAffineTransformIdentity }
    super.touchesEnded(touches, withEvent: event)
  }
  
}


