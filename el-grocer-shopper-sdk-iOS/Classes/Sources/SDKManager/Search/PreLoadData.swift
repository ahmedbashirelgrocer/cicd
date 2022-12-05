//
//  PreLoadData.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 28/11/2022.
//
/*
import Foundation

public class PreLoadData {
    
    public static var shared = PreLoadData()
    fileprivate var completion: (() -> Void)?
    
    public func loadData(launchOptions: LaunchOptions, completion: (() -> Void)? ) {
        self.completion = completion
        guard !ElGrocerAppState.isSDKLoadedAndDataAvailable(launchOptions) else {
            // Data already loaded return
            self.completion?()
            return
        }
        
        SDKManager.shared.launchOptions = launchOptions
        
        configureElgrocerShopper()
        HomePageData.shared.delegate = self
        
        if self.isNotLoggedin() {
            loginSignup {
                HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
            }
        } else {
            HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
        }
    }
    
    func loginSignup(completion: (() -> Void)?) {
        let launchOptions = SDKManager.shared.launchOptions!
        let manager = SDKLoginManager(launchOptions: launchOptions)
        manager.loginFlowForSDK() { [weak self] isSuccess, errorMessage in
            guard let self = self else { return }
            let positiveButton = localizedString("no_internet_connection_alert_button", comment: "")
            if isSuccess {
                ElGrocerUtility.sharedInstance.setDefaultGroceryAgain()
                completion?()
            } else {
                self.configLoginFailureCase(coompletion: completion)
            }
        }
    }
    private func configLoginFailureCase(coompletion: (() -> Void)?) {
        var delay : Double = 3
        if  ReachabilityManager.sharedInstance.isNetworkAvailable() {
            delay = 1.0
        }
        let when = DispatchTime.now() + delay
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: when) {
            self.loginSignup(completion: coompletion)
        }
    }
    
    
//    func reloadData() -> Void {
//        Thread.OnMainThread {
//            NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateNotificationKey), object: nil)
//            NotificationCenter.default.post(name: Notification.Name(rawValue: KUpdateBasketToServer), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KReloadGenericView), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KresetToZero), object: nil)
//        }
//    }
    
    private func configureElgrocerShopper() {
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
}

extension PreLoadData: HomePageDataLoadingComplete {
    func loadingDataComplete(type: loadingType?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if HomePageData.shared.isDataLoading == false {
                self.completion?()
            }
        }
    }
    
    func isNotLoggedin() -> Bool {
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let  locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let launchOptions = SDKManager.shared.launchOptions!
        
        if (userProfile == nil || userProfile?.phone?.count == 0) || launchOptions.accountNumber != userProfile?.phone || UserDefaults.isUserLoggedIn() == false {
            
            return true
            
        }
        return false
    }
}
*/
