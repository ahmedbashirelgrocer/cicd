//
//  File.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 20/06/2022.
//

import Foundation
import CleverTapSDK
import FirebaseMessaging
import FirebaseAuth

// MARK: Notifications
extension SDKManager {
    func registerForNotifications() {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {(granted,error) in
                if granted{
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            })
        } else {
            
            // Fallback on earlier versions
            let types:UIUserNotificationType = ([.alert, .badge, .sound])
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
            
            UIApplication.shared.registerUserNotificationSettings(settings)
            
            DispatchQueue.main.async(execute: {
                UIApplication.shared.registerForRemoteNotifications()
            })
        }
       // Messaging.messaging().delegate = self
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        
    }
    
    
    func zendeskNotifcationHandling (_ requestID : String) {
        
        
//        if let _ = Zendesk.instance {
//            if Support.instance?.refreshRequest(requestId: requestID) == true {
//            }else{
//                ZenDesk.sharedInstance.presentRequest(with: requestID)
//            }
//        }else{
//            ElGrocerUtility.sharedInstance.delay(5) {
//                self.zendeskNotifcationHandling(requestID)
//            }
//        }

    }
    
    

    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        print("push notif data: \(userInfo)")
        
        
        if let _ = userInfo["sendbird"] as? NSDictionary {
            var delayTimeSendBird = 0.0
            // if let SDKManager = SDKManager.shared {
                if let dataAvailable = SDKManager.shared.sdkStartTime {
                    if dataAvailable.timeIntervalSinceNow > -10 {
                        delayTimeSendBird = 6.0
                    }
                }
            // }
            if delayTimeSendBird == 0 && UIApplication.shared.applicationState == .inactive {
                delayTimeSendBird = 0.2
            }
            ElGrocerUtility.sharedInstance.delay(delayTimeSendBird) {
                SendBirdManager().didReciveRemoteNotification(userInfo: userInfo)
            }
            completionHandler(.noData)
            return
        }
        
        if CleverTap.sharedInstance()?.isCleverTapNotification(userInfo) ?? false {
            CleverTap.sharedInstance()?.handleNotification(withData: userInfo , openDeepLinksInForeground: false)
            completionHandler(.noData)
          //  return
        }

        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
           // return
        }
        
        if let data = userInfo["data"] as? NSDictionary {
            if let type = data["type"] as? String {
                if type.count > 0 {
                    var delayTime = 1.0
                    // if let SDKManager = SDKManager.shared {
                        if let dataAvailable = SDKManager.shared.sdkStartTime {
                            if dataAvailable.timeIntervalSinceNow > -5 {
                                delayTime = 4.0
                            }
                        }
                    //}
                    ElGrocerUtility.sharedInstance.delay(delayTime) {
                        if let msgDict = userInfo["aps"] as? NSDictionary {
                            if let alert = msgDict["alert"] as? NSDictionary {
                                if let msg = alert["body"] as? String {
                                    self.chatNotifcationFromZenDesk(msg)
                                }
                            }
                        }
                       
                    }
                }
                completionHandler(.noData)
                return
            }
        }
     
        if let _ = userInfo["ticket_id"] as? String {
            let requestID = userInfo["ticket_id"] as! String
            
            var delayTime = 1.0
            // if let SDKManager = SDKManager.shared {
                if let dataAvailable = SDKManager.shared.sdkStartTime {
                    if dataAvailable.timeIntervalSinceNow > -5 {
                        delayTime = 4.0
                    }
                }
            // }
            ElGrocerUtility.sharedInstance.delay(delayTime) {
                self.zendeskNotifcationHandling(requestID)
            }
            
            completionHandler(.noData)
            return
            
        }
       
       
        
        if let userdata : [String : Any] = userInfo as? [String : Any] {
           ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("received_push_notification" , userdata)
        }else{
            ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("received_push_notification")
        }
        
        var delayTime = 1.0
        // if let SDKManager = SDKManager.shared {
            if let dataAvailable = SDKManager.shared.sdkStartTime {
                if dataAvailable.timeIntervalSinceNow > -10 {
                    delayTime = 8.0
                }
            }
        // }
        
        ElGrocerUtility.sharedInstance.delay(delayTime) {
            _ = RemoteNotificationHandler()
                .addHandler(HelpshiftRemoteNotificationHandler())
                .addHandler(BackendRemoteNotificationHandler())
                .handleObject(userInfo as AnyObject)
        }
        
        if #available(iOS 10.0, *) {
            completionHandler(UIBackgroundFetchResult.noData)
        } else {
           // PushNotificationManager.push().handlePushReceived(userInfo)
            completionHandler(UIBackgroundFetchResult.noData)
        }
  
    }
    
    func chatNotifcationFromZenDesk (_ msg : String) {
        if let topVc = UIApplication.topViewController() {
            if NSStringFromClass(topVc.classForCoder) != "CommonUISDK.MessagingViewController"  {
                var newMsg: String = msg
                if newMsg.count > 100 {
                    newMsg = (newMsg as NSString).substring(to: 100)
                    newMsg.append("...")
                }
                ElGrocerUtility.sharedInstance.showTopMessageView(newMsg, image: UIImage(name: "chat-White") , -1 , false  ) { (data, index, isShow) in
                    debugPrint("msg")
                    //ZohoChat.showChat()
                    NotificationCenter.default.post(name: KChatNotifcation, object: false)
                    
                }
                NotificationCenter.default.post(name: KChatNotifcation, object: true)
            }
        }
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        _ = LocalNotificationHandler()
            .addHandler(HelpshiftLocalNotificationHandler())
            .handleObject(notification)
    }
    
    /** For iOS 10 and above - Foreground**/
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        
        print("SDKManager: didReceiveResponseWithCompletionHandler \(notification.request.content.userInfo)")
        
        // If you wish CleverTap to record the notification click and fire any deep links contained in the payload.
        CleverTap.sharedInstance()?.handleNotification(withData: notification.request.content.userInfo, openDeepLinksInForeground: true)
        
        completionHandler([.sound])
    }
  
    func checkForNotificationAtAppLaunch(_ application: UIApplication, userInfo: [AnyHashable: Any]?) {
        
        guard let userInfo = userInfo else {
            return
        }
        
        if let localNotification = userInfo[UIApplication.LaunchOptionsKey.localNotification] as? UILocalNotification {
            self.application(application, didReceive: localNotification)
        } else if let remoteNotification = userInfo[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("opens_app_after_push_notification")
            self.application(application, didReceiveRemoteNotification: remoteNotification)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token String: \(deviceTokenString)")
        
        self.updateDeviceTokenToServer(deviceTokenString)
        //ZohoSalesIQ.enablePush( deviceTokenString , isTestDevice: false , mode: .production)
        CleverTapEventsLogger.registerFor(deviceToken)
        UserDefaults.setDevicePushToken(deviceTokenString)
        UserDefaults.setDevicePushTokenData(deviceToken)
        Messaging.messaging().apnsToken = deviceToken
        
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async {
            SendBirdManager().registerPushNotification(deviceToken){ isSuccess in
                if isSuccess{
                    print("sendBird token registered")
                }
            }
        }
        
//        SendBirdDeskManager(type: .agentSupport).registerPushNotification(deviceToken){
//            isSuccess in
//            if isSuccess{
//                print("sendBird Desk token registered")
//            }
//        }
        
        NotificationCenter.default.post(name: Notification.Name("deviceToken"), object: deviceTokenString, userInfo: nil)
     
      
        

        //register token in Intercom
        // Intercom.setDeviceToken(deviceToken)
        
        /*
        //register token in Firebase
        if Platform.isDebugBuild {
            Messaging.messaging()
                .setAPNSToken(deviceToken, type: MessagingAPNSTokenType.sandbox)
        }else if Platform.isSimulator {
            Messaging.messaging()
                .setAPNSToken(deviceToken, type: MessagingAPNSTokenType.unknown)
        }else {
            Messaging.messaging()
                .setAPNSToken(deviceToken, type: MessagingAPNSTokenType.prod)
        }
 */
      //  PushNotificationManager.push().handlePushRegistration(deviceToken as Data)
//      InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.prod)
    }
    
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error While Register For Remote Notifications:%@",error.localizedDescription)
      //  PushNotificationManager.push().handlePushRegistrationFailure(error)
    }
    
    // MARK: Abandoned basket notification
    
    func scheduleAbandonedBasketNotification() {
        
        //cancel all previously scheduled notifications
        UIApplication.shared.cancelAllLocalNotifications()
        
        //schedule new notification after 20 min
        let min20Notification = createLocalNotificationWithFireTime(fireTimeMinutes: 20)
        UIApplication.shared.scheduleLocalNotification(min20Notification)
    }
    
    func scheduleAbandonedBasketNotificationAfter24Hour() {
        //cancel all previously scheduled notifications
        UIApplication.shared.cancelAllLocalNotifications()
        
        //schedule new notification after 24 hrs
        let min20Notification = createLocalNotificationWith24HourFireTime(fireTimeMinutes: 1440)
        UIApplication.shared.scheduleLocalNotification(min20Notification)
    }
    
    func scheduleAbandonedBasketNotificationAfter72Hour() {
        //cancel all previously scheduled notifications
        UIApplication.shared.cancelAllLocalNotifications()
        
        //schedule new notification after 72 hrs
        let min20Notification = createLocalNotificationWith72HourFireTime(fireTimeMinutes: 4320)
        UIApplication.shared.scheduleLocalNotification(min20Notification)
    }
    
    fileprivate func createLocalNotificationWithFireTime(fireTimeMinutes:TimeInterval) -> UILocalNotification {
        
        let message = localizedString("abandoned_cart_notification_message", comment: "")
        
        let localNotification = UILocalNotification()
        localNotification.userInfo = nil
        localNotification.applicationIconBadgeNumber = 0
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.alertBody = message
        localNotification.fireDate = Date().addingTimeInterval(fireTimeMinutes * 60)
        
        return localNotification
    }
    
    fileprivate func createLocalNotificationWith24HourFireTime(fireTimeMinutes:TimeInterval) -> UILocalNotification {
        
        let message = localizedString("abandoned_cart_notification_message_24_Hour", comment: "")
        
        let localNotification = UILocalNotification()
        var dict = NSDictionary()
        dict = ["type" : "24 Hour"]
        localNotification.userInfo = dict as? [AnyHashable: Any]
        localNotification.applicationIconBadgeNumber = 0
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.alertBody = message
        localNotification.fireDate = Date().addingTimeInterval(fireTimeMinutes * 60)
        
        return localNotification
    }
    
    fileprivate func createLocalNotificationWith72HourFireTime(fireTimeMinutes:TimeInterval) -> UILocalNotification {
        
        let message = localizedString("abandoned_cart_notification_message_72_Hour", comment: "")
        
        let localNotification = UILocalNotification()
        var dict = NSDictionary()
        dict = ["type" : "72 Hour"]
        localNotification.userInfo = dict as? [AnyHashable: Any]
        localNotification.applicationIconBadgeNumber = 0
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.alertBody = message
        localNotification.fireDate = Date().addingTimeInterval(fireTimeMinutes * 60)
        
        return localNotification
    }
    
    private func updateDeviceTokenToServer(_ deviceTokenString:String){
        
        guard UserDefaults.isUserLoggedIn() else {return}
        
        ElGrocerApi.sharedInstance.registerDeviceToServerWithToken(deviceToken: deviceTokenString) { (result:Bool, responseObject:NSDictionary?) in
            if result {
                print("SERVER Response:%@",responseObject ?? "Dictionary Error")
            } else {
                print("Error from SERVER While register device on SERVER")
            }
        }
    }
}
