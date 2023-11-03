//
//  CommonEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 06/02/2023.
//

import Foundation



// MARK: SDK Only Events
struct SDKLaunchedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(launchOption: LaunchOptions?) {
        self.eventType = .track(eventName: AnalyticsEventName.sdkLaunched)
        self.metaData = [
            EventParameterKeys.latitude: launchOption?.latitude ?? 0.0,
            EventParameterKeys.longitude: launchOption?.longitude ?? 0.0,
            EventParameterKeys.phone: launchOption?.accountNumber ?? "" ,
            EventParameterKeys.loyaltyId: launchOption?.loyaltyID ?? "",
            EventParameterKeys.deeplink: launchOption?.deepLinkPayload ?? "",
            EventParameterKeys.pushNotifcation: launchOption?.pushNotificationPayload?.description ?? "",
        ]
    }
}

// MARK: ShopperOnly

struct HomeTileClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(title: String, isFeatured: Bool, retailerId: String? = nil) {
        self.eventType = .track(eventName: AnalyticsEventName.homeTileClicked)
        var metaData: [String: Any] = [:]
        
        metaData[EventParameterKeys.title] = title
        metaData[EventParameterKeys.isFeatured] = isFeatured
        if let retailerId = retailerId {
            metaData[EventParameterKeys.retailerID] = retailerId
        }
        
        self.metaData = metaData
    }
}

struct ApplicationOpenedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.applicationOpened)
    }
}



// MARK: Help Event
struct HelpClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.helpClicked)
    }
}

// MARK: General API Error event
struct GeneralAPIErrorEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(endPoint: String?, message: String, code: Int) {
        self.eventType = .track(eventName: AnalyticsEventName.generalAPIError)
        self.metaData = [
            EventParameterKeys.apiEndpoint: endPoint ?? "",
            EventParameterKeys.message: message,
            EventParameterKeys.code: String(code),
        ]
    }
}

struct MenuItemClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(name: String) {
        self.eventType = .track(eventName: AnalyticsEventName.menuItemClicked)
        self.metaData = [
            EventParameterKeys.name: name,
        ]
    }
}

struct ABTestExperimentEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(authToken: String, variant: String, experimentType: ExperimentType = .home) {
        self.eventType = .track(eventName: AnalyticsEventName.abTestExperiment)
        self.metaData = [
            EventParameterKeys.authToken: authToken,
            EventParameterKeys.variant: variant,
            EventParameterKeys.experimentType: experimentType.rawValue,
        ]
    }
    enum ExperimentType: String {
        case home = "home"
        case store = "store"
    }
}

/*
 struct GenericABTestConfigError: AnalyticsEventDataType {
     var eventType: AnalyticsEventType
     var metaData: [String : Any]?
}
 */
