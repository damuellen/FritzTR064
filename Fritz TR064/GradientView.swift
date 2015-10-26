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
    self.addOrChangeGradientLayerWithColors(UIColor.randomNiceColors(3))
    let subview = UIView(frame: self.frame)
    subview.backgroundColor = UIColor.whiteColor()
    subview.alpha = 0.5
    self.addSubview(subview)
  }

  func changeColors() {
    self.addOrChangeGradientLayerWithColors(UIColor.randomNiceColors(3))
  }
  
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
}
