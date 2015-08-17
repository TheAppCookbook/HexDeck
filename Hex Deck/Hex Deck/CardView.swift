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
    
    private var anchorPoint: CGPoint = CGPoint.zeroPoint
    
    // MARK: Touch Handlers
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.anchorPoint = self.center
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        let touch = touches.first as? UITouch
        if var location = touch?.locationInView(self.superview) {
            if !self.dragVertically {
                location.y = self.center.y
            }
            
            if !self.dragHorizontally {
                location.x = self.center.x
            }
            
            self.center = location
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        if self.anchored {
            self.center = self.anchorPoint
        }
    }
}

extension CardView: NSCopying {
    func copyWithZone(zone: NSZone) -> AnyObject {
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(self))!
    }
}
