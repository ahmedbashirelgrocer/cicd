//
//  HelpshiftLocalNotificationHandler.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 04/03/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import Foundation
import UIKit

class HelpshiftLocalNotificationHandler: LocalNotificationHandlerType {
    
    fileprivate let originKey = "origin"
    fileprivate let helpshiftOriginKey = "helpshift"
    
    func handleLocalNotification(_ notification: UILocalNotification) -> Bool {
        
        guard let userInfo = notification.userInfo, let origin = userInfo[originKey] as? String , origin == helpshiftOriginKey else {
            return false
        }
        
        // The notification is a helpshift notification so we can handle it
        
        /*guard let SDKManager: SDKManagerType! = sdkManager else {
            return false
        }
        
        //Helpshift
        HelpshiftCore.initialize(with: HelpshiftAll.sharedInstance())
        HelpshiftCore.install(forApiKey: kHelpShiftApiKey, domainName: kHelpShiftDomainName, appID:kHelpShiftAppId)
        
         HelpshiftCore.handle(notification, with: SDKManager.window?.rootViewController)*/
        
        return true
    }
    
}
