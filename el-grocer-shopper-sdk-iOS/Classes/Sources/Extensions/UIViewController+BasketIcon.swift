//
//  UIViewController+BasketIcon.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 10.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

private var BasketIconKey = "BasketIconKey"

extension UIViewController {
    
    var basketIconOverlay:BasketIconOverlayView? {
        
        get {
            
            return objc_getAssociatedObject(self, &BasketIconKey) as? BasketIconOverlayView
        }
        
        set {
            
            objc_setAssociatedObject(self, &BasketIconKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func addBasketIconOverlay(_ delegate:BasketIconOverlayViewProtocol?, grocery:Grocery?, shouldShowGroceryActiveBasket:Bool?) {
        
        self.basketIconOverlay?.removeFromSuperview()
        
        self.basketIconOverlay = Bundle.resource.loadNibNamed("BasketIconOverlayView", owner: nil, options: nil)![0] as? BasketIconOverlayView
        self.basketIconOverlay?.translatesAutoresizingMaskIntoConstraints = false
        self.basketIconOverlay?.delegate = delegate
        self.basketIconOverlay?.grocery = grocery
        self.basketIconOverlay?.shouldShowGroceryActiveBasket = shouldShowGroceryActiveBasket
        //self.basketIconOverlay!.refreshStatus()
        
        self.view.addSubview(self.basketIconOverlay!)
        
        let views:NSDictionary = ["basketView": self.basketIconOverlay!]
        let metrics:NSDictionary = ["basketHeight": kBasketIconOverlayViewHeight]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[basketView]-(0)-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: views as! [String : AnyObject]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[basketView(basketHeight)]-(0)-|", options: NSLayoutConstraint.FormatOptions(), metrics: metrics as? [String : AnyObject], views: views as! [String : AnyObject]))
    }
    
    func refreshBasketIconStatus() {
        self.basketIconOverlay!.refreshStatus(self)
        
    }
}
