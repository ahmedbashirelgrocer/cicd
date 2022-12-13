//
//  UserEvents.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 07/12/2022.
//

import Foundation

// MARK: Identify User Event
struct IdentifyUserEvent: AnalyticsEventType {
    var eventCategory: AnalyticsEventCategory
    var metaData: [String : Any]?

    init(user: UserProfile?) {
        self.eventCategory = .identifyUser(userID: String(user?.dbID.intValue ?? -1))
        self.metaData = [
            EventParameterKeys.email        : user?.email ?? "",
            EventParameterKeys.phone        : user?.phone ?? "",
            EventParameterKeys.name         : user?.name ?? "",
            EventParameterKeys.isSmilesSDK  : false, // need to fetch this value from SDKManager in Single Code Base
        ]
    }
}
