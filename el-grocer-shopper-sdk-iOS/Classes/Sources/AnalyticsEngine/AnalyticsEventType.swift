//
//  AnalyticsEventType.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 28/11/2022.
//

import Foundation

protocol AnalyticsEventDataType {
    var eventType: AnalyticsEventType { get }
    var metaData: [String: Any]? { get }
}

enum AnalyticsEventType {
    case track(eventName: String)
    case screen(screenName: String)
}

protocol IdentifyUserDataType {
    var userId: String { get }
    var traits: [String: Any]? { get }
    
}
