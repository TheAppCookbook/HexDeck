//
//  UIColor+Hex.swift
//  Hex Deck
//
//  Created by PATRICK PERINI on 8/17/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: Int) {
        self.init(red: CGFloat(hex & 0xFF0000) / 255.0,
            green: CGFloat(hex & 0x00FF00) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: 1.0)
    }
    
    func contrastingColor() -> UIColor {
        var lightness: CGFloat = 0.0
        self.getWhite(&lightness,
            alpha: nil)          
        return (lightness > 0.50) ? UIColor.blackColor() : UIColor.whiteColor()
    }
}
