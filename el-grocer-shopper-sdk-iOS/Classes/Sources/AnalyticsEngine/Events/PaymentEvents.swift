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
    
    init(paymentMethodId: Int, paymentMethodName: String) {
        self.eventType = .track(eventName: AnalyticsEventName.paymentMethodChanged)
        self.metaData = [
            EventParameterKeys.paymentMethodId: paymentMethodId,
            EventParameterKeys.paymentMethodName: paymentMethodName,
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

struct FundMethodSelectedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(paymentMethodId: Int) {
        self.eventType = .track(eventName: AnalyticsEventName.fundMethodSelected)
        self.metaData = [
            EventParameterKeys.paymentMethodId: paymentMethodId,
        ]
    }
}

struct CardAddedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.cardAdded)
    }
}

struct CardRemovedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.cardRemoved)
    }
}

struct FundAddedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(paymentMethodId: Int, amount: Double) {
        self.eventType = .track(eventName: AnalyticsEventName.fundAdded)
        self.metaData = [
            EventParameterKeys.paymentMethodId: paymentMethodId,
            EventParameterKeys.amount: amount,
        ]
    }
}

struct VoucherRedeemedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init(code: String?) {
        self.eventType = .track(eventName: AnalyticsEventName.voucherRedeemed)
        self.metaData = [
            EventParameterKeys.voucherCode: code ?? "",
        ]
    }
}

struct AddFundClickedEvent: AnalyticsEventDataType {
    var eventType: AnalyticsEventType
    var metaData: [String : Any]?
    
    init() {
        self.eventType = .track(eventName: AnalyticsEventName.addFundClicked)
    }
}
