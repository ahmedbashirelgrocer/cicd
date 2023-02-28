//  SDKManager.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 01.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//  Final Release Build & Update
//from commit update pod file for xcode 14 & ios16 ==== branch : origin/DevSDK/Xcode14-IOS16Fixing

import UIKit
import CoreData
import FirebaseCrashlytics
import GoogleMaps
import GooglePlaces
import UserNotifications
// import AFNetworking
import BackgroundTasks
import IQKeyboardManagerSwift
import CleverTapSDK
import AdSupport
//import AppsFlyerLib
// import FBSDKCoreKit
import FirebaseCore
import Messages
// import AFNetworkActivityLogger
import SendBirdUIKit
import SwiftDate
import Adyen
import Segment
// import FirebaseDynamicLinks
// import FirebaseAuth
// import FirebaseMessaging

extension SDKManager {
    static var isSmileSDK: Bool { SDKManager.shared.launchOptions?.isSmileSDK == true }
    static var isGrocerySingleStore: Bool { SDKManager.shared.launchOptions?.marketType == .grocerySingleStore }
}

class SDKManager: NSObject  {
    
    var sdkStartTime : Date?
    var homeLastFetch : Date?
    
    var launchCompletion: (() -> Void)?
    
    
    var window: UIWindow?
    var rootViewController: UIViewController?
    var rootContext: UIViewController?
    
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
    static var shared: SDKManager = SDKManager()
    //var isFromSmile : Bool = fals
    var launchOptions: LaunchOptions? = nil
    var launchOptionsLocation: CLLocation? = nil
    var isLaunchEventConfigured: Bool = false
    var isInitialized = false
    
