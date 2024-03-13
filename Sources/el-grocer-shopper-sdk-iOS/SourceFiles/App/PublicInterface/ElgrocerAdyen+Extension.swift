//
//  ElgrocerAdyen+Extension.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 20/09/2023.
//

import Foundation
import Adyen
import AdyenActions


public extension ElGrocer {
    
    static func HandleAdyenUrl(_ url : URL) -> Bool {
        return RedirectComponent.applicationDidOpen(from: url)
    }
    
}


