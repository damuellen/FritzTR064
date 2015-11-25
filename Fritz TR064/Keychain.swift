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
    let keychainData: NSData? = self.dataForKey(keyName)
    var stringValue: String?
    if let data = keychainData {
      stringValue = NSString(data: data, encoding: NSUTF8StringEncoding) as String?
    }
    return stringValue
  }
  
  static func dataForKey(keyName: String) -> NSData? {
    var keychainQueryDictionary = self.setupKeychainDictionaryForKey(keyName)
    var result: AnyObject?
    
    keychainQueryDictionary[SecMatchLimit] = kSecMatchLimitOne
    keychainQueryDictionary[SecReturnData] = kCFBooleanTrue
    
    let status = withUnsafeMutablePointer(&result) {
      SecItemCopyMatching(keychainQueryDictionary, $0)
    }
    
    return status == noErr ? result as? NSData : nil
  }
  
  static func persistentRefForKey(keyName: String) -> NSData? {
    var keychainDictionary = self.setupKeychainDictionaryForKey(keyName)
    var result: AnyObject?
    
    keychainDictionary[SecMatchLimit] = kSecMatchLimitOne
    keychainDictionary[SecReturnPersistentRef] = kCFBooleanTrue
    
    let status = withUnsafeMutablePointer(&result) {
      SecItemCopyMatching(keychainDictionary, $0)
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
    var keychainDictionary: [String:AnyObject] = self.setupKeychainDictionaryForKey(keyName)
    
    keychainDictionary[SecValueData] = value
    keychainDictionary[SecReturnPersistentRef] = kCFBooleanTrue
    let status: OSStatus = SecItemAdd(keychainDictionary, nil)
    
    if status == errSecSuccess {
      return true
    } else if status == errSecDuplicateItem {
      return self.updateData(value, forKey: keyName)
    } else {
      return false
    }
  }
  
  static func removeObjectForKey(keyName: String) -> Bool {
    let keychainDictionary: [String:AnyObject] = self.setupKeychainDictionaryForKey(keyName)
    
    let status: OSStatus =  SecItemDelete(keychainDictionary);
    
    if status == errSecSuccess {
      return true
    } else {
      return false
    }
  }
  
  private static func updateData(value: NSData, forKey keyName: String) -> Bool {
    let keychainDictionary: [String:AnyObject] = self.setupKeychainDictionaryForKey(keyName)
    let updateDictionary = [SecValueData:value]

    let status: OSStatus = SecItemUpdate(keychainDictionary, updateDictionary)
    
    if status == errSecSuccess {
      return true
    } else {
      return false
    }
  }
  
  private static func setupKeychainDictionaryForKey(keyName: String) -> [String:AnyObject] {
    var keychainDictionary: [String:AnyObject] = [SecClass:kSecClassGenericPassword]
    
    let encodedIdentifier: NSData? = keyName.dataUsingEncoding(NSUTF8StringEncoding)
    
    keychainDictionary[SecAttrGeneric] = encodedIdentifier
    keychainDictionary[SecAttrAccount] = encodedIdentifier
    
    keychainDictionary[SecAttrService] = "FritzVPN"
    
    keychainDictionary[SecAttrAccessible] = kSecAttrAccessibleAlwaysThisDeviceOnly
    
    return keychainDictionary
  }
}


