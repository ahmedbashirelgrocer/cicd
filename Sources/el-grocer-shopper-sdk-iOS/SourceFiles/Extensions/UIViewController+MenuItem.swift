//
//  UIViewController+MenuItem.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 02.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

private var MenuItemKey = "MenuItemKey"

extension UIViewController {
    
    var menuItem:MenuItem? {
        
        get {
            
            return objc_getAssociatedObject(self, &MenuItemKey) as? MenuItem
        }
        
        set {
            
            objc_setAssociatedObject(self, &MenuItemKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}

class MenuItem {
    
    fileprivate (set) var title:String
    fileprivate (set) var canShowNotificationDot:Bool = false
    
    init(title:String) {
        
        self.title = title
    }
    
    init(title:String, canShowNotificationDot:Bool) {
        
        self.title = title
        self.canShowNotificationDot = canShowNotificationDot
    }
}
