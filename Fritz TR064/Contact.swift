//
//  Contact.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 04/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

struct Number {
  let quickdial: String
  let prio: String
  let type: String
  let value: String
}

struct Contact {
  let uniqueid: Int
  let realName: String
  let services: [String]
  let numbers: [String]
  let imageURL: String?
  
  init(_ uniqueid: Int,
    _ realName: String,
    _ services: [String],
    _ numbers: [String],
    _ imageURL: String?) {
      
      self.uniqueid = uniqueid
      self.realName = realName
      self.services = services
      self.numbers = numbers

      if let URL = imageURL {
        self.imageURL = URL
      } else {
        self.imageURL = nil
      }
  }
  /*
  static func ContactFromXML(phonebook: AEXMLElement) -> Contact {
    var uniqueid: Int
    var realName: String
    var services: [String]
    var numbers: [String]
    let imageURL: String?
    
    let contacts = phonebook.children
    for contact in contacts where contact.value != nil {
      if let name = contact["person"]["realName"].value {
        realName = name
      }
      switch contact.name {
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
    return Contact(uniqueid,realName,services,numbers,imageURL)
  }
  */
}

extension Contact: Equatable { }

func ==(lhs: Contact, rhs: Contact) -> Bool {
  return lhs.uniqueid == rhs.uniqueid
}


