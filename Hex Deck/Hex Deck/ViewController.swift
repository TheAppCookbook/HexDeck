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
                self.cardStackView.reloadData()
            }
        }
        
        self.cardStackView.dataSource = self
        self.cardStackView.registerNibForReusableCardView("ColorCardView")
    }
}

extension ViewController: CardStackViewDataSource {
    func numberOfCardsInCardStackView(cardStackView: CardStackView) -> Int {
        if let game = AppDelegate.sharedGameDelegate.game {
            return 0xFFFFFF - game.currentCard
        }
        
        return 0
    }
    
    func cardStackView(cardStackView: CardStackView, cardViewAtIndex index: Int) -> CardView {
        let cardView = self.cardStackView.dequeueReusableCardView() as! ColorCardView
        cardView.hex = index
        return cardView
    }
}