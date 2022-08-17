//
//  Application+Extension.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 15/06/2022.
//

import UIKit

extension UIApplication {
    
    class func topViewController(_ controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(presented)
        }
        
        return controller
    }
    class func gettopViewControllerName(_ controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> String? {
        return FireBaseEventsLogger.gettopViewControllerName(controller)
    }
    
    class func isElGrocerSDKClass() -> Bool {
        if let topVc = UIApplication.topViewController()?.classForCoder {
            let className = "\(topVc)"
            if className.contains("el_grocer_shopper_sdk_iOS.") {
                return true
            }
        }
        return false
    }
    
    
}
