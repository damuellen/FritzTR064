//
//  CallList.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 30/09/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

private let _DateFormatterSharedInstance = NSDateFormatter()
typealias CallingDuration = NSTimeInterval

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
  var id: Int
  let type: CallType
  let called: String, caller: String, name: String, numbertype: String, device: String, port: String
  let date: NSDate?
  let duration: CallingDuration
  let pathURL: String?
  
  init(_ id: Int, _ calltype: Int, _ called: String, _ caller: String,
    _ name: String, _ numbertype: String, _ device: String, _ port: String,
    _ dateString: String, _ duration: String, _ pathURL: String?) {
      
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
  
  static func extractCalls(envelope: AEXMLDocument) -> [AEXMLElement] {
    if let callsXML = envelope.root["Call"].all {
      return callsXML
    }
    return []
  }
  
  init?(_ call: AEXMLElement) {
    guard let id = call["Id"].value, idInt = Int(id), duration = call["Duration"].value,
      caller = call["Caller"].value, name = call["Name"].value, numbertype =  call["Numbertype"].value,
      called = call["Called"].value, port = call["Port"].value, callType = call["Type"].value,
      rawType = Int(callType), type = CallType(rawValue: rawType) else { return nil }
    
    self.id = idInt
    self.called = called
    self.caller = caller
    self.name = name
    self.numbertype = numbertype
    self.port = port
    self.type = type
    
    self.date = { date -> NSDate in
      let dateFormatter = NSDateFormatter.sharedInstance
      dateFormatter.dateFormat = "dd.MM.yy HH:mm"
      if let dateString = call["Date"].value, dateObject = dateFormatter.dateFromString(dateString) {
        return dateObject
      } else {
        return NSDate()
      }
      }()
    
    self.duration = { callingDuration -> CallingDuration in
      let time = duration.split(":").map { Int($0) }
      return CallingDuration((time[0]! * 3600) + (time[1]! * 60))
      }()
    
    self.device = call["Device"].value ?? ""
    self.pathURL = call["Path"].value
  }

}

extension Call: Equatable, Comparable { }

func ==(lhs: Call, rhs: Call) -> Bool {
  return lhs.id < rhs.id
}

func < (lhs: Call, rhs: Call) -> Bool {
  return lhs.id == rhs.id
}

