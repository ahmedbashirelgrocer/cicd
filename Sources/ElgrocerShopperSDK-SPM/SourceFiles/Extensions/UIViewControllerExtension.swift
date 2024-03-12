//
//  UIViewControllerExtension.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 07/10/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
        var arr = array
        guard arr.count > fromIndex else { return arr }
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)
        return arr
    }
    
    //MARK: view will appear swizzling
    @objc func viewDidAppearOverride(_ animated: Bool) {
            self.viewDidAppearOverride(animated) //Incase we need to override this method
            if UIApplication.isElGrocerSDKClass() {
            MixpanelEventLogger.trackCurrentScreenName()
            }
        }

        static func swizzleViewDidAppear() {
        //Make sure This isn't a subclass of UIViewController, So that It applies to all UIViewController childs
//            if self != UIViewController.self {
//                return
//            }
//            let originalSelector = #selector(UIViewController.viewDidAppear(_:))
//            let swizzledSelector = #selector(UIViewController.viewDidAppearOverride(_:))
//            guard let originalMethod = class_getInstanceMethod(self, originalSelector),
//                let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else { return }
//            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
}

func localizedString(_ named: String,
                     tableName: String = "",
                     bundle: Bundle = .resource,
                     value: String = "",
                     comment: String) -> String {
    return NSLocalizedString(named,
                             tableName: tableName,
                             bundle: bundle,
                             value: value,
                             comment: comment)
}
