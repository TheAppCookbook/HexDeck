//
//  ViewController.swift
//  Hex Deck
//
//  Created by PATRICK PERINI on 8/17/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController {
    // MARK: Properties
    @IBOutlet var cardStackView: CardStackView!
    
    // MARK: Lifecycle
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        AppDelegate.sharedGameDelegate.authenticateLocalPlayer() {
            AppDelegate.sharedGameDelegate.joinGlobalMatch() {
            }
        }
        
        self.cardStackView.dataSource = self
        self.cardStackView.reloadData()
    }
}

extension ViewController: CardStackViewDataSource {
    func numberOfCardsInCardStackView(cardStackView: CardStackView) -> Int {
        return 5
    }
    
    func cardStackView(cardStackView: CardStackView, cardViewAtIndex index: Int) -> CardView {
        return self.cardStackView.prototypeCardView?.copy() as! CardView
    }
}