    // MARK: Initializers
    private override init() {
        super.init()
        window = .key
//        DispatchQueue.main.async { [weak self] in self?.configure() }
    }
    
  
    func start(with launchOptions: LaunchOptions?) {
        self.launchOptions = launchOptions
        
        if !isInitialized {
            self.configure()
            isInitialized = true
        }
        
        self.rootContext = UIWindow.key?.rootViewController
        self.configuredElgrocerClevertapMixPannelSandBirdLoggerifNeeded()
        _ = ReachabilityManager.sharedInstance
        NotificationCenter.default.addObserver(self, selector: #selector(SDKManager.networkStatusDidChanged(_:)), name:NSNotification.Name(rawValue: kReachabilityManagerNetworkStatusChangedNotificationCustom), object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { SDKManager.shared.networkStatusDidChanged(nil) }
        self.showAnimatedSplashView()
        
    }
    
    func startWithSingleStore(_ grocery: Grocery?) {
        guard let launchOptions = launchOptions else { return }
        self.launchOptions = launchOptions
        
        if !isInitialized {
            DispatchQueue.main.async { [weak self] in self?.configure() }
            isInitialized = true
        }
        
        self.rootContext = UIWindow.key?.rootViewController
        self.configuredElgrocerClevertapMixPannelSandBirdLoggerifNeeded()
        let manager = SDKLoginManager(launchOptions: launchOptions)
        manager.loginFlowForSDK() { isSuccess, errorMessage in
            
            if isSuccess {
                SDKManager.shared.setupLanguage()
                if let grocery = grocery {
                    HomePageData.shared.groceryA = [grocery]
                    ElGrocerUtility.sharedInstance.activeGrocery = grocery
                }
                let tabNav = self.getTabbarController(isNeedToShowChangeStoreByDefault: true, selectedGrocery: grocery, nil, true)
                if let tabVC = tabNav.viewControllers[0] as? UITabBarController {
                    tabVC.selectedIndex = 1
                    if let nav = tabVC.viewControllers?[1] as? UINavigationController {
                        nav.setViewControllers([nav.viewControllers[0]], animated: false)
                        if let main = nav.viewControllers[0] as? MainCategoriesViewController {
                            main.grocery = nil
                        }
                    }
                    self.rootViewController = tabNav

                    tabNav.modalPresentationStyle = .fullScreen
                    if let topVC = self.rootContext {
                        topVC.present(tabNav, animated: true)
                    }
                }
            
        } else {
            ElGrocerAlertView.createAlert(
                localizedString("error_500", comment: ""),
                description: nil,
                positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                negativeButton: nil)
            { index in
                if let topVC = UIApplication.topViewController() {
                    if let navVc = topVC.navigationController, navVc.viewControllers.count > 1 {
                        navVc.popViewController(animated: true)
                    } else {
                        topVC.dismiss(animated: true, completion: nil)
                    }
                }
            }.show()
        }
    }
}

    private func configure() { //_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        
        SwiftDate.defaultRegion = Region.getCurrentRegion()
        self.sdkStartTime = Date()
        _ = ReachabilityManager.sharedInstance
        self.refreshSessionStatesForEditOrder()
        self.setSendbirdDelegate()
        self.initializeExternalServices()
        ElGrocerUtility.sharedInstance.resetBasketPresistence()
        self.checkNotifcation()
        self.logApiError()
        
        
    }
    
    fileprivate func checkNotifcation() {
        
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications {
            elDebugPrint("User is registered for notification")
            self.registerForNotifications()
        } else {
            elDebugPrint("Show alert user is not registered for notification")
            
        }
        
    }
   
    
    fileprivate func logApiError () {
     
        NotificationCenter.default.addObserver(self,selector: #selector(SDKManager.logToCrashleytics(_:)), name: NSNotification.Name(rawValue: "api-error"), object: nil)
        
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
                if let launchOptions = launchOptions, launchOptions.isSmileSDK {
                    
                } else {
                    FirebaseCrashlytics.Crashlytics.crashlytics().record(error: error.addItemsToUserInfo(newUserInfo: apiData))
                }
//                FireBaseEventsLogger.trackCustomEvent(eventType: "errorToParse", action: "error.localizedDescription : \(error.localizedDescription)"  ,  apiData  , false)
                
                // Logging segment event for general api error
                let elError = ElGrocerError(error: error)
                SegmentAnalyticsEngine.instance.logEvent(event: GeneralAPIErrorEvent(endPoint: apiData["url"] as? String, message: elError.message ?? elError.localizedMessage, code: elError.code))
                
               
            }else{
                
                if let launchOptions = launchOptions, launchOptions.isSmileSDK {
                    
                } else {
                    FirebaseCrashlytics.Crashlytics.crashlytics().record(error: error.addItemsToUserInfo(newUserInfo:  [ FireBaseParmName.SessionID.rawValue : ElGrocerUtility.sharedInstance.getGenericSessionID() ]))
                }
                // FireBaseEventsLogger.trackCustomEvent(eventType: "errorToParse", action: "error.localizedDescription : \(error.localizedDescription)" , [:] , false )
                
                // Logging segment event for general api error
                let elError = ElGrocerError(error: error)
                SegmentAnalyticsEngine.instance.logEvent(event: GeneralAPIErrorEvent(endPoint: "", message: elError.message ?? elError.localizedMessage, code: elError.code))
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
    
    
// FixMe: Ignore in SDK
//    func applicationWillEnterForeground(_ application: UIApplication) {
//
//        if let timer = self.bgtimer {
//            timer.invalidate()
//            self.bgtimer  = nil
//        }
//
//    }

// FixMe:
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//
//        UIApplication.shared.applicationIconBadgeNumber = 0
//
//        AppsFlyerLib.shared().start()
//        // FixMe SDK Update
//        //AppEvents.activateApp()
//
//
//        if UserDefaults.getLogInUserID() != "0" {
//             FireBaseEventsLogger.setUserID(UserDefaults.getLogInUserID())
//        }else{
//            FireBaseEventsLogger.setUserID(ElGrocerUtility.sharedInstance.getGenericSessionID())
//        }
//
//    }
   
//FixMe: Do it latter
//    func applicationWillTerminate(_ application: UIApplication) {
//        if ElGrocerUtility.sharedInstance.isItemInBasket {
//            FireBaseEventsLogger.setUserProperty("1", key: FireBaseEventsName.AbandonBasket.rawValue)
//            FireBaseEventsLogger.logEventToFirebaseWithEventName(eventName: FireBaseEventsName.AbandonBasket.rawValue)
//        }else{
//            FireBaseEventsLogger.setUserProperty("0", key: FireBaseEventsName.AbandonBasket.rawValue)
//        }
//
//
//        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//        // Saves changes in the application's managed object context before the application terminates.
//
//        let phoneLanguage = UserDefaults.getCurrentLanguage()
//        if phoneLanguage == "ar" {
//            LanguageManager.sharedInstance.setLocale("ar")
//        }else{
//            LanguageManager.sharedInstance.setLocale("Base")
//        }
//        let products = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
//        if products.count > 0 {
//            ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("abandon_basket")
//        }
//    }
    
    func deleteBasketFromServerWithGrocery(_ grocery:Grocery?){
        
        guard UserDefaults.isUserLoggedIn() else {return}
        
        ElGrocerApi.sharedInstance.deleteBasketFromServerWithGrocery(grocery) { (result) in
            switch result {
                case .success(let responseDict):
                   elDebugPrint("Delete Basket Response:%@",responseDict)
                
                case .failure(let error):
                   elDebugPrint("Delete Basket Error:%@",error.localizedMessage)
            }
        }
    }
    
    
    // MARK: Methods
    func initializeExternalServices() { //_ application: UIApplication, didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        
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
        UIViewController.swizzleViewDidAppear()
        
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

        
        
        // Initialize Facebook SDK
        // FixMe:
        // ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: didFinishLaunchingWithOptions)
        
        // Google Maps
        GMSPlacesClient.provideAPIKey(kGoogleMapsApiKey)
        GMSServices.provideAPIKey(kGoogleMapsApiKey)
        self.configuredElgrocerEventLogger() //didFinishLaunchingWithOptions)
        
        // initialize Segment SDK used for event logging.
        initializeSegmentSDK()
        
//        let action1 = UNNotificationAction(identifier: "action_1", title: "Back", options: [])
//        let action2 = UNNotificationAction(identifier: "action_2", title: "Next", options: [])
        let action3 = UNNotificationAction(identifier: "action_3", title: "View In App", options: [])
        let category = UNNotificationCategory(identifier: "CTNotification", actions: [action3], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
    }
    
    func configureFireBase(){
    // ElGrocerApi.sharedInstance.baseApiPath == "https://el-grocer-admin.herokuapp.com/api/"
        
        
        guard !(SDKManager.shared.launchOptions?.isSmileSDK ?? true) else {
          // Fixme: Firebase disabled
        #if DEBUG
          // debugFirebaseSetting()
        #else
            smileSDKFireBaseSetting()
        #endif
            return
        }

        guard Bundle.main.bundleIdentifier == "com.shopper.elgrocerShopper" else {
            return
        }
        
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
        
// FixMe: SDK Update
//        let networkLogger = AFNetworkActivityLogger.shared()
//        networkLogger?.startLogging()
//        networkLogger?.setLogLevel(.AFLoggerLevelDebug)
        

        
    }
    
    private func initializeSegmentSDK() {
        // launch options are nil here
        let configurationName =  self.launchOptions?.environmentType.value() ??  "Release"
        let environmentsPath = Bundle.resource.path(forResource: "EnvironmentVariables", ofType: "plist")
        let environmentsDict = NSDictionary(contentsOfFile: environmentsPath!)
        let dictionary = environmentsDict![configurationName] as! NSDictionary
        
        guard let segmentSDKWriteKey = dictionary["segmentSDKWriteKey"] as? String else { return }
        
        let configuration = AnalyticsConfiguration(writeKey: segmentSDKWriteKey)
        
        configuration.trackApplicationLifecycleEvents = true
        configuration.flushAt = 3
        configuration.flushInterval = 10
        
        Analytics.setup(with: configuration)
    }
    
    fileprivate func smileSDKFireBaseSetting() {
        
        var filePath:String!
        filePath = Bundle.resource.path(forResource: "GoogleService-Info", ofType: "plist")
        //let projectName = "ShopperSmile"
        let options = FirebaseOptions.init(contentsOfFile: filePath)!
        options.googleAppID = "1:793956033248:ios:0bea4a41f785ab7201a685"
        options.clientID = "793956033248-94r5vl24meiq6c8fod92759q2nvoabvl.apps.googleusercontent.com"
        options.bundleID = "Etisalat.House"
        options.apiKey = "AIzaSyDYXdoLYTAByiN7tc1wDIL_D7hqe01dJG0"
        options.trackingID = "UA-64355049-2"
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure(options: options)
        } else {
            FirebaseApp.configure(name: "elGrocer", options: options)
        }
        
       
        
    }
    
    fileprivate func productionFirebaseSetting() {
        // FirebaseApp.configure() // defualt info plist
        var filePath:String!
        filePath = Bundle.resource.path(forResource: "GoogleService-Info", ofType: "plist")
        let projectName = "elgrocer"
        let options = FirebaseOptions.init(contentsOfFile: filePath)!
        FirebaseApp.configure(options: options)
        
    }
    
    
    func initiliazeMarketingCampaignTrackingServices() {
        // FixMe Arch Error
        //MarketingCampaignTrackingHelper.sharedInstance.initializeMarketingCampaignTrackingServices()
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
    
  
    
    
    func showGenericStoreUI() {
        let entryController =  ElGrocerViewControllers.ElgrocerParentTabbarController()
        let navController = ElgrocerGenericUIParentNavViewController(navigationBarClass: ElgrocerWhilteLogoBar.self, toolbarClass: nil)
        navController.viewControllers = [entryController]
        navController.modalPresentationStyle = .fullScreen
       self.replaceRootControllerWith(navController)
    }


    func showForceUpdateView() {
        DispatchQueue.main.async {
            let forceUpdateController = ElGrocerViewControllers.forceUpdateViewController()
            self.replaceRootControllerWith(forceUpdateController)
        }
    }
    
     func showAnimatedSplashView() {
         
         defer {
             self.refreshSessionStatesForEditOrder()
         }
        
        let entryController =  ElGrocerViewControllers.splashAnimationViewController()
         
        let navEntryController : ElGrocerNavigationController = ElGrocerNavigationController.init(rootViewController: entryController)
        navEntryController.hideNavigationBar(true)
         LanguageManager.sharedInstance.languageButtonAction(selectedLanguage: launchOptions?.language ?? "Base", SDKManagers: self)
        if SDKManager.shared.launchOptions?.isSmileSDK ?? false, let topVC = UIApplication.shared.keyWindow?.rootViewController {
            navEntryController.modalPresentationStyle = .fullScreen
            topVC.present(navEntryController, animated: true) {  }
            rootViewController = navEntryController
            return
        }
        self.replaceRootControllerWith(navEntryController)
    }
    
    
     func showEntryView() {
         
         defer {
             self.refreshSessionStatesForEditOrder()
         }
         
         if let launchOptions = launchOptions, launchOptions.isSmileSDK { // Entry point for SDK
             let manager = SDKLoginManager(launchOptions: launchOptions)
             manager.loginFlowForSDK() { isSuccess, errorMessage in
                 let positiveButton = localizedString("no_internet_connection_alert_button", comment: "")
                 if isSuccess {
                     manager.setHomeView()
                 } else {
                  let alert = ElGrocerAlertView.createAlert(localizedString("error_500", comment: ""), description: nil, positiveButton: positiveButton, negativeButton: nil) { index in
                         Thread.OnMainThread {
                             if let topVC = UIApplication.topViewController() {
                                 if let navVc = topVC.navigationController, navVc.viewControllers.count > 1 {
                                     navVc.popViewController(animated: true)
                                 } else {
                                     topVC.dismiss(animated: true, completion: nil)
                                 }
                             }
                         }
                     }
                     alert.show()
                 }
             }
         } else {
             let entryController =  ElGrocerViewControllers.entryViewController()
             let navEntryController : ElGrocerNavigationController = ElGrocerNavigationController.init(rootViewController: entryController)
             navEntryController.hideNavigationBar(true)
             self.replaceRootControllerWith(navEntryController)
         }
    }
    
   
    func showAppWithMenu() {

        self.showAppWithMenu(false)
        
    }
    
    func showAppWithMenu(_ isNeedToShowChangeStoreByDefault : Bool = false) {
        
        let smileSDK = SDKManager.shared.launchOptions?.isSmileSDK ?? false
        guard !smileSDK else {
            let tabVC = self.getTabbarController(isNeedToShowChangeStoreByDefault: false, selectedGrocery: nil, nil, true)
            if let topVC = UIApplication.topViewController() {
               // topVC.present(tabVC, animated: true, completion: nil)
                if tabVC.viewControllers.count > 0  {
                    if let tabController = tabVC.viewControllers[0] as? UITabBarController {
                        Thread.OnMainThread {
                            //topVC.navigationController?.pushViewControllerFromLeftAndSetRoot(controller: tabController)
                            topVC.navigationController?.setViewControllers([tabController], animated: false)
                        }
                    }
                }
            }
            return
        }
    
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
    
    func makeRootViewController( controller : UIViewController) {
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
    
    func getTabbarController(isNeedToShowChangeStoreByDefault : Bool , selectedGrocery : Grocery? = nil ,_  selectedBannerLink : BannerLink? = nil, _ isSmile: Bool = false ) -> UINavigationController {
        
        
        
        let tabController = UITabBarController()
        tabController.delegate = self
        let homeViewEmpty =  ElGrocerViewControllers.getGenericStoresViewController(HomePageData.shared)
        homeViewEmpty.launchCompletion = launchCompletion
        var smileHomeVc : SmileSdkHomeVC? = nil
        if isSmile {
            smileHomeVc =  ElGrocerViewControllers.getSmileHomeVC(HomePageData.shared)
            smileHomeVc?.launchCompletion = launchCompletion
        }
        
        let storeMain = ElGrocerViewControllers.mainCategoriesViewController()
        storeMain.selectedBannerLink = selectedBannerLink
        let searchController = ElGrocerViewControllers.getSearchListViewController()
        let settingController = ElGrocerViewControllers.settingViewController()
        let myBasketViewController = ElGrocerViewControllers.myBasketViewController()

        let vcData: [(UIViewController, UIImage , String)] = [
            (isSmile ? smileHomeVc! : homeViewEmpty, UIImage(name: "TabbarHome")!,localizedString("Home_Title", comment: "")),
            (storeMain, UIImage(name: "icStore")!,localizedString("Store_Title", comment: "")),
            (searchController, UIImage(name: "icTabBarshoppingList")! ,localizedString("Shopping_list_Titile", comment: "")),
            (settingController, UIImage(name: "TabbarProfile")!   ,localizedString("more_title", comment: "")),
            (myBasketViewController, UIImage(name: "TabbarCart")!   ,localizedString("Cart_Title", comment: ""))
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
        tabController.tabBar.backgroundColor = .white
        tabController.tabBar.barTintColor = .white
        tabController.tabBar.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        if SDKManager.isSmileSDK == false {
            UITabBarItem.appearance().setTitleTextAttributes(
                [NSAttributedString.Key.font: UIFont.SFProDisplayMediumFont(11),
                 NSAttributedString.Key.foregroundColor: UIColor.colorWithHexString(hexString: "595959")],
                for: .normal
            )
        
            UITabBarItem.appearance().setTitleTextAttributes(
                [NSAttributedString.Key.font: UIFont.SFProDisplayMediumFont(11),
                 NSAttributedString.Key.foregroundColor: ApplicationTheme.currentTheme.themeBasePrimaryColor],
                for: .selected
            )
        
            UITabBar.appearance().barTintColor = UIColor.colorWithHexString(hexString: "ffffff")
        }
     
            tabController.tabBar.shadowImage =  UIImage.colorForNavBar(color: .colorWithHexString(hexString: "e4e4e4"))
        
        if #available(iOS 13, *) {
            
            let appearance = tabController.tabBar.standardAppearance
            appearance.shadowImage = UIImage.colorForNavBar(color: .colorWithHexString(hexString: "e4e4e4"))
            appearance.backgroundColor = UIColor.colorWithHexString(hexString: "ffffff")
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.colorWithHexString(hexString: "595959")
            appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = .colorWithHexString(hexString: "E83737")
            appearance.stackedLayoutAppearance.selected.iconColor =  ApplicationTheme.currentTheme.themeBasePrimaryColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.font: UIFont.SFProDisplayMediumFont(11),NSAttributedString.Key.foregroundColor: UIColor.colorWithHexString(hexString: "595959")]
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.font:UIFont.SFProDisplayMediumFont(11),NSAttributedString.Key.foregroundColor: ApplicationTheme.currentTheme.themeBasePrimaryColor]
            appearance.stackedItemPositioning = .automatic
            tabController.tabBar.standardAppearance = appearance
        }
      
        // color of background -> This works
        tabController.tabBar.barTintColor = UIColor.colorWithHexString(hexString: "ffffff")
        // This does not work
        tabController.tabBar.isTranslucent = false
        
        if #available(iOS 10.0, *) {
            tabController.tabBar.unselectedItemTintColor = UIColor.colorWithHexString(hexString: "595959")
            tabController.tabBar.tintColor =  ApplicationTheme.currentTheme.themeBasePrimaryColor
        }

        let navtabController = UINavigationController()
        navtabController.isNavigationBarHidden = true;
        navtabController.viewControllers = [tabController]
        self.currentTabBar = tabController
        return navtabController
        
    }
    
    func logoutAndShowEntryView() {
        
        
        DispatchQueue.main.async {
            self.showEntryView()
        }
        self.logout()
        
    }
    
    func logout(completion: (() -> Void)? = nil) {
        
        SendBirdManager().logout { success in
            if success{
               elDebugPrint("logout successfull")
            }else{
               elDebugPrint("error")
            }
        }
        
        ElGrocerUtility.sharedInstance.isDeliveryMode = true
        ElGrocerApi.sharedInstance.logoutUser { (result) -> Void in  }
        FireBaseEventsLogger.trackSignOut(true)
        AlgoliaApi.sharedInstance.resetAlgoliaLocalData()
        //ZohoChat.logOut()
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
            SegmentAnalyticsEngine.instance.reset() // delay added so config load sdk to avoid crash when access analytic shared instance// location sdkmanage , dispatch ... config ... segment need to init first before accesing shared intance
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
            
            completion?()
        }
       
    }
    
    func getCurrentAppVersion() -> String {
        let infoDictionary: NSDictionary? = Bundle.resource.infoDictionary as NSDictionary? // Fetch info.plist as a Dictionary
        let major = infoDictionary?.object(forKey: "CFBundleShortVersionString") as! String
        let minor = infoDictionary?.object(forKey: "CFBundleVersion") as! String
        return "\(major).\(minor)"
    }

    // MARK: Network state
    @objc func networkStatusDidChanged(_ notification: NSNotification?) {
        
        let isNetworkAvailable = ReachabilityManager.sharedInstance.isNetworkAvailable()
        
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
        
        if let topController = UIApplication.topViewController() {
            
            if isNetworkAvailable {
                
                //check if no network controller is shown
                if topController is NoNetworkConnectionViewController {
                    topController.dismiss(animated: false, completion:nil)
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
                        topController.present(navController, animated: false, completion: nil)
                    }
                    
                }
            }
            }
            
        }
    }
    
    
    func resetUserDefaultsOnFirstRun() {
        UserDefaults.setUserLoggedIn(false)
        UserDefaults.setLogInUserID("0")
        UserDefaults.setDidUserSetAddress(false)
        DeliveryAddress.clearDeliveryAddressEntity()
    }
    
