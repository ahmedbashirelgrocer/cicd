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
 
    static func startEngine(with launchOptions: LaunchOptions? = nil, completion: (() -> Void)?  = nil) {
        
        SDKManager.shared.launchCompletion = completion
        
        if SDKManager.shared.launchOptions?.marketType != launchOptions?.marketType {
            HomePageData.shared.groceryA = []
        }
        
        DispatchQueue.main.async {

            func defers() {
                ElGrocer.isSDKLoaded = true
                ElGrocerUtility.sharedInstance.delay(0.2) {
                    FireBaseEventsLogger.logEventToFirebaseWithEventName(eventName: FireBaseParmName.SdkLaunch.rawValue, parameter: ["payload" : launchOptions?.pushNotificationPayload?.description ?? "Nil", "deeplink" : launchOptions?.deepLinkPayload ?? "Nil", "phone" : launchOptions?.accountNumber ?? "Nil", "ID" : launchOptions?.loyaltyID ?? "Nil", "lat": launchOptions?.latitude ?? 0.0, "lng" : launchOptions?.longitude ?? 0.0 ])
                }
            }
            
            guard ElGrocerAppState.checkDBCanBeLoaded() else {
                ElGrocer.showDefaultErrorForDB()
                return defers()
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
    
    static func showDefaultErrorForDB() {
        
        let refreshAlert = UIAlertController(title:  localizedString("alert_error_title", comment: ""), message:  localizedString("error_500", comment: ""), preferredStyle: UIAlertController.Style.alert)

        refreshAlert.addAction(UIAlertAction(title: localizedString("btn_Go_Back", comment: ""), style: .default, handler: {(action: UIAlertAction!) in }))
        UIWindow.key.rootViewController?.present(refreshAlert, animated: true, completion: nil)
        
    }
  
}


public enum ElgrocerSDKNavigationType: Int {
    case `Default`
    case search
    case singleStore
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

public struct LaunchOptions {
    var accountNumber: String?
    public var latitude: Double?
    public var longitude: Double?
    var address: String?
    var loyaltyID: String?
    var email: String?
    var pushNotificationPayload: [String: AnyHashable]?
    var deepLinkPayload: String?
    var language: String?
    var marketType : MarketType = .marketPlace
    var isSmileSDK: Bool { marketType == .marketPlace || marketType == .grocerySingleStore }
    var isLoggingEnabled = false {
        didSet { MixpanelManager.loggingEnabled(isLoggingEnabled) }
    }
    var isFromPush = false
    
    
    var environmentType : EnvironmentType = .live
    var theme: Theme!
    var navigationType : ElgrocerSDKNavigationType? =  ElgrocerSDKNavigationType.Default
    
    public enum MarketType: Hashable {
            /// - Parameter marketPlace: Smile App, market place.
            /// - Parameter shopper: Elgrocer Shopper App; Not for external Use (Smile Team PLease dont use this in sdk)
           /// - Parameter grocerySingleStore: Single Store for smile app
    case marketPlace, shopper, grocerySingleStore
    }
            
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
                isSmileSDK: Bool = true,
                marketType: MarketType = .marketPlace,
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
        self.marketType = marketType
        self.isLoggingEnabled = isLoggingEnabled
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
        language: String? = nil,
        marketype: MarketType = .marketPlace,
        environmentType : EnvironmentType = .live,
        theme: Theme = ApplicationTheme.smilesSdkTheme(), navigationType : ElgrocerSDKNavigationType = ElgrocerSDKNavigationType.Default) {
        
        self.accountNumber = accountNumber
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.loyaltyID = loyaltyID
        self.email = email
        self.pushNotificationPayload = pushNotificationPayload
        self.deepLinkPayload = deepLinkPayload
        self.language = language
        self.marketType = marketype
        self.navigationType = navigationType
        self.environmentType =  environmentType
        self.isLoggingEnabled = environmentType == .staging
        self.theme = theme
        if (pushNotificationPayload?.count ?? 0) > 0 {
            self.isFromPush = true
        }
    }
    
    public init(
        latitude: Double?,
        longitude: Double?,
        marketType : MarketType) {
        self.latitude = latitude
        self.longitude = longitude
        self.marketType = marketType
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
