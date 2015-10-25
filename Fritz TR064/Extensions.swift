//
//  Extensions.swift
//  Fritz TR064
//
//  Created by Daniel Müllenborn on 20/10/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

extension String {
  
  var isEmpty: Bool  {
    return self.characters.count == 0
  }
  var length: Int {
    return self.characters.count
  }
  
  static var DateDetector = try? NSDataDetector(types: NSTextCheckingType.Date.rawValue)
  static var LinkDetector = try? NSDataDetector(types: NSTextCheckingType.Link.rawValue)
  static var PhoneNumberDetector = try? NSDataDetector(types: NSTextCheckingType.PhoneNumber.rawValue)
  static var AddressDetector = try? NSDataDetector(types: NSTextCheckingType.Address.rawValue)
  static var CorrectionDetector = try? NSDataDetector(types: NSTextCheckingType.Correction.rawValue)
  static var SpellingDetector = try? NSDataDetector(types: NSTextCheckingType.Spelling.rawValue)
  
  func getDates() -> [NSDate] {
    guard let detector = String.DateDetector else { return [NSDate]() }
    return detector.matchesInString(self, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, length)).flatMap { $0.date }
  }
  
  func containsDate() -> Bool {
    return self.getDates().count > 0
  }
  
  func getLink() -> String? {
    guard let detector = String.LinkDetector else { return nil }
    return detector.firstMatchInString(self, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, length))?.URL?.absoluteString
  }
  
  func getURLs() -> [NSURL] {
    guard let detector = String.LinkDetector else { return [NSURL]() }
    return detector.matchesInString(self, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, length))
      .flatMap { $0.URL }
  }
  
  func containsURL() -> Bool {
    return self.getURLs().count > 0
  }
  
  var isEmail: Bool {
    guard let detector = String.LinkDetector else { return false }
    let firstMatch = detector.firstMatchInString(self, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, length))
    return (firstMatch?.range.location != NSNotFound && firstMatch?.URL?.scheme == "mailto")
  }
  
  func getPhoneNumber() -> String? {
    guard let detector = String.PhoneNumberDetector else { return nil }
    return detector.firstMatchInString(self, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, length))?.phoneNumber
  }
  
  var isPhoneNumber: Bool {
    return getPhoneNumber() != nil
  }
  
  func detectLanguage() -> String? {
    if self.length > 4 {
      let tagger = NSLinguisticTagger(tagSchemes:[NSLinguisticTagSchemeLanguage], options: 0)
      tagger.string = self
      return tagger.tagAtIndex(0, scheme: NSLinguisticTagSchemeLanguage, tokenRange: nil, sentenceRange: nil)
    }
    return nil
  }
  
}

extension Int {
  
  func isIn (interval: ClosedInterval<Int>) -> Bool {
    return interval.contains(self)
  }
  func isIn (interval: HalfOpenInterval<Int>) -> Bool {
    return interval.contains(self)
  }
  func times <T>(function: Void -> T) {
    (0..<self).forEach { _ in function(); return }
  }
  func times (function: Void -> Void) {
    (0..<self).forEach { _ in function(); return }
  }
  func clamp (min: Int, _ max: Int) -> Int {
    return Swift.max(min, Swift.min(max, self))
  }
  static func random(min: Int = 0, max: Int) -> Int {
    return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
  }
  var years: NSTimeInterval {
    return 365 * self.days
  }
  var year: NSTimeInterval {
    return self.years
  }
  var days: NSTimeInterval {
    return 24 * self.hours
  }
  var day: NSTimeInterval {
    return self.days
  }
  var hours: NSTimeInterval {
    return 60 * self.minutes
  }
  var hour: NSTimeInterval {
    return self.hours
  }
  var minutes: NSTimeInterval {
    return 60 * self.seconds
  }
  var minute: NSTimeInterval {
    return self.minutes
  }
  var seconds: NSTimeInterval {
    return NSTimeInterval(self)
  }
  var second: NSTimeInterval {
    return self.seconds
  }
  
}


