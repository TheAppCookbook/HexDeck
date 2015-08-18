//
//  RipViewController.swift
//  Hex Deck
//
//  Created by PATRICK PERINI on 8/17/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit

class RipViewController: UIViewController {
    // MARK: Properties
    @IBOutlet var cardImageViews: [UIImageView] = []
    @IBOutlet var cardLabel: UILabel!
    @IBOutlet var instructionLabels: [UILabel] = []
    
    var hex: Int = 0x000000 {
        didSet {
            for cardImageView in self.cardImageViews {
                cardImageView.tintColor = UIColor(hex: self.hex)
            }
            
            if let cardLabel = self.cardLabel {
                cardLabel.text = String(hex: self.hex)
            }
            
            self.view.backgroundColor = UIColor(hex: self.hex).contrastingColor()
            for instructionLabel in self.instructionLabels {
                instructionLabel.textColor = self.view.backgroundColor?.contrastingColor()
            }
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hex = self.hex
        self.hex = hex
    }
    
    // MARK: Responders
    @IBAction func tapGestureWasRecognized(gestureRecognizer: UITapGestureRecognizer!) {
        self.presentingViewController?.dismissViewControllerAnimated(true,
            completion: nil)
    }
}
