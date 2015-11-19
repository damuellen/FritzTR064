//
//  FileManager.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 06/11/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

extension NSSearchPathDirectory {
  func directoryURL() -> NSURL? {
    return NSFileManager.defaultManager().URLsForDirectory(self, inDomains: .UserDomainMask).first
  }
}

struct FileManager {
  
  static let fileManager = NSFileManager.defaultManager()
  
  static func pathWithBundleIdentifierForDirectory(directory: NSSearchPathDirectory) -> String? {
    guard let directoryURL = directory.directoryURL(),
      bundle = NSBundle.mainBundle().bundleIdentifier,
      path = directoryURL.URLByAppendingPathComponent(bundle).path
      else { return nil }
    if !fileManager.fileExistsAtPath(path) {
      do {
        try fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
      } catch { return nil }
    }
    return path
  }
  
  static func saveValuesToDiskCache<T:PropertyListReadable>(newValues:[T], name: String) -> Bool {
    guard let path = pathWithBundleIdentifierForDirectory(.CachesDirectory) else { return false }
    let URL = NSURL(fileURLWithPath: path).URLByAppendingPathComponent(name).URLByAppendingPathExtension("plist")
    let encodedValues = NSArray(array: newValues.map {$0.propertyListRepresentation()})
    return encodedValues.writeToURL(URL, atomically: true)
  }
  
  static func loadValuesFromDiskCache(name: String) -> [AnyObject]? {
    guard let path = pathWithBundleIdentifierForDirectory(.CachesDirectory) else { return nil }
    let URL = NSURL(fileURLWithPath: path).URLByAppendingPathComponent(name).URLByAppendingPathExtension("plist")
    guard fileManager.fileExistsAtPath(URL.path!) else { return nil }
    return NSArray(contentsOfURL: URL) as? [AnyObject]
  }
  
  static func saveBinaryToDiskCache<T:PropertyListReadable>(newValues:[T], name: String) -> Bool {
    guard let path = pathWithBundleIdentifierForDirectory(.CachesDirectory) else { return false }
    let URL = NSURL(fileURLWithPath: path).URLByAppendingPathComponent(name).URLByAppendingPathExtension("plist")
    let encodedValues = NSArray(array: newValues.map {$0.propertyListRepresentation()})
    let data = try? NSPropertyListSerialization.dataWithPropertyList(encodedValues, format: NSPropertyListFormat.BinaryFormat_v1_0, options: 0)
    return data?.writeToURL(URL, atomically: true) ?? false
  }
  
  static func loadBinaryFromDiskCache(name: String) -> [AnyObject]? {
    guard let path = pathWithBundleIdentifierForDirectory(.CachesDirectory) else { return nil }
    let URL = NSURL(fileURLWithPath: path).URLByAppendingPathComponent(name).URLByAppendingPathExtension("plist")
    guard fileManager.fileExistsAtPath(URL.path!) else { return nil }
    guard let data = NSData(contentsOfURL: URL) else { return nil }
    return try? NSPropertyListSerialization.propertyListWithData(data, options:[.MutableContainersAndLeaves], format:nil) as! [AnyObject]
  }
  
}