//
//  CardStackView.swift
//  Hex Deck
//
//  Created by PATRICK PERINI on 8/17/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit

@objc protocol CardStackViewDataSource: NSObjectProtocol {
    func numberOfCardsInCardStackView(cardStackView: CardStackView) -> Int
    func cardStackView(cardStackView: CardStackView, cardViewAtIndex index: Int) -> CardView
}

class CardStackView: UIView {
    // MARK: Class Properties
    private static let numberOfVisibleCards = 2
    
    // MARK: Properties
    @IBOutlet var dataSource: CardStackViewDataSource?
    
    private var bottomCardView: CardView?
    private var currentCardIndex: Int = 0
    
    private var reuseNibName: String?
    private var queuedReusableCardViews: [CardView] = []

    // MARK: Queueing
    func registerNibForReusableCardView(nibName: String) {
        self.reuseNibName = nibName
        
    }
    
    func dequeueReusableCardView() -> CardView {
        var cardView: CardView?
        for queuedCardView in self.queuedReusableCardViews {
            if queuedCardView.superview == nil {
                cardView = queuedCardView
                break
            }
        }
        
        if cardView == nil {
            assert(self.reuseNibName != nil, "Nib must be register for reuse")
            let nib = UINib(nibName: self.reuseNibName!, bundle: nil)
            
            cardView = (nib.instantiateWithOwner(nil, options: nil)[0] as! CardView)
            self.queuedReusableCardViews.append(cardView!)
        }
        
        cardView?.frame.origin = CGPoint.zeroPoint
        return cardView!
    }
    
    // MARK: Data Handlers
    func reloadData() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        if let dataSource = self.dataSource {
            let numberOfCards = min(dataSource.numberOfCardsInCardStackView(self), CardStackView.numberOfVisibleCards)
            for var index = 0; index < numberOfCards; index++ {
                self.addCardAtIndex(index)
            }
        }
    }
    
    private func cardViewWasRemoved() {
        if let dataSource = self.dataSource {
            let numberOfCards = dataSource.numberOfCardsInCardStackView(self)
            if self.currentCardIndex + 1 <= numberOfCards {
                self.addCardAtIndex(self.currentCardIndex + 1)
            }
        }
    }
    
    private func addCardAtIndex(index: Int) {
        if let dataSource = self.dataSource {
            let cardView = dataSource.cardStackView(self,
                cardViewAtIndex: index)
            
            cardView.removalHandler = { [unowned self] in
                self.cardViewWasRemoved()
            }
            
            if let bottomCardView = self.bottomCardView {
                self.insertSubview(cardView,
                    belowSubview: bottomCardView)
            } else {
                self.addSubview(cardView)
            }
            
            self.bottomCardView = cardView            
            self.currentCardIndex += 1
        }
    }
}
