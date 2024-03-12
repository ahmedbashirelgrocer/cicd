//
//  LocalNotificationHandler.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 04/03/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import Foundation
import UIKit

class LocalNotificationHandler: HandlerType {
    
    var handlers = [LocalNotificationHandlerType]()
    
    func handleObject(_ object: AnyObject) -> Bool {
        
        guard let notification  = object as? UILocalNotification else {
            return false
        }
        
        return handlers.contains(where: { (handler) -> Bool in
            return handler.handleLocalNotification(notification)
        })
        
    }
    
    func addHandler(_ handler: LocalNotificationHandlerType) -> LocalNotificationHandler {
        handlers.append(handler)
        return self
    }
    
}
