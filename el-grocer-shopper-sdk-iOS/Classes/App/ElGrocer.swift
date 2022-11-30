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
    
    public static func startEngine(with launchOptions: LaunchOptions? = nil) {
        
        DispatchQueue.main.async {

            func defers() {
                ElGrocer.isSDKLoaded = true
                FireBaseEventsLogger.logEventToFirebaseWithEventName(FireBaseScreenName.Splash.rawValue,eventName: FireBaseParmName.SdkLaunch.rawValue, parameter: ["payload" : launchOptions?.pushNotificationPayload?.description ?? "Nil", "deeplink" : launchOptions?.deepLinkPayload ?? "Nil", "phone" : launchOptions?.accountNumber ?? "Nil", "ID" : launchOptions?.loyaltyID ?? "Nil"])
            }
            
            guard ElGrocerAppState.checkDBCanBeLoaded() else {
                ElGrocer.showDefaultErrorForDB()
                return
            }
            
            guard !ElGrocerAppState.isSDKLoadedAndDataAvailable(launchOptions) else {
                
                func basicHomeViewSetUp() {
                    if let launchOptions = launchOptions {
                        let manager = SDKLoginManager(launchOptions: launchOptions)
                        SDKManager.shared.launchOptions = launchOptions
                        manager.setHomeView()
                    }
                }
                
                if let data = launchOptions?.pushNotificationPayload, (launchOptions?.pushNotificationPayload?.count ?? 0) > 0 , let dataObj = data["elgrocerMap"] as? String, dataObj.count > 0 {
                    basicHomeViewSetUp()
                    ElGrocerNotification.handlePushNotification(launchOptions)
                }else if let url = URL(string: launchOptions?.deepLinkPayload ?? ""), (launchOptions?.deepLinkPayload?.count ?? 0) > 0 {
                    basicHomeViewSetUp()
                    ElGrocerDynamicLink.handleDeepLink(url)
                    return defers()
                }else {
                    SDKManager.shared.start(with: launchOptions)
                }
                return defers()
            }
            
            SDKManager.shared.start(with: launchOptions)
            if let data = launchOptions?.pushNotificationPayload, (launchOptions?.pushNotificationPayload?.count ?? 0) > 0, let dataObj = data["elgrocerMap"] as? String, dataObj.count > 0 {
                ElGrocerNotification.handlePushNotification(launchOptions)
            } else if let url = URL(string: launchOptions?.deepLinkPayload ?? ""), (launchOptions?.deepLinkPayload?.count ?? 0) > 0 {
                ElGrocerDynamicLink.handleDeepLink(url)
            }
            defers()
            
        }
        
        
    }
    
    private static func showDefaultErrorForDB() {
        
        let refreshAlert = UIAlertController(title:  localizedString("alert_error_title", comment: ""), message:  localizedString("error_500", comment: ""), preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: localizedString("btn_Go_Back", comment: ""), style: .default, handler: {(action: UIAlertAction!) in }))
        UIWindow.key.rootViewController?.present(refreshAlert, animated: true, completion: nil)
        
    }
  
}


enum SDKType {
    
    case smiles
    case elGrocerShopper
}

public enum EnvironmentType {
    
    case staging
    case preAdmin
    case live
    
    func value() -> String {
        
        switch self {
            case .staging:
                return "Debug"
            case .preAdmin:
                return "PreAdmin"
            case .live:
                return "Release"
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
    var isLoggingEnabled = false {
        didSet { MixpanelManager.loggingEnabled(isLoggingEnabled) }
    }
    var isFromPush = false
    
    var SDKType : SDKType = .smiles
    var environmentType : EnvironmentType = .live
    var theme: Theme!
        
    @available(*, deprecated)
    public init(accountNumber: String?,
                latitude: Double?,
                longitude: Double?,
                address: String?,
                loyaltyID: String?,
                email: String? = nil,
                pushNotificationPayload: [String: AnyHashable]? = nil,
                deepLinkPayload: String? = nil,
                language: String? = nil,
                isSmileSDK: Bool,
                isLoggingEnabled: Bool = false,
                theme: Theme = ApplicationTheme.smilesSdkTheme()) {
        
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
        self.isLoggingEnabled = isLoggingEnabled
        self.SDKType = .smiles
        self.isSmileSDK = true
        self.environmentType =  .live
        self.theme = theme
        if (pushNotificationPayload?.count ?? 0) > 0 {
            self.isFromPush = true
        }
    }
    

    public init(
        accountNumber: String?,
        latitude: Double?,
        longitude: Double?,
        address: String?,
        loyaltyID: String?,
        email: String? = nil,
        pushNotificationPayload: [String: AnyHashable]? = nil,
        deepLinkPayload: String? = nil,
        language: String? = nil, environmentType : EnvironmentType = .live,
        theme: Theme = ApplicationTheme.smilesSdkTheme()) {
        
        self.accountNumber = accountNumber
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.loyaltyID = loyaltyID
        self.email = email
        self.pushNotificationPayload = pushNotificationPayload
        self.deepLinkPayload = deepLinkPayload
        self.language = language
        self.SDKType = .smiles
        self.isSmileSDK = true
        self.environmentType =  environmentType
        self.isLoggingEnabled = environmentType == .staging
        self.theme = theme
        if (pushNotificationPayload?.count ?? 0) > 0 {
            self.isFromPush = true
        }
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
    if SDKManager.shared.launchOptions?.isLoggingEnabled == true {
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
