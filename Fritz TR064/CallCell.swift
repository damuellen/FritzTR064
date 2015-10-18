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
  @IBOutlet weak var port: UILabel!
  @IBOutlet weak var called: UILabel!
  @IBOutlet weak var device: UILabel!
  @IBOutlet weak var date: UILabel!
  @IBOutlet weak var duration: UILabel!

  func configure(call: Call) {
    called.text = call.called
    caller.text = call.caller
    name.text = call.name
    port.text = call.port
    device.text = call.device
    let dateFormatter = NSDateFormatter.sharedInstance
    dateFormatter.dateStyle = .ShortStyle
    date.text = dateFormatter.stringFromDate(call.date!)
    duration.text = "\(call.duration)"
    switch call.type {
    case .activeIncoming:
      self.changeGradientLayerWithColors(UIColor.deepBlue())
    case .activeOutgoing:
      self.changeGradientLayerWithColors(UIColor.maceWindu())
    case .incoming:
      self.changeGradientLayerWithColors(UIColor.mojitoBlast())
    case .missed:
      self.changeGradientLayerWithColors(UIColor.haze())
    case .outgoing:
      self.changeGradientLayerWithColors(UIColor.orangeMango())
    case .rejectedIncoming:
      self.changeGradientLayerWithColors(UIColor.blueOcean())
    case .error:
      self.changeGradientLayerWithColors(UIColor.lovelyPink())
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.frame = self.bounds }
  }
  
}
