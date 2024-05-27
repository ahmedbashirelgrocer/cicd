//
//  SplashAnimationViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 24/09/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

/**
 
 LottieAniamtionViewUtil.showAnimation(onView:  self.lottieAnimation, withJsonFileName: "OrderConfirmationSmiles", removeFromSuper: false, loopMode: .playOnce) { isloaded in }
 
 */

import UIKit
import Lottie
import FirebaseCore

private enum BackendSuggestedAction: Int {
    case Continue = 0
    case ForceUpdate = 1
}
class SplashAnimationViewController: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet var splashLottieLogoAnimator: UIView! {
        didSet {
            splashLottieLogoAnimator.isHidden = false
        }
    }
    
    @IBOutlet var logoAnimator: ElGrocerLogoIndicatorView! {
            didSet {
                logoAnimator.isHidden = false
            }
        }

    lazy var delegate = getSDKManager()
    var isAnimationCompleted : Bool = false
    var locationFetching: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = sdkManager.isSmileSDK ? ApplicationTheme.currentTheme.themeBasePrimaryColor :ApplicationTheme.currentTheme.navigationBarWhiteColor
        
        if  sdkManager.isShopperApp {
            
            if UserDefaults.isUserLoggedIn() && !UserDefaults.isAnalyticsIdentificationCompleted() {
                let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                SegmentAnalyticsEngine.instance.identify(userData: IdentifyUserEvent(user: userProfile))
                UserDefaults.setIsAnalyticsIdentificationCompleted(new: true)
            }
            self.checkClientVersion()
            self.configureElgrocerShopper()
            if UserDefaults.isUserLoggedIn() { self.fetchLocations() }
            
            if ElGrocerUtility.sharedInstance.adSlots == nil {
                self.configureElgrocerShopper()
                getSponsoredProductsAndBannersSlots { isLoaded in }
            }
            
            UserDefaults.setIsPopAlreadyDisplayed(false)
            // Logging segment event for Application Opnened only for shopper application
            SegmentAnalyticsEngine.instance.logEvent(event: ApplicationOpenedEvent())
           
        } else {
            // ElGrocerUtility.isAddressCentralisation
            // Smiles Application case
            fetchData()
        }
  
        
        
        SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .splashScreen))
        
    }
    
    func fetchData() {
        
        var sDKLoginManager: SDKLoginManager?
        var isAddressChanged = false
        let fetchGroup = DispatchGroup()
        
        // fetchGroup.enter()
        self.startLogoAnimation() { }
        
        if ElGrocerUtility.sharedInstance.appConfigData == nil || ElGrocerUtility.sharedInstance.adSlots == nil {
            fetchGroup.enter()
            self.configureSmilesSDK() { AccessQueue.execute {
                fetchGroup.leave()
            } }
        }
      
       /* if ElGrocerUtility.sharedInstance.adSlots == nil {
            self.getSponsoredProductsAndBannersSlots { isLoaded in }
        }
        
        if ElGrocerUtility.sharedInstance.appConfigData == nil {
            fetchGroup.enter()
            self.configureElgrocerShopper() { AccessQueue.execute {
                fetchGroup.leave()
            } }
        }*/
        
        // LoginSignup
        fetchGroup.enter()
        self.delegate.showEntryViewWithSuccessClouser({ (_ manager: SDKLoginManager?) -> Void in
            AccessQueue.execute {
                sDKLoginManager = manager
                
                if !UserDefaults.isAnalyticsIdentificationCompleted() {
                    let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    SegmentAnalyticsEngine.instance.identify(userData: IdentifyUserEvent(user: userProfile))
                    UserDefaults.setIsAnalyticsIdentificationCompleted(new: true)
                }
                
                let _ = ElGrocerUtility.setDefaultAddress()
                // this code crashing on smiles application please do not enable it in future
                // https://console.firebase.google.com/u/2/project/smiles-83564/crashlytics/app/ios:Etisalat.House/issues/f1a7ac176d17c10438478ba0391f19ee?time=last-seven-days&types=crash&sessionEventKey=3c854bdc3953405691fe6a167f9a452a_1939451492008114799
//                if !SDKLoginManager.isAddressFetched {
//                    fetchGroup.enter()
//                    let oldAddressId = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()?.dbID ?? ""
//                    SDKLoginManager.getDeliveryAddress { isSuccess, errorMessage, errorCode in
//
//                        let newAddressId = ElGrocerUtility.setDefaultAddress()
//                        isAddressChanged = oldAddressId != newAddressId
//                        fetchGroup.leave()
//                    }
//                }
                
                fetchGroup.leave()
            }
        })
        
        fetchGroup.notify(queue: .main) { AccessQueue.execute {
            HomePageData.shared.loadingCompletionSplash = {
                sDKLoginManager?.setHomeView()
                HomePageData.shared.loadingCompletionSplash = nil
            }
            
            if isAddressChanged {
                HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
                return
            }
            
            if HomePageData.shared.isDataLoading {
                print("loading data ...")
                return
            } else if HomePageData.shared.isLoadingComplete {
                sDKLoginManager?.setHomeView()
            } else {
                HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
            }
        }}
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ElGrocerUtility.isAddressCentralisation { return }
        
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        if HomePageData.shared.isLoadingComplete && sdkManager.launchOptions?.accountNumber == userProfile?.phone {
            self.animationCompletedSetRootVc()
        } else {
            self.startLogoAnimation()
        }
        // self.startConditionalHomeDataFetching()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.StartLogoAnimation() // for lottie splash
    }
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }

 
    private func startConditionalHomeDataFetching() {
        if UserDefaults.isUserLoggedIn() || UserDefaults.didUserSetAddress() {
            HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
        }
    }
    
    private func startLogoAnimation(completion: (()->Void)? = nil) {
        
        if UIApplication.shared.applicationState == .active {
            // 
            if sdkManager.isShopperApp {
                // splash_animation_shopper
                LottieAniamtionViewUtil.showAnimation(onView:  self.splashLottieLogoAnimator,
                                                      contentMode: .scaleToFill,
                                                      withJsonFileName: self.getLottieFileName(),
                                                      removeFromSuper: false,
                                                      loopMode: .playOnce) {[weak self] isloaded in
                    guard let self = self else { return }
                    completion?()
                    
                    if isloaded {
                        self.isAnimationCompleted = true
                        if HomePageData.shared.fetchOrder.count == 0 && self.locationFetching == false {
                            self.animationCompletedSetRootVc()
                        }
                        self.activityIndicator.isHidden = false
                        self.activityIndicator.startAnimating()
                    }
                }
                
                
            } else {
                // this method is only for smile sdk. if you thing you need to remove png and add lottie here please make sure to remove this method and update the fetching process accordinly
//                self.forLogoAnimatorStartFetchProcess()
                
                self.logoAnimator.startAnimate { [weak self] (isCompleted) in
                    completion?()
                    
                    if isCompleted {
//                        if HomePageData.shared.fetchOrder.count == 0 && self?.locationFetching == false {
//                            self?.animationCompletedSetRootVc()
//
//                        }
//                        self?.isAnimationCompleted = true
                        
                        self?.activityIndicator.isHidden = false
                        self?.activityIndicator.startAnimating()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                            self?.logoAnimator.image = UIImage(name: "ElgrocerLogoAnimation-87")
                        }
                    }
                }
            }
            
            
            
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(cameBackFromSleep(sender:)),
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )
            
        } else {
            ElGrocerUtility.sharedInstance.delay(0.5) {
                self.startLogoAnimation(completion: completion)
            }
        }
       
    }
    
    private func getLottieFileName() -> String {
        if sdkManager.isSmileSDK { return "splash_animation_sdk" }
        
        let currentDate = Date()
        
        // end date of ramadan splash animation
        let endDate = Calendar.current.date(from: DateComponents(year: 2024, month: 4, day: 10))!
        
        let shopperLottieFileName = (currentDate <= endDate) ? "ramadan_splash" : "splash_animation_shopper"
//        let shopperLottieFileName = (currentDate <= endDate) ? "splash_animation_shopper" : "splash_animation_shopper"
 
        return shopperLottieFileName
    }
    
