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

    init(grocery: Grocery?) {
        self.eventType = .track(eventName: AnalyticsEventName.cartCreated)
        self.metaData = [
            EventParameterKeys.retailerID       : grocery?.dbID ?? "",
            EventParameterKeys.retailerName     : grocery?.name ?? "",
            EventParameterKeys.typesStoreID     : grocery?.retailerType.stringValue ?? "",
        ]
    }
}

// MARK: - Cart Deleted Event
struct CartDeletedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?

    init(grocery: Grocery?) {
        self.eventType = .track(eventName: AnalyticsEventName.cartDeleted)
        self.metaData = [
            EventParameterKeys.typesStoreID     : grocery?.retailerType.stringValue ?? "",
            EventParameterKeys.retailerID       : ElGrocerUtility.sharedInstance.cleanGroceryID(grocery?.dbID),
            EventParameterKeys.retailerName     : grocery?.name ?? "",
        ]
    }
}

// MARK: - Cart Updated Event
// If action is .added "Product Added" event will logged
// If action is .removed "Product Removed" event will logged

enum CartUpdatedEventSource: String {
    case searchResult = "Search Result Screen"
    case viewScreenName = ""
    
    
    func getScreenName() -> String {
            switch self {
            case .searchResult:
                return "Search Result Screen"
            case .viewScreenName:
                return SegmentAnalyticsEngine.instance.getSource()
        }
    }
    
}

struct CartUpdatedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(grocery: Grocery?, product: Product, actionType: CartActionType, quantity: Int, source: CartUpdatedEventSource = .viewScreenName) {
        let eventName = actionType == .added ? AnalyticsEventName.productAdded : AnalyticsEventName.productRemoved
        
        self.eventType = .track(eventName: eventName)
        self.metaData = [
            EventParameterKeys.typesStoreID     : grocery?.retailerType.stringValue ?? "",
            EventParameterKeys.retailerID       : grocery?.dbID ?? "",
            EventParameterKeys.retailerName     : grocery?.name ?? "",
            EventParameterKeys.categoryID       : product.categoryId?.stringValue ?? "",
            EventParameterKeys.categoryName     : product.categoryNameEn ?? "",
            EventParameterKeys.subcategoryID    : product.subcategoryId.stringValue,
            EventParameterKeys.subcategoryName  : product.subcategoryNameEn ?? "",
            EventParameterKeys.price            : product.price.stringValue,
            EventParameterKeys.brandId          : product.brandId?.stringValue ?? "",
            EventParameterKeys.brandName        : product.brandNameEn ?? "",
            EventParameterKeys.productId        : product.productId.stringValue,
            EventParameterKeys.productName      : product.nameEn ?? "",
            EventParameterKeys.promoPrice       : self.promoPrice(product: product),
            EventParameterKeys.isSponsored      : product.isSponsoredProduct,
            EventParameterKeys.isPromotion      : product.promotion?.boolValue ?? false,
            EventParameterKeys.isRecipe         : false,
            EventParameterKeys.quantity         : String(quantity),
            EventParameterKeys.deeplink         : product.queryID ?? "",
            EventParameterKeys.source           : source.getScreenName(),
        ]
    }
    
    // if the isPromotion is false then need to send the actual price in promoPrice
    private func promoPrice(product: Product) -> String {
        let isPromoProduct = product.promotion?.boolValue ?? false
        
        if isPromoProduct {
            return "\(round((product.promoPrice?.doubleValue ?? 0.0) * 100) / 100)"
        }
        
        return product.price.stringValue
    }
}

// MARK: Cart Viewed Event
struct CartViewdEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(grocery: Grocery?) {
        self.eventType = .track(eventName: AnalyticsEventName.cartViewed)
        self.metaData = [
            EventParameterKeys.retailerID      : grocery?.dbID ?? "",
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
            EventParameterKeys.retailerID       : activeGrocery?.dbID ?? "",
            EventParameterKeys.retailerName     : activeGrocery?.name ?? "",
            EventParameterKeys.products         : self.getProductDic(products: products, gorcery: activeGrocery)
        ]
    }
    
    private func getProductDic(products: [Product], gorcery: Grocery?) -> [[String: Any]] {
        let result = products.map { product -> [String: Any] in
            var dictionary: [String: Any] = [:]
            
            let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
            var quantity = 0
            if let basketItem = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: gorcery, context: context) {
                quantity = basketItem.count.intValue
            }
            
            dictionary[EventParameterKeys.productName]      = product.nameEn ?? ""
            dictionary[EventParameterKeys.productId]        = product.productId.stringValue
            dictionary[EventParameterKeys.categoryID]       = product.categoryId?.stringValue ?? ""
            dictionary[EventParameterKeys.categoryName]     = product.categoryNameEn ?? ""
            dictionary[EventParameterKeys.subcategoryID]    = product.subcategoryId.stringValue
            dictionary[EventParameterKeys.subcategoryName]  = product.subcategoryNameEn ?? ""
            dictionary[EventParameterKeys.price]            = product.price.stringValue
            dictionary[EventParameterKeys.brandId]          = product.brandId?.stringValue ?? ""
            dictionary[EventParameterKeys.brandName]        = product.brandNameEn ?? ""
            dictionary[EventParameterKeys.isSponsored]      = product.isSponsoredProduct
            dictionary[EventParameterKeys.isPromotion]      = product.promotion?.boolValue ?? false
            dictionary[EventParameterKeys.quantity]         = String(quantity)
            // if the isPromotion is false then need to send the actual price in promoPrice
            dictionary[EventParameterKeys.promoPrice]       = product.promotion?.boolValue ?? false ? "\(round((product.promoPrice?.doubleValue ?? 0.0) * 100) / 100)" : product.price.stringValue
            
            return dictionary
        }
        
        return result
    }
}

struct MultiCartViewedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.multiCartViewed)
    }
}

struct CartClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(grocery: Grocery?, source: CartUpdatedEventSource = .viewScreenName) {
        self.eventType = .track(eventName: AnalyticsEventName.cartClicked)
        self.metaData = [
            EventParameterKeys.retailerID: grocery?.dbID ?? "",
            EventParameterKeys.retailerName: grocery?.name ?? "",
            EventParameterKeys.source : source.getScreenName()
        ]
    }
}

struct CheckoutStartedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.checkoutStarted)
    }
}

struct MultiCartsClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.multiCartsClicked)
    }
}

struct OTPConfirmedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.otpConfirmed)
    }
}


