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
            EventParameterKeys.currentCategoryId    : currentStoreCategoryType?.storeTypeid ?? "",
            EventParameterKeys.currentCategoryName  : currentStoreCategoryType?.name ?? "",
            EventParameterKeys.nextCategoryId       : nextStoreCategoryType?.storeTypeid ?? "",
            EventParameterKeys.nextCategoryName     : nextStoreCategoryType?.name ?? "",
        ]
    }
}

struct StoreClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(grocery: Grocery) {
        self.eventType = .track(eventName: AnalyticsEventName.storeClicked)
        self.metaData = [
            EventParameterKeys.retailerID       : grocery.dbID,
            EventParameterKeys.retailerName     : grocery.name ?? "",
            EventParameterKeys.isFeatured       : grocery.featured?.boolValue ?? false,
            EventParameterKeys.parentId         : grocery.parentID.intValue,
            EventParameterKeys.typesStoreID     : grocery.retailerType.stringValue,
            EventParameterKeys.address          : grocery.address ?? "",
        ]
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
        let retailerDictionaryArray = retailers.map { grocery in
            var dictionary: [String: Any] = [:]
            
            dictionary[EventParameterKeys.retailerID] = grocery.dbID
            dictionary[EventParameterKeys.zoneId] = grocery.deliveryZoneId
            dictionary[EventParameterKeys.parentId] = grocery.parentID
            dictionary[EventParameterKeys.typesStoreID] = grocery.retailerType.stringValue
            
            return dictionary
        }
        
        return retailerDictionaryArray
    }
}
