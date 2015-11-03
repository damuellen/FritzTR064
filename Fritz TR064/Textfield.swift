//
//  TextField.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 30/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class TextField: UITextField {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    configure()
  }
  
  func configure() {
    let layer = CALayer()
    layer.backgroundColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.25).CGColor
    layer.masksToBounds = true
    self.layer.insertSublayer(layer, atIndex: 0)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.sublayers?[0].frame = self.bounds
  }
  
}