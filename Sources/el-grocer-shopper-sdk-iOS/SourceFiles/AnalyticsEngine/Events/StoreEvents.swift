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

enum StoreComponentMarketingEnablers: String {
    case Neighbourhood_Stores = "Neighborhood Favorites"
    case One_Click_Re_Order = "One Click Re-Order"
    case All_Available_Stores = "All Available Stores"
    case none = "None"
}
//position is set to -1 for search and other controllers to represent no position
//position will only be sent for home page and view all retailers
struct StoreClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(grocery: Grocery, source: String?, section: StoreComponentMarketingEnablers, position: Int = -1) {
        self.eventType = .track(eventName: AnalyticsEventName.storeClicked)
        self.metaData = [
            EventParameterKeys.retailerID       : grocery.dbID,
            EventParameterKeys.retailerName     : grocery.name ?? "",
            EventParameterKeys.isFeatured       : grocery.featured?.boolValue ?? false,
            EventParameterKeys.parentId         : grocery.parentID.stringValue,
            EventParameterKeys.typesStoreID     : grocery.retailerType.stringValue,
            EventParameterKeys.address          : grocery.address ?? "",
            EventParameterKeys.marketingEnablers  : section.rawValue,
            EventParameterKeys.position  : String(position)
        ]
        if source != nil {self.metaData?[EventParameterKeys.source] = source}
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
    
    init(category: CategoryDTO?,isCustomCategory: Bool = false, source: ScreenName, grocery: Grocery) {
        self.eventType = .track(eventName: AnalyticsEventName.productCategoryClicked)
        self.metaData = [
            EventParameterKeys.categoryID: String(category?.id ?? 0),
            EventParameterKeys.categoryName: category?.slug ?? "",
            EventParameterKeys.isCustomCategory: isCustomCategory,
            EventParameterKeys.retailerID: grocery.getCleanGroceryID(),
            EventParameterKeys.retailerName: grocery.name ?? "",
            EventParameterKeys.retailerGroupId: grocery.groupId.stringValue,
            EventParameterKeys.source: source.rawValue
        ]
    }
}

struct ProductSubCategoryClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(subCategory: SubCategory?, grocery: Grocery) {
        self.eventType = .track(eventName: AnalyticsEventName.productSubCategoryClicked)
        self.metaData = [
            EventParameterKeys.subcategoryID: subCategory?.subCategoryId.stringValue ?? "",
            EventParameterKeys.subcategoryName: subCategory?.subCategoryNameEn ?? "",
            EventParameterKeys.retailerID: grocery.getCleanGroceryID(),
            EventParameterKeys.retailerName: grocery.name ?? ""
            
        ]
    }
}

struct StoreCategoryClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(storeType: StoreType, screenName: String) {
        self.eventType = .track(eventName: AnalyticsEventName.storeCategoryClicked)
        self.metaData = [
            EventParameterKeys.categoryID: String(storeType.storeTypeid),
            EventParameterKeys.categoryName: storeType.name ?? "",
            EventParameterKeys.source: screenName
        ]
    }
}

struct StoreBuyItAgainViewAllClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(grocery: Grocery, source: ScreenName) {
        self.eventType = .track(eventName: AnalyticsEventName.buyItAgainViewAll)
        self.metaData = [
            EventParameterKeys.retailerID: grocery.getCleanGroceryID(),
            EventParameterKeys.retailerName: grocery.name ?? "",
            EventParameterKeys.source: source.rawValue
        ]
    }
}

struct ShoppingListClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(grocery: Grocery) {
        self.eventType = .track(eventName: AnalyticsEventName.shoppingListClicked)
        self.metaData = [
            EventParameterKeys.retailerID: grocery.getCleanGroceryID(),
            EventParameterKeys.retailerName: grocery.name ?? "",
            EventParameterKeys.retailerGroupId: grocery.groupId
        ]
    }
}

struct SlotSelectedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(grocery: Grocery, slot: DeliverySlotDTO, source: ScreenName) {
        self.eventType = .track(eventName: AnalyticsEventName.deliverySlotSelected)
        self.metaData = [
            EventParameterKeys.retailerID: grocery.getCleanGroceryID(),
            EventParameterKeys.retailerName: grocery.name ?? "",
            EventParameterKeys.id: String(slot.id),
            EventParameterKeys.slotUsid: String(slot.usid ?? 0),
            EventParameterKeys.source: source.rawValue
        ]
    }
}

struct StoreCustomCampaignClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(grocery: Grocery, campaignId: String) {
        self.eventType = .track(eventName: AnalyticsEventName.storeCustomCampaignClicked)
        self.metaData = [
            EventParameterKeys.retailerID: grocery.getCleanGroceryID(),
            EventParameterKeys.retailerName: grocery.name ?? "",
            EventParameterKeys.retailerGroupId: grocery.groupId,
            EventParameterKeys.campaignId: campaignId
        ]
    }
}

struct StoreFilterButtonClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(grocery: Grocery, category: CategoryDTO, subcategory: SubCategory?) {
        self.eventType = .track(eventName: AnalyticsEventName.storeFilterButtonClicked)
        self.metaData = [
            EventParameterKeys.retailerID: grocery.getCleanGroceryID(),
            EventParameterKeys.retailerName: grocery.name ?? "",
            EventParameterKeys.categoryID: String(category.id),
            EventParameterKeys.categoryName: category.slug ?? "",
            EventParameterKeys.subcategoryID: (subcategory?.subCategoryId.stringValue ?? "0"),
            EventParameterKeys.subcategoryName: (subcategory?.subCategoryNameEn ?? "All")
        ]
    }
}

struct StoreFilterAppliedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(searchQuery: String, isPromotionalSelected: Bool, grocery: Grocery) {
        self.eventType = .track(eventName: AnalyticsEventName.storeFilterButtonClicked)
        self.metaData = [
            EventParameterKeys.retailerID: grocery.getCleanGroceryID(),
            EventParameterKeys.retailerName: grocery.name ?? "",
            EventParameterKeys.searchedQuery: searchQuery,
            EventParameterKeys.isDiscountedProductSelected: isPromotionalSelected
        ]
    }
}
