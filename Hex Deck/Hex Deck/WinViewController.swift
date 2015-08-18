//
//  WinViewController.swift
//  Hex Deck
//
//  Created by PATRICK PERINI on 8/17/15.
//  Copyright (c) 2015 AppCookbook. All rights reserved.
//

import UIKit

class WinViewController: UIViewController {
    // MARK: Properties
    @IBOutlet var collectionView: UICollectionView!
    var colors: [Int] = [] {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        self.collectionView.reloadData()
    }
    
    // MARK: Responders
    @IBAction func doneButtonWasPressed(sender: UIButton!) {
        self.presentingViewController?.dismissViewControllerAnimated(true,
            completion: nil)
    }
}

extension WinViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CardViewCell",
            forIndexPath: indexPath) as! UICollectionViewCell
        
        let color = self.colors[indexPath.row]
        
        let cardView = cell.viewWithTag(1) as! CardView
        cardView.backgroundColor = UIColor(hex: color)
        
        let label = cell.viewWithTag(2) as! UILabel
        label.text = String(hex: color)
        
        return cell
    }
}
