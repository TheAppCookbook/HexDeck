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
    
    // MARK: Touch Handlers
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as? UITouch
        if var location = touch?.locationInView(self.superview) {
            let yDistance = (location.y - self.originalOrigin.y)
            if yDistance > (self.bounds.height / 2.0) {
                UIView.animateWithDuration(0.33, animations: {
                    self.center = CGPoint(x: self.center.x,
                        y: CGRectGetMaxY(self.superview!.frame) + self.bounds.height)
                }, completion: { (finished: Bool) in
                    self.removeFromSuperview()
                })
                
                return
            }
        }
        
        super.touchesEnded(touches, withEvent: event)
    }
}
