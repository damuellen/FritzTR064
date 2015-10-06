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
      backgroundColor = UIColor.redColor()
    case .activeOutgoing:
      backgroundColor = UIColor.blueColor()
    case .incoming:
      backgroundColor = UIColor.greenColor()
    case .missed:
      backgroundColor = UIColor.grayColor()
    case .outgoing:
      backgroundColor = UIColor.orangeColor()
    case .rejectedIncoming:
      backgroundColor = UIColor.brownColor()
    case .error:
      backgroundColor = UIColor.blackColor()
    }
  }
  
}
