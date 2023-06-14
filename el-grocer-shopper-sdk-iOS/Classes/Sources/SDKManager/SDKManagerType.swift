//
//  SDKManagerType.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 14/09/2022.
//

import UIKit
import CoreData
import FirebaseCrashlytics
import GoogleMaps
import GooglePlaces
import UserNotifications
//import AFNetworking
import BackgroundTasks
import IQKeyboardManagerSwift
import CleverTapSDK
import AdSupport
//import AppsFlyerLib
import FBSDKCoreKit
import FirebaseCore
import Messages
import FirebaseMessaging
//import AFNetworkActivityLogger
import SendBirdUIKit
import SwiftDate
import Adyen

public protocol SDKManagerType: CleverTapInAppNotificationDelegate {
    var sdkStartTime: Date? { get }
    var window: UIWindow? { get }
    var backgroundUpdateTask: UIBackgroundTaskIdentifier! { get }
    var bgtimer: Timer? { get }
    var backgroundURLSession: URLSession { get set }
    var currentTabBar: UITabBarController? { get }
    var parentTabNav: ElgrocerGenericUIParentNavViewController? { get }
    var launchOptions: LaunchOptions? { get set }
    var rootViewController: UIViewController? { get set }
    var homeLastFetch : Date? { get set }
    var isSmileSDK: Bool { get }
    var isGrocerySingleStore: Bool { get }
    var isShopperApp: Bool { get }
    
    
    var kGoogleMapsApiKey: String { get }
    
    // Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    func refreshSessionStatesForEditOrder()
    func configuredElgrocerEventLogger(_ launchOptions: [UIApplication.LaunchOptionsKey : Any]?)
    func checkAdvertPermission()
    func startChatFeature()
    func scheduleAppRefresh()
    @available(iOS 13.0, *)
    func handleAppRefresh(task: BGAppRefreshTask)
    func applicationWillResignActive(_ application: UIApplication)
    func applicationDidEnterBackground(_ application: UIApplication)
    func applicationWillEnterForeground(_ application: UIApplication)
    func applicationDidBecomeActive(_ application: UIApplication)
    func applicationWillTerminate(_ application: UIApplication)
    func deleteBasketFromServerWithGrocery(_ grocery: Grocery?)
    func open(_ url: URL, options: [String : Any], completionHandler completion: ((Bool) -> Swift.Void)?)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool
    func initializeExternalServices(_ application: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey : Any]?)
    func configureFireBase()
    func initiliazeMarketingCampaignTrackingServices()
    func showGenericStoreUI()
    func showForceUpdateView()
    func showAnimatedSplashView()
    func showEntryView()
    func showEntryViewWithSuccessClouser(_ completion:@escaping ((_ manager: SDKLoginManager?) -> Void))
    func showAppWithMenu()
    func showAppWithMenu(_ isNeedToShowChangeStoreByDefault: Bool)
    func makeRootViewController(controller: UIViewController)
    func getTabbarController(isNeedToShowChangeStoreByDefault: Bool, selectedGrocery: Grocery?, _ selectedBannerLink: BannerLink?) -> UINavigationController
    func logoutAndShowEntryView()
    func logout()
    func logout(completion: (() -> Void)?)
    func getCurrentAppVersion() -> String
    func networkStatusDidChanged(_ notification: NSNotification?)
    func registerForNotifications()
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any])
    func zendeskNotifcationHandling(_ requestID: String)
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    func chatNotifcationFromZenDesk(_ msg: String)
    func application(_ application: UIApplication, didReceive notification: UILocalNotification)
    /** For iOS 10 and above - Foreground**/
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void)
    func checkForNotificationAtAppLaunch(_ application: UIApplication, userInfo: [AnyHashable : Any]?)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String)
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    func scheduleAbandonedBasketNotification()
    func scheduleAbandonedBasketNotificationAfter24Hour()
    func scheduleAbandonedBasketNotificationAfter72Hour()
    func resetUserDefaultsOnFirstRun()
    func setupLanguage()
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    func didReceiveNotificationCount(_ count: Int)
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool
    func beginBackgroundUpdateTask()
    func endBackgroundUpdateTask()
    func doBackgroundTask()
    func endProgress()
    func inAppNotificationButtonTapped(withCustomExtras customExtras: [AnyHashable : Any]!)
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    func setSendbirdDelegate()
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage)
    func channel(_ sender: SBDBaseChannel, didUpdate message: SBDBaseMessage)
    func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64)
    func channel(_ channel: SBDBaseChannel, didReceiveMention message: SBDBaseMessage)
    func channelWasChanged(_ sender: SBDBaseChannel)
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType)
    func channelWasFrozen(_ sender: SBDBaseChannel)
    func channelWasUnfrozen(_ sender: SBDBaseChannel)
    func channel(_ sender: SBDBaseChannel, createdMetaData: [String : String]?)
    func channel(_ sender: SBDBaseChannel, updatedMetaData: [String : String]?)
    func channel(_ sender: SBDBaseChannel, deletedMetaDataKeys: [String]?)
    func channel(_ sender: SBDBaseChannel, createdMetaCounters: [String : NSNumber]?)
    func channel(_ sender: SBDBaseChannel, updatedMetaCounters: [String : NSNumber]?)
    func channel(_ sender: SBDBaseChannel, deletedMetaCountersKeys: [String]?)
    func channelWasHidden(_ sender: SBDGroupChannel)
    func channel(_ sender: SBDGroupChannel, didReceiveInvitation invitees: [SBDUser]?, inviter: SBDUser?)
    func channel(_ sender: SBDGroupChannel, didDeclineInvitation invitee: SBDUser?, inviter: SBDUser?)
    func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser)
    func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser)
    func channelDidUpdateDeliveryReceipt(_ sender: SBDGroupChannel)
    func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel)
    func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel)
    func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser)
    func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser)
    func channel(_ sender: SBDBaseChannel, userWasMuted user: SBDUser)
    func channel(_ sender: SBDBaseChannel, userWasUnmuted user: SBDUser)
    func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser)
    func channel(_ sender: SBDBaseChannel, userWasUnbanned user: SBDUser)
    func channelDidChangeMemberCount(_ channels: [SBDGroupChannel])
    func channelDidChangeParticipantCount(_ channels: [SBDOpenChannel])
    func start(with launchOptions: LaunchOptions?)
    
}

public extension SDKManagerType {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool { return false }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask { .portrait }
    func configuredElgrocerEventLogger(_ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) { }
    func applicationWillResignActive(_ application: UIApplication) { }
    func applicationDidEnterBackground(_ application: UIApplication) { }
    func applicationWillEnterForeground(_ application: UIApplication) { }
    func applicationDidBecomeActive(_ application: UIApplication) { }
    func applicationWillTerminate(_ application: UIApplication) { }
    func open(_ url: URL, options: [String : Any], completionHandler completion: ((Bool) -> Void)?) { }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool { return false }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool { return false }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool { return false }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool { return false }
    func initializeExternalServices(_ application: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey : Any]?) { }
    func logout() { }
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool { return false }
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool { return false }
    func showEntryViewWithSuccessClouser(_ completion:@escaping ((_ manager: SDKLoginManager?) -> Void)) { }
    func getTabbarController(isNeedToShowChangeStoreByDefault : Bool , selectedGrocery : Grocery? = nil ,_  selectedBannerLink : BannerLink? = nil ) -> UINavigationController {
        return getTabbarController(isNeedToShowChangeStoreByDefault: isNeedToShowChangeStoreByDefault, selectedGrocery: selectedGrocery, selectedBannerLink)
    }
    
    func logout(completion: (() -> Void)? = nil) {
        logout(completion: completion)
    }
}
