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
