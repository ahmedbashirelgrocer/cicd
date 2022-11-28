//
//  PreLoadData.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 28/11/2022.
//

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
        
        HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
        HomePageData.shared.delegate = self
        
        
        
        
        
        
        
//        if UserDefaults.isUserLoggedIn() || UserDefaults.didUserSetAddress() {
//            HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
//        }
        
    }
    
//    func showEntryView() {
//
//        defer {
//            self.refreshSessionStatesForEditOrder()
//        }
//
//        if let launchOptions = launchOptions, launchOptions.isSmileSDK { // Entry point for SDK
//            let manager = SDKLoginManager(launchOptions: launchOptions)
//            manager.loginFlowForSDK() { isSuccess, errorMessage in
//                let positiveButton = localizedString("no_internet_connection_alert_button", comment: "")
//                if isSuccess {
//                    manager.setHomeView()
//                } else {
//                 let alert = ElGrocerAlertView.createAlert(localizedString("error_500", comment: ""), description: nil, positiveButton: positiveButton, negativeButton: nil) { index in
//                        Thread.OnMainThread {
//                            if let topVC = UIApplication.topViewController() {
//                                if let navVc = topVC.navigationController, navVc.viewControllers.count > 1 {
//                                    navVc.popViewController(animated: true)
//                                } else {
//                                    topVC.dismiss(animated: true, completion: nil)
//                                }
//                            }
//                        }
//                    }
//                    alert.show()
//                }
//            }
//        } else {
//            let entryController =  ElGrocerViewControllers.entryViewController()
//            let navEntryController : ElGrocerNavigationController = ElGrocerNavigationController.init(rootViewController: entryController)
//            navEntryController.hideNavigationBar(true)
//            self.replaceRootControllerWith(navEntryController)
//        }
//   }
    
    
//    func setHomeView() -> Void {
//        ElGrocerUtility.sharedInstance.setDefaultGroceryAgain()
//        //let signInView = self
//        if let nav = SDKManager.shared.rootViewController as? UINavigationController {
//            if nav.viewControllers.count > 0 {
//                if  nav.viewControllers[0] as? UITabBarController != nil {
//                    let tababarController = nav.viewControllers[0] as! UITabBarController
//                    tababarController.selectedIndex = 0
//                    ElGrocerUtility.sharedInstance.CurrentLoadedAddress = ""
//
//                    Thread.OnMainThread {
//
//                        if let topVc = UIApplication.topViewController()?.navigationController?.classForCoder {
//                            let className = "\(topVc)"
//                            if className.contains("ElGrocer") {
//                                NotificationCenter.default.post(name: SDKLoginManager.KOpenOrderRefresh, object: SDKManager.shared.launchOptions)
//                                return
//                            }
//                        }
//                        NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateNotificationKey), object: nil)
//                        NotificationCenter.default.post(name: Notification.Name(rawValue: KUpdateBasketToServer), object: nil)
//                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KReloadGenericView), object: nil)
//                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KresetToZero), object: nil)
//                        SDKManager.shared.rootContext?.present(nav, animated: true, completion: nil)
////
////                        if !UIApplication.isElGrocerSDKClass() {
////                            UIApplication.topViewController()?.present(nav, animated: true, completion: nil)
////                        } else {
////                            // send notifcation push to refresh
////                            NotificationCenter.default.post(name: SDKLoginManager.KOpenOrderRefresh, object: SDKManager.shared.launchOptions)
////                        }
//                    }
//                    return
//                }
//            }
//        }
//        SDKManager.shared.showAppWithMenu()
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
}
