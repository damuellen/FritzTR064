//
//  Alamofire+Promise.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 10/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Alamofire

public struct AFPValue<T> : ErrorType {
  public let request: NSURLRequest?
  public let response: NSHTTPURLResponse?
  public let value: T
}

public struct AFPError : ErrorType {
  public let request: NSURLRequest?
  public let response: NSHTTPURLResponse?
  public let data: NSData?
  public let error: ErrorType
}

extension Request {
  
  public func responsePromise<T: ResponseSerializer, V where T.SerializedObject == V>(
    queue queue: dispatch_queue_t? = nil, responseSerializer: T) -> Promise<AFPValue<V>, AFPError> {
      
      let source = FutureSource<AFPValue<V>, AFPError>()
      
      self.response(queue: queue, responseSerializer: responseSerializer) { request, response, result in
        switch result {
        case let .Failure(data, error):
          source.reject(AFPError(request: request, response: response, data: data, error: error))
        case let.Success(value):
          source.resolve(AFPValue(request: request, response: response, value: value))
        }
      }
      return source.promise
  }
}

// MARK: - XML decode

public enum AlamofireDecodeError : ErrorType {
  case XMLDecodeError
  case HttpError(status: Int, result: Alamofire.Result<AEXMLDocument>?)
  case UnknownError(error: ErrorType, data: NSData?)
}

extension Request {
  
  public func responseDecodePromise<T>(decoder: AnyObject -> T?) -> Promise<T, AlamofireDecodeError> {
    return self.responseXMLPromise()
      .mapError { err in
        if let resp = err.response where resp.statusCode < 200 || resp.statusCode > 299 {
          let result: Alamofire.Result<AEXMLDocument> = Alamofire.Result.Failure(err.data, err.error)
          return AlamofireDecodeError.HttpError(status: resp.statusCode, result: result)
        }
        
        return AlamofireDecodeError.UnknownError(error: err.error, data: err.data)
      }
      .flatMap { val in
        if let resp = val.response where resp.statusCode < 200 || resp.statusCode > 299 {
          let result = Alamofire.Result.Success(val.value)
          return Promise(error: AlamofireDecodeError.HttpError(status: resp.statusCode, result: result))
        }
        
        guard let decoded = decoder(val.value) else {
          return Promise(error: AlamofireDecodeError.XMLDecodeError)
        }
        
        return Promise(value: decoded)
    }
  }
  
}

// MARK: - XML

extension Request {
  public func responseXMLPromise() -> Promise<AFPValue<AEXMLDocument>, AFPError> {
    return self.responsePromise(responseSerializer: Request.XMLResponseSerializer())
  }
  func responsePromiseFor(Action action: Action) -> Promise<AFPValue<AEXMLElement>, AFPError> {
    return self.responsePromise(responseSerializer: Request.XMLResponseSerializerFor(action))
  }
}

extension Request {
  public static func XMLResponseSerializer() -> GenericResponseSerializer<AEXMLDocument> {
    return GenericResponseSerializer { request, response, data in
      guard let validData = data else {
        let failureReason = "Data could not be serialized. Input data was nil."
        let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
        return .Failure(data, error)
      }
      do {
        let XML = try AEXMLDocument(xmlData: validData)
        return .Success(XML)
      } catch {
        return .Failure(data, error as NSError)
      }
    }
  }
  
  static func XMLResponseSerializerFor(action: Action) -> GenericResponseSerializer<AEXMLElement> {
    return GenericResponseSerializer { request, response, data in
      guard let validData = data else {
        let failureReason = "Data could not be serialized. Input data was nil."
        let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
        return .Failure(data, error)
      }
      do {
        let XML = try AEXMLDocument(xmlData: validData)
        if let validXML = XML.checkWithAction(action) {
          return .Success(validXML)
        }else {
          let failureReason = "XML is no valid response for action."
          let error = Error.errorWithCode(.ContentTypeValidationFailed, failureReason: failureReason)
          return .Failure(data, error)
        }
      } catch {
        return .Failure(data, error as NSError)
      }
    }
  }
  
  public func responseXMLDocument(completionHandler: (NSURLRequest?, NSHTTPURLResponse?, Result<AEXMLDocument>) -> Void) -> Self {
    return response(responseSerializer: Request.XMLResponseSerializer(), completionHandler: completionHandler)
  }
}