//    private func forLogoAnimatorStartFetchProcess() {
//        self.delegate.showEntryViewWithSuccessClouser { manager in
//            self.setHome(manager: manager)
//        }
//    }
    
//    private func setHome(manager : SDKLoginManager?) {
//
//        guard self.isAnimationCompleted  else {
//            let when = DispatchTime.now() + 1
//            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: when) {
//                self.setHome(manager: manager)
//            }
//            return
//        }
//        Thread.OnMainThread {
//            manager?.setHomeView()
//        }
//    }
    
    private func animationCompletedSetRootVc() {
        
        Thread.OnMainThread {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self.isAnimationCompleted = true
            self.setRootVc()
        }
        
    }
    
    @objc func cameBackFromSleep(sender : AnyObject) {
        
        if ElGrocerUtility.isAddressCentralisation {
            fetchData()
            return
        }
        
        if self.isAnimationCompleted {
            
            if let dataAvailable = getSDKManager().sdkStartTime {
                if dataAvailable.timeIntervalSinceNow > -3 {
                    self.animationCompletedSetRootVc()
                    return
                }
            }
            self.startLogoAnimation()
        }else{
            self.startLogoAnimation()
        }
        
    }
    
    
    @objc
    private func setRootVc() {
        

        guard let topVc = UIApplication.topViewController() , topVc is ForceUpdateViewController else {
            if !(sdkManager.launchOptions?.isSmileSDK == true) && (UserDefaults.isUserLoggedIn() || UserDefaults.didUserSetAddress()) {
                let tabVC = self.delegate.getTabbarController(isNeedToShowChangeStoreByDefault: false)
                if let main = self.delegate.window {
                    self.setLanguage()
                    main.rootViewController =  tabVC     // getParentNav()
                    main.makeKeyAndVisible()
                }
            } else {
                self.callSetUpApis()
                if SDKManager.shared.isShopperApp {  sdkManager.showEntryView() }
            }
            return
        }
    }
    
 
   
   
}
extension SplashAnimationViewController {
    
    
    private func getSponsoredProductsAndBannersSlots(completion: @escaping (Bool) -> Void) {
        var marketType = 0 // Shopper
        if SDKManager.shared.launchOptions?.marketType == .marketPlace {
            marketType = 2
        } else if SDKManager.shared.launchOptions?.marketType == .grocerySingleStore {
            marketType = 1
        }
            
        ElGrocerApi.sharedInstance.getSponsoredProductsAndBannersSlots(formerketType: marketType) { result in
            switch result {
                
            case .success(let adSlots):
                ElGrocerUtility.sharedInstance._adSlots[marketType] = adSlots
                completion(true)
                
            case .failure(let error):
                elDebugPrint("Error in fetching sponsored product and banners slots >> \(error.localizedMessage)")
                completion(false)
            }
        }
    }
    
    
    
