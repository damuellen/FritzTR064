//
//  Delay.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 11/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

/// Wrapper around `dispatch_after`, with a seconds parameter.
public func delay(seconds: NSTimeInterval, queue: dispatch_queue_t! = dispatch_get_main_queue(), block: dispatch_block_t!) {
  let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))

  dispatch_after(when, queue, block)
}

/// Create a Promise that resolves with the specified value after the specified number of seconds.
public func delayPromise<Value, Error>(seconds: NSTimeInterval, value: Value, queue: dispatch_queue_t! = dispatch_get_main_queue()) -> Promise<Value, Error> {
  let source = FutureSource<Value, Error>()

  delay(seconds, queue: queue) {
    source.resolve(value)
  }

  return source.promise
}

/// Create a Promise that rejects with the specified error after the specified number of seconds.
public func delayErrorPromise<Value, Error>(seconds: NSTimeInterval, error: Error, queue: dispatch_queue_t! = dispatch_get_main_queue()) -> Promise<Value, Error> {
  let source = FutureSource<Value, Error>()

  delay(seconds, queue: queue) {
    source.reject(error)
  }

  return source.promise
}

/// Create a Promise that resolves after the specified number of seconds.
public func delayPromise<Error>(seconds: NSTimeInterval, queue: dispatch_queue_t! = dispatch_get_main_queue()) -> Promise<Void, Error> {
  return delayPromise(seconds, value: (), queue: queue)
}

extension Promise {

  /// Return a Promise with the resolve or reject delayed by the specified number of seconds.
  public func delay(seconds: NSTimeInterval) -> Promise<Value, Error> {
    return self
      .flatMap { value in
        return delayPromise(seconds).map { value }
      }
      .flatMapError { error in
        return delayPromise(seconds).flatMap { Promise(error: error) }
      }
  }
}
