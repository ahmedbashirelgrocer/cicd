//
//  ActiveCartEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 27/11/2022.
//

import Foundation

struct MulticartViewedEvent: AnalyticsEventType {
    var eventCategory: AnalyticsEventCategory
    var metaData: [String : Any]?
    
    init(eventCategory: AnalyticsEventCategory, metaData: [String : Any]? = nil) {
        self.eventCategory = eventCategory
        self.metaData = metaData
    }
}


enum MulticartEvents {
    case screenViewed
}

extension MulticartEvents: AnalyticsEventType {
    var eventCategory: AnalyticsEventCategory {
        switch self {
            case .screenViewed:   return .sendScreen(screenName: "Multicart Screen")
        }
    }
    
    var metaData: [String : Any]? {
        switch self {
            case .screenViewed:     return nil
        }
    }
}

enum CartEvents {
    case cartCreated(time: Date, typesStoreID: String, storeName: String)
    case cartDeleted(time: Date, typesStoreID: String, storeName: String)
    case cartUpdated(time: Date, typesStoreID: String, storeName: String)
    case cartCheckout
    case cartViewed
}

extension CartEvents: AnalyticsEventType {
    var eventCategory: AnalyticsEventCategory {
        switch self {
            case .cartCreated   :   return .sendEvent(eventName: "Cart Created")
            case .cartDeleted   :   return .sendEvent(eventName: "Cart Deleted")
            case .cartUpdated   :   return .sendEvent(eventName: "Cart Checkout")
            case .cartCheckout  :   return .sendEvent(eventName: "Cart Viewed")
            case .cartViewed    :   return .sendScreen(screenName: "Cart Screen")
        }
    }
    
    var metaData: [String : Any]? {
        switch self {
        case .cartCreated(let time, let typesStoreID, let storeName):
            return [
                EventParameterKeys.time         : time,
                EventParameterKeys.typesStoreID : typesStoreID,
                EventParameterKeys.storeName    : storeName
            ]
            
        case .cartDeleted(let time, let typesStoreID, let storeName):
            return [
                EventParameterKeys.time         : time,
                EventParameterKeys.typesStoreID : typesStoreID,
                EventParameterKeys.storeName    : storeName
            ]
            
        case .cartUpdated(let time, let typesStoreID, let storeName):
            return [
                EventParameterKeys.time         : time,
                EventParameterKeys.typesStoreID : typesStoreID,
                EventParameterKeys.storeName    : storeName
            ]
            
        case .cartCheckout:
            return [:]
            
        case .cartViewed:
            return [:]
        }
    }
}
