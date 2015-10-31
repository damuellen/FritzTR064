
import UIKit

extension String {
  /**
   true iff self contains characters.
   */
  public var isNotEmpty: Bool {
    return !isEmpty
  }
}


//
//  YoshikoTextField.swift
//  TextFieldEffects
//
//  Created by Keenan Cassidy on 01/10/2015.
//  Copyright © 2015 Raul Riera. All rights reserved.
//

import UIKit

@IBDesignable public class YoshikoTextField: UITextField {
  
  private let borderLayer = CALayer()
  private let textFieldInsets = CGPoint(x: 6, y: 0)
  private let placeHolderInsets = CGPoint(x: 6, y: 0)
  private let outerBackgroundView = UIView()
  
  public let placeholderLabel = UILabel()
  
  @IBInspectable public var borderSize: CGFloat = 2.0 {
    didSet {
      updateBorder()
    }
  }
  
  @IBInspectable dynamic public var activeColor: UIColor = .blueColor() {
    didSet {
      updateBorder()
      updateBackground()
      updatePlaceholder()
    }
  }
  
  @IBInspectable dynamic public var inactiveColor: UIColor = .lightGrayColor() {
    didSet {
      updateBorder()
      updateBackground()
      updatePlaceholder()
    }
  }
  
  @IBInspectable dynamic public var outerBackgroundColor: UIColor = .lightGrayColor() {
    didSet {
      updateBorder()
    }
  }
  
  @IBInspectable dynamic public var activeInnerBackgroundColor: UIColor = .clearColor() {
    didSet {
      updateBackground()
    }
  }
  
  @IBInspectable dynamic public var placeholderColor: UIColor = .darkGrayColor() {
    didSet {
      updatePlaceholder()
    }
  }
  
  override public var placeholder: String? {
    didSet {
      updatePlaceholder()
    }
  }
  override public func drawRect(rect: CGRect) {
    drawViewsForRect(rect)
  }
  
  override public func drawPlaceholderInRect(rect: CGRect) {
    // Don't draw any placeholders
  }
  
  override public var text: String? {
    didSet {
      if let text = text where text.isNotEmpty {
        animateViewsForTextEntry()
      } else {
        animateViewsForTextDisplay()
      }
    }
  }
  
  // MARK: - UITextField Observing
  
  override public func willMoveToSuperview(newSuperview: UIView!) {
    if newSuperview != nil {
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidEndEditing", name:UITextFieldTextDidEndEditingNotification, object: self)
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidBeginEditing", name:UITextFieldTextDidBeginEditingNotification, object: self)
    } else {
      NSNotificationCenter.defaultCenter().removeObserver(self)
    }
  }
  
  /**
   The textfield has started an editing session.
   */
  public func textFieldDidBeginEditing() {
    animateViewsForTextEntry()
  }
  
  /**
   The textfield has ended an editing session.
   */
  public func textFieldDidEndEditing() {
    animateViewsForTextDisplay()
  }
  
  // MARK: - Interface Builder
  
  override public func prepareForInterfaceBuilder() {
    drawViewsForRect(frame)
  }
  // MARK: Private
  
  private func updateBorder() {
    borderLayer.frame = rectForBounds(bounds)
    borderLayer.borderWidth = borderSize
    borderLayer.borderColor = (isFirstResponder() || text!.isNotEmpty) ? activeColor.CGColor : inactiveColor.CGColor
  }
  
  private func updateBackground() {
    outerBackgroundView.frame = CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: placeholderHeight))
    outerBackgroundView.backgroundColor = outerBackgroundColor
    
    if !subviews.contains(outerBackgroundView) {
      addSubview(outerBackgroundView)
    }
    
    backgroundColor = .clearColor()
    
    if isFirstResponder() || text!.isNotEmpty {
      layer.backgroundColor = activeInnerBackgroundColor.CGColor
    } else {
      layer.backgroundColor = inactiveColor.CGColor
    }
  }
  
  private func updatePlaceholder() {
    placeholderLabel.frame = placeholderRectForBounds(bounds)
    placeholderLabel.text = placeholder
    placeholderLabel.textAlignment = textAlignment
    
    if isFirstResponder() || text!.isNotEmpty {
      placeholderLabel.font = placeholderFontFromFontAndPercentageOfOriginalSize(font: font!, percentageOfOriginalSize: 0.5)
      placeholderLabel.text = placeholder?.uppercaseString
      placeholderLabel.textColor = activeColor
    } else {
      placeholderLabel.font = placeholderFontFromFontAndPercentageOfOriginalSize(font: font!, percentageOfOriginalSize: 0.7)
      placeholderLabel.textColor = placeholderColor
    }
  }
  
  private func placeholderFontFromFontAndPercentageOfOriginalSize(font font: UIFont, percentageOfOriginalSize: CGFloat) -> UIFont! {
    let smallerFont = UIFont(name: font.fontName, size: font.pointSize * percentageOfOriginalSize)
    return smallerFont
  }
  
  private func rectForBounds(bounds: CGRect) -> CGRect {
    return CGRect(x: bounds.origin.x, y: bounds.origin.y + placeholderHeight, width: bounds.size.width, height: bounds.size.height - placeholderHeight)
  }
  
  private var placeholderHeight : CGFloat {
    return placeHolderInsets.y + placeholderFontFromFontAndPercentageOfOriginalSize(font: font!, percentageOfOriginalSize: 0.7).lineHeight
  }
  
  private func animateViews() {
    UIView.animateWithDuration(0.2, animations: {
      self.placeholderLabel.alpha = 0
      self.placeholderLabel.frame = self.placeholderRectForBounds(self.bounds)
      
      }) { complete in
        self.updatePlaceholder()
        UIView.animateWithDuration(0.3, animations: {
          self.placeholderLabel.alpha = 1
          self.updateBorder()
          self.updateBackground()
        })
    }
  }
  
  // MARK: - TextFieldEffects
  
  public func animateViewsForTextEntry() {
    guard text!.isEmpty else { return }
    
    animateViews()
  }
  
  public func animateViewsForTextDisplay() {
    guard text!.isEmpty else { return }
    
    animateViews()
  }
  
  // MARK: - Overrides
  
  override public var bounds: CGRect {
    didSet {
      updatePlaceholder()
      updateBorder()
      updateBackground()
    }
  }
  
  public func drawViewsForRect(rect: CGRect) {
    updatePlaceholder()
    updateBorder()
    updateBackground()
    
    addSubview(placeholderLabel)
    layer.addSublayer(borderLayer)
  }
  
  public override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
    if isFirstResponder() || text!.isNotEmpty {
      return CGRectMake(placeHolderInsets.x, placeHolderInsets.y, bounds.width, placeholderHeight)
    } else {
      return textRectForBounds(bounds)
    }
  }
  
  public override func editingRectForBounds(bounds: CGRect) -> CGRect {
    return textRectForBounds(bounds)
  }
  
  override public func textRectForBounds(bounds: CGRect) -> CGRect {
    return CGRectOffset(bounds, textFieldInsets.x, textFieldInsets.y + placeholderHeight / 2)
  }
  
  // MARK: - Interface Builder

  
}