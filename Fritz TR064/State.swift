//
//  State.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 11/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

/// Type used when there is no error possible.
public enum NoError : ErrorType {}

/// State of a FutureSource.
public enum State<Value, Error> {
  case Unresolved
  case Resolved(Value)
  case Rejected(Error)
}

extension State: CustomStringConvertible {

  public var description: String {
    switch self {
    case .Unresolved:
      return "Unresolved"
    case .Resolved(let value):
      return "Resolved(\(value))"
    case .Rejected(let error):
      return "Rejected(\(error))"
    }
  }
}
