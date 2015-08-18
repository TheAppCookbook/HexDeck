//
//  CardView.swift
//  Hex Deck
//
//  Created by PATRICK PERINI on 8/17/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit

@IBDesignable class CardView: UIView {
    // MARK: Properties
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return self.layer.shadowRadius
        }
        
        set {
            self.layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor {
        get {
            return UIColor(CGColor: self.layer.shadowColor)!
        }
        
        set {
            self.layer.shadowColor = newValue.CGColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return self.layer.shadowOffset
        }
        
        set {
            self.layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: CGFloat {
        get {
            return CGFloat(self.layer.shadowOpacity)
        }
        
        set {
            self.layer.shadowOpacity = Float(newValue)
        }
    }
    
    @IBInspectable var reuseIdentifier: String?
    
    @IBInspectable var dragVertically: Bool = true
    @IBInspectable var dragHorizontally: Bool = true
    @IBInspectable var anchored: Bool = false
    
    private(set) internal var originalOrigin: CGPoint = CGPoint.zeroPoint
    
    internal var tapHandler: ((CGPoint) -> Void)?
    internal var untapHandler: (() -> Void)?
    
    internal var removalHandler: (() -> Void)?
    
    // MARK: Lifecycle Handlers
    override func removeFromSuperview() {
        self.removalHandler?()
        super.removeFromSuperview()
    }
    
    // MARK: Touch Handlers
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.originalOrigin = self.frame.origin
        self.tapHandler?((touches.first as! UITouch).locationInView(self.superview))
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        let touch = touches.first as? UITouch
        if var location = touch?.locationInView(self.superview),
           var previousLocation = touch?.previousLocationInView(self.superview) {
                var frame = self.frame
            
                var newY = frame.origin.y
                if self.dragVertically {
                    newY += location.y - previousLocation.y
                }
                
                var newX = frame.origin.x
                if self.dragHorizontally {
                    newX += location.x - previousLocation.x
                }
                
                frame.origin = CGPoint(x: newX, y: newY)
                self.frame = frame
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        if self.anchored {
            UIView.animateWithDuration(0.33) {
                var frame = self.frame
                frame.origin = self.originalOrigin
                self.frame = frame
            }
        }
        
        self.untapHandler?()
    }
}
