//
//  UIView+UIColor.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 18/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

let colors = [UIColor(rgb: 0xFF9500), UIColor(rgb: 0xFF5E3A),
  UIColor(rgb: 0x2BC0E4), UIColor(rgb: 0xEAECC6),
  UIColor(rgb: 0x614385), UIColor(rgb: 0x516395),
  UIColor(rgb: 0x70e1f5), UIColor(rgb: 0xffd194),
  UIColor(rgb: 0xF09819), UIColor(rgb: 0xEDDE5D)]

extension UIColor {
  
  static var rainbowColors: [UIColor] {
    var colors = [UIColor]()
    for i in 0..<9 { colors.append(UIColor(hue: CGFloat(i)/CGFloat(9), saturation: 1.0, brightness: 1.0, alpha: 1.0)) }
    return colors
  }
  
}

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
    return colors[random(colors.count)]
  }
  
  class func randomRainbowColor() -> UIColor {
    return UIColor.rainbowColors[random(UIColor.rainbowColors.count)]
  }
  
  class func randomNiceColors(number: Int) -> [UIColor] {
    var result = [UIColor]()
    for _ in 0..<number {
      var color: UIColor
      
      repeat {
        color = self.randomNiceColor()
      }
      while result.contains(color) && result.count < colors.count
      
      result.append(color)
    }
    return result
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
  
  func addOrChangeGradientLayerWithColors(colors: [UIColor]) {
    let gradientLayer: CAGradientLayer
    let presentGradientLayer = self.layer.sublayers?.first as? CAGradientLayer
    gradientLayer = presentGradientLayer ?? CAGradientLayer()
    gradientLayer.frame = self.bounds
    gradientLayer.cornerRadius = self.layer.cornerRadius
    gradientLayer.colors = colors.map { $0.CGColor }
    gradientLayer.shouldRasterize = true
    if presentGradientLayer == nil {
      self.layer.insertSublayer(gradientLayer, atIndex: 0)
    }
  }
  
}

func isGradientLayer(layer: CALayer) -> Bool {
  return layer is CAGradientLayer
}

func random(number: Int) -> Int {
  return Int(arc4random_uniform(UInt32(number)))
}

