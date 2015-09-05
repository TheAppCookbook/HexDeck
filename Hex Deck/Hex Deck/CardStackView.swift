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

@objc protocol CardStackViewDelegate: NSObjectProtocol {
    optional func cardStackView(cardStackView: CardStackView, cardWasTappedAtPoint point: CGPoint)
    optional func cardStackViewCardWasReleased(cardStackView: CardStackView)
    optional func cardStackView(cardStackView: CardStackView, cardWasSwipedOffFromIndex: Int, swipedDown: Bool)
}

class CardStackView: UIView {
    // MARK: Class Properties
    private static let numberOfVisibleCards = 2
    
    // MARK: Properties
    @IBOutlet var dataSource: CardStackViewDataSource?
    @IBOutlet var delegate: CardStackViewDelegate?
    
    private(set) var topCardView: CardView?
    private(set) var bottomCardView: CardView?
    
    var currentCardIndex: Int = 0
    
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
        
        cardView?.frame = self.bounds
        
        let subviews = cardView?.subviews.filter { $0.isKindOfClass(TapView.self) }
        for subview in subviews ?? [] {
            subview.removeFromSuperview()
        }
        
        return cardView!
    }
    
    // MARK: Data Handlers
    func reloadData(fromIndex index: Int) {
        for subview in self.subviews {
            (subview as? CardView)?.removalHandler = nil
            subview.removeFromSuperview()
        }
        
        if let dataSource = self.dataSource {
            let numberOfCards = min(dataSource.numberOfCardsInCardStackView(self), CardStackView.numberOfVisibleCards) + index
            for var index = index; index < numberOfCards; index++ {
                self.addCardAtIndex(index)
            }
        }
    }
    
    private func cardViewWasRemoved(cardView: CardView) {
        if let delegate = self.delegate {
            let swipedDown = cardView.frame.origin.y >= 0
            delegate.cardStackView?(self, cardWasSwipedOffFromIndex: self.currentCardIndex, swipedDown: swipedDown)
        }
        
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
            
            cardView.tapHandler = { [unowned self] (location: CGPoint) in
                self.delegate?.cardStackView?(self, cardWasTappedAtPoint: location)
            }
            
            cardView.untapHandler = { [unowned self] in
                self.delegate?.cardStackViewCardWasReleased?(self)
            }
            
            cardView.removalHandler = { [unowned self] in
                self.cardViewWasRemoved(cardView)
            }
            
            if let bottomCardView = self.bottomCardView {
                self.insertSubview(cardView,
                    belowSubview: bottomCardView)
            } else {
                self.addSubview(cardView)
            }
            
            self.topCardView = self.bottomCardView
            self.bottomCardView = cardView
            
            self.currentCardIndex = index
        }
    }
}
