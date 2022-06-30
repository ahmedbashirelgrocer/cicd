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
    public static func startEngine(with options: LaunchOptions? = nil) {
        SDKManager.shared.start()
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
}
