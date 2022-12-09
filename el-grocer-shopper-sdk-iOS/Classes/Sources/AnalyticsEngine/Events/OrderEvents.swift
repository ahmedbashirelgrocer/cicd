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

    init(products: [Product], grocery: Grocery?, order: Order?) {
        self.eventCategory = .sendEvent(eventName: AnalyticsEventName.orderPurchased)
        self.metaData = [
            EventParameterKeys.totalOrderAmount : order?.totalValue ?? "",
            EventParameterKeys.paymentMethodId  : order?.payementType ?? "",
            EventParameterKeys.storeId          : grocery?.dbID ?? "",
            EventParameterKeys.typesStoreID     : grocery?.dbID ?? "",
            EventParameterKeys.storeName        : grocery?.name ?? "",
            EventParameterKeys.retailerID       : grocery?.dbID ?? "",
            EventParameterKeys.retailerName     : grocery?.name ?? "",
            EventParameterKeys.products         : self.getProductDic(products: products),
        ]
    }
    
    private func getProductDic(products: [Product]) -> [[String: Any]] {
        let result = products.map { product in
            var dictionary: [String: Any] = [:]
            
            dictionary[EventParameterKeys.productId]        = product.productId
            dictionary[EventParameterKeys.name]             = product.name
            dictionary[EventParameterKeys.categoryID]       = product.categoryId ?? ""
            dictionary[EventParameterKeys.categoryName]     = product.categoryName ?? ""
            dictionary[EventParameterKeys.subcategoryID]    = product.subcategoryId
            dictionary[EventParameterKeys.subcategoryName]  = product.subcategoryName ?? ""
            dictionary[EventParameterKeys.price]            = product.price
            dictionary[EventParameterKeys.brandName]        = product.brandName
            dictionary[EventParameterKeys.brandId]          = product.brandId ?? ""
            dictionary[EventParameterKeys.isSponsored]      = product.isSponsored as? Bool ?? false
            dictionary[EventParameterKeys.isPromotion]      = product.promotion as? Bool ?? false
            dictionary[EventParameterKeys.isRecipe]         = false
            
            return dictionary
        }
        
        return result
    }
}
