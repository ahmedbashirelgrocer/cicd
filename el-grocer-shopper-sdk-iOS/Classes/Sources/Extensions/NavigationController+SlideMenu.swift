//
//  NavigationController+SlideMenu.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 02.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

var kSlideMenuViewControllerKey = "SlideMenuViewController"

extension UINavigationController {
    
    var slideMenuViewController: SlideMenuViewController? {
        
        get {
            return (objc_getAssociatedObject(self, &kSlideMenuViewControllerKey) as! SlideMenuViewController)
        }
        
        set(newValue) {
            objc_setAssociatedObject(self, &kSlideMenuViewControllerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.filter({$0.isKind(of: ofClass)}).last {
            popToViewController(vc, animated: animated)
        }
    }

    func pushViewControllerFromLeft(controller: UIViewController){
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        //present(controller, animated: false)
        pushViewController(controller, animated: false)
    }
    
    func popViewControllerToLeft(){
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        //dismiss(animated: false)
        popViewController(animated: false)
    }
    
}
