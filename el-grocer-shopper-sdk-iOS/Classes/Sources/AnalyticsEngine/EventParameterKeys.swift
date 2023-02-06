//
//  EventParametersName.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 28/11/2022.
//

import Foundation

// If the enum goes long then its better to move this to module level each module will have their own event params enum
enum EventParameterKeys {
    static let storeId          = "storeId"
    static let typesStoreID     = "typesStoreId"
    static let storeName        = "storeName"
    static let retailerID       = "retailerId"
    static let retailerName     = "retailerName"
    static let categoryID       = "categoryId"
    static let categoryName     = "categoryName"
    static let subcategoryID    = "subCategoryId"
    static let subcategoryName  = "subCategoryName"
    static let price            = "price"
    static let brandId          = "brandId"
    static let brandName        = "brandName"
    static let isSponsored      = "isSponsored"
    static let isPromotion      = "isPromotion"
    static let isRecipe         = "isRecipe"
    static let isSmilesSDK      = "isSmilesSDK"
    static let municipality     = "municipality"
    static let products         = "products"
    static let email            = "email"
    static let phone            = "phone"
    static let name             = "name"
    static let paymentMethodId  = "paymentMethodId"
    static let totalOrderAmount = "totalOrderAmount"
    static let productId        = "productId"
    static let productName      = "productName"
    static let promoPrice       = "promoPrice"
    static let quantity         = "quantity"
    static let actionType       = "actionType"
    static let isEnabled        = "isEnabled"
    static let isApplied        = "isApplied"
    static let promoCode        = "promoCode"
    static let realizationId    = "realizationId"
    static let amount           = "amount"
    static let voucherCode      = "voucherCode"
    static let source           = "source"
    static let address          = "address"
    static let apiEndpoint      = "apiEndpoint"
    static let message          = "message"
    static let code             = "code"
    static let searchQuery      = "searchQuery"
    static let isSuggestion     = "isSuggestion"
    static let parentId         = "parentId"
    static let orderId          = "orderId"
    static let smilesPointsBurnt = "smilesPointsBurnt"
    static let smilesPointsEarned = "smilesPointsEarned"
    static let isSmilesEnabled = "isSmilesEnabled"
    static let isWalletEnabled = "isWalletEnabled"
    static let isPromoCodeApplied = "isPromoCodeApplied"
    static let reason           = "reason"
    static let suggestion       = "suggestion"
}
