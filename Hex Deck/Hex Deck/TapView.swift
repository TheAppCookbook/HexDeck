//
//  TapView.swift
//  Hex Deck
//
//  Created by PATRICK PERINI on 8/17/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit

class TapView: UIView {
    // MARK: Properties
    private var centerView: UIView?
    var identifier: String = ""
    
    // MARK: Initializers
    override func layoutSubviews() {
        super.layoutSubviews()
        self.centerView?.removeFromSuperview()
        
        self.centerView = UIView(frame: CGRectInset(self.bounds, self.bounds.width / 3.0, self.bounds.height / 3.0))
        self.centerView?.backgroundColor = self.backgroundColor?.colorWithAlphaComponent(0.70)
        
        self.addSubview(self.centerView!)
    }
    
    // MARK: Drawing Handlers
    override func drawRect(rect: CGRect) {
        self.centerView?.layer.cornerRadius = max(self.centerView!.frame.width, self.centerView!.frame.height) / 2.0
        self.centerView?.layer.masksToBounds = true
        
        self.layer.cornerRadius = max(self.frame.width, self.frame.height) / 2.0
        self.layer.masksToBounds = true
        
        super.drawRect(rect)
    }
}
