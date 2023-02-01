//
//  ScreenTrackEvent.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 01/02/2023.
//

import Foundation

struct ScreenRecordEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(screenName: ScreenName) {
        self.eventType = .screen(screenName: screenName.rawValue)
    }
}
