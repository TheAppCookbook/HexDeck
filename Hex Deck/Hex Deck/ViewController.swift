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
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: Initializers
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        // Game State Handlers
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "gameWasReset:",
            name: HexGame.WasResetNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "gameOver:",
            name: GameDelegate.DidReceiveGameOverNotification,
            object: nil)
        
        // Drag Handlers
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "cardDragDidBegin:",
            name: GameDelegate.DidReceiveCardDragStartNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "cardDragWasCanceled:",
            name: GameDelegate.DidReceiveCardDragCanceledNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "cardDragDidComplete:",
            name: GameDelegate.DidReceiveCardDragCompletionNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "cardDragDidCollide:",
            name: GameDelegate.DidReceiveCardDragCollisionNotification,
            object: nil)
        
        AppDelegate.sharedGameDelegate.authenticateLocalPlayer() {
            AppDelegate.sharedGameDelegate.joinGlobalMatch() {
                self.cardStackView.reloadData(fromIndex: AppDelegate.sharedGameDelegate.game!.currentCard)
                self.collectionView.reloadData()
            }
        }
        
        self.cardStackView.dataSource = self
        self.cardStackView.delegate = self
        self.cardStackView.registerNibForReusableCardView("ColorCardView")
    }
    
    override func viewDidAppear(animated: Bool) {
        if let game = AppDelegate.sharedGameDelegate.game {
            self.collectionView.reloadData()
            self.cardStackView.reloadData(fromIndex: game.currentCard)
        }
    }
    
    // MARK: Responders
    func gameWasReset(notification: NSNotification!) {
        if GKLocalPlayer.localPlayer().authenticated {
            let alert = UIAlertController(title: "The game was reset!",
                message: "While you were away, the game reset to #000000",
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Drat!",
                style: .Default, handler: nil))
            
            self.presentViewController(alert,
                animated: true,
                completion: nil)
        }
    }
    
    func gameOver(notification: NSNotification!) {
        if let winViewController = self.storyboard?.instantiateViewControllerWithIdentifier("WinViewController") as? WinViewController {
            winViewController.colors = AppDelegate.sharedGameDelegate.game!.localPlayerColors
            AppDelegate.sharedGameDelegate.game!.localPlayerColors = []
            
            self.presentViewController(winViewController,
                animated: true,
                completion: nil)
        }
    }
    
    func cardDragDidBegin(notification: NSNotification!) {
        let userID = notification.object as? String
        if userID == GKLocalPlayer.localPlayer().playerID {
            return
        }
        
        let location = CGPointFromString(notification.userInfo!["location"] as! String)
        self.addTapViewAtPoint(location, forUser: userID!)
    }
    
    func cardDragWasCanceled(notification: NSNotification!) {
        self.removeTapViewsForIdentifiers([notification.object as! String])
    }
    
    func cardDragDidComplete(notification: NSNotification!) {
        let cardIndex = AppDelegate.sharedGameDelegate.game!.currentCard
        
        if (notification.object as? String) == GKLocalPlayer.localPlayer().playerID {
            AppDelegate.sharedGameDelegate.game?.localPlayerColors.append(cardIndex - 1)
            self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
            return
        }
        
        // Reset, if we're out of sync
        if cardIndex != self.cardStackView.currentCardIndex {
            self.cardStackView.reloadData(fromIndex: cardIndex)
            return
        }
        
        if let topCardView = self.cardStackView.topCardView as? ColorCardView {
            topCardView.swipeUp()
        }
    }
    
    func cardDragDidCollide(notification: NSNotification!) {
        if let ripViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RipViewController") as? RipViewController {
            ripViewController.hex = (self.cardStackView.topCardView as! ColorCardView).hex
            self.presentViewController(ripViewController,
                animated: true,
                completion: nil)
        }
        
        (self.cardStackView.topCardView as? ColorCardView)?.hex = 0
        self.cardStackView.reloadData(fromIndex: 0)
    }
    
    // MARK: Tap Handlers
    func addTapViewAtPoint(point: CGPoint, forUser userID: String) {
        let size: CGFloat = 90.0
        var frame = CGRect(x: point.x - (size / 2.0),
            y: point.y - (size / 2.0),
            width: size,
            height: size)
        
        let tapView = TapView(frame: frame)
        tapView.identifier = userID
        tapView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.10)
        
        self.cardStackView.topCardView?.addSubview(tapView)
        
        if userID == GKLocalPlayer.localPlayer().playerID {
            AppDelegate.sharedGameDelegate.cardDragWasStarted(point)
        }
    }
    
    func removeTapViewsForIdentifiers(identifiers: [String]) {
        let tapViews = self.cardStackView.topCardView?.subviews.filter {
            $0.isKindOfClass(TapView.self) &&
            find(identifiers, ($0 as! TapView).identifier) != nil
        } as! [UIView]
        
        for tapView in tapViews  {
            tapView.removeFromSuperview()
        }
    }
}

// MARK: - Card Stack View
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

extension ViewController: CardStackViewDelegate {
    func cardStackView(cardStackView: CardStackView, cardWasTappedAtPoint point: CGPoint) {
        self.addTapViewAtPoint(point, forUser: GKLocalPlayer.localPlayer().playerID)
    }
    
    func cardStackViewCardWasReleased(cardStackView: CardStackView) {
        AppDelegate.sharedGameDelegate.cardDragWasCanceled()
        self.removeTapViewsForIdentifiers([GKLocalPlayer.localPlayer().playerID])
    }
    
    func cardStackView(cardStackView: CardStackView, cardWasSwipedOffFromIndex: Int, swipedDown: Bool) {
        if swipedDown {
            AppDelegate.sharedGameDelegate.cardDragWasCompleted()
        }
    }
}

// MARK: - Collection View
extension ViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let game = AppDelegate.sharedGameDelegate.game {
            return game.localPlayerColors.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CardViewCell",
            forIndexPath: indexPath) as! UICollectionViewCell
        
        let color = AppDelegate.sharedGameDelegate.game!.localPlayerColors.reverse()[indexPath.item]
        
        let cardView = cell.viewWithTag(1) as! CardView
        cardView.backgroundColor = UIColor(hex: color)
        
        let label = cell.viewWithTag(2) as! UILabel
        label.text = String(hex: color)
        
        return cell
    }
}