//
//  CallList.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 30/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

private let _DateFormatterSharedInstance = NSDateFormatter()

extension NSDateFormatter {
  class var sharedInstance: NSDateFormatter {
    return _DateFormatterSharedInstance
  }
}

enum CallType: Int {
  case incoming = 1
  case missed = 2
  case outgoing = 3
  case activeIncoming = 9
  case rejectedIncoming = 10
  case activeOutgoing = 11
  case error = 99
}

struct Call {
  let id: Int
  let type: CallType
  let called: String, caller: String, name: String, numbertype: String, device: String, port: String
  let date: NSDate?
  let duration: NSTimeInterval
  let pathURL: String?
  
  init(_ id: Int,
    _ calltype: Int,
    _ called: String,
    _ caller: String,
    _ name: String,
    _ numbertype: String,
    _ device: String,
    _ port: String,
    _ dateString: String,
    _ duration: String,
    _ pathURL: String?) {
      
      self.id = id
      self.called = called
      self.caller = caller
      self.name = name
      self.numbertype = numbertype
      self.device = device
      self.port = port
      
      self.type = CallType(rawValue: calltype)!
      
      self.date = { date -> NSDate in
        let dateFormatter = NSDateFormatter.sharedInstance
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        if let dateObject = dateFormatter.dateFromString(dateString) {
          return dateObject
        } else {
          return NSDate()
        }
      }()

      self.duration = { durationTime -> NSTimeInterval in
        let time = duration.componentsSeparatedByString(":").map { Int($0) }
        return NSTimeInterval((time[0]! * 3600) + (time[1]! * 60))
      }()
      
      if let URL = pathURL {
      self.pathURL = URL
      } else {
        self.pathURL = nil
      }
  }
  
  static func CallFromXML(call: AEXMLElement) -> Call {
    var id = Int()
    var type = Int()
    var called = String()
    var caller = String()
    var name = String()
    var numbertype = String()
    var device = String()
    var port = String()
    var date = String()
    var duration = String()
    var pathURL: String?
    
    let content = call.children
    for value in content where value.value != nil {
      
      switch value.name {
      case "Id":
        id = Int(value.value!)!
      case "Called":
        called = value.value!
      case "Caller":
        caller = value.value!
      case "Name":
        name = value.value!
      case "Numbertype":
        numbertype = value.value!
      case "Device":
        device = value.value!
      case "Port":
        port = value.value!
      case "Type":
        type = Int(value.value!)!
      case "Date":
        date = value.value!
      case "Duration":
        duration = value.value!
      case "Path":
        pathURL = value.value
      default:
        break
      }
    }
    return Call(id,type,called,caller,name,numbertype,device,port,date,duration,pathURL)
  }

}

extension Call: Equatable, Comparable { }

func ==(lhs: Call, rhs: Call) -> Bool {
  return lhs.id < rhs.id
}

func < (lhs: Call, rhs: Call) -> Bool {
  return lhs.id == rhs.id
}

