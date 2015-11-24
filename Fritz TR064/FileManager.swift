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

protocol PropertyListReadable {
  func propertyListRepresentation() -> NSDictionary
  init?(propertyListRepresentation: NSDictionary?)
}

enum FileError: ErrorType {
  case FileNotFound
  case CacheDirectory
}

struct FileManager {
  
  static let fileManager = NSFileManager.defaultManager()
  
  static func pathWithBundleIdentifierForDirectory(directory: NSSearchPathDirectory)throws -> String? {
    guard let directoryURL = directory.directoryURL(),
      bundle = NSBundle.mainBundle().bundleIdentifier,
      path = directoryURL.URLByAppendingPathComponent(bundle).path
      else { return nil }
    if !fileManager.fileExistsAtPath(path) {
      do {
        try fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
      } catch { throw FileError.CacheDirectory }
    }
    return path
  }
  
  static func saveValuesToDiskCache<T:PropertyListReadable>(newValues:[T], name: String)throws -> Bool {
    do {
      guard let path = try pathWithBundleIdentifierForDirectory(.CachesDirectory) else { return false }
      let URL = NSURL(fileURLWithPath: path).URLByAppendingPathComponent(name).URLByAppendingPathExtension("plist")
      let encodedValues = NSArray(array: newValues.map {$0.propertyListRepresentation()})
      let success = encodedValues.writeToURL(URL, atomically: true)
      debugPrint("write",URL)
      return success
    } catch let error { throw error }
  }
  
  static func loadValuesFromDiskCache(name: String)throws -> [AnyObject]? {
    do {
      guard let path = try pathWithBundleIdentifierForDirectory(.CachesDirectory) else { return nil }
      let URL = NSURL(fileURLWithPath: path).URLByAppendingPathComponent(name).URLByAppendingPathExtension("plist")
      guard fileManager.fileExistsAtPath(URL.path!) else { throw FileError.FileNotFound }
      debugPrint("read",URL)
      return NSArray(contentsOfURL: URL) as? [AnyObject]
    } catch let error { throw error }
  }
  /*
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
  */
}

func loadValuesFromDefaults(key: String) -> [AnyObject]? {
  return NSUserDefaults.standardUserDefaults().objectForKey("Services") as? [AnyObject]
}

func extractValuesFromPropertyListArray<T:PropertyListReadable>(propertyListArray:[AnyObject]?) -> [T] {
  guard let encodedArray = propertyListArray else {return []}
  return encodedArray.map { $0 as? NSDictionary }.flatMap { T (propertyListRepresentation: $0) }
}

func saveValuesToDefaults<T:PropertyListReadable>(newValues:[T], key:String) {
  let encodedValues = newValues.map{$0.propertyListRepresentation()}
  NSUserDefaults.standardUserDefaults().setObject(encodedValues, forKey:key)
}
