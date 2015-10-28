//
//  Timeout.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 27/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

class Timeout {
  
  class CallbackHolder  {
    
    var callback: (NSTimer) -> ()
    
    init(callback: (NSTimer) -> ()) {
      self.callback = callback
    }

    @objc func fired(timer: NSTimer){
      callback(timer)
    }

  }

  class func scheduledTimer(timeInterval: NSTimeInterval, repeats: Bool = false, actions: (NSTimer) -> ()) -> NSTimer {
    let holder = CallbackHolder(callback: actions)
    let timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: holder, selector: Selector("fired:"), userInfo: nil, repeats: repeats)
    if repeats {
      holder.fired(timer)
    }
    return timer
  }
  
}