//
//  AddressEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 02/02/2023.
//

import Foundation

enum AddressClickedEventSource: String {
    case home = "Home Screen"
    case settings = "Settings Screen"
}

struct AddressClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(source: AddressClickedEventSource) {
        self.eventType = .track(eventName: AnalyticsEventName.addressClicked)
        self.metaData = [
            EventParameterKeys.source: source.rawValue
        ]
    }
}

struct ConfirmDeliveryLocationEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(address: String?) {
        self.eventType = .track(eventName: AnalyticsEventName.confirmDeliveryLocation)
        self.metaData = [
            EventParameterKeys.address: address ?? ""
        ]
    }
}

struct ConfirmAddressDetailsEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.confirmAddressDetails)
    }
}
