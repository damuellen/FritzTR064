//
//  Future.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 11/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//


import Foundation

/// The Future type is used for Promises that are Resolved or Rejected.
public enum Future<TValue, TError> {
  case Value(TValue)
  case Error(TError)

  /// Optional value, set when Result is Value.
  public var value: TValue? {
    switch self {
    case .Value(let value):
      return value
    case .Error:
      return nil
    }
  }

  /// Optional error, set when Result is Error.
  public var error: TError? {
    switch self {
    case .Error(let error):
      return error
    case .Value:
      return nil
    }
  }
}

extension Future: CustomStringConvertible {

  public var description: String {
    switch self {
    case .Value(let value):
      return "Value(\(value))"
    case .Error(let error):
      return "Error(\(error))"
    }
  }
}
