//
//  ActiveCartEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 27/11/2022.
//

import Foundation

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
