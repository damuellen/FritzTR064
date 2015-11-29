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
  case FatalError
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
      } catch {
        throw FileError.CacheDirectory
      }
    }
    return path
  }
  
  static func saveValuesToDiskCache<T:PropertyListReadable>(newValues:[T], name: String)throws -> Bool {
    do {
      guard let path = try pathWithBundleIdentifierForDirectory(.CachesDirectory)
        else { return false }
      
      let URL = NSURL(fileURLWithPath: path).URLByAppendingPathComponent(name).URLByAppendingPathExtension("plist")
      let encodedValues = NSArray(array: newValues.map {$0.propertyListRepresentation()})
      let success = encodedValues.writeToURL(URL, atomically: true)
      debugPrint("write",URL)
      return success
    } catch let error {
      throw error
    }
  }
  
  static func loadValuesFromDiskCache(name: String)throws -> [AnyObject]? {
    do {
      guard let path = try pathWithBundleIdentifierForDirectory(.CachesDirectory)
        else { return nil }
      
      let URL = NSURL(fileURLWithPath: path).URLByAppendingPathComponent(name).URLByAppendingPathExtension("plist")
      guard fileManager.fileExistsAtPath(URL.path!) else { throw FileError.FileNotFound }
      debugPrint("read",URL)
      return NSArray(contentsOfURL: URL) as? [AnyObject]
    } catch let error {
      throw error
    }
  }
  
  static func saveCompressedValuesToDiskCache<T:PropertyListReadable>(newValues:[T], name: String)throws -> Bool {
    do {
      guard let path = try pathWithBundleIdentifierForDirectory(.CachesDirectory)
        else { return false }
      
      let URL = NSURL(fileURLWithPath: path).URLByAppendingPathComponent(name).URLByAppendingPathExtension("plist")
      let encodedValues = NSArray(array: newValues.map {$0.propertyListRepresentation()})
      let data = try? NSPropertyListSerialization.dataWithPropertyList(encodedValues, format: NSPropertyListFormat.BinaryFormat_v1_0, options: 0)
      debugPrint("write",URL)
      return data?.compressedDataUsingCompression(.LZFSE)?.writeToURL(URL, atomically: true) ?? false
    } catch let error { throw error }
  }
  
  static func loadCompressedValuesFromDiskCache(name: String)throws -> [AnyObject]? {
    guard let path = try pathWithBundleIdentifierForDirectory(.CachesDirectory)
      else { return nil }
    
    let URL = NSURL(fileURLWithPath: path).URLByAppendingPathComponent(name).URLByAppendingPathExtension("plist")
    guard fileManager.fileExistsAtPath(URL.path!)
      else { throw FileError.FileNotFound }
    
    guard let compressedData = NSData(contentsOfURL: URL),
      data = compressedData.uncompressedDataUsingCompression(.LZFSE)
      else { return nil }
      debugPrint("read",URL)
    return try NSPropertyListSerialization.propertyListWithData(data, options:[.Immutable], format:nil) as? [AnyObject]
  }
  
}

func loadValuesFromDefaults(key: String) -> [AnyObject]? {
  return NSUserDefaults.standardUserDefaults().objectForKey("Services") as? [AnyObject]
}

func extractValuesFromPropertyListArray<T:PropertyListReadable>(propertyListArray:[AnyObject]?) -> [T] {
  guard let encodedArray = propertyListArray
    else {return []}
  return encodedArray.map { $0 as? NSDictionary }.flatMap { T (propertyListRepresentation: $0) }
}

func saveValuesToDefaults<T:PropertyListReadable>(newValues:[T], key:String) {
  let encodedValues = newValues.map{$0.propertyListRepresentation()}
  NSUserDefaults.standardUserDefaults().setObject(encodedValues, forKey:key)
}

//
//  NSData+Compression.swift
//  NSData+Compression
//
//  Created by Lee Morgan on 7/17/15.
//  Copyright © 2015 Lee Morgan. All rights reserved.
//

import Compression

/** Available Compression Algorithms
 - Compression.LZ4   : Fast compression
 - Compression.ZLIB  : Balanced between speed and compression
 - Compression.LZMA  : High compression
 - Compression.LZFSE : Apple-specific high performance compression. Faster and better compression than ZLIB, but slower than LZ4 and does not compress as well as LZMA.
 */
