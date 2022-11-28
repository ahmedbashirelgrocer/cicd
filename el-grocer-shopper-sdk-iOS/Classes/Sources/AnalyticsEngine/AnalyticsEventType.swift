//
//  AnalyticsEventType.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 28/11/2022.
//

import Foundation

protocol AnalyticsEventType {
    var eventCategory: AnalyticsEventCategory { get }
    var metaData: [String: Any]? { get }
}

enum AnalyticsEventCategory {
    case identifyUser(userID: String)
    case sendEvent(eventName: String)
    case sendScreen(screenName: String)
}
