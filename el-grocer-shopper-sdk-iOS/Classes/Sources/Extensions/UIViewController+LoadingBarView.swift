//
//  UIViewController+LoadingBarView.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 17.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

private var LoadingBarViewKey = "LoadingBarView"
private var LoadingBarViewBottomConstraintKey = "LoadingBarBottomConstraintView"

extension UIViewController {
    
    var loadingBarView:LoadingBarView? {
        
        get {
            
            return objc_getAssociatedObject(self, &LoadingBarViewKey) as? LoadingBarView
        }
        
        set {
            
            objc_setAssociatedObject(self, &LoadingBarViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var loadingBarViewBottomConstraint:NSLayoutConstraint? {
        
        get {
            
            return objc_getAssociatedObject(self, &LoadingBarViewBottomConstraintKey) as? NSLayoutConstraint
        }
        
        set {
            
            objc_setAssociatedObject(self, &LoadingBarViewBottomConstraintKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func addLoadingBarView() {
        
        self.loadingBarView = Bundle.resource.loadNibNamed("LoadingBarView", owner: nil, options: nil)![0] as? LoadingBarView
        self.loadingBarView?.translatesAutoresizingMaskIntoConstraints = false
        self.loadingBarView?.isHidden = true
        
        self.view.addSubview(self.loadingBarView!)
        
        let views:NSDictionary = ["barView": self.loadingBarView!]
        let metrics:NSDictionary = ["barHeight": kLoadingBarViewHeight]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[barView]-(0)-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: views as! [String : AnyObject]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[barView(barHeight)]", options: NSLayoutConstraint.FormatOptions(), metrics: metrics as? [String : AnyObject], views: views as! [String : AnyObject]))
        self.loadingBarViewBottomConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.loadingBarView!, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0)
        self.view.addConstraint(self.loadingBarViewBottomConstraint!)
        self.view.bringSubviewToFront(self.loadingBarView!)
    }
    
    func showLoadingBarView() {
        
        DispatchQueue.main.async {
            self.loadingBarView?.startAnimation()
            self.loadingBarView?.alpha = 0
            self.loadingBarView?.isHidden = false
            
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                
                self.loadingBarView?.alpha = 1
            })
        }
    }
    
    func hideLoadingBarView() {
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.loadingBarView?.alpha = 0
            
        }, completion: { (result:Bool) -> Void in
            
            self.loadingBarView?.isHidden = true
            self.loadingBarView?.stopAnimation()
        }) 
    }
    
    // MARK: View position (with keyboard or without)
    
    func adjustLoadingBarViewPosition(_ keyboardHeight:CGFloat) {
        
        self.view.bringSubviewToFront(self.loadingBarView!)
        self.loadingBarViewBottomConstraint!.constant = keyboardHeight
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
        })
    }
    
}
