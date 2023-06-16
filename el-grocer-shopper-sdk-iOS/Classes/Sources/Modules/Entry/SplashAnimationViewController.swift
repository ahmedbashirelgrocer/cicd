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
        self.view.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        HomePageData.shared.loadingCompletionSplash = { [weak self] in
            if self?.isAnimationCompleted == true {
                if AppSetting.currentSetting.isSmileApp() {
                    self?.animationCompletedSetRootVc()
                }
            }
        }
        SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .splashScreen))
        
        // segment identification of existing users who already logged in application
        if UserDefaults.isUserLoggedIn() && !UserDefaults.isAnalyticsIdentificationCompleted() {
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            SegmentAnalyticsEngine.instance.identify(userData: IdentifyUserEvent(user: userProfile))
            UserDefaults.setIsAnalyticsIdentificationCompleted(new: true)
        }
        
        if  sdkManager.isShopperApp {
            self.configureElgrocerShopper()
            if UserDefaults.isUserLoggedIn() {
                self.fetchLocations()
            }
            self.checkClientVersion()
        }
        
        if ElGrocerUtility.sharedInstance.adSlots == nil {
            self.configureElgrocerShopper()
            getSponsoredProductsAndBannersSlots { isLoaded in }
        }
        
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        if HomePageData.shared.isLoadingComplete && SDKManager.shared.launchOptions?.accountNumber == userProfile?.phone {
            self.animationCompletedSetRootVc()
        } else {
            self.StartLogoAnimation()
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
    
    private func StartLogoAnimation() {
        
        if UIApplication.shared.applicationState == .active {
            
            if SDKManager.shared.isShopperApp {
                
                LottieAniamtionViewUtil.showAnimation(onView:  self.splashLottieLogoAnimator,
                                                      withJsonFileName:
                                                      sdkManager.isSmileSDK ? "splash_animation_sdk" : "splash_animation_shopper",
                                                      removeFromSuper: false,
                                                      loopMode: .playOnce) {[weak self] isloaded in
                    guard let self = self else { return }
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
                self.forLogoAnimatorStartFetchProcess()
                
                self.logoAnimator.startAnimate { [weak self] (isCompleted) in
                    if isCompleted {
                        if HomePageData.shared.fetchOrder.count == 0 && self?.locationFetching == false {
                            self?.animationCompletedSetRootVc()
                            
                        }
                        self?.isAnimationCompleted = true
                        self?.activityIndicator.isHidden = false
                        self?.activityIndicator.startAnimating()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                            self?.logoAnimator.image = UIImage(name: "ElgrocerLogoAnimation-121")
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
                self.StartLogoAnimation()
            }
        }
       
    }
    
    private func forLogoAnimatorStartFetchProcess() {
        self.delegate.showEntryViewWithSuccessClouser { manager in
            self.setHome(manager: manager)
        }
    }
    
    private func setHome(manager : SDKLoginManager?) {
        
        guard self.isAnimationCompleted  else {
            let when = DispatchTime.now() + 1
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: when) {
                self.setHome(manager: manager)
            }
            return
        }
        Thread.OnMainThread {
            manager?.setHomeView()
        }
    }
    
    private func animationCompletedSetRootVc() {
        
        Thread.OnMainThread {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self.isAnimationCompleted = true
            self.setRootVc()
        }
        
    }
    
    @objc func cameBackFromSleep(sender : AnyObject) {
        
        if self.isAnimationCompleted {
            
            if let dataAvailable = getSDKManager().sdkStartTime {
                if dataAvailable.timeIntervalSinceNow > -3 {
                    self.animationCompletedSetRootVc()
                    return
                }
            }
            self.StartLogoAnimation()
        }else{
            self.StartLogoAnimation()
        }
        
    }
    
    
    @objc
    private func setRootVc() {
        

        guard let topVc = UIApplication.topViewController() , topVc is ForceUpdateViewController else {
            if !(SDKManager.shared.launchOptions?.isSmileSDK == true) && (UserDefaults.isUserLoggedIn() || UserDefaults.didUserSetAddress()) {
                let tabVC = self.delegate.getTabbarController(isNeedToShowChangeStoreByDefault: false)
                if let main = self.delegate.window {
                    self.setLanguage()
                    main.rootViewController =  tabVC     // getParentNav()
                    main.makeKeyAndVisible()
                }
            } else {
                self.callSetUpApis()
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
    
    
    
 @objc private func configureElgrocerShopper() {

        ElGrocerApi.sharedInstance.getAppConfig { (result) in
            switch result {
                case .success(let response):
                    if let newData = response["data"] as? NSDictionary {
                        ElGrocerUtility.sharedInstance.appConfigData = AppConfiguration.init(dict: newData as! Dictionary<String, Any>)
                    }else{
                        self.configFailureCase()
                    }
                case .failure(let error):
                if error.code >= 500 && error.code <= 599 {
                        let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage() , header: localizedString("alert_error_title", comment: "") , detail: localizedString("error_500", comment: ""),localizedString("promo_code_alert_no", comment: "") , localizedString("lbl_retry", comment: "") , withView: SDKManager.shared.window!) { (buttonIndex) in
                            if buttonIndex == 1 {
                                self.configFailureCase()
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
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: when) {
            self.configureElgrocerShopper()
        }

    }
    
    private func checkClientVersion() {
        
        let when = DispatchTime.now() + 5
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: when) {
            ElGrocerApi.sharedInstance.checkClientVersion({ (action, message) -> Void in
                guard let action = BackendSuggestedAction(rawValue: action) else {
                    return
                }
                switch action {
                    case .ForceUpdate:
                        self.delegate.showForceUpdateView()
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
            
            if let activeAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext){
                self.locationFetching = false
                return
            }
            
            ElGrocerApi.sharedInstance.getDeliveryAddresses({ (result:Bool, responseObject:NSDictionary?) -> Void in
                if result {
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                    context.performAndWait({ () -> Void in
                       _ = DeliveryAddress.insertOrUpdateDeliveryAddressesForUser(userProfile, fromDictionary: responseObject!, context: context)
                        DatabaseHelper.sharedInstance.saveDatabase()
                    })
                }
                self.locationFetching = false
            })
        }
        
        
        if let userProfile = UserProfile.getOptionalUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            callAddressApi(userProfile)
            return
        }
        
        ElGrocerApi.sharedInstance.getUserProfile { response in
            switch response {
            case.success(let responseObject):
                let userProfile = UserProfile.createOrUpdateUserProfile(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                callAddressApi(userProfile)
            case.failure(_):
                self.locationFetching = false
            }
        }
      
    }

    
}
