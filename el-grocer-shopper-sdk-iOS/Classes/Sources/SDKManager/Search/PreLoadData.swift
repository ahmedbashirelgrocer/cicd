//
//  PreLoadData.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 28/11/2022.
//

import Foundation
public class PreLoadData {
    
    public static var shared = PreLoadData()
    
    public func loadData(launchOptions: LaunchOptions) {
        guard !ElGrocerAppState.isSDKLoadedAndDataAvailable(launchOptions) else {
            // Data already loaded return
            return
        }
        
        SDKManager.shared.launchOptions = launchOptions
        
        // SDKManager.shared.refreshSessionStatesForEditOrder()
        
        configureElgrocerShopper()
        
        HomePageData.shared.fetchHomeData(Platform.isDebugBuild)
    }
    
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
