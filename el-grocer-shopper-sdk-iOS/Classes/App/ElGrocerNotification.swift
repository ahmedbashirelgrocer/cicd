//
//  ElgrocerNotifcation.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 19/07/2022.
//

import Foundation


public class ElGrocerNotification {
    
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
        
        guard let data = options?.pushNotificationPayload, let dataObj = data["elgrocerMap"] else {
            return
        }
        
        ElGrocerUtility.sharedInstance.delay(delayTime) {
            _ = RemoteNotificationHandler()
                .addHandler(HelpshiftRemoteNotificationHandler())
                .addHandler(BackendRemoteNotificationHandler())
                .handleObject(dataObj as AnyObject)
        }
    }
    
    
    
}