enum Compression {
  
  case LZ4, ZLIB, LZMA, LZFSE
}

extension NSData {
  
  /// Returns a NSData object created by compressing the receiver using the given compression algorithm.
  ///
  ///     let compressedData = someData.compressedDataUsingCompression(Compression.LZFSE)
  ///
  /// - Parameter compression: Algorithm to use during compression
  /// - Returns: A NSData object created by encoding the receiver's contents using the provided compression algorithm. Returns nil if compression fails or if the receiver's length is 0.
  func compressedDataUsingCompression(compression: Compression) -> NSData? {
    return self.dataUsingCompression(compression, operation: .Encode)
  }
  
  /// Returns a NSData object by uncompressing the receiver using the given compression algorithm.
  ///
  ///     let uncompressedData = someCompressedData.uncompressedDataUsingCompression(Compression.LZFSE)
  ///
  /// - Parameter compression: Algorithm to use during decompression
  /// - Returns: A NSData object created by decoding the receiver's contents using the provided compression algorithm. Returns nil if decompression fails or if the receiver's length is 0.
  func uncompressedDataUsingCompression(compression: Compression) -> NSData? {
    return self.dataUsingCompression(compression, operation: .Decode)
  }
  
  
  private enum CompressionOperation {
    case Encode
    case Decode
  }
  
  private func dataUsingCompression(compression: Compression, operation: CompressionOperation) -> NSData? {
    
    guard self.length > 0 else {
      return nil
    }
    
    let streamPtr = UnsafeMutablePointer<compression_stream>.alloc(1)
    var stream = streamPtr.memory
    var status : compression_status
    var op : compression_stream_operation
    var flags : Int32
    var algorithm : compression_algorithm
    
    switch compression {
    case .LZ4:
      algorithm = COMPRESSION_LZ4
    case .LZFSE:
      algorithm = COMPRESSION_LZFSE
    case .LZMA:
      algorithm = COMPRESSION_LZMA
    case .ZLIB:
      algorithm = COMPRESSION_ZLIB
    }
    
    switch operation {
    case .Encode:
      op = COMPRESSION_STREAM_ENCODE
      flags = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
    case .Decode:
      op = COMPRESSION_STREAM_DECODE
      flags = 0
    }
    
    status = compression_stream_init(&stream, op, algorithm)
    guard status != COMPRESSION_STATUS_ERROR else {
      // an error occurred
      return nil
    }
    
    // setup the stream's source
    stream.src_ptr = UnsafePointer<UInt8>(bytes)
    stream.src_size = length
    
    // setup the stream's output buffer
    // we use a temporary buffer to store the data as it's compressed
    let dstBufferSize : size_t = 4096
    let dstBufferPtr = UnsafeMutablePointer<UInt8>.alloc(dstBufferSize)
    stream.dst_ptr = dstBufferPtr
    stream.dst_size = dstBufferSize
    // and we stroe the output in a mutable data object
    let outputData = NSMutableData()
    
    
    repeat {
      status = compression_stream_process(&stream, flags)
      
      switch status.rawValue {
      case COMPRESSION_STATUS_OK.rawValue:
        // Going to call _process at least once more, so prepare for that
        if stream.dst_size == 0 {
          // Output buffer full...
          
          // Write out to mutableData
          outputData.appendBytes(dstBufferPtr, length: dstBufferSize)
          
          // Re-use dstBuffer
          stream.dst_ptr = dstBufferPtr
          stream.dst_size = dstBufferSize
        }
        
      case COMPRESSION_STATUS_END.rawValue:
        // We are done, just write out the output buffer if there's anything in it
        if stream.dst_ptr > dstBufferPtr {
          outputData.appendBytes(dstBufferPtr, length: stream.dst_ptr - dstBufferPtr)
        }
        
      case COMPRESSION_STATUS_ERROR.rawValue:
        return nil
        
      default:
        break
      }
      
    } while status == COMPRESSION_STATUS_OK
    
    compression_stream_destroy(&stream)
    
    return outputData.copy() as? NSData
  }
  
}
