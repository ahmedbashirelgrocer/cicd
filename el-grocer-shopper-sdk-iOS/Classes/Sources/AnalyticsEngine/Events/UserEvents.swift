//
//  UserEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 07/12/2022.
//

import Foundation

// MARK: Identify User Event
// MARK: Identify User Event
struct IdentifyUserEvent: IdentifyUserDataType {
    var userId: String
    var traits: [String : Any]?

    init(user: UserProfile?) {
        self.userId = String(user?.dbID.intValue ?? -1)
        self.traits = [
            EventParameterKeys.email        : user?.email ?? "",
            EventParameterKeys.phone        : user?.phone ?? "",
            EventParameterKeys.name         : user?.name ?? "",
            EventParameterKeys.isSmilesSDK  : SDKManager.shared.launchOptions?.isSmileSDK ?? true,
        ]
    }
}

struct UserRegisteredEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.userRegistered)
    }
}

struct UserSignedInEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.userSignedIn)
    }
}

struct MenuButtonClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.menuButtonClicked)
    }
}

struct OnboardingStartedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.onboardingStarted)
    }
}

struct PhoneNumberEnteredEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.phoneNumberEntered)
    }
}


struct PushNotificationEnabledEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(isEnabled: Bool) {
        self.eventType = .track(eventName: AnalyticsEventName.pushNotificationEnabled)
        self.metaData = [
            EventParameterKeys.isEnabled: isEnabled,
        ]
    }
}
