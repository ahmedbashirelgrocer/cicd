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
                delayTime = 5.0
            }
        }
        
        if (HomePageData.shared.groceryA?.count ?? 0) == 0 || !UserDefaults.isUserLoggedIn() {
            ElGrocerUtility.sharedInstance.delay(delayTime) {
                ElGrocerNotification.handlePushNotification(options)
            }
            return
        }
        
        guard let data = options?.pushNotificationPayload, let dataObj = data[SmileMapKeyName] as? String else {
            ElGrocerNotification.logErrorOption(options)
            return
        }
       
        var pushData : [NSDictionary] = []
        if let data = dataObj.data(using: .utf8) {
            do {
                pushData = try JSONSerialization.jsonObject(with: data, options: []) as? [NSDictionary] ?? []
            } catch let error as NSError {
                elDebugPrint(error.localizedDescription)
                ElGrocerNotification.logErrorOption(options)
                return
            }
        }
        
        var finalPushData : [String : AnyHashable] = [:]
        for data in pushData {
            if let key = data["key"]  as? String, let value = data["value"] as? AnyHashable  {
                finalPushData[key] = value
            }
        }
        
        
        // Proceed with Notifcation
        ElGrocerUtility.sharedInstance.delay(delayTime) {
            
            _ = RemoteNotificationHandler()
                .addHandler(HelpshiftRemoteNotificationHandler())
                .addHandler(BackendRemoteNotificationHandler())
                .handleObject(finalPushData as AnyObject)
        }
    }
    
    class func logErrorOption(_ options: LaunchOptions?) {
        FireBaseEventsLogger.trackCustomEvent(eventType: "InvalidPushJson", action: "SmileSDk: \(SDKManager.shared.isSmileSDK ? "YES": "NO")", ["payload" : options?.pushNotificationPayload?.description ?? "Nil", "phone" : options?.accountNumber ?? "Nil", "ID" : options?.loyaltyID ?? "Nil"], false)
        
    }
    
}
