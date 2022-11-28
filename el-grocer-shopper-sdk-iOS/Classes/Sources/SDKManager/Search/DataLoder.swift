//
//  DataLoder.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 24/11/2022.
//

import Foundation

struct DataLoader {
    static func startLoading() {
        self.configureElgrocerShopper()
        let location = Location.init(latitude: SDKManager.shared.launchOptions?.latitude ?? 0,
                                     longitude: SDKManager.shared.launchOptions?.longitude ?? 0)
        self.fetchRetailersIfNeeded(new: location) { _, retailers in
            ElgrocerSearchClient.shared.retailers = retailers ?? []
        }
    }
    
    //MARK: - Load Retailers
    static func fetchRetailersIfNeeded(new location1: Location,
                                       old location2: Location? = nil,
                                       completion: @escaping (ElGrocerError?, [RetailerShort]?) -> Void ) {
        
        if location2 == nil || (location2?.distance(from: location1) ?? 0) > 10 {
            ElGrocerApi
                .sharedInstance
                .getRetailersListLight(lat: location1.latitude,
                                       lng: location1.longitude) { result in
                    switch result {
                    case .success(let response):
                        let retailers = (response["data"] as? [[String: Any]])?
                            .map{ RetailerShort(data: $0) } ?? []
                        completion(nil, retailers)
                    case .failure(_):
                        configFailureCase(new: location1, old: location2, completion: completion)
                    }
                }
        } else {
            completion(nil, nil)
        }
    }
    private static func configFailureCase(new location1: Location,
                                          old location2: Location?,
                                          completion: @escaping (ElGrocerError?, [RetailerShort]?) -> Void) {
        var delay : Double = 3
        if  ReachabilityManager.sharedInstance.isNetworkAvailable() {
            delay = 1.0
        }
        let when = DispatchTime.now() + delay
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: when) {
            self.fetchRetailersIfNeeded(new: location1, old: location2, completion: completion)
        }
    }
    
    //MARK: - Load configurations
    private static func configureElgrocerShopper() {
        ElGrocerApi.sharedInstance.getAppConfig { (result) in
            switch result {
                case .success(let response):
                    if let newData = response["data"] as? NSDictionary {
                        ElGrocerUtility.sharedInstance.appConfigData = AppConfiguration.init(dict: newData as! Dictionary<String, Any>)
                    } else {
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
    
    private static func configFailureCase() {
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
