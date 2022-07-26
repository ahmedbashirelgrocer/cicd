//
//  ElGrocer.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 29/06/2022.
//

import Foundation


import UIKit
import FirebaseCore


public final class ElGrocer {
    // elgrocer

    static var isSDKLoaded = false
    
    public static var isLoggingEnabled = true { didSet {
        MixpanelManager.loggingEnabled(ElGrocer.isLoggingEnabled)
    } }
    
    public static func startEngine(with launchOptions: LaunchOptions? = nil) {
        defer {
            ElGrocer.isSDKLoaded = true
        }
        guard !ElGrocerAppState.isSDKLoadedAndDataAvailable(launchOptions) else {
            
            
            func basicHomeViewSetUp() {
                if let launchOptions = launchOptions {
                    let manager = SDKLoginManager(launchOptions: launchOptions)
                    manager.setHomeView()
                }
            }
            
            if let _ = launchOptions?.pushNotificationPayload, (launchOptions?.pushNotificationPayload?.count ?? 0) > 0 {
                basicHomeViewSetUp()
                ElGrocerNotification.handlePushNotification(launchOptions)
            }else if let url = URL(string: launchOptions?.deepLinkPayload ?? ""), (launchOptions?.deepLinkPayload?.count ?? 0) > 0 {
                basicHomeViewSetUp()
                ElGrocerDynamicLink.handleDeepLink(url)
                return
            }else {
                SDKManager.shared.start(with: launchOptions)
            }
            return
        }
        
        SDKManager.shared.start(with: launchOptions)
        if let _ = launchOptions?.pushNotificationPayload, (launchOptions?.pushNotificationPayload?.count ?? 0) > 0 {
            ElGrocerNotification.handlePushNotification(launchOptions)
        } else if let url = URL(string: launchOptions?.deepLinkPayload ?? ""), (launchOptions?.deepLinkPayload?.count ?? 0) > 0 {
            ElGrocerDynamicLink.handleDeepLink(url)
        }
       
    }
    public static func startEngine(with launchOptions: LaunchOptions? = nil, _ deepLink : URL?) {
        
        defer {
            ElGrocer.isSDKLoaded = true
        }
        
        guard !ElGrocerAppState.isSDKLoadedAndDataAvailable(launchOptions) else {
            
            if let launchOptions = launchOptions {
                let manager = SDKLoginManager(launchOptions: launchOptions)
                manager.setHomeView()
            }
            
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

public struct LaunchOptions  {
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

func elDebugPrint(_ items: Any...,
                  separator: String = " ",
                  terminator: String = "\n",
                  line: Int = #line,
                  column: Int = #column,
                  function: String = #function,
                  file: String = #file) {
#if DEBUG
    if ElGrocer.isLoggingEnabled {
        var index = items.startIndex
        let end = items.endIndex
        // Swift.debugPrint("==> File: \(file), Function: \(function) <==")
        repeat {
            Swift.debugPrint("elGrocer: Debug: \(items[index])",
                             separator: separator,
                             terminator: index == (end - 1) ? terminator : separator)
            index += 1
        } while index < end
    }
#endif
}
