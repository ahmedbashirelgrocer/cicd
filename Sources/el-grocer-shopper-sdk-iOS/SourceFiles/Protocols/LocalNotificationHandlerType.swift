//
//  LocalNotificationHandlerType.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 04/03/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import Foundation
import UIKit

protocol LocalNotificationHandlerType {
    
    func handleLocalNotification(_ notification: UILocalNotification) -> Bool
    
}
