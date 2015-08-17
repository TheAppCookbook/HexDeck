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
    // MARK: Properties
    private var webSocket: SRWebSocket
    private var authCompletion: (() -> Void)?

    var game: HexGame?
    
    // MARK: Initializers
    override init() {
        self.webSocket = SRWebSocket(URL: NSURL(string: "ws://localhost:5000")!)
        
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
}

extension GameDelegate: SRWebSocketDelegate {
    func webSocketDidOpen(webSocket: SRWebSocket!) {
    
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        let eventInfo: NSDictionary = NSJSONSerialization.JSONObjectWithData(message.dataUsingEncoding(NSUTF8StringEncoding)!,
            options: nil,
            error: nil) as! NSDictionary
        
        switch (eventInfo["event"] as! String) {
        case "connection":
            self.game = HexGame(id: NSUUID(UUIDString: eventInfo["game_id"] as! String)!,
                currentCard: eventInfo["current_card"] as! Int)
            
            println(self.game?.currentCard)
            sleep(3)
            self.webSocket(webSocket, sendMessage: ["event": "drag_completed", "player_id": GKLocalPlayer.localPlayer().playerID])
            
        case "card_taken":
            self.game?.currentCard = eventInfo["current_card"] as! Int
            println(self.game?.currentCard)
            
        default:
            println("Unhandled event \(eventInfo)")
        }
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceivePong pongPayload: NSData!) {
        
    }
    
    func webSocket(webSocket: SRWebSocket!, sendMessage message: AnyObject!) {
        let data = NSJSONSerialization.dataWithJSONObject(message,
            options: nil,
            error: nil)!
        let string = NSString(data: data, encoding: NSUTF8StringEncoding)
        webSocket.send(string)
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
            if authVC != nil {
                let rootVC = UIApplication.sharedApplication().delegate?.window??.rootViewController
                rootVC?.presentViewController(authVC, animated: true) {
                    GKLocalPlayer.localPlayer().authenticateHandler = nil
                }
            } else {
                self.authCompletion?()
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
    func joinGlobalMatch() {
        self.webSocket.open()
    }
}
