//
//  FileManager.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 06/11/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

var cacheFileFolder: String? {
  let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first!
  guard let bundle = NSBundle.mainBundle().bundleIdentifier,
    path = directoryURL.URLByAppendingPathComponent(bundle).path else { return nil }
  if !NSFileManager.defaultManager().fileExistsAtPath(path) {
    try! NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
  }
  return path
}

func saveValuesToDiskCache<T:PropertyListReadable>(newValues:[T], name: String) -> Bool {
  guard let folder = cacheFileFolder else { return false }
  let URL = NSURL(fileURLWithPath: folder).URLByAppendingPathComponent(name).URLByAppendingPathExtension("plist")
  let encodedValues = NSArray(array: newValues.map {$0.propertyListRepresentation()})
  return encodedValues.writeToURL(URL, atomically: true)
}

func loadValuesFromDiskCache(name: String) -> [AnyObject]? {
  guard let folder = cacheFileFolder else { return nil }
  let URL = NSURL(fileURLWithPath: folder).URLByAppendingPathComponent(name).URLByAppendingPathExtension("plist")
  if NSFileManager.defaultManager().fileExistsAtPath(URL.path!) {
    return NSArray(contentsOfURL: URL) as? [AnyObject]
  }
  return nil
}

