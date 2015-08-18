//
//  TapView.swift
//  Hex Deck
//
//  Created by PATRICK PERINI on 8/17/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit
import QuartzCore

class TapView: UIView {
    // MARK: Properties
    private var centerView: UIView?
    private var backgroundView: UIView?
    
    var identifier: String = ""
    
    // MARK: Initializers
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = true
        
        // Background View
        self.backgroundView?.removeFromSuperview()
        
        self.backgroundView = UIView(frame: self.bounds)
        self.backgroundView?.backgroundColor = self.backgroundColor
        
        let scaleAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        
        scaleAnimation.duration = 1.0
        scaleAnimation.repeatCount = HUGE
        scaleAnimation.autoreverses = true
        scaleAnimation.fromValue = 0.9
        scaleAnimation.toValue = 0.5
        
        self.backgroundView?.layer.removeAllAnimations()
        self.backgroundView?.layer.addAnimation(scaleAnimation, forKey: nil)
        
        self.backgroundView?.layer.cornerRadius = max(self.frame.width, self.frame.height) / 2.0
        self.backgroundView?.layer.masksToBounds = true
        
        self.addSubview(self.backgroundView!)
        
        // Center View
        self.centerView?.removeFromSuperview()
        
        self.centerView = UIView(frame: CGRectInset(self.bounds, self.bounds.width / 4.0, self.bounds.height / 4.0))
        self.centerView?.backgroundColor = self.backgroundColor?.colorWithAlphaComponent(0.70)
        
        self.centerView?.layer.cornerRadius = max(self.centerView!.frame.width, self.centerView!.frame.height) / 2.0
        self.centerView?.layer.masksToBounds = true
        
        self.addSubview(self.centerView!)
        
        self.backgroundColor = nil
    }
}
