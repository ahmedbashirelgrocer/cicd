//
//  StoreEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 08/02/2023.
//

import Foundation

struct StoreCategorySwitchedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(currentStoreCategoryType: StoreType?, nextStoreCategoryType: StoreType?) {
        self.eventType = .track(eventName: AnalyticsEventName.storeCategorySwitched)
        self.metaData = [
            EventParameterKeys.currentCategoryId    : String(currentStoreCategoryType?.storeTypeid ?? -1),
            EventParameterKeys.currentCategoryName  : currentStoreCategoryType?.name ?? "",
            EventParameterKeys.nextCategoryId       : String(nextStoreCategoryType?.storeTypeid ?? -1),
            EventParameterKeys.nextCategoryName     : nextStoreCategoryType?.name ?? "",
        ]
    }
}

enum StoreClickedEventSource: String {
    case smilesHomeScreen = "Smiles Home Screen"
    case searchResultScreen = "Search Result Screen"
    case popularStore = "Popular Store"
    case relatedStore = "Related Store"
    case allStoreScreen = "All Store Screen"
    case elgrocerApp = "Elgrocer Store Selection"
}

struct StoreClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(grocery: Grocery, source: StoreClickedEventSource?) {
        self.eventType = .track(eventName: AnalyticsEventName.storeClicked)
        self.metaData = [
            EventParameterKeys.retailerID       : grocery.dbID,
            EventParameterKeys.retailerName     : grocery.name ?? "",
            EventParameterKeys.isFeatured       : grocery.featured?.boolValue ?? false,
            EventParameterKeys.parentId         : grocery.parentID.stringValue,
            EventParameterKeys.typesStoreID     : grocery.retailerType.stringValue,
            EventParameterKeys.address          : grocery.address ?? "",
        ]
        if source != nil {self.metaData?[EventParameterKeys.source] = source?.rawValue}
    }
}

struct StoresInRangeEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(retailers: [Grocery]?) {
        self.eventType = .track(eventName: AnalyticsEventName.storesInRange)
        self.metaData = [
            EventParameterKeys.availableStores: getAvailableStores(retailers: retailers ?? [])
        ]
    }
    
    private func getAvailableStores(retailers: [Grocery]) -> [[String: Any]] {
        let retailerDictionaryArray = retailers.map { grocery -> [String: Any] in
            var dictionary: [String: Any] = [:]
            
            dictionary[EventParameterKeys.retailerID] = grocery.dbID
            dictionary[EventParameterKeys.zoneId] = grocery.deliveryZoneId
            dictionary[EventParameterKeys.parentId] = grocery.parentID.stringValue
            dictionary[EventParameterKeys.typesStoreID] = grocery.retailerType.stringValue
            
            return dictionary
        }
        
        return retailerDictionaryArray
    }
}

struct CategoryViewAllClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(grocery: Grocery?) {
        self.eventType = .track(eventName: AnalyticsEventName.categoryViewAllClicked)
        self.metaData = [
            EventParameterKeys.retailerID: grocery?.dbID ?? "",
            EventParameterKeys.retailerName: grocery?.name ?? "",
        ]
    }
}

struct ProductCategoryViewAllClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(category: Category?) {
        self.eventType = .track(eventName: AnalyticsEventName.productCategoryViewAllClicked)
        self.metaData = [
            EventParameterKeys.categoryID: category?.dbID.stringValue ?? "",
            EventParameterKeys.categoryName: category?.nameEn ?? "",
        ]
    }
}

struct ProductCategoryClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(category: Category?, varient: String) {
        self.eventType = .track(eventName: AnalyticsEventName.productCategoryClicked)
        self.metaData = [
            EventParameterKeys.categoryID: category?.dbID.stringValue ?? "",
            EventParameterKeys.categoryName: category?.nameEn ?? "",
            EventParameterKeys.variant: varient,
        ]
    }
}

struct ProductSubCategoryClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(subCategory: SubCategory?) {
        self.eventType = .track(eventName: AnalyticsEventName.productSubCategoryClicked)
        self.metaData = [
            EventParameterKeys.subcategoryID: subCategory?.subCategoryId.stringValue ?? "",
            EventParameterKeys.subcategoryName: subCategory?.subCategoryNameEn ?? "",
        ]
    }
}
