//
//  HelpshiftRemoteNotificationHandler.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 04/03/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import Foundation

class HelpshiftRemoteNotificationHandler: RemoteNotificationHandlerType {
    
    fileprivate let originKey = "origin"
    fileprivate let helpshiftOriginKey = "helpshift"
    
    func handleRemoteNotification(_ notification: [AnyHashable: Any]) -> Bool {
        
        guard let origin = notification[originKey] as? String , origin == helpshiftOriginKey else {
            return false
        }
        
        // The notification is a helpshift notification so we can handle it
        
//        guard let _ = SDKManager.shared else {
//            return false
//        }
        
        //Helpshift
        /*HelpshiftCore.initialize(with: HelpshiftAll.sharedInstance())
        HelpshiftCore.install(forApiKey: kHelpShiftApiKey, domainName: kHelpShiftDomainName, appID:kHelpShiftAppId)
        
        HelpshiftCore.handleRemoteNotification(notification, with: SDKManager.window?.rootViewController)*/
        
        if UIApplication.shared.applicationState == UIApplication.State.active {
            
            self.notifyHelpshiftChatMessageUnread()
        }
        
        return true
    }
    
    fileprivate func notifyHelpshiftChatMessageUnread() {
        
        UserDefaults.setHelpShiftChatResponseUnread(true)
        NotificationCenter.default.post(name: Notification.Name(rawValue: kHelpshiftChatResponseNotificationKey), object: nil)
        
    }
    
}
