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

  func configure(call: Call) {
    name.text = call.name
    device.text = call.device
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
      self.subviews.filter { $0 is UILabel}.forEach { ($0 as! UILabel).textColor = UIColor.whiteColor() }
    }
    
    switch call.type {
    case .activeIncoming:
      calledClosure()
      self.addOrChangeGradientLayerWithColors(UIColor.deepBlue())
    case .activeOutgoing:
      calledClosure()
      self.addOrChangeGradientLayerWithColors(UIColor.lovelyPink())
    case .incoming:
      callerClosure()
      self.addOrChangeGradientLayerWithColors(UIColor.mojitoBlast())
    case .missed:
      callerClosure()
      self.addOrChangeGradientLayerWithColors(UIColor.haze())
    case .outgoing:
      calledClosure()
      self.addOrChangeGradientLayerWithColors(UIColor.lovelyPink())
    case .rejectedIncoming:
      callerClosure()
      self.addOrChangeGradientLayerWithColors(UIColor.blueOcean())
    case .error:
      break
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.frame = self.bounds }
  }
  
}
