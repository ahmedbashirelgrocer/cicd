//
//  ActiveCartEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 27/11/2022.
//

import Foundation

enum CartActionType: String {
    case added = "Added"
    case removed = "Removed"
}

// MARK: - Cart Created Event
struct CartCreatedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?

    init(product: Product, activeGrocery: Grocery?) {
        self.eventType = .track(eventName: AnalyticsEventName.cartCreated)
        self.metaData = [
            EventParameterKeys.productId        : product.productId,
            EventParameterKeys.productName      : product.name ?? "",
            EventParameterKeys.quantity         : 1,
            EventParameterKeys.brandName        : product.brandName ?? "",
            EventParameterKeys.retailerID       : ElGrocerUtility.sharedInstance.cleanGroceryID(activeGrocery),
            EventParameterKeys.isPromotion      : product.promotion?.boolValue ?? false,
            EventParameterKeys.categoryName     : product.categoryName ?? "",
            EventParameterKeys.subcategoryID    : product.subcategoryId,
            EventParameterKeys.subcategoryName  : product.subcategoryName ?? "",
            EventParameterKeys.isSponsored      : product.isSponsored?.boolValue ?? false,
            EventParameterKeys.brandId          : product.brandId ?? "",
            EventParameterKeys.price            : product.price,
            EventParameterKeys.isRecipe         : false,
            EventParameterKeys.retailerName     : activeGrocery?.name ?? "",
            EventParameterKeys.typesStoreID     : activeGrocery?.retailerType.stringValue ?? "",
            EventParameterKeys.categoryID       : product.categoryId ?? "",
            // if the isPromotion is false then need to send the actual price in promoPrice
            EventParameterKeys.promoPrice       : product.promotion?.boolValue ?? false ? round((product.promoPrice?.doubleValue ?? 0.0) * 100) / 100 : product.price,
            EventParameterKeys.deeplink         : product.queryID ?? "",
        ]
    }
}

// MARK: - Cart Deleted Event
struct CartDeletedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?

    init(product: Product, activeGrocery: Grocery?) {
        self.eventType = .track(eventName: AnalyticsEventName.cartDeleted)
        self.metaData = [
            EventParameterKeys.productId        : product.productId,
            EventParameterKeys.productName      : product.name ?? "",
            EventParameterKeys.typesStoreID     : activeGrocery?.retailerType.stringValue ?? "",
            EventParameterKeys.retailerID       : ElGrocerUtility.sharedInstance.cleanGroceryID(activeGrocery),
            EventParameterKeys.retailerName     : activeGrocery?.name ?? "",
            EventParameterKeys.price            : product.price,
            EventParameterKeys.brandId          : product.brandId ?? "",
            EventParameterKeys.brandName        : product.brandName ?? "",
            EventParameterKeys.isSponsored      : product.isSponsored?.boolValue ?? false,
            EventParameterKeys.isPromotion      : product.promotion?.boolValue ?? false,
            EventParameterKeys.isRecipe         : false,
            // if the isPromotion is false then need to send the actual price in promoPrice
            EventParameterKeys.promoPrice       : product.promotion?.boolValue ?? false ? round((product.promoPrice?.doubleValue ?? 0.0) * 100) / 100 : product.price,
            EventParameterKeys.quantity         : 0,
            EventParameterKeys.categoryID       : product.categoryId ?? "",
            EventParameterKeys.categoryName     : product.categoryName ?? "",
            EventParameterKeys.subcategoryID    : product.subcategoryId,
            EventParameterKeys.subcategoryName  : product.subcategoryName ?? "",
            EventParameterKeys.deeplink         : product.queryID ?? "",
        ]
    }
}

// MARK: - Cart Updated Event
// If action is .added "Product Added" event will logged
// If action is .removed "Product Removed" event will logged
struct CartUpdatedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(grocery: Grocery?, product: Product, actionType: CartActionType, quantity: Int) {
        let eventName = actionType == .added ? AnalyticsEventName.productAdded : AnalyticsEventName.productRemoved
        
