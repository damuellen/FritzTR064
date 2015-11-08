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
    self.layer.cornerRadius = 10
    self.layer.masksToBounds = true
    addBlurEffect(.Light, addVibrancy: true).contentView.addSubview(self.titleLabel!)
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
    self.addOrChangeGradientLayerWithColors(UIColor.orangeMango())
    super.touchesBegan(touches, withEvent: event)
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.superview?.addOrChangeGradientLayerWithColors(UIColor.randomNiceColors(2))
    super.touchesMoved(touches, withEvent: event)
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    (self.layer.sublayers?.first as? CAGradientLayer)?.removeFromSuperlayer()
    super.touchesEnded(touches, withEvent: event)
  }
  
}


