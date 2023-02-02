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
    static let productAdded   = "Product Added"
    static let productRemoved = "Product Removed"
    static let cartDeleted   = "Cart Deleted"
    static let cartViewed    = "Cart Viewed"
    static let cartCheckout  = "Cart Checkout"
    
    // MARK: Order Events
    static let orderPurchased = "Order Purchased"
}
