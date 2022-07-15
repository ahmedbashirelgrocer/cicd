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
    
    static var isSDKLoaded = false
    
    public static func startEngine(with launchOptions: LaunchOptions? = nil) {
        defer {
            ElGrocer.isSDKLoaded = true
        }
        SDKManager.shared.start(with: launchOptions)
    }
    public static func startEngine(with launchOptions: LaunchOptions? = nil, _ deepLink : URL?) {
        
        defer {
            ElGrocer.isSDKLoaded = true
        }
        
        guard !ElGrocerAppState.isSDKLoadedAndDataAvailable(launchOptions) else{
            if let url = deepLink {
                ElGrocerDynamicLink.handleDeepLink(url)
            }
            return
        }
        SDKManager.shared.start(with: launchOptions)
        if let url = deepLink {
            ElGrocerDynamicLink.handleDeepLink(url)
        }
    }
    
    
    
}

public struct LaunchOptions {
    var accountNumber: String?
    var latitude: Double?
    var longitude: Double?
    var address: String?
    var loyaltyID: String?
    var email: String?
    var pushNotificationPayload: [String: AnyHashable]?
    var deepLinkPayload: String?
    var language: String?
    var isSmileSDK: Bool
    
    public init(accountNumber: String?,
                latitude: Double?,
                longitude: Double?,
                address: String?,
                loyaltyID: String?,
                email: String? = nil,
                pushNotificationPayload: [String: AnyHashable]? = nil,
                deepLinkPayload: String? = nil,
                language: String? = nil, isSmileSDK: Bool) {
        
        self.accountNumber = accountNumber
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.loyaltyID = loyaltyID
        self.email = email
        self.pushNotificationPayload = pushNotificationPayload
        self.deepLinkPayload = deepLinkPayload
        self.language = language
        self.isSmileSDK = isSmileSDK
        
    }
}
