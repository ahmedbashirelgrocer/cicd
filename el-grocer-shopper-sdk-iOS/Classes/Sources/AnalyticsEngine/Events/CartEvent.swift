//
//  ActiveCartEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 27/11/2022.
//

import Foundation

// MARK: - Cart Created Event
struct CartCreatedEvent: AnalyticsEventType {
    var eventCategory: AnalyticsEventCategory
    var metaData: [String : Any]?

    init(product: Product, activeGrocery: Grocery?) {
        self.eventCategory = .sendEvent(eventName: AnalyticsEventName.cartCreated)
        self.metaData = [
            EventParameterKeys.productId        : product.dbID,
            EventParameterKeys.productName      : product.name ?? "",
            EventParameterKeys.storeId          : activeGrocery?.dbID ?? "",
            EventParameterKeys.typesStoreID     : activeGrocery?.dbID ?? "",
            EventParameterKeys.storeName        : activeGrocery?.name ?? "",
            EventParameterKeys.retailerID       : activeGrocery?.dbID ?? "",
            EventParameterKeys.retailerName     : activeGrocery?.name ?? "",
            EventParameterKeys.price            : product.price,
            EventParameterKeys.brandId          : product.brandId ?? "",
            EventParameterKeys.brandName        : product.brandNameEn ?? "",
            EventParameterKeys.isSponsored      : product.isSponsored as? Bool ?? false,
            EventParameterKeys.isPromotion      : product.promotion as? Bool ?? false,
            EventParameterKeys.isRecipe         : false,
            EventParameterKeys.categoryID       : product.categoryId ?? "",
            EventParameterKeys.categoryName     : product.categoryNameEn ?? "",
            EventParameterKeys.subcategoryID    : product.subcategoryId,
            EventParameterKeys.subcategoryName  : product.subcategoryNameEn ?? ""
        ]
    }
}

// MARK: - Cart Deleted Event
struct CartDeletedEvent: AnalyticsEventType {
    var eventCategory: AnalyticsEventCategory
    var metaData: [String : Any]?

    init(product: Product, activeGrocery: Grocery?) {
        self.eventCategory = .sendEvent(eventName: AnalyticsEventName.cartDeleted)
        self.metaData = [
            EventParameterKeys.productId        : product.dbID,
            EventParameterKeys.productName      : product.name ?? "",
            EventParameterKeys.storeId          : activeGrocery?.dbID ?? "",
            EventParameterKeys.typesStoreID     : activeGrocery?.dbID ?? "",
            EventParameterKeys.storeName        : activeGrocery?.name ?? "",
            EventParameterKeys.retailerID       : activeGrocery?.dbID ?? "",
            EventParameterKeys.retailerName     : activeGrocery?.name ?? "",
            EventParameterKeys.price            : product.price,
            EventParameterKeys.brandId          : product.brandId ?? "",
            EventParameterKeys.brandName        : product.brandNameEn ?? "",
            EventParameterKeys.isSponsored      : product.isSponsored as? Bool ?? false,
            EventParameterKeys.isPromotion      : product.promotion as? Bool ?? false,
            EventParameterKeys.isRecipe         : false,
        ]
    }
}

// MARK: - Cart Updated Event
struct CartUpdatedEvent: AnalyticsEventType {
    var eventCategory: AnalyticsEventCategory
    var metaData: [String : Any]?
    
    init(grocery: Grocery?, product: Product) {
        self.eventCategory = .sendEvent(eventName: AnalyticsEventName.cartUpdated)
        self.metaData = [
            EventParameterKeys.storeId          : grocery?.dbID ?? "",
            EventParameterKeys.storeName        : grocery?.name ?? "",
            EventParameterKeys.typesStoreID     : grocery?.dbID ?? "",
            EventParameterKeys.retailerID       : grocery?.dbID ?? "",
            EventParameterKeys.retailerName     : grocery?.name ?? "",
            EventParameterKeys.categoryID       : product.categoryId ?? "",
            EventParameterKeys.categoryName     : product.categoryNameEn ?? "",
            EventParameterKeys.subcategoryID    : product.subcategoryId,
            EventParameterKeys.subcategoryName  : product.subcategoryNameEn ?? "",
            EventParameterKeys.price            : product.price,
            EventParameterKeys.brandId          : product.brandId ?? "",
            EventParameterKeys.brandName        : product.brandNameEn ?? "",
            EventParameterKeys.productId        : product.dbID,
        ]
    }
}

// MARK: Cart Viewed Event
struct CartViewdEvent: AnalyticsEventType {
    var eventCategory: AnalyticsEventCategory
    var metaData: [String : Any]?
    
    init(grocery: Grocery?) {
        self.eventCategory = .sendEvent(eventName: AnalyticsEventName.cartViewed)
        self.metaData = [
            EventParameterKeys.storeId      : grocery?.dbID ?? "",
            EventParameterKeys.storeName    : grocery?.name ?? "",
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
            EventParameterKeys.storeId          : activeGrocery?.dbID ?? "",
            EventParameterKeys.typesStoreID     : activeGrocery?.dbID ?? "",
            EventParameterKeys.storeName        : activeGrocery?.name ?? "",
            EventParameterKeys.retailerID       : activeGrocery?.dbID ?? "",
            EventParameterKeys.retailerName     : activeGrocery?.name ?? "",
            EventParameterKeys.products         : self.getProductDic(products: products)
        ]
    }
    
    private func getProductDic(products: [Product]) -> [[String: Any]] {
        let result = products.map { product in
            var dictionary: [String: Any] = [:]
            
            dictionary[EventParameterKeys.name]             = product.name ?? ""
            dictionary[EventParameterKeys.productId]        = product.dbID
            dictionary[EventParameterKeys.categoryID]       = product.categoryId ?? ""
            dictionary[EventParameterKeys.categoryName]     = product.categoryNameEn ?? ""
            dictionary[EventParameterKeys.subcategoryID]    = product.subcategoryId
            dictionary[EventParameterKeys.subcategoryName]  = product.subcategoryNameEn ?? ""
            dictionary[EventParameterKeys.price]            = product.price
            dictionary[EventParameterKeys.brandId]          = product.brandId ?? ""
            dictionary[EventParameterKeys.brandName]        = product.brandNameEn ?? ""
            dictionary[EventParameterKeys.isSponsored]      = product.isSponsored as? Bool ?? false
            dictionary[EventParameterKeys.isPromotion]      = product.promotion as? Bool ?? false
            dictionary[EventParameterKeys.isRecipe]         = false
            
            return dictionary
        }
        
        return result
    }
}
