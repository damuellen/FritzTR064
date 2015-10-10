//
//  Combinators.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 11/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

/// Flattens a nested Promise of Promise into a single Promise.
///
/// The returned Promise resolves (or rejects) when the nested Promise resolves.
public func flatten<Value, Error>(promise: Promise<Promise<Value, Error>, Error>) -> Promise<Value, Error> {
  return promise.flatMap { $0 }
}

/// Creates a Promise that resolves when both arguments resolve.
///
/// The new Promise's value is of a tuple type constructed from both argument promises.
///
/// If either of the two Promises fails, the returned Promise also fails.
public func whenBoth<A, B, Error>(promiseA: Promise<A, Error>, _ promiseB: Promise<B, Error>) -> Promise<(A, B), Error> {
  return promiseA.flatMap { valueA in promiseB.map { valueB in (valueA, valueB) } }
}

/// Creates a Promise that resolves when all of the provided Promises are resolved.
///
/// The new Promise's value is an array of all resolved values.
/// If any of the supplied Promises fails, the returned Promise immediately fails.
///
/// When called with an empty array of promises, this returns a Resolved Promise (with an empty array value).
public func whenAll<Value, Error>(promises: [Promise<Value, Error>]) -> Promise<[Value], Error> {
  let source = FutureSource<[Value], Error>()
  var results = promises.map { $0.value }
  var remaining = promises.count

  if remaining == 0 {
    source.resolve([])
  }
  
  for (ix, promise) in promises.enumerate() {

    promise
      .then { value in
        results[ix] = value
        remaining = remaining - 1

        if remaining == 0 {
          source.resolve(results.map { $0! })
        }
      }

    promise
      .trap { error in
        source.reject(error)
      }
  }

  return source.promise
}

/// Creates a Promise that resolves when either argument resolves.
///
/// The new Promise's value is the value of the first promise to resolve.
/// If both argument Promises are already Resolved, the first Promise's value is used.
///
/// If both Promises fail, the returned Promise also fails.
public func whenEither<Value, Error>(promise1: Promise<Value, Error>, _ promise2: Promise<Value, Error>) -> Promise<Value, Error> {
  return whenAny([promise1, promise2])
}

/// Creates a Promise that resolves when any of the argument Promises resolves.
///
/// If all of the supplied Promises fail, the returned Promise fails.
///
/// When called with an empty array of promises, this returns a Promise that will never resolve.
public func whenAny<Value, Error>(promises: [Promise<Value, Error>]) -> Promise<Value, Error> {
  let source = FutureSource<Value, Error>()
  var remaining = promises.count

  for promise in promises {

    promise
      .then { value in
        source.resolve(value)
      }

    promise
      .trap { error in
        remaining = remaining - 1

        if remaining == 0 {
          source.reject(error)
        }
      }
  }

  return source.promise
}

/// Creates a Promise that resolves when all provided Promises finalize.
///
/// When called with an empty array of promises, this returns a Resolved Promise.
public func whenAllFinalized<Value, Error>(promises: [Promise<Value, Error>]) -> Promise<Void, NoError> {
  let source = FutureSource<Void, NoError>()
  var remaining = promises.count

  if remaining == 0 {
    source.resolve()
  }

  for promise in promises {

    promise
      .finally {
        remaining = remaining - 1

        if remaining == 0 {
          source.resolve()
        }
      }
  }

  return source.promise
}

/// Creates a Promise that resolves when any of the provided Promises finalize.
///
/// When called with an empty array of promises, this returns a Promise that will never resolve.
public func whenAnyFinalized<Value, Error>(promises: [Promise<Value, Error>]) -> Promise<Void, NoError> {
  let source = FutureSource<Void, NoError>()

  for promise in promises {

    promise
      .finally {
        source.resolve()
      }
  }

  return source.promise
}

extension Promise {

  /// Returns a Promise where the value information is thrown away.
  public func void() -> Promise<Void, Error> {
    return self.map { _ in }
  }
}

extension Promise where Error : ErrorType {

  /// Returns a Promise where the error is casted to an ErrorType.
  public func mapErrorType() -> Promise<Value, ErrorType> {
    return self.mapError { $0 }
  }
}