    func setupLanguage() {
        
        var phoneLanguage = UserDefaults.getCurrentLanguage()
        
        if phoneLanguage == nil {
            
            let deviceLanguage = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as? String
           elDebugPrint("Current Device Language:%@",deviceLanguage ?? "NULL Language")
            
            if(deviceLanguage != nil){
                UserDefaults.setCurrentLanguage(deviceLanguage)
                phoneLanguage = deviceLanguage
            }else{
                UserDefaults.setCurrentLanguage("Base")
                phoneLanguage = "Base"
            }
            LanguageManager.sharedInstance.languageButtonAction(selectedLanguage: phoneLanguage!, SDKManagers: self , updateRootViewController: false)
        }
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData);
    }
    
    // MARK: HelpshiftDelegate
    
    fileprivate func helpshiftChatMessageUnread() {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kHelpshiftChatResponseNotificationKey), object: nil)
    }
    
    func didReceiveNotificationCount(_ count: Int) {
        
        if count > 0 {
            helpshiftChatMessageUnread()
        }
    }
    
    private func updateUserLanguage(_ selectedLanguage:String){
                
        guard UserDefaults.isUserLoggedIn() else {return}
        
        ElGrocerApi.sharedInstance.updateUserLanguageToServer(selectedLanguage) { (result, responseObject) in
            if result == true {
               elDebugPrint("Language Change Successfully")
                let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                userProfile?.language = selectedLanguage
                DatabaseHelper.sharedInstance.saveDatabase()
                
            }else{
               elDebugPrint("Some Issue orrcus while changing language")
            }
        }
    }

}