    @objc private func configureSmilesSDK(completion: (()->Void)? = nil) {
        
        ElgrocerConfigManager.shared.fetchMasterConfiguration { results in
            completion?()
            if sdkManager.isShopperApp {
                ABTestManager.shared.fetchRemoteConfigs()
            }
        }
    }
    
    
    
    @objc private func configureElgrocerShopper(completion: (()->Void)? = nil) {

        ElGrocerApi.sharedInstance.getAppConfig { [weak self] (result) in
            switch result {
                case .success(let response):
                    if let newData = response["data"] as? NSDictionary {
                        ElGrocerUtility.sharedInstance.appConfigData = AppConfiguration.init(dict: newData as! Dictionary<String, Any>)
                        if sdkManager.isShopperApp {
                            ABTestManager.shared.fetchRemoteConfigs()
                        }
                        completion?()
                    }else{
                        self?.configFailureCase()
                    }
                case .failure(let error):
                if error.code >= 500 && error.code <= 599 {
                        let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage() , header: localizedString("alert_error_title", comment: "") , detail: localizedString("error_500", comment: ""),localizedString("promo_code_alert_no", comment: "") , localizedString("lbl_retry", comment: "") , withView: SDKManager.shared.window!) { (buttonIndex) in
                            if buttonIndex == 1 {
                                self?.configFailureCase()
                            }
                        }
                    }
            }
        }

    }
    
    private func configFailureCase() {

        var delay : Double = 3
        if  ReachabilityManager.sharedInstance.isNetworkAvailable() {
            delay = 1.0
        }
        let when = DispatchTime.now() + delay
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: when) { [weak self] in
            self?.configureElgrocerShopper()
        }

    }
    
    private func checkClientVersion() {
        
        let when = DispatchTime.now() + 5
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: when) { [weak self] in
            ElGrocerApi.sharedInstance.checkClientVersion({ (action, message) -> Void in
                guard let action = BackendSuggestedAction(rawValue: action) else {
                    return
                }
                switch action {
                    case .ForceUpdate:
                        self?.delegate.showForceUpdateView()
                    case .Continue:
                        break
                }
            }) { () -> Void in
               elDebugPrint("Error checking client version")
            }
        }
    }
    
    @objc
    private func callSetUpApis() {
        // FixMe: 
        // self.checkClientVersion()
        self.setLanguage()
    }
    @objc
    private func setLanguage() {
        SDKManager.shared.setupLanguage()
            // self.delegate.setupLanguage()
    }
    
    fileprivate func fetchLocations() {
        
        self.locationFetching = true
        
        func callAddressApi(_ userProfile: UserProfile) {
            
            if let activeAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext), !activeAddress.dbID.isEmptyStr, activeAddress.latitude != 0.0, activeAddress.longitude != 0.0 {
                self.locationFetching = false
                return
            }
            
            ElGrocerApi.sharedInstance.getDeliveryAddresses({ [weak self] (result:Bool, responseObject:NSDictionary?) -> Void in
                if result {
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                    context.performAndWait({ () -> Void in
                       _ = DeliveryAddress.insertOrUpdateDeliveryAddressesForUser(userProfile, fromDictionary: responseObject!, context: context)
                        DatabaseHelper.sharedInstance.saveDatabase()
                    })
                }
                self?.locationFetching = false
            })
        }
        
        
        if let userProfile = UserProfile.getOptionalUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            callAddressApi(userProfile)
            return
        }
        
        ElGrocerApi.sharedInstance.getUserProfile { [weak self] response in
            switch response {
            case.success(let responseObject):
                let userProfile = UserProfile.createOrUpdateUserProfile(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                callAddressApi(userProfile)
            case.failure(_):
                self?.locationFetching = false
            }
        }
      
    }

    
}
