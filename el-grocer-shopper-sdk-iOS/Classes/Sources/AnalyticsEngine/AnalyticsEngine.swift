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
    func logEvent(event: AnalyticsEventDataType, launchOptions: LaunchOptions)
    func reset()
}

class SegmentAnalyticsEngine: AnalyticsEngineType {
    
    static let instance = SegmentAnalyticsEngine()
    private var analytics: Analytics
    private var source: String = "" // will set when ever screen viwer event is being triggered.
    
    init(analytics: Analytics = Analytics.shared()) {
        self.analytics = analytics
    }
    
    func register(deviceToke: Data) {
        self.analytics.registeredForRemoteNotifications(withDeviceToken: deviceToke)
    }
    
    func identify(userData: IdentifyUserDataType) {
        let traits = self.addMarketTypeProperty(metaData: userData.traits ?? [:])
        self.analytics.identify(userData.userId, traits: traits)
        self.debugLogEvent(eventType: "Identify", eventName: "Identify User - \(userData.userId)", params: traits)
    }
    
    func logEvent(event: AnalyticsEventDataType) {
        switch event.eventType {
        case .track(let eventName):
            let metaData = self.addMarketTypeProperty(metaData: event.metaData ?? [:])
            self.analytics.track(eventName, properties: metaData)
            self.debugLogEvent(eventType: "Track", eventName: eventName, params: metaData)
            
        case .screen(let screenName):
            self.source = screenName
            let metaData = self.addMarketTypeProperty(metaData: event.metaData ?? [:])
            self.analytics.screen(screenName, properties: metaData)
            self.debugLogEvent(eventType: "Screen", eventName: screenName, params: metaData)
        }
    }
    
    func logEvent(event: AnalyticsEventDataType, launchOptions: LaunchOptions) {
        switch event.eventType {
            
        case .track(eventName: let eventName):
            let metaData = self.addMarketTypeProperty(metaData: event.metaData ?? [:], launchOptions: launchOptions)
            self.analytics.track(eventName, properties: metaData)
            self.debugLogEvent(eventType: "Track", eventName: eventName, params: metaData)
            break
            
        case .screen(screenName: let screenName):
            let metaData = self.addMarketTypeProperty(metaData: event.metaData ?? [:], launchOptions: launchOptions)
            self.analytics.screen(screenName, properties: metaData)
            self.debugLogEvent(eventType: "Screen", eventName: screenName, params: metaData)
            break
        }
    }
    
    func reset() {
        self.analytics.reset()
    }
    
    func getSource() -> String {
        return self.source
    }
}

private extension SegmentAnalyticsEngine {
    func addMarketTypeProperty(metaData: [String: Any], launchOptions: LaunchOptions? = sdkManager.launchOptions) -> [String: Any] {
        if let launchOptions = launchOptions {
            switch launchOptions.marketType {
            case .marketPlace:
                var metaData = metaData
                metaData[EventParameterKeys.marketType] = "Smiles Marketplace"
                metaData[EventParameterKeys.sessionId] = ElGrocerUtility.sharedInstance.getSesstionId()
                return metaData
                
            case .shopper:
                var metaData = metaData
                metaData[EventParameterKeys.marketType] = "Shopper Marketplace"
                metaData[EventParameterKeys.sessionId] = ElGrocerUtility.sharedInstance.getSesstionId()
                return metaData
                
            case .grocerySingleStore:
                var metaData = metaData
                metaData[EventParameterKeys.marketType] = "Smiles Market"
                metaData[EventParameterKeys.sessionId] = ElGrocerUtility.sharedInstance.getSesstionId()
                return metaData
            }
        } else {
            var metaData = metaData
            metaData[EventParameterKeys.marketType] = sdkManager.isShopperApp ? "Shopper Marketplace" : "Smiles Marketplace"
            metaData[EventParameterKeys.sessionId] = ElGrocerUtility.sharedInstance.getSesstionId()
            return metaData
        }
    }
    
    func debugLogEvent(eventType: String, eventName: String, params: [String: Any]) {
        #if DEBUG
        print("\n\n")
        print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< SEGMENT ANALYTICS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        print("Event Type: \(eventType)")
        print("Event Name: \(eventName)")
        print("Event Params: \(params)")
        print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< END >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        #endif
    }
}
