//
//  Device+version.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 22/09/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    
    class func isIOS12() -> Bool {
        
        let systemVersion = UIDevice.current.systemVersion as NSString
        let value = systemVersion.doubleValue
        return (value > 11.0  && value < 13 )
        
    }
    
    
}


