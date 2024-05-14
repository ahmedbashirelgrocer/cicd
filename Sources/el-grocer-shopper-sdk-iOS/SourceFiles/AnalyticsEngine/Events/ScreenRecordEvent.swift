//
//  Screens.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 16/12/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation

struct ScreenRecordEvent: AnalyticsEventDataType {
    enum CampaignType: String{
        case marketingCampaign = "Marketing Campaign"
        case limitedSavingsCampaign = "Limited Time Savings Campaign"
    }
    
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(screenName: ScreenName) {
        self.eventType = .screen(screenName: screenName.rawValue)
    }
}


//struct ScreenDismissedEvent: AnalyticsEventDataType {
//    var eventType: AnalyticsEventType
//    var metaData: [String : Any]?
//    
//    init(screenName: ScreenName) {
//        self.eventType = .screen(screenName: screenName.rawValue)
//    }
//}
