//
//  InValidSessionNavigation.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 08/07/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation

class InValidSessionNavigation {
    @discardableResult
    class func CheckErrorCase(_ error : ElGrocerError) -> Bool  {
        if error.code == 401 {
            if UserDefaults.isUserLoggedIn() {
                ElGrocerAlertView.createAlert(localizedString("sign_out_alert_title", comment: ""),
                                              description: localizedString("Msg_InvalidSession", comment: ""),
                                              positiveButton: localizedString("sign_out_alert_yes", comment: ""),
                                              negativeButton:nil,
                                              buttonClickCallback: { (buttonIndex:Int) -> Void in
                                                    let SDKManager = UIApplication.shared.delegate as! SDKManager
                                                    if UIApplication.topViewController() is GenericProfileViewController {
                                                        SDKManager.currentTabBar?.dismiss(animated: false, completion: {
                                                            SDKManager.logoutAndShowEntryView()
                                                            
                                                        })
                                                    }else {
                                                        SDKManager.logoutAndShowEntryView()
                                                    }
                                              }).show()
                return false
            }
        }
        return true
    }
    
    
}
