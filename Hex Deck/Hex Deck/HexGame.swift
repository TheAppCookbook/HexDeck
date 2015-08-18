//
//  HexGame.swift
//  Hex Deck
//
//  Created by PATRICK PERINI on 8/17/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit

class HexGame {
    // MARK: Constants
    static let WasResetNotification: String = "HexGameWasResetNotification"
    
    // MARK: Properties
    let id: NSUUID
    var currentCard: Int
    var localPlayerColors: [Int] = [] {
        didSet {
            self.synchronize()
        }
    }
    
    // MARK: Initializers
    init(id: NSUUID, currentCard: Int) {
        self.id = id
        self.currentCard = currentCard
        self.load()
    }
    
    // MARK: Accessors
    func dictionaryValue() -> NSDictionary {
        return [
            "id": self.id.UUIDString,
            "current_card": self.currentCard,
            "local_player_colors": self.localPlayerColors
        ]
    }
    
    // MARK: Save Handlers
    func synchronize() {
        NSUserDefaults.standardUserDefaults().setObject(self.dictionaryValue(), forKey: "HexDeckLastPlayedGame")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func load() {
        if let dictionary = NSUserDefaults.standardUserDefaults().objectForKey("HexDeckLastPlayedGame") as? NSDictionary {
            if dictionary["id"] as! String == self.id.UUIDString {
                self.localPlayerColors = dictionary["local_player_colors"] as! [Int]
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(HexGame.WasResetNotification,
                    object: dictionary)
            }
        }
    }
}
