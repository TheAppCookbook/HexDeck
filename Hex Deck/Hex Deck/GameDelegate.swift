//
//  GameDelegate.swift
//  Hex Deck
//
//  Created by PATRICK PERINI on 8/17/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit
import GameKit
import SocketRocket

class GameDelegate: NSObject {
    // MARK: Constants
    static let DidReceiveCardDragStartNotification: String = "GameDelegateDidReceiveCardDragStartNotification"
    static let DidReceiveCardDragCanceledNotification: String = "GameDelegateDidReceiveCardDragCanceledNotification"
    static let DidReceiveCardDragCompletionNotification: String = "GameDelegateDidReceiveCardDragCompletionNotification"
    static let DidReceiveCardDragCollisionNotification: String = "GameDelegateDidReceiveCardDragCollisionNotification"
    static let DidReceiveGameOverNotification: String = "GameDelegateDidReceiveGameOverNotification"
    
    // MARK: Properties
    private let socketURL: NSURL = NSURL(string: "ws://10.0.1.7:5000")!
    private var webSocket: SRWebSocket {
        didSet {
            self.webSocket.delegate = self
        }
    }
    
    private var authCompletion: (() -> Void)?
    private var joinCompletion: (() -> Void)?

    private(set) var game: HexGame?
    
    // MARK: Initializers
    override init() {
        self.webSocket = SRWebSocket(URL: self.socketURL)
        super.init()
        
        self.webSocket.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "playerDidAuthenticate:",
            name: GKPlayerAuthenticationDidChangeNotificationName,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Game Responders
    func cardDragWasStarted(point: CGPoint) {
        self.webSocket(self.webSocket, sendMessage: [
            "event": "drag_started",
            "player_id": GKLocalPlayer.localPlayer().playerID,
            "location": NSStringFromCGPoint(point)
        ])
    }
    
    func cardDragWasCanceled() {
        self.webSocket(self.webSocket, sendMessage: [
            "event": "drag_canceled",
            "player_id": GKLocalPlayer.localPlayer().playerID
        ])
    }
    
    func cardDragWasCompleted() {
        self.game?.currentCard
        self.webSocket(self.webSocket, sendMessage: [
            "event": "drag_completed",
            "player_id": GKLocalPlayer.localPlayer().playerID
        ])
    }
}

extension GameDelegate: SRWebSocketDelegate {
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        let eventInfo: NSDictionary = NSJSONSerialization.JSONObjectWithData(message.dataUsingEncoding(NSUTF8StringEncoding)!,
            options: nil,
            error: nil) as! NSDictionary
        
        switch (eventInfo["event"] as! String) {
        case "connection":
            self.game = HexGame(id: NSUUID(UUIDString: eventInfo["game_id"] as! String)!,
                currentCard: eventInfo["current_card"] as! Int)
            
            self.joinCompletion?()
            self.joinCompletion = nil
            
        case "drag_started":
            NSNotificationCenter.defaultCenter().postNotificationName(GameDelegate.DidReceiveCardDragStartNotification,
                object: eventInfo["player_id"],
                userInfo: ["location": eventInfo["location"] as! String])
            
        case "drag_canceled":
            NSNotificationCenter.defaultCenter().postNotificationName(GameDelegate.DidReceiveCardDragCanceledNotification,
                object: eventInfo["player_id"])
            
        case "card_taken":
            self.game?.currentCard = eventInfo["current_card"] as! Int
            NSNotificationCenter.defaultCenter().postNotificationName(GameDelegate.DidReceiveCardDragCompletionNotification,
                object: eventInfo["player_id"])
            
        case "card_collided":
            self.game?.currentCard = eventInfo["current_card"] as! Int
            NSNotificationCenter.defaultCenter().postNotificationName(GameDelegate.DidReceiveCardDragCollisionNotification,
                object: nil)
            
        case "game_over":
            self.game?.currentCard = 0
            NSNotificationCenter.defaultCenter().postNotificationName(GameDelegate.DidReceiveGameOverNotification,
                object: nil)
            
        default:
            println("Unhandled event \(eventInfo)")
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, sendMessage message: AnyObject!) {
        let data = NSJSONSerialization.dataWithJSONObject(message,
            options: nil,
            error: nil)!
        let string = NSString(data: data, encoding: NSUTF8StringEncoding)
        webSocket.send(string)
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        self.webSocket = SRWebSocket(URL: self.socketURL)
        self.webSocket.open()
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        self.webSocket = SRWebSocket(URL: self.socketURL)
        self.webSocket.open()
    }
}

extension GameDelegate { // Authenication Handlers
    func authenticateLocalPlayer(completion: () -> Void) {
        // Unmatched calls will clobber authenticationCompletion
        
        if GKLocalPlayer.localPlayer().authenticated {
            completion()
            return
        }
        
        self.authCompletion = completion
        GKLocalPlayer.localPlayer().authenticateHandler = { (authVC: UIViewController!, error: NSError!) in
            if GKLocalPlayer.localPlayer().authenticated {
                self.authCompletion?()
                self.authCompletion = nil
            } else if authVC != nil {
                let rootVC = UIApplication.sharedApplication().delegate?.window??.rootViewController
                rootVC?.presentViewController(authVC, animated: true) { }
            } else {
                self.authCompletion?()
                self.authCompletion = nil
            }
        }
    }
    
    // MARK: Responders
    func playerDidAuthenticate(notification: NSNotification) {
        self.authCompletion?()
        self.authCompletion = nil
    }
}

extension GameDelegate { // Match Handlers
    func joinGlobalMatch(completion: () -> Void) {
        self.joinCompletion = completion
        self.webSocket.open()
    }
}
