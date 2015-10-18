//
//  UIView+UIColor.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 18/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

let colors = UIColor.fieryOrange() + UIColor.blueOcean() + UIColor.mojitoBlast() + UIColor.beach()

extension UIColor {
  
  convenience init(r: UInt, g: UInt, b: UInt, alpha: CGFloat = 1) {
    self.init(
      red: CGFloat(r) / 255.0,
      green: CGFloat(g) / 255.0,
      blue: CGFloat(b) / 255.0,
      alpha: alpha
    )
  }
  
  convenience init(rgb: UInt, alpha: CGFloat = 1) {
    self.init(
      red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgb & 0x0000FF) / 255.0,
      alpha: alpha
    )
  }
  
  class func randomNiceColor() -> UIColor {
    let randomIndex = Int(arc4random_uniform(UInt32(colors.count)))
    return colors[randomIndex]
  }
  
  class func fieryOrange() -> [UIColor] {
    return [UIColor(rgb: 0xFF9500), UIColor(rgb: 0xFF5E3A)]
    
  }
  class func blueOcean() -> [UIColor] {
    return [UIColor(rgb: 0x2BC0E4), UIColor(rgb: 0xEAECC6)]
  }
  
  class func deepBlue() -> [UIColor] {
    return [UIColor(rgb: 0x085078), UIColor(rgb: 0x85D8CE)]
  }
  
  class func maceWindu() -> [UIColor] {
    return [UIColor(rgb: 0x614385), UIColor(rgb: 0x516395)]
  }
  
  class func mojitoBlast() -> [UIColor] {
    return [UIColor(rgb: 0x1D976C), UIColor(rgb: 0x93F9B9)]
  }
  
  class func lovelyPink() -> [UIColor] {
    return [UIColor(rgb: 0xDD5E89), UIColor(rgb: 0xF7BB97)]
  }
  
  class func haze() -> [UIColor] {
    return [UIColor(rgb: 0x8e9eab), UIColor(rgb: 0xeef2f3)]
  }
  
  class func beach() -> [UIColor] {
    return [UIColor(rgb: 0x70e1f5), UIColor(rgb: 0xffd194)]
  }
  
  class func metalic() -> [UIColor] {
    return [UIColor(rgb: 0xD6CEC3), UIColor(rgb: 0xE4DDCA)]
  }
  
  class func orangeMango() -> [UIColor] {
    return [UIColor(rgb: 0xF09819), UIColor(rgb: 0xEDDE5D)]
  }
  
}

extension UIView {
  
  func changeGradientLayerWithColors(colors: [UIColor]) {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = self.bounds
    gradientLayer.cornerRadius = self.layer.cornerRadius
    gradientLayer.colors = colors.map { $0.CGColor }
    self.layer.sublayers?.filter { $0 is CAGradientLayer }
      .forEach { $0.removeFromSuperlayer() }
    self.layer.insertSublayer(gradientLayer, atIndex: 0)
    
  }
  
}

