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
    // MARK: Lifecycle
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        AppDelegate.sharedGameDelegate.authenticateLocalPlayer() {
            AppDelegate.sharedGameDelegate.joinGlobalMatch()
        }
    }
}

