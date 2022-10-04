//
//  ElgrocerNotifcation.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 19/07/2022.
//

import Foundation


public class ElGrocerNotification {
    
    static let SmileMapKeyName = "elgrocerMap"
    
    public class func handlePushNotification(_ options : LaunchOptions?) {
       
        var delayTime = 1.0
        if let dataAvailable = SDKManager.shared.sdkStartTime {
            if dataAvailable.timeIntervalSinceNow > -10 {
                delayTime = 8.0
            }
        }
        
        if (HomePageData.shared.groceryA?.count ?? 0) == 0 {
            ElGrocerUtility.sharedInstance.delay(5) {
                ElGrocerNotification.handlePushNotification(options)
            }
            return
        }
        
        guard let data = options?.pushNotificationPayload, let dataObj = data[SmileMapKeyName] as? String else {
            ElGrocerNotification.logErrorOption(options)
            return
        }

        var pushData : [String: AnyHashable] = [:]
        if let data = dataObj.data(using: .utf8) {
            do {
                pushData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyHashable] ?? [:]
            } catch {
                ElGrocerNotification.logErrorOption(options)
                return
            }
        }
        // Proceed with Notifcation
        ElGrocerUtility.sharedInstance.delay(delayTime) {
            _ = RemoteNotificationHandler()
                .addHandler(HelpshiftRemoteNotificationHandler())
                .addHandler(BackendRemoteNotificationHandler())
                .handleObject(pushData as AnyObject)
        }
    }
    
    class func logErrorOption(_ options: LaunchOptions?) {
        FireBaseEventsLogger.trackCustomEvent(eventType: "InvalidPushJson", action: "SmileSDk: \(SDKManager.isSmileSDK ? "YES": "NO")", ["payload" : options?.pushNotificationPayload?.description ?? "Nil", "phone" : options?.accountNumber ?? "Nil", "ID" : options?.loyaltyID ?? "Nil"], false)
        
    }
    
    
    
}
