//
//  AnalyticsEvent.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 25/11/2022.
//

import Foundation
import Segment

protocol AnalyticsEngineType {
    func logEvent(event: AnalyticsEventType)
}

class SegmentAnalyticsEngine: AnalyticsEngineType {
    static let instance = SegmentAnalyticsEngine()
    
    private var analytics: Analytics
    
    init(analytics: Analytics = Analytics.shared()) {
        self.analytics = analytics
    }
    
    func logEvent(event: AnalyticsEventType) {
        switch event.eventCategory {
        case .identifyUser(userID: let userID):
            self.analytics.identify(userID, traits: event.metaData)
            break
            
        case .sendEvent(let eventName):
            self.analytics.track(eventName, properties: event.metaData)
            break
            
        case .sendScreen(let screenName):
            self.analytics.screen(screenName, properties: event.metaData)
            break
        }
    }
}
