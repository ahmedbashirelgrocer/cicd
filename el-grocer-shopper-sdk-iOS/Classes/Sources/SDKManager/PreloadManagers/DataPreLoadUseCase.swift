//
//  DataPreLoadUseCase.swift
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
            self.updateLocationIfNeeded() {
                HomePageData.shared.fetchHomeData(Platform.isDebugBuild, completion: completion)
            }
            return
        }

        SDKManager.shared.launchOptions = launchOptions

        configureElgrocerShopper()
        
        // Remove me
        // HomePageData.shared.delegate = self

        if self.isNotLoggedin() {
            loginSignup {
                HomePageData.shared.fetchHomeData(Platform.isDebugBuild, completion: completion)
            }
        } else {
            HomePageData.shared.fetchHomeData(Platform.isDebugBuild, completion: completion)
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
                self.updateLocationIfNeeded(completion: completion)
            } else {
                self.configLoginFailureCase(coompletion: completion)
            }
        }
    }
    
    func updateLocationIfNeeded(completion: (() -> Void)? ) {
        let  locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        let lat = SDKManager.shared.launchOptions?.latitude
        let lng = SDKManager.shared.launchOptions?.longitude
        
        if let dLocation = locations.first(where: { $0.isActive == NSNumber(value: true) }),
           dLocation.latitude == lat && dLocation.longitude == lng {
            completion?()
            return
        }
        
        var isDefaultUpdated = false
        
        for location in locations {
            if location.latitude == lat && location.longitude == lng {
                location.isActive = true
                isDefaultUpdated = true
                ElGrocerApi.sharedInstance.setDefaultDeliveryAddress(location, completionHandler: { (result) in
                    if (result == true){
                        HomePageData.shared.fetchHomeData(Platform.isDebugBuild, completion: completion)
                    }else{
                       elDebugPrint("Error while setting default location on Server.")
                    }
                })
            } else {
                location.isActive = false
            }
        }
        
        if !isDefaultUpdated {
            let launchOptions = SDKManager.shared.launchOptions!
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)!
            
            let newDeliveryAddress: DeliveryAddress = DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            newDeliveryAddress.locationName = ""
            newDeliveryAddress.apartment = ""
            newDeliveryAddress.building = ""
            newDeliveryAddress.street = ""
            
            newDeliveryAddress.userProfile = userProfile
            
            newDeliveryAddress.address = launchOptions.address ?? ""
            newDeliveryAddress.latitude = launchOptions.latitude ?? 0
            newDeliveryAddress.longitude = launchOptions.longitude ?? 0
            newDeliveryAddress.isActive = NSNumber(value: true)
            newDeliveryAddress.addressType = "1"
            
            SDKLoginManager(launchOptions: launchOptions).addAddressFromDeliveryAddress(newDeliveryAddress, forUser: userProfile) { isSuccess, errorMessage in
                if isSuccess {
                    UserDefaults.setDidUserSetAddress(true)
                    UserDefaults.setUserLoggedIn(true)
                    UserDefaults.setLogInUserID(userProfile.dbID.stringValue)
                }
                HomePageData.shared.fetchHomeData(Platform.isDebugBuild, completion: completion)
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

extension PreLoadData {
    func isNotLoggedin() -> Bool {
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        let launchOptions = SDKManager.shared.launchOptions!

        if (userProfile == nil || userProfile?.phone?.count == 0) || launchOptions.accountNumber != userProfile?.phone || UserDefaults.isUserLoggedIn() == false {
            
            return true
            
        }
        return false
    }
}

//extension DataPreLoadUseCase {
//     3
//    func getRetailerData(location : Location) -> Observable<RetailerData> {
//        return Observable<RetailerData>.create { observer in
//            let apiHandeler = GenericStoreMeduleAPI()
//            apiHandeler.getAllretailers(latitude: location.latitude, longitude: location.longitude, success: { (task, responseObj) in
//                if  responseObj is NSDictionary {
//                    let data: NSDictionary = responseObj as? NSDictionary ?? [:]
//                    if let dataDict : NSDictionary = data["data"] as? NSDictionary {
//
//                        let storeTypes = (dataDict["store_types"] as? [[String: Any]])?
//                            .map{ StoreType(storeType: $0) } ?? []
//                        let retailerTypes = (dataDict["retailer_types"] as? [[String : Any]])?
//                            .map{ RetailerType(retailerType: $0) } ?? []
//                        var retailers: [Grocery] = []
//
//                        if dataDict["retailers"] as? [NSDictionary] != nil {
//                            retailers = Grocery.insertOrReplaceGroceriesFromDictionary(data, context: DatabaseHelper.sharedInstance.mainManagedObjectContext , false)
//                        }
//
//                        let retailerData: RetailerData = .init(storeTypes: storeTypes,
//                                                               retailerTypes: retailerTypes,
//                                                               retailers: retailers)
//                        observer.onNext(retailerData)
//                    } else {
//                        observer.onError(NSError())
//                    }
//                } else {
//                    observer.onError(NSError())
//                }
//            }) { (task, error) in
//                observer.onError(error)
//            }
//
//            return Disposables.create()
//        }.retry(5)
//    }
//}
//
//struct RetailerData {
//    var storeTypes: [StoreType]
//    var retailerTypes: [RetailerType]
//    var retailers: [Grocery]
//}
