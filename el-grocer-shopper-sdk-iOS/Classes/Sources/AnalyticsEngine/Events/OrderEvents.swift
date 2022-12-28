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

    init(products: [Product], grocery: Grocery?, order: Order?) {
        self.eventType = .track(eventName: AnalyticsEventName.orderPurchased)
        self.metaData = [
            EventParameterKeys.totalOrderAmount : order?.totalValue ?? "",
            EventParameterKeys.paymentMethodId  : order?.payementType ?? "",
            EventParameterKeys.typesStoreID     : grocery?.retailerType ?? "",
            EventParameterKeys.retailerID       : grocery?.dbID ?? "",
            EventParameterKeys.retailerName     : grocery?.name ?? "",
            EventParameterKeys.products         : self.getProductDic(products: products, gorcery: grocery),
        ]
    }
    
    private func getProductDic(products: [Product], gorcery: Grocery?) -> [[String: Any]] {
        let result = products.map { product in
            var dictionary: [String: Any] = [:]
            
            // compute the quantity of product in cart
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
            dictionary[EventParameterKeys.isSponsored]      = product.isSponsored as? Bool ?? false
            dictionary[EventParameterKeys.isPromotion]      = product.promotion as? Bool ?? false
            dictionary[EventParameterKeys.isRecipe]         = false
            dictionary[EventParameterKeys.quantity]         = quantity
            // if the isPromotion is false then need to send the actual price in promoPrice
            dictionary[EventParameterKeys.promoPrice]       = product.promotion as? Bool ?? false ? round((product.promoPrice?.doubleValue ?? 0.0) * 100) / 100 : product.price
            
            return dictionary
        }
        
        return result
    }
}
