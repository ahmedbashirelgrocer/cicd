//
//  EventParametersName.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 28/11/2022.
//

import Foundation

// If the enum goes long then its better to move this to module level each module will have their own event params enum
enum EventParameterKeys {
    static let typesStoreID         = "typesStoreId"
    static let retailerID           = "retailerId"
    static let retailerName         = "retailerName"
    static let categoryID           = "categoryId"
    static let categoryName         = "categoryName"
    static let subcategoryID        = "subCategoryId"
    static let subcategoryName      = "subCategoryName"
    static let price                = "price"
    static let brandId              = "brandId"
    static let brandName            = "brandName"
    static let isSponsored          = "isSponsored"
    static let isPromotion          = "isPromotion"
    static let isRecipe             = "isRecipe"
    static let isSmilesSDK          = "isSmilesSDK"
    static let municipality         = "municipality"
    static let products             = "products"
    static let email                = "email"
    static let phone                = "phone"
    static let name                 = "name"
    static let paymentMethodId      = "paymentMethodId"
    static let paymentMethodName    = "paymentMethodName"
    static let totalOrderAmount     = "totalOrderAmount"
    static let grandTotal           = "grandTotal"
    static let productId            = "productId"
    static let productName          = "productName"
    static let promoPrice           = "promoPrice"
    static let quantity             = "quantity"
    static let actionType           = "actionType"
    static let isEnabled            = "isEnabled"
    static let isApplied            = "isApplied"
    static let promoCode            = "promoCode"
    static let realizationId        = "realizationId"
    static let amount               = "amount"
    static let voucherCode          = "voucherCode"
    static let source               = "source"
    static let address              = "address"
    static let apiEndpoint          = "apiEndPoint"
    static let message              = "message"
    static let code                 = "code"
    static let searchQuery          = "searchQuery"
    static let isSuggestion         = "isSuggestion"
    static let parentId             = "parentId"
    static let orderId              = "orderId"
    static let smilesPointsBurnt    = "smilesPointsBurnt"
    static let smilesPointsEarned   = "smilesPointsEarned"
    static let isSmilesEnabled      = "isSmilesEnabled"
    static let isWalletEnabled      = "isWalletEnabled"
    static let isPromoCodeApplied   = "isPromoCodeApplied"
    static let reason               = "reason"
    static let suggestion           = "suggestion"
    static let oosProduct           = "oosProduct"
    static let substituteProduct    = "substituteProduct"
    static let deeplink             = "deeplink"
    static let currentCategoryId    = "currentCategoryId"
    static let currentCategoryName  = "currentCategoryName"
    static let nextCategoryId       = "nextCategoryId"
    static let nextCategoryName     = "nextCategoryName"
    static let isFeatured           = "isFeatured"
    static let zoneId               = "zoneId"
    static let availableStores      = "availableStores"
    static let bannerId             = "bannerId"
    static let title                = "title"
    static let priority             = "priority"
    static let campaignType         = "campaignType"
    static let imageUrl             = "imageUrl"
    static let location             = "bannerLocation"
    static let position             = "position"
    static let sessionId            = "sessionId"
    static let marketType           = "marketType"
    
    static let latitude             = "latitude"
    static let longitude            = "longitude"
    static let loyaltyId            = "loyaltyId"
    static let pushNotifcation      = "pushNotification"
    
    static let attemptCount         = "attemptCount"
    static let isLoggedIn           = "isLoggedIn"
    
    static let language             = "language"
    // CleverTap
    static let msgEmail          = "MSG-email"
    static let msgPush           = "MSG-push"
    static let msgSMS            = "MSG-sms"
    static let msgWhatsApp       = "MSG-whatsapp"
    // A/b testing
    static let authToken            = "authToken"
    static let variant              = "variant"
    static let experimentType       = "experimentType"
    // Tabby
    static let amountPaidWithTabby  = "amountPaidWithTabby"

    static let campaignId       = "campaignId"
    static let storeId       = "storeId"
    static let storeName       = "storeName"
    
    static let marketingEnablers = "marketingEnabler"
    
    static let elWalletRedeem       = "elWalletRedeem"
    static let smilesRedeem         = "smilesRedeem"
    static let id                   = "id"
    
    static let elWalletBalance = "elWalletBalance"
    // Release, address centralisation, payment centralisation
    static let releaseType = "releaseType"
}
