//
//  ActiveCartEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 27/11/2022.
//

import Foundation

// MARK: Cart Created, Updated and Deleted Event
struct CartAnalyticEvent: AnalyticsEventType {
    var eventCategory: AnalyticsEventCategory
    var metaData: [String : Any]?
    
    init(eventCategory: AnalyticsEventCategory, product: Product, activeGrocery: Grocery?) {
        self.eventCategory = eventCategory
        self.metaData = [
            EventParameterKeys.time             : Date(),
            EventParameterKeys.storeId          : activeGrocery?.dbID ?? "",
            EventParameterKeys.typesStoreID     : "",
            EventParameterKeys.storeName        : activeGrocery?.name ?? "",
            EventParameterKeys.retailerID       : activeGrocery?.dbID ?? "",
            EventParameterKeys.retailerName     : activeGrocery?.name ?? "",
            EventParameterKeys.categoryID       : product.categoryId ?? "",
            EventParameterKeys.categoryName     : product.categoryNameEn ?? "",
            EventParameterKeys.subcategoryID    : product.subcategoryId,
            EventParameterKeys.subcategoryName  : product.subcategoryNameEn ?? "",
            EventParameterKeys.price            : product.price,
            EventParameterKeys.brand            : product.brandId ?? "",
            EventParameterKeys.isSponsored      : product.isSponsored ?? false,
            EventParameterKeys.isPromotion      : product.promotion ?? false,
            EventParameterKeys.isRecipe         : false,
            EventParameterKeys.onSmilesSDK      : SDKManager.shared.launchOptions?.isSmileSDK ?? false,
            EventParameterKeys.municipality     : "",
        ]
    }
}

// MARK: Cart Viewed Event
struct CartViewdEvent: AnalyticsEventType {
    var eventCategory: AnalyticsEventCategory
    var metaData: [String : Any]?
    
    init(storeId: String?) {
        self.eventCategory = .sendEvent(eventName: AnalyticsEventName.cartViewed)
        self.metaData = [
            EventParameterKeys.time: Date(),
            EventParameterKeys.storeId: storeId ?? "",
            EventParameterKeys.onSmilesSDK: SDKManager.isSmileSDK,
            EventParameterKeys.municipality: ""
        ]
    }
}

// MARK: Cart Checkout Event
struct CartCheckoutEvent: AnalyticsEventType {
    var eventCategory: AnalyticsEventCategory
    var metaData: [String : Any]?
    
    init(products: [Product], activeGrocery: Grocery?) {
        self.eventCategory = .sendEvent(eventName: AnalyticsEventName.cartCheckout)
        self.metaData = [
            EventParameterKeys.time             : Date(),
            EventParameterKeys.storeId          : activeGrocery?.dbID ?? "",
            EventParameterKeys.typesStoreID     : "",
            EventParameterKeys.storeName        : activeGrocery?.name ?? "",
            EventParameterKeys.retailerID       : activeGrocery?.dbID ?? "",
            EventParameterKeys.retailerName     : activeGrocery?.name ?? "",
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
