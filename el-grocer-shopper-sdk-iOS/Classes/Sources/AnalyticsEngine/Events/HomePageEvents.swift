//
//  HomePageEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by saboor Khan on 05/03/2024.
//

import Foundation

struct HomeViewAllClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.homeViewAllClicked)
        self.metaData = [:]
    }
}


struct OneClickReOrderCloseEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.oneClickReorderCloseClicked)
        self.metaData = [:]
    }
}

struct SDKExitedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.sdkExited)
        self.metaData = [:]
    }
}

struct SDKExitedDiscoverOffersEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(_ isSmileStore: Bool) {
        self.eventType = .track(eventName: AnalyticsEventName.sdkDiscoverOffers)
        self.metaData = [:]
    }
}

struct ExclusiveDealClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(retailerId: String, retailerName: String, categoryId: String, categoryName: String, promoCode: String, source: ScreenName) {
        self.eventType = .track(eventName: AnalyticsEventName.exclusiveDealClicked)
        self.metaData = [EventParameterKeys.retailerID: retailerId, EventParameterKeys.retailerName: retailerName, EventParameterKeys.categoryID: categoryId, EventParameterKeys.categoryName: categoryName, EventParameterKeys.promoCode: promoCode,EventParameterKeys.source: source.rawValue]
    }
}

struct ExclusiveDealsViewAllClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(categoryId: String, categoryName: String, source: ScreenName) {
        self.eventType = .track(eventName: AnalyticsEventName.exclusiveDealsViewAllClicked)
        self.metaData = [ EventParameterKeys.categoryID: categoryId, EventParameterKeys.categoryName: categoryName,EventParameterKeys.source: source.rawValue]
    }
}

struct ExclusiveDealCopiedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(retailerId: String, retailerName: String, promoCode: String, source: ScreenName) {
        self.eventType = .track(eventName: AnalyticsEventName.exclusiveDealCopied)
        self.metaData = [EventParameterKeys.retailerID: retailerId, EventParameterKeys.retailerName: retailerName, EventParameterKeys.promoCode: promoCode,EventParameterKeys.source: source.rawValue]
    }
}