        self.eventType = .track(eventName: eventName)
        self.metaData = [
            EventParameterKeys.typesStoreID     : grocery?.retailerType.stringValue ?? "",
            EventParameterKeys.retailerID       : ElGrocerUtility.sharedInstance.cleanGroceryID(grocery),
            EventParameterKeys.retailerName     : grocery?.name ?? "",
            EventParameterKeys.categoryID       : product.categoryId ?? "",
            EventParameterKeys.categoryName     : product.categoryName ?? "",
            EventParameterKeys.subcategoryID    : product.subcategoryId,
            EventParameterKeys.subcategoryName  : product.subcategoryName ?? "",
            EventParameterKeys.price            : product.price,
            EventParameterKeys.brandId          : product.brandId ?? "",
            EventParameterKeys.brandName        : product.brandName ?? "",
            EventParameterKeys.productId        : product.productId,
            EventParameterKeys.productName      : product.name ?? "",
            // if the isPromotion is false then need to send the actual price in promoPrice
            EventParameterKeys.promoPrice       : product.promotion?.boolValue ?? false ? round((product.promoPrice?.doubleValue ?? 0.0) * 100) / 100 : product.price,
            EventParameterKeys.isSponsored      : product.isSponsored?.boolValue ?? false,
            EventParameterKeys.isPromotion      : product.promotion?.boolValue ?? false,
            EventParameterKeys.isRecipe         : false,
            EventParameterKeys.quantity         : quantity,
            EventParameterKeys.deeplink         : product.queryID ?? "",
        ]
    }
}

// MARK: Cart Viewed Event
struct CartViewdEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(grocery: Grocery?) {
        self.eventType = .track(eventName: AnalyticsEventName.cartViewed)
        self.metaData = [
            EventParameterKeys.retailerID      : ElGrocerUtility.sharedInstance.cleanGroceryID(grocery),
            EventParameterKeys.retailerName    : grocery?.name ?? "",
        ]
    }
}

// MARK: Cart Checkout Event
struct CartCheckoutEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(products: [Product], activeGrocery: Grocery?) {
        self.eventType = .track(eventName: AnalyticsEventName.cartCheckout)
        self.metaData = [
            EventParameterKeys.typesStoreID     : activeGrocery?.retailerType.stringValue ?? "",
            EventParameterKeys.retailerID       : ElGrocerUtility.sharedInstance.cleanGroceryID(activeGrocery),
            EventParameterKeys.retailerName     : activeGrocery?.name ?? "",
            EventParameterKeys.products         : self.getProductDic(products: products, gorcery: activeGrocery)
        ]
    }
    
    private func getProductDic(products: [Product], gorcery: Grocery?) -> [[String: Any]] {
        let result = products.map { product in
            var dictionary: [String: Any] = [:]
            
            let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
            var quantity = 0
            if let basketItem = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: gorcery, context: context) {
                quantity = basketItem.count.intValue
            }
            
            dictionary[EventParameterKeys.productName]      = product.name ?? ""
            dictionary[EventParameterKeys.productId]        = product.productId
            dictionary[EventParameterKeys.categoryID]       = product.categoryId ?? ""
            dictionary[EventParameterKeys.categoryName]     = product.categoryName ?? ""
            dictionary[EventParameterKeys.subcategoryID]    = product.subcategoryId
            dictionary[EventParameterKeys.subcategoryName]  = product.subcategoryName ?? ""
            dictionary[EventParameterKeys.price]            = product.price
            dictionary[EventParameterKeys.brandId]          = product.brandId ?? ""
            dictionary[EventParameterKeys.brandName]        = product.brandName ?? ""
            dictionary[EventParameterKeys.isSponsored]      = product.isSponsored?.boolValue ?? false
            dictionary[EventParameterKeys.isPromotion]      = product.promotion?.boolValue ?? false
            dictionary[EventParameterKeys.quantity]         = quantity
            // if the isPromotion is false then need to send the actual price in promoPrice
            dictionary[EventParameterKeys.promoPrice]       = product.promotion?.boolValue ?? false ? round((product.promoPrice?.doubleValue ?? 0.0) * 100) / 100 : product.price
            
            return dictionary
        }
        
        return result
    }
}