extension SDKManager {
    
    func beginBackgroundUpdateTask() {
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }
    
    func endBackgroundUpdateTask() {

        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = .invalid
    }
    
    func doBackgroundTask() {
        self.beginBackgroundUpdateTask()
    }
    @objc
    func endProgress() {
        
        if let activeGrocery = ElGrocerUtility.sharedInstance.activeGrocery?.name {
            elDebugPrint("active grocer name is : \(activeGrocery)")
        }
    }
   
    
}

// Send Bird sdk management
extension SDKManager {
    func setSendbirdDelegate () {
        SBDMain.add(self as SBDChannelDelegate, identifier: "UNIQUE_DELEGATE_ID")
    }
}

// MARK: Supporting methods
fileprivate extension SDKManager {
    @objc
    func refreshSessionStatesForEditOrder() {
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
    func configuredElgrocerClevertapMixPannelSandBirdLoggerifNeeded() { //_ launchOptions : [UIApplication.LaunchOptionsKey: Any]?) {
        
        guard !isLaunchEventConfigured else { return }
        
        isLaunchEventConfigured = true
        
        ElGrocerUtility.sharedInstance.delay(5) {
            self.checkAdvertPermission ()
        }
        
        // Google Analytics
        GoogleAnalyticsHelper.configureGoogleAnalytics()
        self.initiliazeMarketingCampaignTrackingServices()
        
        // CleverTap
        CleverTapEventsLogger.shared.startCleverTapSharedSDK()
        
        // logToCrashleytics
        self.logApiError()
        ElGrocerEventsLogger.sharedInstance.firstOpen()
        
        // MARK:- TODO fixappsflyer
        //AppsFlyer
        //AppsFlyerLib.shared().appsFlyerDevKey = "fFWrKTcB3XBybYmSgAcLnP"
       // AppsFlyerLib.shared().appleAppID = "1040399641"
      // // AppsFlyerLib.shared().delegate = self
        if Platform.isDebugBuild {
           // AppsFlyerLib.shared().isDebug = true
        }
        //AppsFlyerLib.shared().customerUserID = CleverTap.sharedInstance()?.profileGetID()
        // MARK:- TODO fixappsflyer
        //AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 30)
        ElGrocerUtility.sharedInstance.delay(2) {
            self.startChatFeature()
        }
    }
   
    @objc
    func configuredElgrocerEventLogger() { //_ launchOptions : [UIApplication.LaunchOptionsKey: Any]?) {
        // Elgolia Events
        AlgoliaApi.sharedInstance.reStartInsights()
    }
    
    func startChatFeature() {
        
     //   self.configureZenDesk()
        
    }
    
    func scheduleAppRefresh() {

    }
   
    @available(iOS 13.0, *)
    func handleAppRefresh(task: BGAppRefreshTask) { }
    
     func checkAdvertPermission () {
    // FixMe Arch Error Fix
    //    MarketingCampaignTrackingHelper.sharedInstance.isAdvertRequestPermission { (reuslt) in
    //        FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: FireBaseElgrocerPrefix + "AdvertRequestPermission", parameter: ["isPermissionGranted" : reuslt])
    //    }
        
    // FixMe SDK Update
    //    Settings.isAdvertiserIDCollectionEnabled = true
    //    Settings.setAdvertiserTrackingEnabled(true)
    //    Settings.isAutoLogAppEventsEnabled = true
    //    Analytics.setAnalyticsCollectionEnabled(true)
        
    }
    
}

// MARK: Other life cycle methods
extension SDKManager {
//    func application(_ application: UIApplication,
//                     shouldSaveApplicationState coder: NSCoder) -> Bool {
//        return true
//    }
//
//    func application(_ application: UIApplication,
//                     shouldRestoreApplicationState coder: NSCoder) -> Bool {
//        return false
//    }
//
//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.portrait
//    }


//    // They will han
//    func open(_ url: URL, options: [String : Any] = [:],
//              completionHandler completion: ((Bool) -> Swift.Void)? = nil) {
//        CleverTap.sharedInstance()?.handleOpen(url, sourceApplication: nil)
//        completion?(false)
//    }
//
//
//    // Respond to Universal Links
//     func application(_ application: UIApplication, continue userActivity: NSUserActivity,
//                      restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
//
//        let dynamicLinks = DynamicLinks.dynamicLinks()
//
//        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
//
//            if let dynamiclink = dynamiclink, let _ = dynamiclink.url {
//               elDebugPrint("Your Imcomming Url Parameter is:%@",dynamiclink.url ?? "NUll")
//                ElGrocerUtility.sharedInstance.deepLinkURL = (dynamiclink.url?.absoluteString)!
//               elDebugPrint("Deep Link URL Str:%@",ElGrocerUtility.sharedInstance.deepLinkURL)
//                NotificationCenter.default.post(name: Notification.Name(rawValue: kDeepLinkNotificationKey), object: nil)
//            }
//        }
//
//        return handled
//    }
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
//
//        if Auth.auth().canHandle(url) {
//            return true
//        }
//        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url){
//           elDebugPrint("I'm Handling a link through the OpenURL method.")
//           elDebugPrint("Your Imcomming Url Parameter is:%@",dynamicLink.url ?? "DynamicLink URL is Null")
//            if let urlString = dynamicLink.url?.absoluteString {
//                ElGrocerUtility.sharedInstance.deepLinkURL = urlString
//                ElGrocerUtility.sharedInstance.deepLinkShotURL = url.absoluteString
//               elDebugPrint("Deep Link URL Str:%@",ElGrocerUtility.sharedInstance.deepLinkURL)
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDeepLinkNotificationKey), object: nil)
//                FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: "EG_DeepLink", parameter: ["url" : urlString , "DeepLink" : url.absoluteString])
//            }
//            return true
//        }
//
//
//
//        return application(app, open: url,
//                           sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//                           annotation: "") || RedirectComponent.applicationDidOpen(from: url)
//    }
//
//
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//
//        if Auth.auth().canHandle(url) {
//            return true
//        }
//
//
//
//        let dynamicLinksss = DynamicLinks.dynamicLinks()
//        let _ = dynamicLinksss.handleUniversalLink(url) { (dynamiclink, error) in
//            if let dynamiclink = dynamiclink, let _ = dynamiclink.url {
//                ElGrocerUtility.sharedInstance.deepLinkURL = (dynamiclink.url?.absoluteString)!
//                NotificationCenter.default.post(name: Notification.Name(rawValue: kDeepLinkNotificationKey), object: nil)
//            }
//        }
//        CleverTap.sharedInstance()?.handleOpen(url, sourceApplication: sourceApplication)
//
//        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) || RedirectComponent.applicationDidOpen(from: url)
//    }
//
//
//    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
//                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
//
//        let dynamicLinks = DynamicLinks.dynamicLinks()
//        let urlCameFrom = userActivity.webpageURL?.getQueryItemValueForKey("_osl")
//        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
//
//            if let dynamiclink = dynamiclink, let urlString = dynamiclink.url {
//                ElGrocerUtility.sharedInstance.deepLinkURL = (dynamiclink.url?.absoluteString)!
//               elDebugPrint("Deep Link URL Str:%@",ElGrocerUtility.sharedInstance.deepLinkURL)
//                DynamicLinksHelper.handleIncomingDynamicLinksWithUrl(ElGrocerUtility.sharedInstance.deepLinkURL)
//                ElGrocerUtility.sharedInstance.deepLinkShotURL = urlCameFrom ?? urlString.absoluteString
//
//                FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: "EG_DeepLink", parameter: ["url" : urlString.absoluteString , "DeepLink" : urlCameFrom ?? urlString.absoluteString])
//            }
//        }
//        return handled
//
//    }
}

extension UIWindow {
    static var key: UIWindow! {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
