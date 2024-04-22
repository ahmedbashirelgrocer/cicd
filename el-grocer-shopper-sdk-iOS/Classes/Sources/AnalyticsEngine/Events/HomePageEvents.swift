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