struct ChunkSequence<Element>: SequenceType {
  let chunkSize: Array<Element>.Index
  let collection: Array<Element>
  
  func generate() -> AnyGenerator<ArraySlice<Element>> {
    var offset:Array<Element>.Index = collection.startIndex
    return anyGenerator {
      let result = self.collection[offset..<offset.advancedBy(self.chunkSize, limit: self.collection.endIndex)]
      offset += result.count
      return result.count > 0 ? result : nil
    }
  }
}


extension Array {
  
  func each (call: (Int, Element) -> ()) {
    for (index, item) in self.enumerate() {
      call(index, item)
    }
  }
  func any (test: (Element) -> Bool) -> Bool {
    for item in self {
      if test(item) { return true }
    }
    return false
  }
  func all (test: (Element) -> Bool) -> Bool {
    for item in self {
      if !test(item) { return false }
    }
    return true
  }
  func slice(every every: Index) -> ChunkSequence<Element> {
    return ChunkSequence(chunkSize: every, collection: self)
  }
}

public extension NSDate {
  
  public func add(seconds seconds: Int = 0, minutes: Int = 0, hours: Int = 0, days: Int = 0, weeks: Int = 0, months: Int = 0, years: Int = 0) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let version = floor(NSFoundationVersionNumber)
    
