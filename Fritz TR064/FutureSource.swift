//
//  FutureSource.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 11/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//


import Foundation

internal protocol OriginalSource {
  func registerHandler(handler: () -> Void)
}

public class FutureSource<Value, Error> : OriginalSource {
  typealias ResultHandler = Future<Value, Error> -> Void

  private var handlers: [Future<Value, Error> -> Void] = []
  private let originalSource: OriginalSource?
  public var state: State<Value, Error>

  public var warnUnresolvedDeinit: Bool

  // MARK: Initializers & deinit

  public convenience init(warnUnresolvedDeinit: Bool = true) {
    self.init(state: .Unresolved, originalSource: nil, warnUnresolvedDeinit: warnUnresolvedDeinit)
  }

  internal init(state: State<Value, Error>, originalSource: OriginalSource?, warnUnresolvedDeinit: Bool) {
    self.originalSource = originalSource
    self.warnUnresolvedDeinit = warnUnresolvedDeinit

    self.state = state
  }

  deinit {
    if warnUnresolvedDeinit {
      switch state {
      case .Unresolved:
        print("FutureSource.deinit: WARNING: Unresolved FutureSource deallocated, maybe retain this object?")
      default:
        break
      }
    }
  }

  // MARK: Computed properties

  /// Promise related to this FutureSource
  public var promise: Promise<Value, Error> {
    return Promise(source: self)
  }


  // MARK: Resolve / reject

  /// Resolve an Unresolved FutureSource with supplied value.
  ///
  /// When called on a FutureSource that is already Resolved or Rejected, the call is ignored.
  public func resolve(value: Value) {

    switch state {
    case .Unresolved:
      state = .Resolved(value)
      executeResultHandlers(.Value(value))
    default:
      break
    }
  }

  /// Reject an Unresolved FutureSource with supplied error.
  ///
  /// When called on a FutureSource that is already Resolved or Rejected, the call is ignored.
  public func reject(error: Error) {

    switch state {
    case .Unresolved:
      state = .Rejected(error)
      executeResultHandlers(.Error(error))
    default:
      break
    }
  }

  private func executeResultHandlers(result: Future<Value, Error>) {

    // Call all previously scheduled handlers
    callHandlers(result, handlers: handlers)

    // Cleanup
    handlers = []
  }

  // MARK: Adding result handlers

  internal func registerHandler(handler: () -> Void) {
    addOrCallResultHandler({ _ in handler() })
  }

  internal func addOrCallResultHandler(handler: Future<Value, Error> -> Void) {

    switch state {
    case .Unresolved:
      // Register with original source
      // Only call handlers after original completes
      if let originalSource = originalSource {
        originalSource.registerHandler {

          switch self.state {
          case .Resolved(let value):
            // Value is already available, call handler immediately
            callHandlers(Future.Value(value), handlers: [handler])

          case .Rejected(let error):
            // Error is already available, call handler immediately
            callHandlers(Future.Error(error), handlers: [handler])

          case .Unresolved:
            assertionFailure("callback should only be called if state is resolved or rejected")
          }
        }
      }
      else {
        // Save handler for later
        handlers.append(handler)
      }

    case .Resolved(let value):
      // Value is already available, call handler immediately
      callHandlers(Future.Value(value), handlers: [handler])

    case .Rejected(let error):
      // Error is already available, call handler immediately
      callHandlers(Future.Error(error), handlers: [handler])
    }
  }
}

internal func callHandlers<T>(arg: T, handlers: [T -> Void]) {
  for handler in handlers {
    handler(arg)
  }
}
