//
//  SDKLoginManager.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 30/06/2022.
//

import Foundation
import UIKit


struct SDKLoginManager {
    
    static var KOpenOrderRefresh = NSNotification.Name(rawValue: "KOpenOrderRefreshFromPush")
    
    var launchOptions: LaunchOptions
    
    typealias CompletionHandler = (_ isSuccess: Bool, _ errorMessage: String) -> Void
    

    func loginFlowForSDK(_ completionHandler:@escaping CompletionHandler) {
        // if from SDK
        
        
        self.setLanguageWithLunchOptions()
        
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let  locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        guard ((userProfile == nil || userProfile?.phone?.count == 0 || launchOptions.accountNumber != userProfile?.phone || locations.count == 0) || ElGrocerUtility.sharedInstance.projectScope == nil)  else {
            ElGrocerEventsLogger.sharedInstance.setUserProfile(userProfile!)
            UserDefaults.setLogInUserID(userProfile?.dbID.stringValue ?? "")
            FireBaseEventsLogger.setUserID(userProfile?.dbID.stringValue)
            UserDefaults.setUserLoggedIn(true)
            UserDefaults.setDidUserSetAddress(true)
            completionHandler(true, "")
            return
        }
        
        //UserProfile.clearEntity()
        //DeliveryAddress.clearDeliveryAddressEntity()
        //DatabaseHelper.sharedInstance.clearDatabase(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        SDKManager.shared.logout() {
            loginRegisterUser(launchOptions.accountNumber ?? "") { isSuccess, errorMessage in
                if isSuccess {
                    ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_login")
                    FireBaseEventsLogger.trackSignIn()
                    SendBirdManager().createNewUserAndDeActivateOld()
                    
                }
                completionHandler(isSuccess, errorMessage)
            }
        }
    }
    
    private func loginRegisterUser(_ phoneNumber: String, _ completionHandler: @escaping CompletionHandler) {
        
        ElGrocerApi.sharedInstance
            .registerPhone(phoneNumber) { result, responseObject in
                if result {
                    let  locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    if (locations.count > 0 && locations[0].address.count > 0) {
                        self.updateProfileAndData(responseObject!)
                        ElGrocerUtility.sharedInstance.addDeliveryToServerWithBlock(locations) { (isResult) in
                            if isResult {
                                UserDefaults.setDidUserSetAddress(true)
                                completionHandler(true, "")
                            }
                        }
                    }else{
                        self.getUserDeliveryAddresses(responseObject!, completionHandler: completionHandler)
                    }
                    
                } else {
                    let errorMessage = localizedString("login_error_alert", comment: "")
                    completionHandler(false, errorMessage)
                }
            }
    }
    
    private func updateProfileAndData(_ responseObject:NSDictionary?) {
        
        // Set the user profile
        let userProfile = UserProfile.createOrUpdateUserProfile(responseObject!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        ElGrocerEventsLogger.sharedInstance.setUserProfile(userProfile)
        UserDefaults.setLogInUserID(userProfile.dbID.stringValue)
        FireBaseEventsLogger.setUserID(userProfile.dbID.stringValue)
    }
    
    private func getUserDeliveryAddresses(_ responseObject:NSDictionary?, completionHandler:@escaping CompletionHandler){
        
        // Set the user profile
        let userProfile = UserProfile.createOrUpdateUserProfile(responseObject!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        ElGrocerEventsLogger.sharedInstance.setUserProfile(userProfile)
        UserDefaults.setLogInUserID(userProfile.dbID.stringValue)
        FireBaseEventsLogger.setUserID(userProfile.dbID.stringValue)
        
        // Get the user delivery addresses
        ElGrocerApi.sharedInstance.getDeliveryAddresses({ (result, responseObject) -> Void in
         
            if result {
                let deliveryAddress = DeliveryAddress.insertOrUpdateDeliveryAddressesForUser(userProfile, fromDictionary: responseObject!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                if deliveryAddress.count == 0 {
                    self.createNewDefaultAddressForNewUser(for: userProfile, completion: completionHandler)
                } else {
                    UserDefaults.setDidUserSetAddress(true)
                    UserDefaults.setLogInUserID(userProfile.dbID.stringValue)
                    UserDefaults.setUserLoggedIn(true)
                    completionHandler(true, "")
                }
    
            } else {
                let errorMessage = localizedString("registration_error_alert", comment: "")
                completionHandler(false, errorMessage)
            }
            
        })
    }
    
    private func createNewDefaultAddressForNewUser(for userProfile: UserProfile, completion: @escaping CompletionHandler ) {
        
        let newDeliveryAddress: DeliveryAddress = DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        //newDeliveryAddress.addressType = "1"
        newDeliveryAddress.locationName = ""
        newDeliveryAddress.apartment = ""
        newDeliveryAddress.building = ""
        newDeliveryAddress.street = ""
        if userProfile.dbID.stringValue.count > 0 {
            newDeliveryAddress.userProfile = userProfile
        }
        
        newDeliveryAddress.address = launchOptions.address ?? ""
        newDeliveryAddress.latitude = launchOptions.latitude ?? 0
        newDeliveryAddress.longitude = launchOptions.longitude ?? 0
        newDeliveryAddress.isActive = NSNumber(value: true)
        newDeliveryAddress.addressType = "1"
        
        self.addAddressFromDeliveryAddress(newDeliveryAddress, forUser: userProfile) { isSuccess, errorMessage in
            if isSuccess {
                UserDefaults.setDidUserSetAddress(true)
                UserDefaults.setUserLoggedIn(true)
                UserDefaults.setLogInUserID(userProfile.dbID.stringValue)
            }
            completion(isSuccess, errorMessage)
        }
    }
    
    /** Adds a delivery address on the backend and on success saves the local instance in the db */
    func addAddressFromDeliveryAddress(_ deliveryAddress: DeliveryAddress, forUser: UserProfile, completionHandler: @escaping CompletionHandler) {
        
        ElGrocerApi.sharedInstance.addDeliveryAddress(deliveryAddress) { (result, responseObject) -> Void in
            GoogleAnalyticsHelper.trackDeliveryLocationAction(DeliveryLocationActionType.Add)
            // Remove the temporary delivery address
            DatabaseHelper.sharedInstance.mainManagedObjectContext.delete(deliveryAddress)
            if result == true {
                
                let addressDict = (responseObject!["data"] as! NSDictionary)["shopper_address"] as! NSDictionary
                let currentAddress = DeliveryAddress.insertOrUpdateDeliveryAddressForUser(forUser, fromDictionary: addressDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                _ = DeliveryAddress.setActiveDeliveryAddress(currentAddress, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                DatabaseHelper.sharedInstance.saveDatabase()
                completionHandler(true, "")
            } else {
                completionHandler(false, localizedString("registration_error_alert", comment: ""))
            }
        }
    }
}

extension SDKLoginManager {
    
    func setHomeView() -> Void {
        ElGrocerUtility.sharedInstance.setDefaultGroceryAgain()
        //let signInView = self
        if let nav = SDKManager.shared.rootViewController as? UINavigationController {
            if nav.viewControllers.count > 0 {
                if  nav.viewControllers[0] as? UITabBarController != nil {
                    let tababarController = nav.viewControllers[0] as! UITabBarController
                    tababarController.selectedIndex = 0
                    ElGrocerUtility.sharedInstance.CurrentLoadedAddress = ""
                   
                    Thread.OnMainThread {
                        
                        if let topVc = UIApplication.topViewController()?.navigationController?.classForCoder {
                            let className = "\(topVc)"
                            if className.contains("ElGrocer") {
                                NotificationCenter.default.post(name: SDKLoginManager.KOpenOrderRefresh, object: SDKManager.shared.launchOptions)
                                return
                            }
                        }
                        NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateNotificationKey), object: nil)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: KUpdateBasketToServer), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KReloadGenericView), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KresetToZero), object: nil)
                        SDKManager.shared.rootContext?.present(nav, animated: true, completion: nil)
//
//                        if !UIApplication.isElGrocerSDKClass() {
//                            UIApplication.topViewController()?.present(nav, animated: true, completion: nil)
//                        } else {
//                            // send notifcation push to refresh
//                            NotificationCenter.default.post(name: SDKLoginManager.KOpenOrderRefresh, object: SDKManager.shared.launchOptions)
//                        }
                    }
                    return
                }
            }
        }
        SDKManager.shared.showAppWithMenu()
    }
}

// MARK:- Helpers

extension SDKLoginManager {
    
    
    private func setLanguageWithLunchOptions() {
        
        if SDKManager.shared.launchOptions?.isSmileSDK == true && (SDKManager.shared.launchOptions?.language?.count ?? 0) > 0 {
            if let smileLanguage = SDKManager.shared.launchOptions?.language {
                UserDefaults.setCurrentLanguage(smileLanguage)
            }
        }
        
    }
    
    
}
