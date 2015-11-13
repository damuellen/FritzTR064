//
//  HostCell.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 25/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit

class HostCell: UITableViewCell {
	
	@IBOutlet weak var macAddress: UILabel!
	
	@IBOutlet weak var ipAddress: UILabel!
	
	@IBOutlet weak var hostName: UILabel!
	
	@IBOutlet weak var addressSource: UILabel!
	
	func configure(host: Host) {
		hostName.text = host.hostName
		ipAddress.text = host.ip
		addressSource.text = host.addressSource + " " + host.interfaceType
		macAddress.text = host.macAddress
    if host.active {
      self.addOrChangeGradientLayerWithColors(UIColor.metalic())
    } else {
      self.addOrChangeGradientLayerWithColors(UIColor.haze())
    }
    self.gradientLayer?.opacity = 0.5
	}
	
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.frame = self.bounds }
  }
  
}
