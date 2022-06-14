//
//  NotificationHandlerType.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 04/03/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import Foundation

protocol RemoteNotificationHandlerType {
    
    func handleRemoteNotification(_ notification: [AnyHashable: Any]) -> Bool
    
}
