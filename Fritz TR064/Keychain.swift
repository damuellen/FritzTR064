//
//  Keychain.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 25/11/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

class Keychain {
  
  private static let SecMatchLimit = kSecMatchLimit as String,
    SecReturnData = kSecReturnData as String,
    SecReturnPersistentRef: String! = kSecReturnPersistentRef as String,
    SecValueData = kSecValueData as String,
    SecAttrAccessible = kSecAttrAccessible as String,
    SecClass = kSecClass as String,
    SecAttrService = kSecAttrService as String,
    SecAttrGeneric = kSecAttrGeneric as String,
    SecAttrAccount = kSecAttrAccount as String

  static func stringForKey(keyName: String) -> String? {
    return self.dataForKey(keyName).flatMap { NSString(data: $0, encoding: NSUTF8StringEncoding) as String? }
  }
  
  static func dataForKey(keyName: String) -> NSData? {
    var keychainQuery = self.setupKeychainQueryForKey(keyName)
    var result: AnyObject?
    
    keychainQuery[SecMatchLimit] = kSecMatchLimitOne
    keychainQuery[SecReturnData] = kCFBooleanTrue
    
    let status = withUnsafeMutablePointer(&result) {
      SecItemCopyMatching(keychainQuery, $0)
    }
    
    return status == noErr ? result as? NSData : nil
  }
  
  static func persistentRefForKey(keyName: String) -> NSData? {
    var keychainQuery = self.setupKeychainQueryForKey(keyName)
    var result: AnyObject?
    
    keychainQuery[SecMatchLimit] = kSecMatchLimitOne
    keychainQuery[SecReturnPersistentRef] = kCFBooleanTrue
    
    let status = withUnsafeMutablePointer(&result) {
      SecItemCopyMatching(keychainQuery, $0)
    }
    
    return status == noErr ? result as? NSData : nil
  }
  
  static func setString(value: String, forKey keyName: String) -> Bool {
    if let data = value.dataUsingEncoding(NSUTF8StringEncoding) {
      return self.setData(data, forKey: keyName)
    } else {
      return false
    }
  }
  
  static func setData(value: NSData, forKey keyName: String) -> Bool {
    var keychainQuery: [String:AnyObject] = self.setupKeychainQueryForKey(keyName)
    
    keychainQuery[SecValueData] = value
    keychainQuery[SecReturnPersistentRef] = kCFBooleanTrue
    let status: OSStatus = SecItemAdd(keychainQuery, nil)
    
    if status == errSecSuccess {
      return true
    } else if status == errSecDuplicateItem {
      return self.updateData(value, forKey: keyName)
    } else {
      return false
    }
  }
  
  static func removeObjectForKey(keyName: String) -> Bool {
    let keychainQuery: [String:AnyObject] = self.setupKeychainQueryForKey(keyName)
    
    let status: OSStatus =  SecItemDelete(keychainQuery);
    
    if status == errSecSuccess {
      return true
    } else {
      return false
    }
  }
  
  private static func updateData(value: NSData, forKey keyName: String) -> Bool {
    let keychainQuery: [String:AnyObject] = self.setupKeychainQueryForKey(keyName)
    let updateDictionary = [SecValueData:value]

    let status: OSStatus = SecItemUpdate(keychainQuery, updateDictionary)
    
    if status == errSecSuccess {
      return true
    } else {
      return false
    }
  }
  
  private static func setupKeychainQueryForKey(keyName: String) -> [String:AnyObject] {
    var keychainQuery: [String:AnyObject] = [SecClass:kSecClassGenericPassword]
    
    let encodedIdentifier: NSData? = keyName.dataUsingEncoding(NSUTF8StringEncoding)
    
    keychainQuery[SecAttrGeneric] = encodedIdentifier
    keychainQuery[SecAttrAccount] = encodedIdentifier
    
    keychainQuery[SecAttrService] = "FritzVPN"
    
    keychainQuery[SecAttrAccessible] = kSecAttrAccessibleAlwaysThisDeviceOnly
    
    return keychainQuery
  }
}


