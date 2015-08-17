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
    // MARK: Properties
    @IBOutlet var prototypeCardView: CardView?
    @IBOutlet var dataSource: CardStackViewDataSource?
    
    // MARK: Queueing
    func dequeueReusableCardViewWithReuseIdentifer(reuseIdentifier: String) -> CardView {
        return CardView()
    }
    
    // MARK: Data Handlers
    func reloadData() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        if let dataSource = self.dataSource {
            let numberOfCards = dataSource.numberOfCardsInCardStackView(self)
            for var index = 0; index < numberOfCards; index++ {
                self.addSubview(dataSource.cardStackView(self,
                    cardViewAtIndex: index))
            }
        }
        
        println(self.subviews)
    }
}
