//
//  SearchEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 06/02/2023.
//

import Foundation

struct UniversalSearchEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(searchQuery: String, isSuggestion: Bool) {
        self.eventType = .track(eventName: AnalyticsEventName.universalSearch)
        self.metaData = [
            EventParameterKeys.searchQuery: searchQuery,
            EventParameterKeys.isSuggestion: isSuggestion,
        ]
    }
}

struct StoreSearchEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(searchQuery: String, isSuggestion: Bool, retailerId: String) {
        self.eventType = .track(eventName: AnalyticsEventName.storeSearch)
        self.metaData = [
            EventParameterKeys.searchQuery: searchQuery,
            EventParameterKeys.isSuggestion: isSuggestion,
            EventParameterKeys.retailerID: retailerId,
        ]
    }
}

enum SearchHistoryClickedEventSource: String {
    case relatedProduct = "Related Product"
    case searchHistory  = "Search History"
}

struct SearchHistoryClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(productName: String, source: SearchHistoryClickedEventSource) {
        self.eventType = .track(eventName: AnalyticsEventName.searchHistoryClicked)
        self.metaData = [
            EventParameterKeys.productName: productName,
            EventParameterKeys.source: source.rawValue
        ]
    }
}
