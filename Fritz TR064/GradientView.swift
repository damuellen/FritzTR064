//
//  GradientView.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 23/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class GradientView: UIView {

  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.sublayers?.forEach { $0.frame = self.bounds }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addNiceBackground()
  }

  var colors: [CGColor] {
    get { return (self.layer.sublayers!.first as! CAGradientLayer).colors as! [CGColor] }
    set { (self.layer.sublayers!.first as! CAGradientLayer).colors = newValue }
  }
  
  func addNiceBackground() {
    self.addOrChangeGradientLayerWithColors(UIColor.randomNiceColors(3))
    // without this subview the segue animation looks ugly
    let subview = UIView(frame: self.frame)
    subview.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
    self.addSubview(subview)
  }
  
  func changeNiceBackgroundColors() {
    self.addOrChangeGradientLayerWithColors(UIColor.randomNiceColors(3))
  }
  
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
}