    if version <= NSFoundationVersionNumber10_9_2 {
      var component = NSDateComponents()
      component.setValue(seconds, forComponent: .Second)
      var date : NSDate! = calendar.dateByAddingComponents(component, toDate: self, options: [])!
      component = NSDateComponents()
      component.setValue(minutes, forComponent: .Minute)
      date = calendar.dateByAddingComponents(component, toDate: date, options: [])!
      
      component = NSDateComponents()
      component.setValue(hours, forComponent: .Hour)
      date = calendar.dateByAddingComponents(component, toDate: date, options: [])!
      
      component = NSDateComponents()
      component.setValue(days, forComponent: .Day)
      date = calendar.dateByAddingComponents(component, toDate: date, options: [])!
      
      component = NSDateComponents()
      component.setValue(weeks, forComponent: .WeekOfMonth)
      date = calendar.dateByAddingComponents(component, toDate: date, options: [])!
      
      component = NSDateComponents()
      component.setValue(months, forComponent: .Month)
      date = calendar.dateByAddingComponents(component, toDate: date, options: [])!
      
      component = NSDateComponents()
      component.setValue(years, forComponent: .Year)
      date = calendar.dateByAddingComponents(component, toDate: date, options: [])!
      return date
    }
    let options = NSCalendarOptions(rawValue: 0)
    var date : NSDate! = calendar.dateByAddingUnit(NSCalendarUnit.Second, value: seconds, toDate: self, options: options)
    date = calendar.dateByAddingUnit(NSCalendarUnit.Minute, value: minutes, toDate: date, options: options)
    date = calendar.dateByAddingUnit(NSCalendarUnit.Day, value: days, toDate: date, options: options)
    date = calendar.dateByAddingUnit(NSCalendarUnit.Hour, value: hours, toDate: date, options: options)
    date = calendar.dateByAddingUnit(NSCalendarUnit.WeekOfMonth, value: weeks, toDate: date, options: options)
    date = calendar.dateByAddingUnit(NSCalendarUnit.Month, value: months, toDate: date, options: options)
    date = calendar.dateByAddingUnit(NSCalendarUnit.Year, value: years, toDate: date, options: options)
    return date
  }
  public func addSeconds (seconds: Int) -> NSDate {
    return add(seconds: seconds)
  }
  public func addMinutes (minutes: Int) -> NSDate {
    return add(minutes: minutes)
  }
  public func addHours(hours: Int) -> NSDate {
    return add(hours: hours)
  }
  public func addDays(days: Int) -> NSDate {
    return add(days: days)
  }
  public func addWeeks(weeks: Int) -> NSDate {
    return add(weeks: weeks)
  }
  public func addMonths(months: Int) -> NSDate {
    return add(months: months)
  }
  public func addYears(years: Int) -> NSDate {
    return add(years: years)
  }
  public func isAfter(date: NSDate) -> Bool {
    return (self.compare(date) == NSComparisonResult.OrderedDescending)
  }
  public func isBefore(date: NSDate) -> Bool {
    return (self.compare(date) == NSComparisonResult.OrderedAscending)
  }
  public var year : Int {
    return getComponent(.Year)
  }
  public var month : Int {
    return getComponent(.Month)
  }
  public var weekday : Int {
    return getComponent(.Weekday)
  }
  public var weekOfYear : Int {
    return getComponent(.WeekOfYear)
  }
  public var weekMonth : Int {
    return getComponent(.WeekOfMonth)
  }
  public var day : Int {
    return getComponent(.Day)
  }
  public var hours : Int {
    return getComponent(.Hour)
  }
  public var minutes : Int {
    return getComponent(.Minute)
  }
  public var seconds : Int {
    return getComponent(.Second)
  }
  class func dateFromComponents(components: NSDateComponents) -> NSDate? {
    return NSCalendar.currentCalendar().dateFromComponents(components)
  }
  class func dateWithYear(year: Int, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, andSecond second: Int? = nil) -> NSDate? {
    let components = NSDateComponents()
    components.year = year
    if let month = month { components.month = month }
    if let day = day { components.day = day }
    if let hour = hour { components.hour = hour }
    if let minute = minute { components.minute = minute }
    if let second = second { components.second = second }
    return NSCalendar.currentCalendar().dateFromComponents(components)
  }
  public func getComponent (component : NSCalendarUnit) -> Int {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components(component, fromDate: self)
    return components.valueForComponent(component)
  }
  func isEqualToDateIgnoringTime(aDate:NSDate) -> Bool {
    return ((self.year == aDate.year)
      && (self.month == aDate.month)
      && (self.day == aDate.day))
  }
  var isToday: Bool {
    return self.isEqualToDateIgnoringTime(NSDate())
  }
  var isTomorrow: Bool {
    return self.isEqualToDateIgnoringTime(NSDate().addDays(1))
  }
  var isYesterday: Bool {
    return self.isEqualToDateIgnoringTime(NSDate().addDays(-1))
  }
  func isSameWeekAsDate(aDate : NSDate) -> Bool {
    return (self.weekOfYear == (NSDate().weekOfYear))
  }
  var isThisWeek: Bool {
    return self.isSameWeekAsDate(NSDate());
  }
  var isNextWeek: Bool {
    return (self.weekOfYear == (NSDate().weekOfYear + 1))
  }
  var isLastWeek: Bool {
    return (self.weekOfYear == (NSDate().weekOfYear - 1))
  }
  var isThisMonth: Bool {
    return (self.month == (NSDate().month))
  }
  var isNextMonth: Bool {
    return (self.month == (NSDate().month + 1))
  }
  var isLastMonth: Bool {
    return (self.month == (NSDate().month - 1))
  }
  var isThisYear: Bool {
    return (self.year == (NSDate().year ))
  }
  var isNextYear: Bool {
    return (self.year == (NSDate().year + 1))
  }
  var isLastYear: Bool {
    return (self.year == (NSDate().year - 1))
  }
  var isInFuture: Bool {
    return self < NSDate()
  }
  var isInPast: Bool {
    return self > NSDate()
  }
  
}


public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.compare(rhs) == NSComparisonResult.OrderedSame
}

extension NSDate: Comparable {
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.compare(rhs) == NSComparisonResult.OrderedAscending
}
extension Bool {
  
  mutating func toggle() -> Bool {
    self = !self
    return self
  }
  
}