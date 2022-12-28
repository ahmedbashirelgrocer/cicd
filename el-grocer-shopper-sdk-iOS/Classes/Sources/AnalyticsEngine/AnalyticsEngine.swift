//
//  AnalyticsEvent.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 25/11/2022.
//

import Foundation
import Segment

protocol AnalyticsEngineType {
    func identify(userData: IdentifyUserDataType)
    func logEvent(event: AnalyticsEventDataType)
    func reset()
}

class SegmentAnalyticsEngine: AnalyticsEngineType {
    static let instance = SegmentAnalyticsEngine()
    
    private var analytics: Analytics
    
    init(analytics: Analytics = Analytics.shared()) {
        self.analytics = analytics
    }
    
    func identify(userData: IdentifyUserDataType) {
        self.analytics.identify(userData.userId, traits: userData.traits)
    }
    
    func logEvent(event: AnalyticsEventDataType) {
        switch event.eventType {
        case .track(let eventName):
            self.analytics.track(eventName, properties: event.metaData)
            break
            
        case .screen(let screenName):
            self.analytics.screen(screenName, properties: event.metaData)
            break
        }
    }
    
    func reset() {
        self.analytics.reset()
    }
}
