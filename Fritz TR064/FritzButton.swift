//
//  FritzButton.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 21/11/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class FritzButton: UIButton {
  
  enum modelName: String {
    case AVM3490
    case AVM7272
    case AVM7360
    case AVM7490
    
    var image: UIImage {
      switch self {
      case AVM3490:
        return UIImage(named: "3490.png")!
      case AVM7272:
        return UIImage(named: "7272.png")!
      case AVM7360:
        return UIImage(named: "7360.png")!
      case AVM7490:
        return UIImage(named: "7490.png")!
      }
    }
  }

  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    UIView.animateWithDuration(0.2, delay: 0,
      usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [],
      animations: {
      self.transform = CGAffineTransformMakeScale(0.95, 0.95)
    }, completion: nil)
    super.touchesBegan(touches, withEvent: event)
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    UIView.animateWithDuration(0.2) {
      self.transform = CGAffineTransformIdentity }
    super.touchesEnded(touches, withEvent: event)
  }
  
  func setTemplate() {
    let imageTemplate =  modelType.image.imageWithRenderingMode(.AlwaysTemplate)
    self.setBackgroundImage(imageTemplate, forState: .Normal)
  }
  
  func setOriginal() {
    let image =  modelType.image.imageWithRenderingMode(.AlwaysOriginal)
    self.setImage(image, forState: .Normal)
  }
  
  var modelType: modelName = .AVM3490

}