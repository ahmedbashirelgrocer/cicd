//
//  BannerEvent.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 13/02/2023.
//

import Foundation

struct BannerClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(banner: BannerCampaign, position: Int) {
        self.eventType = .track(eventName: AnalyticsEventName.bannerClicked)
        
        self.metaData = [
            EventParameterKeys.bannerId         : banner.dbId.stringValue,
            EventParameterKeys.title            : banner.title,
            EventParameterKeys.priority         : banner.priority.stringValue,
            EventParameterKeys.campaignType     : banner.campaignType.stringValue,
            EventParameterKeys.imageUrl         : banner.bannerImageUrl,
            EventParameterKeys.location         : "0",
            EventParameterKeys.position         : String(position),
        ]
    }
}

struct BannerViewedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(banner: BannerCampaign, position: Int) {
        self.eventType = .track(eventName: AnalyticsEventName.bannerViewed)
        self.metaData = [
            EventParameterKeys.bannerId         : banner.dbId.stringValue,
            EventParameterKeys.title            : banner.title,
            EventParameterKeys.priority         : banner.priority.stringValue,
            EventParameterKeys.campaignType     : banner.campaignType.stringValue,
            EventParameterKeys.imageUrl         : banner.bannerImageUrl,
            EventParameterKeys.location         : "0",
            EventParameterKeys.position         : String(position),
        ]
    }
}
