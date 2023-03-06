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
        let traits = self.addMarketTypeProperty(metaData: userData.traits ?? [:])
        self.analytics.identify(userData.userId, traits: traits)
    }
    
    func logEvent(event: AnalyticsEventDataType) {
        switch event.eventType {
        case .track(let eventName):
            let metaData = self.addMarketTypeProperty(metaData: event.metaData ?? [:])
            self.analytics.track(eventName, properties: metaData)
            break
            
        case .screen(let screenName):
            let metaData = self.addMarketTypeProperty(metaData: event.metaData ?? [:])
            self.analytics.screen(screenName, properties: metaData)
            break
        }
    }
    
    func reset() {
        self.analytics.reset()
    }
}

private extension SegmentAnalyticsEngine {
    func addMarketTypeProperty(metaData: [String: Any]) -> [String: Any] {
        if let launchOptions = SDKManager.shared.launchOptions {
            switch launchOptions.marketType {
            case .marketPlace:
                var metaData = metaData
                metaData[EventParameterKeys.marketType] = "Smile Marketplace"
                metaData[EventParameterKeys.sessionId] = ElGrocerUtility.sharedInstance.getSesstionId()
                return metaData
                
            case .shopper:
                var metaData = metaData
                metaData[EventParameterKeys.marketType] = "Shopper Marketplace"
                metaData[EventParameterKeys.sessionId] = ElGrocerUtility.sharedInstance.getSesstionId()
                return metaData
                
            case .grocerySingleStore:
                var metaData = metaData
                metaData[EventParameterKeys.marketType] = "Market"
                metaData[EventParameterKeys.sessionId] = ElGrocerUtility.sharedInstance.getSesstionId()
                return metaData
            }
        }
        
        return metaData
    }
}
