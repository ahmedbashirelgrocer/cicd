//
//  RemoteNotificationHandler.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 04/03/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import Foundation

/** The base class that composes specialized remote notification handlers */
class RemoteNotificationHandler: HandlerType {
    
    fileprivate var handlers = [RemoteNotificationHandlerType]()
    
    func handleObject(_ object: AnyObject) -> Bool {
        
        guard let notification  = object as? [AnyHashable: Any] else {
            return false
        }
        
        return handlers.contains(where: { (handler) -> Bool in
            return handler.handleRemoteNotification(notification)
        })
        
    }
    
    func addHandler(_ handler: RemoteNotificationHandlerType) -> RemoteNotificationHandler {
        handlers.append(handler)
        return self
    }
    
}
