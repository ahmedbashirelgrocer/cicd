//
//  ElGrocer.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 29/06/2022.
//

import Foundation


import UIKit

public final class ElGrocer {
    // elgrocer
    public static func startEngine(with launchOptions: LaunchOptions? = nil) {
        SDKManager.shared.start(with: launchOptions)
    }
}

public struct LaunchOptions {
    var accountNumber: String?
    var latitude: Double?
    var longitude: Double?
    var loyalityID: String?
    var email: String?
    var pushNotificationPayload: [String: AnyHashable]?
    var deepLinkpayload: String?
    var language: String?
    
    public init(accountNumber: String? = nil,
                latitude: Double? = nil,
                longitude: Double? = nil,
                loyalityID: String? = nil,
                email: String? = nil,
                pushNotificationPayload: [String: AnyHashable]? = nil,
                deepLinkpayload: String? = nil,
                language: String? = nil) {
        
        self.accountNumber = accountNumber
        self.latitude = latitude
        self.longitude = longitude
        self.loyalityID = loyalityID
        self.email = email
        self.pushNotificationPayload = pushNotificationPayload
        self.deepLinkpayload = deepLinkpayload
        self.language = language
        
    }
}
