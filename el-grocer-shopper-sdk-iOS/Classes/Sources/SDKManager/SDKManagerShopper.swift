//
//  SDKManagerShopper.swift
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
import FirebaseDynamicLinks
import FirebaseAnalytics
import FirebaseAuth
//import AFNetworkActivityLogger
import SendBirdUIKit
import SwiftDate
import Adyen
import Segment
import Segment_CleverTap

private enum BackendSuggestedAction: Int {
    case Continue = 0
    case ForceUpdate = 1
}

public class SDKManagerShopper: NSObject, SDKManagerType, SBDChannelDelegate {
    public static var shared: SDKManagerType = SDKManagerShopper()
    
    public var sdkStartTime: Date?
    public var window: UIWindow?
    public var backgroundUpdateTask: UIBackgroundTaskIdentifier! = .invalid
    public var bgtimer : Timer?
    public var launchOptions: LaunchOptions? = nil
    public var rootViewController: UIViewController?
    public var homeLastFetch: Date?
    public var isSmileSDK: Bool { false }
    public var isGrocerySingleStore: Bool { false }
    public var isShopperApp: Bool { true }
    public var kGoogleMapsApiKey: String { "AIzaSyA9ItTIGrVXvJASLZXsokP9HEz-jf1PF7c" }
    public var isInitialized: Bool = false
    
