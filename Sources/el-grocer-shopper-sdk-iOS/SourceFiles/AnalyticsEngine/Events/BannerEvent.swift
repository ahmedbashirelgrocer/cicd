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
    
    init(banner: BannerCampaign, position: Int,groceryId: String = "", groceryName: String = "", _ source: CartUpdatedEventSource = .viewScreenName, location: String = "0") {
        self.eventType = .track(eventName: AnalyticsEventName.bannerClicked)
        
        self.metaData = [
            EventParameterKeys.bannerId         : banner.dbId.stringValue,
            EventParameterKeys.title            : banner.title,
            EventParameterKeys.priority         : banner.priority.stringValue,
            EventParameterKeys.campaignType     : banner.campaignType.stringValue,
            EventParameterKeys.imageUrl         : banner.bannerImageUrl,
            EventParameterKeys.location         : location,
            EventParameterKeys.position         : String(position),
            EventParameterKeys.source : source.getScreenName()
        ]
    }
}

struct BannerViewedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(banner: BannerCampaign, position: Int, _ source: CartUpdatedEventSource = .viewScreenName) {
        self.eventType = .track(eventName: AnalyticsEventName.bannerViewed)
        self.metaData = [
            EventParameterKeys.bannerId         : banner.dbId.stringValue,
            EventParameterKeys.title            : banner.title,
            EventParameterKeys.priority         : banner.priority.stringValue,
            EventParameterKeys.campaignType     : banner.campaignType.stringValue,
            EventParameterKeys.imageUrl         : banner.bannerImageUrl,
            EventParameterKeys.location         : "0",
            EventParameterKeys.position         : String(position),
            EventParameterKeys.source : source.getScreenName()
        ]
    }
}
struct StoryClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(id: String, name: String, deepLink: String) {
        self.eventType = .track(eventName: AnalyticsEventName.storylyClicked)
        self.metaData = [
            EventParameterKeys.id         : id,
            EventParameterKeys.name       : name,
            EventParameterKeys.deeplink   : deepLink
        ]
    }
}
