//
//  CommonEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 06/02/2023.
//

import Foundation

// MARK: Help Event
struct HelpClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.helpClicked)
    }
}

// MARK: General API Error event
struct GeneralAPIErrorEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(endPoint: String?, message: String, code: Int) {
        self.eventType = .track(eventName: AnalyticsEventName.generalAPIError)
        self.metaData = [
            EventParameterKeys.apiEndpoint: endPoint ?? "",
            EventParameterKeys.message: message,
            EventParameterKeys.code: String(code),
        ]
    }
}

struct MenuItemClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(name: String) {
        self.eventType = .track(eventName: AnalyticsEventName.menuItemClicked)
        self.metaData = [
            EventParameterKeys.name: name,
        ]
    }
}
