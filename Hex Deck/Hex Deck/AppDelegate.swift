//
//  AppDelegate.swift
//  Hex Deck
//
//  Created by PATRICK PERINI on 8/17/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: Class Properties
    static var sharedAppDelegate: AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    static var sharedGameDelegate: GameDelegate {
        return AppDelegate.sharedAppDelegate.gameDelegate
    }
    
    // MARK: Properties
    var window: UIWindow?
    var gameDelegate: GameDelegate = GameDelegate()
}

