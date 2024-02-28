//
//  AppDelegate.swift
//  el-grocer-shopper-sdk-iOS
//  for xcode 15 support from 1.8.8
// from origin/2023Q4/Checkout3.0_Merged_Developmemt commit => Merge branch '2023Q4/Checkout3.0' into 2023Q4/Checkout3.0_Merged_Developmemt

/*
 
 import UIKit
 import IQKeyboardManagerSwift
 import Firebase
 import el_grocer_shopper_sdk_iOS

 
// to install elgrocer shopper directly use this ... Please change bundle id to verify things
private enum BackendSuggestedAction: Int {
    case Continue = 0
    case ForceUpdate = 1
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  {
    
    let shopperManager: SDKManagerType = SDKManagerShopper.shared
    var appStartTime : Date?
    var window: UIWindow?
    var backgroundUpdateTask: UIBackgroundTaskIdentifier! = .invalid
    var bgtimer : Timer?
    lazy var backgroundURLSession : URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.elgorcer.background")
        configuration.isDiscretionary = true
        configuration.timeoutIntervalForRequest = 30
        return URLSession(configuration: configuration, delegate: self as? URLSessionDelegate , delegateQueue: OperationQueue.main)
    }()
    
    var  currentTabBar  : UITabBarController?
    
     var parentTabNav  : ElgrocerGenericUIParentNavViewController?
  
    // MARK: App lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //  DBPubicAccessForDummyAppOnly.resetDB() // do this for fresh install every time
        // by default setting 0 for shopper lat
        let userLoginOption = LaunchOptions(.shopper, nil,EnvironmentType.staging)
        ElGrocer.start(with: userLoginOption) // launch shopper app
        return shopperManager.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return shopperManager.application(application, supportedInterfaceOrientationsFor: window)
    }
    
    @objc
    func refreshSessionStatesForEditOrder() {
        shopperManager.refreshSessionStatesForEditOrder()
    }
   
    @objc
    func configuredElgrocerEventLogger(_ launchOptions : [UIApplication.LaunchOptionsKey: Any]?) {
        shopperManager.configuredElgrocerEventLogger(launchOptions)
    }

    func checkAdvertPermission () {
        shopperManager.checkAdvertPermission()
    }
   
    func startChatFeature() {
        shopperManager.startChatFeature()
    }
    
    func scheduleAppRefresh() {
        shopperManager.scheduleAppRefresh()
    }
       
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        shopperManager.applicationWillEnterForeground(application)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        shopperManager.applicationDidBecomeActive(application)
    }
   
    func applicationWillTerminate(_ application: UIApplication) {
        shopperManager.applicationWillTerminate(application)
    }
    
    func deleteBasketFromServerWithGrocery(_ grocery:Grocery?){
        shopperManager.deleteBasketFromServerWithGrocery(grocery)
    }
    
  
    
    func open(_ url: URL, options: [String : Any] = [:], completionHandler completion: ((Bool) -> Swift.Void)? = nil) {
        shopperManager.open(url, options: options) { value in
            completion?(value)
        }
    }
    
    
    
    
        // Respond to URI scheme links
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return shopperManager.application(app, open: url, options: options)
    }
    
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        shopperManager.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return shopperManager.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }

    // Respond to Universal Links
     func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                      restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
         return shopperManager.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    // MARK: Methods
    func initializeExternalServices(_ application: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        shopperManager.initializeExternalServices(application, didFinishLaunchingWithOptions: didFinishLaunchingWithOptions)
    }
    
    func configureFireBase(){
        shopperManager.configureFireBase()
    }
    
    func initiliazeMarketingCampaignTrackingServices() {
        shopperManager.initiliazeMarketingCampaignTrackingServices()
    }
    

    func showGenericStoreUI() {
        shopperManager.showGenericStoreUI()
    }
    func showForceUpdateView() {
        shopperManager.showForceUpdateView()
    }
    
     func showAnimatedSplashView() {
         shopperManager.showAnimatedSplashView()
    }
    
    
     func showEntryView() {
         shopperManager.showEntryView()
    }
    
   
    func showAppWithMenu() {
    }
    
    func showAppWithMenu(_ isNeedToShowChangeStoreByDefault : Bool = false) {
        shopperManager.showAppWithMenu(isNeedToShowChangeStoreByDefault)
    }
    
    func makeRootViewController( controller : UIViewController) {
        shopperManager.makeRootViewController(controller: controller)
    }
    
    func getTabbarController(isNeedToShowChangeStoreByDefault : Bool , selectedGrocery : Grocery? = nil ,_  selectedBannerLink : BannerLink? = nil ) -> UINavigationController {
        
        return shopperManager.getTabbarController(isNeedToShowChangeStoreByDefault: isNeedToShowChangeStoreByDefault, selectedGrocery: selectedGrocery, selectedBannerLink)
     
    }
    
    func logoutAndShowEntryView() {
        shopperManager.logoutAndShowEntryView()
    }
    
    func logout() {
        shopperManager.logout()
    }
    
    func getCurrentAppVersion() -> String {
        shopperManager.getCurrentAppVersion()
    }

    // MARK: Network state
    @objc func networkStatusDidChanged(_ notification: NSNotification?) {
        shopperManager.networkStatusDidChanged(notification)
    }
    
    // MARK: Notifications
    func registerForNotifications() {
        shopperManager.registerForNotifications()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        shopperManager.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    func chatNotifcationFromZenDesk (_ msg : String) {
        shopperManager.chatNotifcationFromZenDesk(msg)
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        shopperManager.application(application, didReceive: notification)
    }
    
    /** For iOS 10 and above - Foreground**/
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        shopperManager.userNotificationCenter(center, willPresent: notification) { option in
            completionHandler(option)
        }
    }
  
    func checkForNotificationAtAppLaunch(_ application: UIApplication, userInfo: [AnyHashable: Any]?) {
        shopperManager.checkForNotificationAtAppLaunch(application, userInfo: userInfo)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        shopperManager.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error While Register For Remote Notifications:%@",error.localizedDescription)
      //  PushNotificationManager.push().handlePushRegistrationFailure(error)
    }
    
    func resetUserDefaultsOnFirstRun() {
        shopperManager.resetUserDefaultsOnFirstRun()
    }
    
    func setupLanguage() {
        shopperManager.setupLanguage()
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        shopperManager.application(application) { result in
            completionHandler(result)
        }
    }
    
    // MARK: HelpshiftDelegate
    
    fileprivate func helpshiftChatMessageUnread() {
        
//        NotificationCenter.default.post(name: Notification.Name(rawValue: kHelpshiftChatResponseNotificationKey), object: nil)
    }
    
    func didReceiveNotificationCount(_ count: Int) {
        
        if count > 0 {
            helpshiftChatMessageUnread()
        }
    }

}

extension AppDelegate {
    
    func beginBackgroundUpdateTask() {
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }
    func endBackgroundUpdateTask() {
        shopperManager.endBackgroundUpdateTask()
    }
    
    func doBackgroundTask() {
        shopperManager.doBackgroundTask()
    }
    @objc
    func endProgress() {
        shopperManager.endProgress()
    }
   
}

*/


import UIKit
import IQKeyboardManagerSwift
import Firebase
import el_grocer_shopper_sdk_iOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
 
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
    
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return ElGrocer.HandleAdyenUrl(url)
    }


}

