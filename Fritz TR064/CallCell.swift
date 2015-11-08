//
//  CallCell.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 04/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class CallCell: UITableViewCell {
  
  @IBOutlet weak var caller: UILabel!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var device: UILabel!
  @IBOutlet weak var date: UILabel!
  @IBOutlet weak var duration: UILabel!
  @IBOutlet weak var time: UILabel!

  func configureCellWith(call: Call) {
    name.text = call.name
    device.text = call.device
    backgroundColor = UIColor.clearColor()
    let dateFormatter = NSDateFormatter.sharedInstance
    let local = NSLocale.currentLocale()
    dateFormatter.locale = local
    dateFormatter.dateFormat = "EEEE d.M."
    date.text = dateFormatter.stringFromDate(call.date!)
    dateFormatter.dateFormat = "HH:mm"
    time.text = dateFormatter.stringFromDate(call.date!)
    duration.text = "\(call.duration)"
    
    let callerClosure = {
      if call.name == "" {
        self.name.text = call.caller
        self.caller.text = "Unbekannt"
      } else {
        self.caller.text = call.caller
      }
    }
    
    let calledClosure = {
      if call.name == "" {
        self.name.text = call.called
        self.caller.text = "Unbekannt"
      } else {
        self.caller.text = call.called
      }
      self.subviews.forEach { ($0 as? UILabel)?.textColor = UIColor.whiteColor() }
    }
    
    switch call.type {
    case .activeIncoming:
      calledClosure()
      self.addOrChangeGradientLayerWithColors(UIColor.metalic())
    case .activeOutgoing:
      calledClosure()
      self.addOrChangeGradientLayerWithColors(UIColor.metalic())
    case .incoming:
      callerClosure()
      self.addOrChangeGradientLayerWithColors(UIColor.mojitoBlast())
    case .missed:
      callerClosure()
      self.addOrChangeGradientLayerWithColors(UIColor.orangeMango())
    case .outgoing:
      calledClosure()
      self.addOrChangeGradientLayerWithColors(UIColor.deepBlue())
    case .rejectedIncoming:
      callerClosure()
      self.addOrChangeGradientLayerWithColors(UIColor.maceWindu())
    case .error:
      break
    }
    self.gradientLayer?.opacity = 0.2
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.frame = self.bounds }
  }
  
}

class CellAnimator {
  
  static let TransformFlip = { (layer: CALayer) -> CATransform3D in
    var transform = CATransform3DIdentity
    transform = CATransform3DTranslate(transform, 0.0, layer.bounds.size.height/2.0, 0.0)
    transform = CATransform3DRotate(transform, CGFloat(M_PI)/2.0, 1.0, 0.0, 0.0)
    transform = CATransform3DTranslate(transform, 0.0, layer.bounds.size.height/2.0, 0.0)
    return transform
  }
  
  static let TransformHelix = { (layer: CALayer) -> CATransform3D in
    var transform = CATransform3DIdentity
    transform = CATransform3DTranslate(transform, 0.0, layer.bounds.size.height/2.0, 0.0)
    transform = CATransform3DRotate(transform, CGFloat(M_PI), 0.0, 1.0, 0.0)
    transform = CATransform3DTranslate(transform, 0.0, -layer.bounds.size.height/2.0, 0.0)
    return transform
  }
  
  static let TransformScale = { (layer: CALayer) -> CATransform3D in
    var transform = CATransform3DIdentity
    transform = CATransform3DScale(transform, 0.5, 0, 0)
    return transform
  }
  
  static let TransformWave = { (layer: CALayer) -> CATransform3D in
    var transform = CATransform3DIdentity
    transform = CATransform3DTranslate(transform, -layer.bounds.size.width , 0.0, 0.0)
    return transform
  }
  
  class func animateCell(cell: UITableViewCell, withTransform transform: (CALayer) -> CATransform3D, andDuration duration: NSTimeInterval) {
    
    cell.layer.transform = transform(cell.layer)
    UIView.animateWithDuration(duration) {
      cell.layer.transform = CATransform3DIdentity
    }
  }
}
