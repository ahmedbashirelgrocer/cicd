//
//  PaymentEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 02/02/2023.
//

import Foundation

struct PaymentMethodChangedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(paymentMethodId: Int) {
        self.eventType = .track(eventName: AnalyticsEventName.paymentMethodChanged)
        self.metaData = [
            EventParameterKeys.paymentMethodId: paymentMethodId
        ]
    }
}

struct SmilesPointEnabledEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(isEnabled: Bool) {
        self.eventType = .track(eventName: AnalyticsEventName.smilesPointsEnabled)
        self.metaData = [
            EventParameterKeys.isEnabled: isEnabled
        ]
    }
}

struct ElWalletToggleEnabledEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(isEnabled: Bool) {
        self.eventType = .track(eventName: AnalyticsEventName.elWalletToggleEnabled)
        self.metaData = [
            EventParameterKeys.isEnabled: isEnabled
        ]
    }
}

struct PromoCodeAppliedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(isApplied: Bool, promoCode: String?, realizationId: Int?) {
        self.eventType = .track(eventName: AnalyticsEventName.promoCodeApplied)
        self.metaData = [
            EventParameterKeys.isApplied: isApplied,
            EventParameterKeys.promoCode: promoCode ?? "",
            EventParameterKeys.realizationId: realizationId ?? -1,
        ]
    }
}

struct PromoCodeViewedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(promoCode: PromotionCode) {
        self.eventType = .track(eventName: AnalyticsEventName.promoCodeViewed)
        self.metaData = [
            EventParameterKeys.promoCode: promoCode.code ?? "",
        ]
    }
}
