//
//  EventParametersName.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 28/11/2022.
//

import Foundation

// If the enum goes long then its better to move this to module level each module will have their own event params enum
enum EventParameterKeys {
    static let time             = "time"
    static let storeId          = "storeId"
    static let typesStoreID     = "typesStoreID"
    static let storeName        = "storeName"
    static let retailerID       = "retailerID"
    static let retailerName     = "retailerName"
    static let categoryID       = "categoryID"
    static let categoryName     = "categoryName"
    static let subcategoryID    = "subcategoryID"
    static let subcategoryName  = "subcategoryName"
    static let price            = "price"
    static let brand            = "brand"
    static let isSponsored      = "isSponsored"
    static let isPromotion      = "isPromotion"
    static let isRecipe         = "isRecipe"
    static let onSmilesSDK      = "onSmilesSDK"
    static let municipality     = "municipality"
}
