//
//  AnalyticsEventName.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 28/11/2022.
//

import Foundation

enum AnalyticsEventName {
    
    // MARK: Cart Events
    static let cartCreated   = "Cart Created"
    static let cartUpdated   = "Cart Updated"
    static let cartDeleted   = "Cart Deleted"
    static let cartViewed    = "Cart Viewed"
    static let cartCheckout  = "Cart Checkout"
    
    // MARK: Order Events
    static let orderPurchase = "Purchase Order"
}
