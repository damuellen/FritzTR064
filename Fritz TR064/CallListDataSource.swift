//
//  CallListDataSource.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 11/11/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

class Calls {
  
  var callsDict = [String:[Call]]()
  
  func numberOfSections()-> Int {
    var number = 0
    if callsDict["Today"]?.count > 0 { number += 1 }
    if callsDict["Yesterday"]?.count > 0 { number += 1 }
    if callsDict["Older"]?.count > 0 { number += 1 }
    return number
  }
  
  func numberOfRows(section: Int) -> Int {
    return callsDict.values.map{$0}.reverse()[section].count
  }
  
  init(calls: [Call]) {
    for call in calls {
      if call.date.isToday {
        if let _ = (callsDict["Today"]) {
          callsDict["Today"]!.append(call)
        } else {
          callsDict["Today"] = [call]
        }
      } else if call.date.isYesterday {
        if let _ = (callsDict["Yesterday"]) {
          callsDict["Yesterday"]!.append(call)
        } else {
          callsDict["Yesterday"] = [call]
        }
      } else {
        if let _ = (callsDict["Older"]) {
          callsDict["Older"]!.append(call)
        } else {
          callsDict["Older"] = [call]
        }
      }
    }
  }
  
}
