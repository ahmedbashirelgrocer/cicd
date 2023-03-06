//
//  Screens.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 16/12/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation

struct ScreenRecordEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(screenName: ScreenName) {
        self.eventType = .screen(screenName: screenName.rawValue)
    }
}