    lazy public var backgroundURLSession : URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.elgorcer.background")
        configuration.isDiscretionary = true
        configuration.timeoutIntervalForRequest = 30
        return URLSession(configuration: configuration, delegate: self as? URLSessionDelegate , delegateQueue: OperationQueue.main)
    }()
    
    public var  currentTabBar  : UITabBarController?
    
    public var parentTabNav  : ElgrocerGenericUIParentNavViewController?
    
    private override init() {
        super.init()
        
        window = .key
    }
    
    // MARK: App lifecycle
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SwiftDate.defaultRegion = Region.getCurrentRegion()
        self.sdkStartTime = Date()
        
        //init network state monitoring
        NotificationCenter.default.addObserver(self, selector: #selector(SDKManagerShopper.networkStatusDidChanged(_:)), name:NSNotification.Name(rawValue: kReachabilityManagerNetworkStatusChangedNotificationCustom), object: nil)
        _ = ReachabilityManager.sharedInstance
        
        self.refreshSessionStatesForEditOrder()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.showAnimatedSplashView()
        
        Thread.sleep(forTimeInterval: 0.2)
        self.setSendbirdDelegate()
        self.initializeExternalServices(application, didFinishLaunchingWithOptions: launchOptions)
        ElGrocerUtility.sharedInstance.resetBasketPresistence()
        self.checkForNotificationAtAppLaunch(application, userInfo: launchOptions)
        self.checkNotifcation()
        self.logApiError()
        
        return true
    }
    
    public func start(with launchOptions: LaunchOptions?) {
        
    }
    
    public func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    @objc
    public func refreshSessionStatesForEditOrder() {
        if UserDefaults.isNeedToClearEditOrder() {
            UserDefaults.setClearEditOrder(false)
            ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
            UserDefaults.removeOrderFromEdit()
            if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                self.deleteBasketFromServerWithGrocery(grocery)
            }
        }
    }
    
    @objc
    public func configuredElgrocerEventLogger(_ launchOptions : [UIApplication.LaunchOptionsKey: Any]?) {
        
        ElGrocerUtility.sharedInstance.delay(5) {
            self.checkAdvertPermission ()
        }
        
        //Google Analytics
        GoogleAnalyticsHelper.configureGoogleAnalytics()
        self.initiliazeMarketingCampaignTrackingServices()
        CleverTapEventsLogger.shared.startCleverTapSharedSDK()
        self.logApiError()
        ElGrocerEventsLogger.sharedInstance.firstOpen()
        //AppsFlyer
//        AppsFlyerLib.shared().appsFlyerDevKey = "fFWrKTcB3XBybYmSgAcLnP"
//        AppsFlyerLib.shared().appleAppID = "1040399641"
//        // AppsFlyerLib.shared().delegate = self
//        if Platform.isDebugBuild {
//            AppsFlyerLib.shared().isDebug = true
//        }
//        AppsFlyerLib.shared().customerUserID = CleverTap.sharedInstance()?.profileGetID()
//        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 30)
        AlgoliaApi.sharedInstance.reStartInsights()
        ElGrocerUtility.sharedInstance.delay(2) {
            self.startChatFeature()
        }
        
        
    }
    
    public func checkAdvertPermission () {
        
//        MarketingCampaignTrackingHelper.sharedInstance.isAdvertRequestPermission { (reuslt) in
//            FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: FireBaseElgrocerPrefix + "AdvertRequestPermission", parameter: ["isPermissionGranted" : reuslt])
//        }
        
        Settings.isAdvertiserIDCollectionEnabled = true
        Settings.setAdvertiserTrackingEnabled(true)
        Settings.isAutoLogAppEventsEnabled = true
        Analytics.setAnalyticsCollectionEnabled(true)
        
    }
    
    public func startChatFeature() {
        
        //   self.configureZenDesk()
        
    }
    
    public func scheduleAppRefresh() {
        
    }
    
    @available(iOS 13.0, *)
    public func handleAppRefresh(task: BGAppRefreshTask) {
    }
    
    fileprivate func checkNotifcation() {
        
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications {
            debugPrint("User is registered for notification")
            self.registerForNotifications()
        } else {
            debugPrint("Show alert user is not registered for notification")
            
        }
        
    }
    
    
    fileprivate func logApiError () {
        
        NotificationCenter.default.addObserver(self,selector: #selector(SDKManagerShopper.logToCrashleytics(_:)), name: NSNotification.Name(rawValue: "api-error"), object: nil)
        
    }
    
    @objc
    fileprivate func logToCrashleytics(_ notifcation : NSNotification) {
        
        if let error = notifcation.object as? NSError {
            if let urlstring : URL  = error.userInfo["NSErrorFailingURLKey"] as? URL {
                if urlstring.absoluteString.contains("payment") {
                    return
                }
            }
            if var apiData = notifcation.userInfo as? [String : Any] {
                apiData[FireBaseParmName.SessionID.rawValue] = ElGrocerUtility.sharedInstance.getGenericSessionID()
                FirebaseCrashlytics.Crashlytics.crashlytics().record(error: error.addItemsToUserInfo(newUserInfo: apiData))
                FireBaseEventsLogger.trackCustomEvent(eventType: "errorToParse", action: "error.localizedDescription : \(error.localizedDescription)"  ,  apiData  , false)
            }else{
                FirebaseCrashlytics.Crashlytics.crashlytics().record(error: error.addItemsToUserInfo(newUserInfo:  [ FireBaseParmName.SessionID.rawValue : ElGrocerUtility.sharedInstance.getGenericSessionID() ]))
                
                FireBaseEventsLogger.trackCustomEvent(eventType: "errorToParse", action: "error.localizedDescription : \(error.localizedDescription)" , [:] , false )
            }
        }
    }
    
    //    fileprivate func configurePushWoosh(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    //        let pushManager:PushNotificationManager  = PushNotificationManager.push();
    //        pushManager.delegate = self;
    //        PushNotificationManager.push().handlePushReceived(launchOptions);
    //    }
    //
    //    fileprivate func startPushWooshAnalytics() {
    //
    //        PushNotificationManager.push().sendAppOpen()
    //        PWGeozonesManager.shared()?.delegate = self
    //
    //    }
    
    fileprivate func configureZenDesk() {
        
        // ZenDesk.sharedInstance.initailized()
    }
    
    
    
    
    public func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    public func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        // self.doBackgroundTask()
        // scheduleAppRefresh()
    }
    
    public func applicationWillEnterForeground(_ application: UIApplication) {
        
        if let timer = self.bgtimer {
            timer.invalidate()
            self.bgtimer  = nil
        }
        
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
//        AppsFlyerLib.shared().start()
//        AppEvents.activateApp()
        
        
        if UserDefaults.getLogInUserID() != "0" {
            FireBaseEventsLogger.setUserID(UserDefaults.getLogInUserID())
        }else{
            FireBaseEventsLogger.setUserID(ElGrocerUtility.sharedInstance.getGenericSessionID())
        }
        
    }
    
    public func applicationWillTerminate(_ application: UIApplication) {
        
        
        
        
        if ElGrocerUtility.sharedInstance.isItemInBasket {
            FireBaseEventsLogger.setUserProperty("1", key: FireBaseEventsName.AbandonBasket.rawValue)
            FireBaseEventsLogger.logEventToFirebaseWithEventName(eventName: FireBaseEventsName.AbandonBasket.rawValue)
        }else{
            FireBaseEventsLogger.setUserProperty("0", key: FireBaseEventsName.AbandonBasket.rawValue)
        }
        
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        let phoneLanguage = UserDefaults.getCurrentLanguage()
        if phoneLanguage == "ar" {
            LanguageManager.sharedInstance.setLocale("ar")
        }else{
            LanguageManager.sharedInstance.setLocale("Base")
        }
        let products = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        if products.count > 0 {
            ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("abandon_basket")
        }
    }
    
    public func deleteBasketFromServerWithGrocery(_ grocery:Grocery?){
        
        guard UserDefaults.isUserLoggedIn() else {return}
        
        ElGrocerApi.sharedInstance.deleteBasketFromServerWithGrocery(grocery) { (result) in
            switch result {
            case .success(let responseDict):
                print("Delete Basket Response:%@",responseDict)
                
            case .failure(let error):
                print("Delete Basket Error:%@",error.localizedMessage)
            }
        }
    }
    
    
    
    public func open(_ url: URL, options: [String : Any] = [:],
              completionHandler completion: ((Bool) -> Swift.Void)? = nil) {
        CleverTap.sharedInstance()?.handleOpen(url, sourceApplication: nil)
        completion?(false)
    }
    
    
    
    
    // Respond to URI scheme links
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        if Auth.auth().canHandle(url) {
            return true
        }
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url){
            print("I'm Handling a link through the OpenURL method.")
            print("Your Imcomming Url Parameter is:%@",dynamicLink.url ?? "DynamicLink URL is Null")
            if let urlString = dynamicLink.url?.absoluteString {
                ElGrocerUtility.sharedInstance.deepLinkURL = urlString
                ElGrocerUtility.sharedInstance.deepLinkShotURL = url.absoluteString
                print("Deep Link URL Str:%@",ElGrocerUtility.sharedInstance.deepLinkURL)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDeepLinkNotificationKey), object: nil)
                FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: "EG_DeepLink", parameter: ["url" : urlString , "DeepLink" : url.absoluteString])
            }
            return true
        }
        
        
        
        return application(app, open: url,
                           sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                           annotation: "") || RedirectComponent.applicationDidOpen(from: url)
    }
    
    
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if Auth.auth().canHandle(url) {
            return true
        }
        
        
        
        let dynamicLinksss = DynamicLinks.dynamicLinks()
        let _ = dynamicLinksss.handleUniversalLink(url) { (dynamiclink, error) in
            if let dynamiclink = dynamiclink, let _ = dynamiclink.url {
                ElGrocerUtility.sharedInstance.deepLinkURL = (dynamiclink.url?.absoluteString)!
                NotificationCenter.default.post(name: Notification.Name(rawValue: kDeepLinkNotificationKey), object: nil)
            }
        }
        CleverTap.sharedInstance()?.handleOpen(url, sourceApplication: sourceApplication)
        
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) || RedirectComponent.applicationDidOpen(from: url)
    }
    
    
    
    
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        let dynamicLinks = DynamicLinks.dynamicLinks()
        let urlCameFrom = userActivity.webpageURL?.getQueryItemValueForKey("_osl")
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            
            if let dynamiclink = dynamiclink, let urlString = dynamiclink.url {
                ElGrocerUtility.sharedInstance.deepLinkURL = (dynamiclink.url?.absoluteString)!
                print("Deep Link URL Str:%@",ElGrocerUtility.sharedInstance.deepLinkURL)
                DynamicLinksHelper.handleIncomingDynamicLinksWithUrl(ElGrocerUtility.sharedInstance.deepLinkURL)
                ElGrocerUtility.sharedInstance.deepLinkShotURL = urlCameFrom ?? urlString.absoluteString
                
                FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: "EG_DeepLink", parameter: ["url" : urlString.absoluteString , "DeepLink" : urlCameFrom ?? urlString.absoluteString])
            }
        }
        return handled
        
    }
    
    
    //    @available(iOS 13.0, *)
    //    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    //        guard let _ = (scene as? UIWindowScene) else { return }
    //
    //        if let userActivity = connectionOptions.userActivities.first {
    //            if let incomingURL = userActivity.webpageURL {
    //                _ = DynamicLinks.dynamicLinks()?.handleUniversalLink(incomingURL) { (dynamicLink, error) in
    //                    guard error == nil else { return }
    //                    if let dynamicLink = dynamicLink {
    //                        //your code for handling the dynamic link goes here
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    
    // Respond to Universal Links
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        let dynamicLinks = DynamicLinks.dynamicLinks()
        
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            
            if let dynamiclink = dynamiclink, let _ = dynamiclink.url {
                print("Your Imcomming Url Parameter is:%@",dynamiclink.url ?? "NUll")
                ElGrocerUtility.sharedInstance.deepLinkURL = (dynamiclink.url?.absoluteString)!
                print("Deep Link URL Str:%@",ElGrocerUtility.sharedInstance.deepLinkURL)
                NotificationCenter.default.post(name: Notification.Name(rawValue: kDeepLinkNotificationKey), object: nil)
            }
        }
        
        return handled
    }
    
    // MARK: Methods
    public func initializeExternalServices(_ application: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        
        //crashlitics
#if DEBUG
        /*Fabric.sharedSDK().debug = true
         <<<<<<< HEAD
         Crashlytics.sharedInstance().delegate = self
         Fabric.with([Crashlytics.self(), MoPub.self()])
         Fabric.with([Crashlytics.self(), Answers.self()])*/
#else
        //        Fabric.with([Crashlytics.self(), MoPub.self()])
        //        Fabric.with([Crashlytics.self(), Answers.self()])
#endif
        
        //MARK: swizzling view will appear call for screen name event logging
        //        UIViewController.swizzleViewDidAppear()
        
        //Firebase Analytics
        // FirebaseApp.configure()
        self.configureFireBase()
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        
        //Google Analytics
        GoogleAnalyticsHelper.configureGoogleAnalytics()
        
        // Intercom
        // Intercom.setApiKey(IntercomeHelper.apiKey, forAppId: IntercomeHelper.appId)
        
        // Marketing
        self.initiliazeMarketingCampaignTrackingServices()
        
        //MARK: Mispanel Initialization
        MixpanelManager.configMixpanel()
        
        //MARK: sendBird
        
        
        SendBirdDeskManager(type: .agentSupport).setUpSenBirdDeskWithCurrentUser(isWithChat: false)
        
        // MARK: Segment Initialization
        self.initializeSegment()
        
        // Initialize Facebook SDK
//        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: didFinishLaunchingWithOptions)
        
        // Google Maps
        GMSPlacesClient.provideAPIKey(kGoogleMapsApiKey)
        GMSServices.provideAPIKey(kGoogleMapsApiKey)
        
        self.isInitialized = true
//        self.configuredElgrocerEventLogger(didFinishLaunchingWithOptions)
        
        //        let action1 = UNNotificationAction(identifier: "action_1", title: "Back", options: [])
        //        let action2 = UNNotificationAction(identifier: "action_2", title: "Next", options: [])
        let action3 = UNNotificationAction(identifier: "action_3", title: "View In App", options: [])
        let category = UNNotificationCategory(identifier: "CTNotification", actions: [action3], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
    }
    
    public func startBasicThirdPartyInit() { }
    
    private func initializeSegment() {
        let key = self.launchOptions?.environmentType == .live ? "cSnpTPUfDsW8zvEiA1AslFPegtWjNIlo"
        : "twDPG5a7cEYzQFkJ0P6WRT5kZiY6ut5b"
        
        let configuration = AnalyticsConfiguration(writeKey: "segmentSDKWriteKey")

        configuration.use(SEGCleverTapIntegrationFactory())
        configuration.flushAt = 3
        configuration.flushInterval = 10
        configuration.trackApplicationLifecycleEvents = false
        
        Segment.Analytics.setup(with: configuration)
    }
    
    public func configureFireBase(){
        // ElGrocerApi.sharedInstance.baseApiPath == "https://el-grocer-admin.herokuapp.com/api/"
#if DEBUG
        debugFirebaseSetting()
#else
        if ElGrocerApi.sharedInstance.baseApiPath == "https://el-grocer-staging-dev.herokuapp.com/api/" {
            debugFirebaseSetting()
        }else{
            productionFirebaseSetting()
        }
#endif
    }
    
    fileprivate func debugFirebaseSetting() {
        
        var filePath:String!
        filePath = Bundle.resource.path(forResource: "GoogleService-Info-SandBox", ofType: "plist")
        let projectName = "elgrocer"
        let options = FirebaseOptions.init(contentsOfFile: filePath)!
        options.deepLinkURLScheme = "elgrocer.com.ElGrocerShopper"
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "elgrocersandboxshopper.page.link"
        FirebaseApp.app(name: projectName)?.options.deepLinkURLScheme = "elgrocersandboxshopper.page.link"
        if NSClassFromString("XCTest") != nil {
        } else {
            FirebaseApp.configure(options: options)
        }
//        let networkLogger = AFNetworkActivityLogger.shared()
//        networkLogger?.startLogging()
//        networkLogger?.setLogLevel(.AFLoggerLevelDebug)
        
        
        
    }
    
    fileprivate func productionFirebaseSetting() {
        // FirebaseApp.configure() // defualt info plist
        var filePath:String!
        filePath = Bundle.resource.path(forResource: "GoogleService-Info", ofType: "plist")
        let options = FirebaseOptions.init(contentsOfFile: filePath)!
        FirebaseApp.configure(options: options)
    }
    
    
    public func initiliazeMarketingCampaignTrackingServices() {
//        MarketingCampaignTrackingHelper.sharedInstance.initializeMarketingCampaignTrackingServices()
    }
    
    // MARK: App Structure
    
    // Replaces the root view controller with the specified controller
    fileprivate func replaceRootControllerWith<T: UIViewController>(_ controller: T) {
        
        
        if self.window?.rootViewController != nil {
            
            self.window?.rootViewController = controller
            //                UIView.transition(with: self.window!, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: {
            //
            //
            //                }, completion: nil)
            
        } else {
            self.window?.rootViewController = controller
            self.window?.makeKeyAndVisible()
        }
        
    }
    
    
    
    
    public func showGenericStoreUI() {
        let entryController =  ElGrocerViewControllers.ElgrocerParentTabbarController()
        let navController = ElgrocerGenericUIParentNavViewController(navigationBarClass: ElgrocerWhilteLogoBar.self, toolbarClass: nil)
        navController.viewControllers = [entryController]
        navController.modalPresentationStyle = .fullScreen
        self.replaceRootControllerWith(navController)
    }
    
    
    public func showForceUpdateView() {
        DispatchQueue.main.async {
            let forceUpdateController = ElGrocerViewControllers.forceUpdateViewController()
            self.replaceRootControllerWith(forceUpdateController)
        }
    }
    
    public func showAnimatedSplashView() {
        
        
        let entryController =  ElGrocerViewControllers.splashAnimationViewController()
        let navEntryController : ElGrocerNavigationController = ElGrocerNavigationController.init(rootViewController: entryController)
        navEntryController.hideNavigationBar(true)
        rootViewController = navEntryController
        self.replaceRootControllerWith(navEntryController)
    }
    
//    public func showEntryViewWithSuccessClouser(_ completion:@escaping ((_ manager: SDKLoginManager?) -> Void)) {
//
//        let entryController =  ElGrocerViewControllers.signInViewController()
//        let navEntryController : ElGrocerNavigationController = ElGrocerNavigationController.init(rootViewController: entryController)
//        navEntryController.hideNavigationBar(true)
//        self.replaceRootControllerWith(navEntryController)
//        completion(nil)
//    }
    
    
    public func showEntryView() {
        
        
        let entryController =  ElGrocerViewControllers.signInViewController()
        let navEntryController : ElGrocerNavigationController = ElGrocerNavigationController.init(rootViewController: entryController)
        navEntryController.hideNavigationBar(true)
        self.replaceRootControllerWith(navEntryController)
    }
    
    
    public func showAppWithMenu() {
        
        self.showAppWithMenu(false)
        
    }
    
    public func showAppWithMenu(_ isNeedToShowChangeStoreByDefault : Bool = false) {
        
        if let rootVC = self.window?.rootViewController {
            rootVC.navigationController?.popToRootViewController(animated: false)
            rootVC.navigationController?.dismiss(animated: false) {  }
            rootVC.view.removeFromSuperview()
            self.window?.rootViewController = nil
        }
        
        let tabVC = self.getTabbarController(isNeedToShowChangeStoreByDefault: false)
        if let main = self.window {
            main.rootViewController =  tabVC     // getParentNav()
            main.makeKeyAndVisible()
        }
        
    }
    
    public func makeRootViewController( controller : UIViewController) {
        if let rootVC = self.window?.rootViewController {
            rootVC.navigationController?.popToRootViewController(animated: false)
            rootVC.navigationController?.dismiss(animated: false) {  }
            rootVC.view.removeFromSuperview()
            self.window?.rootViewController = nil
            self.parentTabNav = nil
            ElGrocerUtility.sharedInstance.CurrentLoadedAddress = ""
        }
        if let main = self.window {
            main.rootViewController = controller
            main.makeKeyAndVisible()
        }
        
    }
    
    public func getTabbarController(isNeedToShowChangeStoreByDefault : Bool , selectedGrocery : Grocery? = nil ,_  selectedBannerLink : BannerLink? = nil ) -> UINavigationController {
        
        
        
        let tabController = UITabBarController()
        tabController.delegate = self
        let homeViewEmpty =  ElGrocerViewControllers.getGenericStoresViewController(HomePageData.shared)
        let storeMain = ElGrocerViewControllers.mainCategoriesViewController()
        storeMain.selectedBannerLink = selectedBannerLink
        let searchController = ElGrocerViewControllers.getSearchListViewController()
        let settingController = SettingViewController.make(viewModel: AppSetting.currentSetting.getSettingCellViewModel(), analyticsEventLogger: SegmentAnalyticsEngine())
        let myBasketViewController = ElGrocerViewControllers.myBasketViewController()
        
        let vcData: [(UIViewController, UIImage , String)] = [
            (homeViewEmpty, UIImage(name: "TabbarHome")!,NSLocalizedString("Home_Title", comment: "")),
            (storeMain, UIImage(name: "icStore")!,NSLocalizedString("Store_Title", comment: "")),
            (searchController, UIImage(name: "icTabBarshoppingList")! ,NSLocalizedString("Shopping_list_Titile", comment: "")),
            (settingController, UIImage(name: "TabbarProfile")!   ,NSLocalizedString("more_title", comment: "")),
            (myBasketViewController, UIImage(name: "TabbarCart")!   ,NSLocalizedString("Cart_Title", comment: ""))
        ]
        
        let vcs = vcData.map { (viewController, image , title) -> UINavigationController in
            let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
            navigationController.hideSeparationLine()
            navigationController.viewControllers = [viewController]
            navigationController.tabBarItem.image = image
            navigationController.tabBarItem.title = title
            navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -3, right: 0)
            // navigationController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: )
            return navigationController
        }
        
        //customize your tab bar
        tabController.viewControllers = vcs
        //        tabController.tabBar.barTintColor = UIColor(red: 238.0/255.0,green: 238.0/255.0,blue: 238.0/255.0,alpha:0.9)
        
        tabController.tabBar.backgroundColor = .white
        tabController.tabBar.barTintColor = .white
        tabController.tabBar.tintColor = UIColor.navigationBarColor()
        
        //595959
        
        //        tabController.tabBar.items![0].selectedImage = UIImage(name: "icHomeGreen")
        //        tabController.tabBar.items![1].selectedImage = UIImage(name: "icHomeGreen")
        //        tabController.tabBar.items![2].selectedImage = UIImage(name: "icBrowseGreen")
        //        tabController.tabBar.items![3].selectedImage = UIImage(name: "navSearchGreen")
        //       // tabController.tabBar.items![4].selectedImage = UIImage(name: "selectRecipeGree")
        //        tabController.tabBar.items![4].selectedImage = UIImage(name: "icMoreGreen")
        //
        //
        
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.SFProDisplayMediumFont(11),
             NSAttributedString.Key.foregroundColor: UIColor.colorWithHexString(hexString: "595959")],
            for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.SFProDisplayMediumFont(11),
             NSAttributedString.Key.foregroundColor: UIColor.navigationBarColor()],
            for: .selected)
        
        UITabBar.appearance().barTintColor = UIColor.colorWithHexString(hexString: "ffffff")
        
        
        tabController.tabBar.shadowImage =  UIImage.colorForNavBar(color: .colorWithHexString(hexString: "e4e4e4"))
        
        if #available(iOS 13, *) {
            
            let appearance = tabController.tabBar.standardAppearance
            appearance.shadowImage = UIImage.colorForNavBar(color: .colorWithHexString(hexString: "e4e4e4"))
            appearance.backgroundColor = UIColor.colorWithHexString(hexString: "ffffff")
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.colorWithHexString(hexString: "595959")
            appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = .colorWithHexString(hexString: "E83737")
            appearance.stackedLayoutAppearance.selected.iconColor =  UIColor.navigationBarColor()
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.font: UIFont.SFProDisplayMediumFont(11),NSAttributedString.Key.foregroundColor: UIColor.colorWithHexString(hexString: "595959")]
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.font:UIFont.SFProDisplayMediumFont(11),NSAttributedString.Key.foregroundColor:UIColor.navigationBarColor()]
            appearance.stackedItemPositioning = .automatic
            tabController.tabBar.standardAppearance = appearance
        }
        
        // color of background -> This works
        tabController.tabBar.barTintColor = UIColor.colorWithHexString(hexString: "ffffff")
        // This does not work
        tabController.tabBar.isTranslucent = false
        
        if #available(iOS 10.0, *) {
            tabController.tabBar.unselectedItemTintColor = UIColor.colorWithHexString(hexString: "595959")
            tabController.tabBar.tintColor =  UIColor.navigationBarColor()
        }
        
        let navtabController = UINavigationController()
        navtabController.isNavigationBarHidden = true;
        navtabController.viewControllers = [tabController]
        self.currentTabBar = tabController
        
        rootViewController = navtabController
        
        return navtabController
        
    }
    
    public func logoutAndShowEntryView() {
        
        
        DispatchQueue.main.async {
            self.showEntryView()
        }
        self.logout()
        
    }
    
    public func logout() {
        
        SendBirdManager().logout { success in
            if success{
                print("logout successfull")
            }else{
                print("error")
            }
        }
        
        ElGrocerUtility.sharedInstance.isDeliveryMode = true
        ElGrocerApi.sharedInstance.logoutUser { (result) -> Void in  }
        FireBaseEventsLogger.trackSignOut(true)
        AlgoliaApi.sharedInstance.resetAlgoliaLocalData()
        //ZohoChat.logOut()
        
        //smiles points values reset
        UserDefaults.setIsSmileUser(false)
        UserDefaults.setSmilesPoints(0)
        FireBaseEventsLogger.setUserID(nil)
        UserDefaults.setUserLoggedIn(false)
        UserDefaults.setLogInUserID("0")
        UserDefaults.setNavigateToHomeAfterInstall(false)
        UserDefaults.setLastSearchList("")
        resetUserDefaultsOnFirstRun()
        UserDefaults.resetEditOrder()
        UserDefaults.setAccessToken(nil)
        UserDefaults.setHelpShiftChatResponseUnread(false)
        UserDefaults.setPaymentAcceptedState(false)
        ElGrocerUtility.sharedInstance.CurrentLoadedAddress = ""
        ElGrocerUtility.sharedInstance.genericBannersA  = [BannerCampaign]()
        ElGrocerUtility.sharedInstance.storeTypeA = []
        ElGrocerUtility.sharedInstance.greatDealsBannersA  = [BannerCampaign]()
        ElGrocerUtility.sharedInstance.chefList   = [CHEF]()
        HomePageData.shared.resetHomeDataHandler()
        ElGrocerUtility.sharedInstance.recipeList = [:]
        SendBirdManager().createNewUserAndDeActivateOld()
        
        
        ElGrocerUtility.sharedInstance.delay(1) {
            
            DatabaseHelper.sharedInstance.clearDatabase(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            //cancel all previously scheduled notifications
            UIApplication.shared.cancelAllLocalNotifications()
            
            ElGrocerUtility.sharedInstance.deepLinkURL = ""
            
            ElGrocerUtility.sharedInstance.groceries.removeAll()
            ElGrocerUtility.sharedInstance.completeGroceries.removeAll()
            ElGrocerUtility.sharedInstance.bannerGroups.removeAll()
            ElGrocerUtility.sharedInstance.basketFetchDict.removeAll()
            ElGrocerUtility.sharedInstance.activeGrocery = nil
            ElGrocerUtility.sharedInstance.activeAddress = nil
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRemoveAllNotifcationObserver), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KResetGenericStoreLocalChacheNotifcation), object: nil)
            
            
        }
        
    }
    
    public func getCurrentAppVersion() -> String {
        let infoDictionary: NSDictionary? = Bundle.main.infoDictionary as NSDictionary? // Fetch info.plist as a Dictionary
        let major = infoDictionary?.object(forKey: "CFBundleShortVersionString") as! String
        let minor = infoDictionary?.object(forKey: "CFBundleVersion") as! String
        return "\(major).\(minor)"
    }
    
    // MARK: Network state
    @objc public func networkStatusDidChanged(_ notification: NSNotification?) {
        
        let isNetworkAvailable = ReachabilityManager.sharedInstance.isNetworkAvailable()
        
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            
            if let topController = UIApplication.topViewController() {
                
                if isNetworkAvailable {
                    
                    //check if no network controller is shown
                    if topController is NoNetworkConnectionViewController {
                        self.window?.rootViewController?.dismiss(animated: false, completion:nil)
                    }
                    
                } else {
                    
                    //check if alredy no network controller is shown
                    if !(topController is NoNetworkConnectionViewController) {
                        
                        let noNetworkController = ElGrocerViewControllers.noNetworkConnectionViewController()
                        let navController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                        navController.viewControllers = [noNetworkController]
                        navController.modalPresentationStyle = .fullScreen
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            self.window?.rootViewController?.present(navController, animated: false, completion: nil)
                        }
                        
                    }
                }
            }
            
        }
    }
    
    // MARK: Notifications
    
    public func registerForNotifications() {
        
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
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        
    }
    
    
    public func zendeskNotifcationHandling (_ requestID : String) {
        
        
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
    
    
    
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        print("push notif data: \(userInfo)")
        
        
        if let _ = userInfo["sendbird"] as? NSDictionary {
            var delayTimeSendBird = 0.0
            if let appDelegate = UIApplication.shared.delegate as? SDKManagerShopper {
                if let dataAvailable = appDelegate.sdkStartTime {
                    if dataAvailable.timeIntervalSinceNow > -10 {
                        delayTimeSendBird = 6.0
                    }
                }
            }
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
                    if let appDelegate = UIApplication.shared.delegate as? SDKManagerShopper {
                        if let dataAvailable = appDelegate.sdkStartTime {
                            if dataAvailable.timeIntervalSinceNow > -5 {
                                delayTime = 4.0
                            }
                        }
                    }
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
            if let appDelegate = UIApplication.shared.delegate as? SDKManagerShopper {
                if let dataAvailable = appDelegate.sdkStartTime {
                    if dataAvailable.timeIntervalSinceNow > -5 {
                        delayTime = 4.0
                    }
                }
            }
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
        if let appDelegate = UIApplication.shared.delegate as? SDKManagerShopper {
            if let dataAvailable = appDelegate.sdkStartTime {
                if dataAvailable.timeIntervalSinceNow > -10 {
                    delayTime = 8.0
                }
            }
        }
        
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
    
    public func chatNotifcationFromZenDesk (_ msg : String) {
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
    
    public func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        _ = LocalNotificationHandler()
            .addHandler(HelpshiftLocalNotificationHandler())
            .handleObject(notification)
    }
    
    /** For iOS 10 and above - Foreground**/
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        
        print("APPDELEGATE: didReceiveResponseWithCompletionHandler \(notification.request.content.userInfo)")
        
        // If you wish CleverTap to record the notification click and fire any deep links contained in the payload.
        CleverTap.sharedInstance()?.handleNotification(withData: notification.request.content.userInfo, openDeepLinksInForeground: true)
        
        completionHandler([.sound])
    }
    
    public func checkForNotificationAtAppLaunch(_ application: UIApplication, userInfo: [AnyHashable: Any]?) {
        
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
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        
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
    
    
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error While Register For Remote Notifications:%@",error.localizedDescription)
        //  PushNotificationManager.push().handlePushRegistrationFailure(error)
    }
    
    // MARK: Abandoned basket notification
    
    public func scheduleAbandonedBasketNotification() {
        
        //cancel all previously scheduled notifications
        UIApplication.shared.cancelAllLocalNotifications()
        
        //schedule new notification after 20 min
        let min20Notification = createLocalNotificationWithFireTime(fireTimeMinutes: 20)
        UIApplication.shared.scheduleLocalNotification(min20Notification)
    }
    
    public func scheduleAbandonedBasketNotificationAfter24Hour() {
        //cancel all previously scheduled notifications
        UIApplication.shared.cancelAllLocalNotifications()
        
        //schedule new notification after 24 hrs
        let min20Notification = createLocalNotificationWith24HourFireTime(fireTimeMinutes: 1440)
        UIApplication.shared.scheduleLocalNotification(min20Notification)
    }
    
    public func scheduleAbandonedBasketNotificationAfter72Hour() {
        //cancel all previously scheduled notifications
        UIApplication.shared.cancelAllLocalNotifications()
        
        //schedule new notification after 72 hrs
        let min20Notification = createLocalNotificationWith72HourFireTime(fireTimeMinutes: 4320)
        UIApplication.shared.scheduleLocalNotification(min20Notification)
    }
    
    fileprivate func createLocalNotificationWithFireTime(fireTimeMinutes:TimeInterval) -> UILocalNotification {
        
        let message = NSLocalizedString("abandoned_cart_notification_message", comment: "")
        
        let localNotification = UILocalNotification()
        localNotification.userInfo = nil
        localNotification.applicationIconBadgeNumber = 0
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.alertBody = message
        localNotification.fireDate = Date().addingTimeInterval(fireTimeMinutes * 60)
        
        return localNotification
    }
    
    fileprivate func createLocalNotificationWith24HourFireTime(fireTimeMinutes:TimeInterval) -> UILocalNotification {
        
        let message = NSLocalizedString("abandoned_cart_notification_message_24_Hour", comment: "")
        
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
        
        let message = NSLocalizedString("abandoned_cart_notification_message_72_Hour", comment: "")
        
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
    
    public func resetUserDefaultsOnFirstRun() {
        UserDefaults.setUserLoggedIn(false)
        UserDefaults.setLogInUserID("0")
        UserDefaults.setDidUserSetAddress(false)
        DeliveryAddress.clearDeliveryAddressEntity()
    }
    
    public func setupLanguage() {
        
        // let phoneLanguage = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as? String
        
        var phoneLanguage = UserDefaults.getCurrentLanguage()
        
        if phoneLanguage == nil {
            
            let deviceLanguage = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as? String
            print("Current Device Language:%@",deviceLanguage ?? "NULL Language")
            
            if(deviceLanguage != nil){
                UserDefaults.setCurrentLanguage(deviceLanguage)
                phoneLanguage = deviceLanguage
            }else{
                UserDefaults.setCurrentLanguage("Base")
                phoneLanguage = "Base"
            }
            LanguageManager.sharedInstance.languageButtonAction(selectedLanguage: phoneLanguage!, updateRootViewController: false)
        }
    }
    
    public func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData);
    }
    
    // MARK: HelpshiftDelegate
    
    fileprivate func helpshiftChatMessageUnread() {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kHelpshiftChatResponseNotificationKey), object: nil)
    }
    
    public func didReceiveNotificationCount(_ count: Int) {
        
        if count > 0 {
            helpshiftChatMessageUnread()
        }
    }
    
    private func updateUserLanguage(_ selectedLanguage:String){
        
        guard UserDefaults.isUserLoggedIn() else {return}
        
        ElGrocerApi.sharedInstance.updateUserLanguageToServer(selectedLanguage) { (result, responseObject) in
            if result == true {
                print("Language Change Successfully")
                let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                userProfile?.language = selectedLanguage
                DatabaseHelper.sharedInstance.saveDatabase()
                
            }else{
                print("Some Issue orrcus while changing language")
            }
        }
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
    
    public func application(_ application: UIApplication,
                     shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    public func application(_ application: UIApplication,
                     shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return false
    }
    
    public func logout(completion: (() -> Void)) {
            
        SendBirdManager().logout { success in
            if success{
                print("logout successfull")
            }else{
                print("error")
            }
        }
        
        ElGrocerUtility.sharedInstance.isDeliveryMode = true
        ElGrocerApi.sharedInstance.logoutUser { (result) -> Void in  }
        FireBaseEventsLogger.trackSignOut(true)
        AlgoliaApi.sharedInstance.resetAlgoliaLocalData()
        //ZohoChat.logOut()
        
        //smiles points values reset
        UserDefaults.setIsSmileUser(false)
        UserDefaults.setSmilesPoints(0)
        FireBaseEventsLogger.setUserID(nil)
        UserDefaults.setUserLoggedIn(false)
        UserDefaults.setLogInUserID("0")
        UserDefaults.setNavigateToHomeAfterInstall(false)
        UserDefaults.setLastSearchList("")
        resetUserDefaultsOnFirstRun()
        UserDefaults.resetEditOrder()
        UserDefaults.setAccessToken(nil)
        UserDefaults.setHelpShiftChatResponseUnread(false)
        UserDefaults.setPaymentAcceptedState(false)
        ElGrocerUtility.sharedInstance.CurrentLoadedAddress = ""
        ElGrocerUtility.sharedInstance.genericBannersA  = [BannerCampaign]()
        ElGrocerUtility.sharedInstance.storeTypeA = []
        ElGrocerUtility.sharedInstance.greatDealsBannersA  = [BannerCampaign]()
        ElGrocerUtility.sharedInstance.chefList   = [CHEF]()
        HomePageData.shared.resetHomeDataHandler()
        ElGrocerUtility.sharedInstance.recipeList = [:]
        SendBirdManager().createNewUserAndDeActivateOld()
        
        
        ElGrocerUtility.sharedInstance.delay(1) {
            
            DatabaseHelper.sharedInstance.clearDatabase(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            //cancel all previously scheduled notifications
            UIApplication.shared.cancelAllLocalNotifications()
            
            ElGrocerUtility.sharedInstance.deepLinkURL = ""
            
            ElGrocerUtility.sharedInstance.groceries.removeAll()
            ElGrocerUtility.sharedInstance.completeGroceries.removeAll()
            ElGrocerUtility.sharedInstance.bannerGroups.removeAll()
            ElGrocerUtility.sharedInstance.basketFetchDict.removeAll()
            ElGrocerUtility.sharedInstance.activeGrocery = nil
            ElGrocerUtility.sharedInstance.activeAddress = nil
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRemoveAllNotifcationObserver), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KResetGenericStoreLocalChacheNotifcation), object: nil)
        }
    }
}

