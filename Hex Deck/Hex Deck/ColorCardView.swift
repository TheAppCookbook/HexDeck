//
//  ColorCardView.swift
//  Hex Deck
//
//  Created by PATRICK PERINI on 8/17/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit

class ColorCardView: CardView {
    // MARK: Properties
    @IBOutlet var hexLabel: UILabel!
    var hex: Int = 0 {
        didSet {
            self.hexLabel.text = NSString(format:"#%06X", self.hex) as? String
            self.backgroundColor = UIColor(hex: self.hex)
            self.hexLabel.textColor = self.backgroundColor?.contrastingColor()
        }
    }
    
    // MARK: Swipe Handlers
    func swipeUp() {
        if let superview = self.superview {
            UIView.animateWithDuration(0.33, animations: {
                self.center = CGPoint(x: self.center.x, y: CGRectGetMinY(superview.frame) - self.bounds.height)
            }, completion: { (finished: Bool) in
                self.removeFromSuperview()
            })
        } else {
            self.removeFromSuperview()
        }
    }
    
    func swipeDown() {
        if let superview = self.superview {
            UIView.animateWithDuration(0.33, animations: {
                self.center = CGPoint(x: self.center.x, y: CGRectGetMaxY(superview.frame) + self.bounds.height)
            }, completion: { (finished: Bool) in
                self.removeFromSuperview()
            })
        } else {
            self.removeFromSuperview()
        }
    }
    
    // MARK: Touch Handlers
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if CGRectGetMidY(self.frame) > (self.frame.height / 2.0) {
            self.swipeDown()
            return
        }
        
        super.touchesEnded(touches, withEvent: event)
    }
}
