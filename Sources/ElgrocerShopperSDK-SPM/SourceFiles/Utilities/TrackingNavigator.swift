//
//  TrackingNavigator.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 08/07/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import UIKit
class TrackingNavigator {
    
    
    class func presentTrackingViewWith(_ trackingURl : String , orderId : String , statusId : String) {
        
        let vc = ElGrocerViewControllers.getEmbededPaymentWebViewController()
        vc.istrackingUrl = true
        vc.isNeedToDismiss = true
        vc.trackingUrl = trackingURl
        
        
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [vc]
        navigationController.setLogoHidden(true)
        navigationController.setBackButtonHidden(true)
        navigationController.modalPresentationStyle = .fullScreen
        
        
        if let topVc = UIApplication.topViewController() {
            ElGrocerEventsLogger.trackOrderTrackingClick(orderId: orderId, statusID: statusId)
            topVc.present(navigationController, animated: true, completion: nil)
        }
        
    }
    
    
}
