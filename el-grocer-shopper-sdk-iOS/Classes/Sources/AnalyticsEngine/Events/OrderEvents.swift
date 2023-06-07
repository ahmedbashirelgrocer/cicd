//
//  OrderEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 29/11/2022.
//

import Foundation

// MARK: Purchase Order Event
struct OrderPurchaseEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?

    init(products: [Product], grocery: Grocery?, order: Order?, isWalletEnabled: Bool, isSmilesEnabled: Bool, isPromoCodeApplied: Bool, smilesPointsEarned: Int, smilesPointsBurnt: Double, realizationId: Int?) {
        self.eventType = .track(eventName: AnalyticsEventName.orderPurchased)
        self.metaData = [
            EventParameterKeys.totalOrderAmount : String(order?.totalValue ?? 0.0),
            EventParameterKeys.paymentMethodId  : order?.payementType?.stringValue ?? "",
            EventParameterKeys.paymentMethodName: PaymentOption(rawValue: UInt32(order?.payementType?.int32Value ?? 0))?.paymentMethodName ?? "",
            EventParameterKeys.typesStoreID     : grocery?.retailerType.stringValue ?? "",
            EventParameterKeys.retailerID       : grocery?.dbID ?? "",
            EventParameterKeys.retailerName     : grocery?.name ?? "",
            EventParameterKeys.parentId         : grocery?.parentID.stringValue ?? "",
            EventParameterKeys.orderId          : order?.dbID.stringValue ?? "",
            EventParameterKeys.isWalletEnabled  : isWalletEnabled,
            EventParameterKeys.isSmilesEnabled  : isSmilesEnabled,
            EventParameterKeys.isPromoCodeApplied: isPromoCodeApplied,
            EventParameterKeys.smilesPointsEarned: String(smilesPointsEarned),
            EventParameterKeys.smilesPointsBurnt: String(smilesPointsBurnt),
            EventParameterKeys.realizationId    : String(realizationId ?? 0),
            EventParameterKeys.products         : self.getProductDic(products: products, gorcery: grocery),
        ]
    }
    
    private func getProductDic(products: [Product], gorcery: Grocery?) -> [[String: Any]] {
        let result = products.map { product -> [String: Any] in
            var dictionary: [String: Any] = [:]
            
            // compute the quantity of product in cart
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
            dictionary[EventParameterKeys.isSponsored]      = product.isSponsored?.boolValue ?? false
            dictionary[EventParameterKeys.isPromotion]      = product.promotion?.boolValue ?? false
            dictionary[EventParameterKeys.isRecipe]         = false
            dictionary[EventParameterKeys.quantity]         = String(quantity)
            // if the isPromotion is false then need to send the actual price in promoPrice
            dictionary[EventParameterKeys.promoPrice]       = product.promotion?.boolValue ?? false ? "\(round((product.promoPrice?.doubleValue ?? 0.0) * 100) / 100)" : product.price.stringValue
            
            return dictionary
        }
        
        return result
    }
}

struct OrderEditClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(order: Order, grocery: Grocery?, products: [Product]) {
        self.eventType = .track(eventName: AnalyticsEventName.orderEditClicked)
        self.metaData = [
            EventParameterKeys.orderId: order.dbID.stringValue,
            EventParameterKeys.retailerID: grocery?.dbID ?? "",
            EventParameterKeys.products: self.getProductDic(products: products, gorcery: grocery)
        ]
    }
    
    private func getProductDic(products: [Product], gorcery: Grocery?) -> [[String: Any]] {
        let result = products.map { product in
            var dictionary: [String: Any] = [:]
            
            // coputing the quantity of products
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
            dictionary[EventParameterKeys.isSponsored]      = product.isSponsored?.boolValue ?? false
            dictionary[EventParameterKeys.isPromotion]      = product.promotion?.boolValue ?? false
            dictionary[EventParameterKeys.quantity]         = String(quantity)
            // if the isPromotion is false then need to send the actual price in promoPrice
            dictionary[EventParameterKeys.promoPrice]       = product.promotion?.boolValue ?? false ? "\(round((product.promoPrice?.doubleValue ?? 0.0) * 100) / 100)" : product.price.stringValue
            
            return dictionary
        }
        
        return result
    }
}

struct OrderDetailsClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(order: Order) {
        self.eventType = .track(eventName: AnalyticsEventName.orderDetailsClicked)
        self.metaData = [
            EventParameterKeys.orderId: order.dbID.stringValue
        ]
    }
}

struct OrderCancelledEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(orderId: String, reason: String, suggestion: String) {
        self.eventType = .track(eventName: AnalyticsEventName.orderCancelled)
        self.metaData = [
            EventParameterKeys.orderId: orderId,
            EventParameterKeys.reason: reason,
            EventParameterKeys.suggestion: suggestion,
        ]
    }
}

struct OrderSubstitutionCompletedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(orderId: String) {
        self.eventType = .track(eventName: AnalyticsEventName.orderSubstitutionCompleted)
        self.metaData = [
            EventParameterKeys.orderId: orderId,
        ]
    }
}

struct EditOrderCompletedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(order: Order?, grocery: Grocery?) {
        self.eventType = .track(eventName: AnalyticsEventName.editOrderCompleted)
        self.metaData = [
            EventParameterKeys.orderId: order?.dbID.stringValue ?? "",
            EventParameterKeys.retailerID: ElGrocerUtility.sharedInstance.cleanGroceryID(grocery?.dbID),
        ]
    }
}

struct CancelOrderClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(orderId: String) {
        self.eventType = .track(eventName: AnalyticsEventName.orderCancelClicked)
        self.metaData = [
            EventParameterKeys.orderId: orderId,
        ]
    }
}

struct RepeatOrderClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(order: Order?, grocery: Grocery?) {
        self.eventType = .track(eventName: AnalyticsEventName.repeatOrderClicked)
        self.metaData = [
            EventParameterKeys.orderId: order?.dbID.stringValue ?? "",
            EventParameterKeys.retailerID: ElGrocerUtility.sharedInstance.cleanGroceryID(grocery?.dbID),
            
        ]
    }
}

struct ChooseReplacementClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(order: Order?, grocery: Grocery?) {
        self.eventType = .track(eventName: AnalyticsEventName.chooseReplacementClicked)
        self.metaData = [
            EventParameterKeys.orderId: order?.dbID.stringValue ?? "",
            EventParameterKeys.retailerID: ElGrocerUtility.sharedInstance.cleanGroceryID(grocery?.dbID),
        ]
    }
}

struct ItemReplacedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(oosProduct: Product, choosedProduct: Product) {
        self.eventType = .track(eventName: AnalyticsEventName.itemReplaced)
        self.metaData = [
            EventParameterKeys.oosProduct: self.getProductDictionary(product: oosProduct),
            EventParameterKeys.substituteProduct: self.getProductDictionary(product: choosedProduct),
        ]
    }
    
    private func getProductDictionary(product: Product) -> [String: Any] {
        return [
            EventParameterKeys.productId        : product.productId.stringValue,
            EventParameterKeys.productName      : product.nameEn ?? "",
        ]
    }
}

struct OTPAttemptsEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(message: String) {
        self.eventType = .track(eventName: AnalyticsEventName.otpAttempts)
        self.metaData = [
            EventParameterKeys.attemptCount: message,
        ]
    }
}

