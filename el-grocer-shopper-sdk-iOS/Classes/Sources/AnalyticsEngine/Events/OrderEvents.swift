//
//  OrderEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 29/11/2022.
//

import Foundation

// MARK: Purchase Order Event
struct OrderPurchaseEvent: AnalyticsEventType {
    var eventCategory: AnalyticsEventCategory
    var metaData: [String : Any]?
    
    init(products: [Product], grocery: Grocery?) {
        self.eventCategory = .sendEvent(eventName: AnalyticsEventName.orderPurchase)
        self.metaData = [
            EventParameterKeys.time             : Date(),
            EventParameterKeys.storeId          : grocery?.dbID ?? "",
            EventParameterKeys.typesStoreID     : "",
            EventParameterKeys.storeName        : grocery?.name ?? "",
            EventParameterKeys.retailerID       : grocery?.dbID ?? "",
            EventParameterKeys.retailerName     : grocery?.name ?? "",
            EventParameterKeys.isRecipe         : false,
            EventParameterKeys.onSmilesSDK      : SDKManager.shared.launchOptions?.isSmileSDK ?? false,
            EventParameterKeys.municipality     : "",
            EventParameterKeys.products         : self.getProductDic(products: products)
        ]
    }
    
    private func getProductDic(products: [Product]) -> [[String: Any]] {
        var result: [[String: Any]] = []
        
        products.forEach { product in
            var dictionary: [String: Any] = [:]
            
            dictionary[EventParameterKeys.categoryID]       = product.categoryId ?? ""
            dictionary[EventParameterKeys.categoryName]     = product.categoryNameEn ?? ""
            dictionary[EventParameterKeys.subcategoryID]    = product.subcategoryId
            dictionary[EventParameterKeys.subcategoryName]  = product.subcategoryNameEn ?? ""
            dictionary[EventParameterKeys.price]            = product.price
            dictionary[EventParameterKeys.brand]            = product.brandId ?? ""
            dictionary[EventParameterKeys.isSponsored]      = product.isSponsored ?? false
            dictionary[EventParameterKeys.isPromotion]      = product.promotion ?? false
            
            result.append(dictionary)
        }
        
        return result
    }
}

// MARK: Identify User Event
struct IdentifyUserEvent: AnalyticsEventType {
    var eventCategory: AnalyticsEventCategory
    var metaData: [String : Any]?

    init(user: UserProfile?) {
        self.eventCategory = .identifyUser(userID: String(user?.dbID.intValue ?? -1))
        self.metaData = [
            EventParameterKeys.email: user?.email ?? "",
            EventParameterKeys.mobileNumber: user?.phone ?? ""
        ]
    }
}