extension SDKManagerShopper {
    
    public func beginBackgroundUpdateTask() {
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }
    
    public func endBackgroundUpdateTask() {
        
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = .invalid
    }
    
    public func doBackgroundTask() {
        self.beginBackgroundUpdateTask()
    }
    @objc
    public func endProgress() {
        
        if let activeGrocery = ElGrocerUtility.sharedInstance.activeGrocery?.name {
            debugPrint("active grocer name is : \(activeGrocery)")
        }
    }
    
    
}

extension SDKManagerShopper : CleverTapInAppNotificationDelegate {
    
    public func inAppNotificationButtonTapped(withCustomExtras customExtras: [AnyHashable : Any]!) {
        
        var promoCode = ""
        if let promo = customExtras["promoCode"] as? String {promoCode = promo}
        if let promo = customExtras["promocode"] as? String {promoCode = promo}
        if let promo = customExtras["to_be_copied"] as? String {promoCode = promo}
        if promoCode.count > 0 {
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = promoCode
        }
    }
    
}

extension SDKManagerShopper : UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if let viewC = (viewController as? ElGrocerNavigationController)?.viewControllers {
            let viewControlleris = viewC[viewC.count - 1]
            ElGrocerEventsLogger.sharedInstance.trackScreenNav( ["clickedEvent" : "fromTabBar" ,  FireBaseParmName.CurrentScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName() ?? "") , FireBaseParmName.NextScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName(viewControlleris) ?? "") ])
        }
        
        
        if let viewControllersA = (viewController as? ElGrocerNavigationController)?.viewControllers {
            if viewControllersA.count > 0 {
                let generice = viewControllersA[0]
                if generice is MainCategoriesViewController {
                    if ElGrocerUtility.sharedInstance.activeGrocery == nil {
                        generice.navigationController?.popToRootViewController(animated: false)
                    }
                }else if generice is GenericStoresViewController {
                    if let topVC = UIApplication.topViewController() {
                        if topVC is GlobalSearchResultsViewController {
                            let globle : GlobalSearchResultsViewController = topVC as! GlobalSearchResultsViewController
                            globle.navigationController?.dismiss(animated: false, completion: {
                                globle.presentingVC?.tabBarController?.selectedIndex = 2
                                globle.presentingVC?.tabBarController?.selectedIndex = 0
                                globle.presentingVC = nil
                            })
                            
                        }else{
                            if generice.presentedViewController is UINavigationController {
                                let zeroIndexPresentedVIew = (generice.presentedViewController  as! UINavigationController).viewControllers
                                if zeroIndexPresentedVIew.count > 0 {
                                    
                                    generice.presentedViewController?.dismiss(animated: false, completion: {
                                        generice.tabBarController?.selectedIndex = 2
                                        generice.tabBarController?.selectedIndex = 0
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if  let homeemtpy = (viewController as? UINavigationController)?.viewControllers {
            if homeemtpy.count > 0 {
                if homeemtpy[0] is MyBasketViewController {
                    
                    if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                        
                        let isOtherGroceryBasketActive = ShoppingBasketItem.checkIfBasketForOtherGroceryIsActive(grocery , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        
                        let activeBasketGrocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        
                        
                        if isOtherGroceryBasketActive && activeBasketGrocery != nil && activeBasketGrocery!.dbID != grocery.dbID {
                            
                            if UserDefaults.isUserLoggedIn() {
                                //clear active basket and add product
                                ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                ElGrocerUtility.sharedInstance.resetBasketPresistence()
                                tabBarController.selectedIndex = 4
                            }else{
                                
                                
                                let appDelegate = UIApplication.shared.delegate as! SDKManagerShopper
                                let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "NoCartPopUp") , header: NSLocalizedString("products_adding_different_grocery_alert_title", comment: ""), detail: NSLocalizedString("products_adding_different_grocery_alert_message", comment: ""),NSLocalizedString("grocery_review_already_added_alert_cancel_button", comment: ""),NSLocalizedString("select_alternate_button_title_new", comment: "") , withView: appDelegate.window!) { (buttonIndex) in
                                    
                                    if buttonIndex == 1 {
                                        
                                        //clear active basket and add product
                                        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                        ElGrocerUtility.sharedInstance.resetBasketPresistence()
                                        tabBarController.selectedIndex = 4
                                    }
                                }
                                
                                
                            }
                            return false
                        } else {
                            return true
                        }
                        
                    }
                }
            }
        }
        return true
    }
}

extension SDKManagerShopper : SBDConnectionDelegate, SBDUserEventDelegate {
    
    public func setSendbirdDelegate () {
        
        SBDMain.add(self as SBDChannelDelegate, identifier: "UNIQUE_DELEGATE_ID")
    }
    
    public func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        debugPrint("\(message.requestId)")
        
        if UIApplication.shared.applicationState == .active {
            
            let dataDict = message._toDictionary()
            var isUserFound = false
            if let usersA = sender.dictionaryWithValues(forKeys: ["_members"])["_members"] as? [SBDMember] {
                for user in usersA {
                    if let msgUserID = user.userId as? String {
                        if msgUserID == SBDMain.getCurrentUser()?.userId {
                            isUserFound = true
                            break;
                        }
                    }
                }
            }
            
            if let topVc = UIApplication.topViewController() {
                if topVc is SBUChannelListViewController  || topVc is ElgrocerChannelController {
                    return
                }
            }
            
            guard isUserFound else {return}
            
            if let msgType = message.customType {
                if msgType.lowercased() == "SENDBIRD:AUTO_EVENT_MESSAGE".lowercased() {
                    return
                }
            }
            let nameDict = sender.dictionaryWithValues(forKeys: ["_name"])
            let name = nameDict != nil ? nameDict["_name"] : message.sender?.nickname
            var data  = [:] as [String : Any]
            var sendbirdData = [:] as [String : Any]
            sendbirdData["channel"] =  ["channel_url" : message.channelUrl , "custom_type" : sender.customType ,  "name" : name]
            sendbirdData["message"] = message.message
            data["sendbird"] = sendbirdData
            SendBirdManager().didReciveRemoteNotification(userInfo: data)
            
            
        }
        
    }
    
    public func channel(_ sender: SBDBaseChannel, didUpdate message: SBDBaseMessage) {
        debugPrint("")
    }
    
    public func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        debugPrint("")
    }
    
    public func channel(_ channel: SBDBaseChannel, didReceiveMention message: SBDBaseMessage) {
        debugPrint("")
    }
    
    public func channelWasChanged(_ sender: SBDBaseChannel) {
        debugPrint("")
        
        
    }
    
    public func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        debugPrint("")
    }
    
    public func channelWasFrozen(_ sender: SBDBaseChannel) {
        debugPrint("")
    }
    
    public func channelWasUnfrozen(_ sender: SBDBaseChannel) {
        debugPrint("")
    }
    
    public func channel(_ sender: SBDBaseChannel, createdMetaData: [String : String]?) {
        debugPrint("")
    }
    
    public func channel(_ sender: SBDBaseChannel, updatedMetaData: [String : String]?) {
        debugPrint("")
    }
    
    public func channel(_ sender: SBDBaseChannel, deletedMetaDataKeys: [String]?) {
        debugPrint("")
    }
    
    public func channel(_ sender: SBDBaseChannel, createdMetaCounters: [String : NSNumber]?) {
        debugPrint("")
    }
    
    public func channel(_ sender: SBDBaseChannel, updatedMetaCounters: [String : NSNumber]?) {
        debugPrint("")
    }
    
    public func channel(_ sender: SBDBaseChannel, deletedMetaCountersKeys: [String]?) {
        debugPrint("")
    }
    
    public func channelWasHidden(_ sender: SBDGroupChannel) {
        debugPrint("")
    }
    
    public func channel(_ sender: SBDGroupChannel, didReceiveInvitation invitees: [SBDUser]?, inviter: SBDUser?) {
    }
    
    public func channel(_ sender: SBDGroupChannel, didDeclineInvitation invitee: SBDUser?, inviter: SBDUser?) {
    }
    
    public func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
    }
    
    public func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
    }
    
    public func channelDidUpdateDeliveryReceipt(_ sender: SBDGroupChannel) {
    }
    
    public func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
    }
    
    public func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        
        debugPrint("unreadMentionCount\(sender.unreadMentionCount)")
    }
    
    public func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
    }
    
    public func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
    }
    
    public func channel(_ sender: SBDBaseChannel, userWasMuted user: SBDUser) {
    }
    
    public func channel(_ sender: SBDBaseChannel, userWasUnmuted user: SBDUser) {
    }
    
    public func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {
    }
    
    public func channel(_ sender: SBDBaseChannel, userWasUnbanned user: SBDUser) {
    }
    
    public func channelDidChangeMemberCount(_ channels: [SBDGroupChannel]) {
    }
    
    public func channelDidChangeParticipantCount(_ channels: [SBDOpenChannel]) {
    }
}
