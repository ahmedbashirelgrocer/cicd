//
//  SDKLoginManager.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 30/06/2022.
//

import Foundation

class SDKLoginManager {
    
    func loginRegisterUser(_ phoneNumber: String, _ completionHandler: @escaping (_ isSuccess: Bool, _ errorMessage: String) -> Void) {
        ElGrocerApi.sharedInstance
            .registerPhone(phoneNumber) { result, responseObject in
                if result {
                    let  locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    if (locations.count > 0) {
                        self.updateProfileAndData(responseObject!, completionHandler: completionHandler)
                    }else{
                        self.getUserDeliveryAddresses(responseObject!, completionHandler: completionHandler)
                    }
                    
                } else {
                    let errorMessage = localizedString("login_error_alert", comment: "")
                    completionHandler(false, errorMessage)
                }
            }
    }
    
    func getUserDeliveryAddresses(_ responseObject:NSDictionary?, completionHandler:@escaping (_ isSuccess: Bool, _ errorMessage: String) -> Void){
        
        // Set the user profile
        let userProfile = UserProfile.createOrUpdateUserProfile(responseObject!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        ElGrocerEventsLogger.sharedInstance.setUserProfile(userProfile)
        UserDefaults.setLogInUserID(userProfile.dbID.stringValue)
        //ZohoChat.loginZohoWith(userProfile.dbID.stringValue)
        // PushWooshTracking.setUserID(userID: userProfile.dbID.stringValue)
        FireBaseEventsLogger.setUserID(userProfile.dbID.stringValue)
        // Get the user delivery addresses
        ElGrocerApi.sharedInstance.getDeliveryAddresses({ (result, responseObject) -> Void in
            
            if result {
                let deliveryAddress = DeliveryAddress.insertOrUpdateDeliveryAddressesForUser(userProfile, fromDictionary: responseObject!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                if deliveryAddress.count == 0 {
                    self.createNewUser(for: userProfile) {
                        completionHandler(true, "")
                    }
                } else {
                    completionHandler(true, "")
                }
                /// login success
                // self.state.value = .loginSuccess
            } else {
                let errorMessage = localizedString("registration_error_alert", comment: "")
                completionHandler(false, errorMessage)
            }
        })
    }
    
    
    func updateProfileAndData(_ responseObject:NSDictionary?,completionHandler:@escaping (_ isSuccess: Bool, _ errorMessage: String) -> Void) {
        
        // Set the user profile
        let userProfile = UserProfile.createOrUpdateUserProfile(responseObject!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        ElGrocerEventsLogger.sharedInstance.setUserProfile(userProfile)
        UserDefaults.setLogInUserID(userProfile.dbID.stringValue)
        //ZohoChat.loginZohoWith(userProfile.dbID.stringValue)
        // PushWooshTracking.setUserID(userID: userProfile.dbID.stringValue)
        FireBaseEventsLogger.setUserID(userProfile.dbID.stringValue)
        completionHandler(true, "")
    }
    
    func setHomeView() -> Void {
        ElGrocerUtility.sharedInstance.setDefaultGroceryAgain()
        //let signInView = self
        if let nav = SDKManager.shared.window!.rootViewController as? UINavigationController {
            if nav.viewControllers.count > 0 {
                if  nav.viewControllers[0] as? UITabBarController != nil {
                    let tababarController = nav.viewControllers[0] as! UITabBarController
                    tababarController.selectedIndex = 0
                    
                    //                    if tababarController.viewControllers?.count == 5 {
                    //                        signInView.navigationController?.dismiss(animated: true, completion: { })
                    //                        if  self.presentingViewController is ElgrocerGenericUIParentNavViewController {
                    //
                    //                        }else{
                    //                            if let top = UIApplication.topViewController() {
                    //                                if top is ElgrocerGenericUIParentNavViewController {}else{
                    //                                 //   tababarController.present(SDKManager.getParentNav(), animated: false, completion: nil)
                    //                                }
                    //                            }
                    //                        }
                    //                    } else if tababarController.viewControllers?.count == 2 {
                    //                        signInView.navigationController?.dismiss(animated: true, completion: { })
                    //                    }
                    ElGrocerUtility.sharedInstance.CurrentLoadedAddress = ""
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kBasketUpdateNotificationKey), object: nil)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: KUpdateBasketToServer), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: KReloadGenericView), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: KresetToZero), object: nil)
                    return
                }}}
        
        //self.navigationController?.dismiss(animated: true, completion: {  })
        SDKManager.shared.showAppWithMenu()
    }
    
    func loginFlowForSDK(_ phoneNumber: String, _ completionHandler:@escaping (_ isSuccess: Bool, _ errorMessage: String) -> Void) {
        // if from SDK
        loginRegisterUser(phoneNumber) { isSuccess, errorMessage in
            if isSuccess {
                ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_login")
                FireBaseEventsLogger.trackSignIn()
                //            if let recipeIDis = self.recipeId {
                //                NotificationCenter.default.post(name: Notification.Name(rawValue: "SaveRefresh"), object: recipeIDis)
                //                RecipeDataHandler().saveRecipeApiCall(recipeID: recipeIDis, isSave: true) { (isSaved) in }
                //                self.recipeId = nil
                //            }
                
                
                SendBirdManager().createNewUserAndDeActivateOld()
                
                
                //            let addresses = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                //
                //            if addresses.count > 0 && self.isCommingFrom == .cart && !ElGrocerUtility.sharedInstance.isDeliveryMode  {
                //                self.dismiss(animated: true, completion: nil)
                //                return
                //            }
                //            guard addresses.count > 0 && self.isCommingFrom != .cart  else {
                //                let dashboardLocationVC = ElGrocerViewControllers.dashboardLocationViewController()
                //                dashboardLocationVC.isRootController = false
                //                dashboardLocationVC.isFormCart = (self.isCommingFrom == .cart)
                //                self.navigationController?.pushViewController(dashboardLocationVC, animated: true)
                //                return
                //            }
                //
                //            guard !(self.isCommingFrom == .cart) else {
                //
                //
                //                let location = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                //                let storeID = ElGrocerUtility.sharedInstance.activeGrocery?.dbID
                //                let parentID = ElGrocerUtility.sharedInstance.activeGrocery?.parentID.stringValue
                //                let _ = SpinnerView.showSpinnerView()
                //                ElGrocerApi.sharedInstance.checkIfGroceryAvailable(CLLocation.init(latitude: location!.latitude, longitude: location!.longitude), storeID: storeID ?? "", parentID: parentID ?? "") { (result) in
                //                    switch result {
                //                        case .success(let responseObject):
                //                            let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                //                            if  let response = responseObject["data"] as? NSDictionary {
                //                                if let groceryDict = response["retailers"] as? [NSDictionary] {
                //                                    if groceryDict.count > 0 {
                //                                        let arrayGrocery = Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)
                //                                        if arrayGrocery.count > 0 {
                //                                            ElGrocerUtility.sharedInstance.groceries = arrayGrocery
                //                                            ElGrocerUtility.sharedInstance.activeGrocery = arrayGrocery[0]
                //                                            self.dismiss(animated: true, completion: nil)
                //                                            return
                //                                        }
                //                                    }
                //                                }
                //                            }
                //
                //                            let SDKManager = SDKManager.shared
                //                            _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "") , header: "", detail: localizedString("lbl_NoCoverage_msg", comment: "") ,localizedString("add_address_alert_yes", comment: "") , localizedString("add_address_alert_no", comment: ""), withView: SDKManager.window!) { (index) in
                //                                if index == 0 {
                //                                     self.setHomeView()
                //                                }else{
                //
                //                                }
                //                        }
                //                        case .failure(let error):
                //                            SpinnerView.hideSpinnerView()
                //                            error.showErrorAlert()
                //                    }
                //                }
                //                return
                //            }
                
                self.setHomeView()
            }
            completionHandler(isSuccess, errorMessage)
        }
    }
    
    
    func registerUser() {
        
        ElGrocerApi.sharedInstance.getDeliveryAddresses { result, responseObject in
            print(result)
            print(responseObject)
        }
    }
    
    func createNewUser(for userProfile: UserProfile, completion: @escaping () -> Void ) {
        var newDeliveryAddress: DeliveryAddress = DeliveryAddress.createDeliveryAddressObject(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        newDeliveryAddress.locationName = ""
        newDeliveryAddress.apartment = ""
        newDeliveryAddress.building = ""
        newDeliveryAddress.street = ""
        newDeliveryAddress.userProfile = userProfile
        newDeliveryAddress.address = ""
        newDeliveryAddress.latitude = 25.276987
        newDeliveryAddress.longitude = 55.296249
        newDeliveryAddress.isActive = NSNumber(value: true)
        
        self.addAddressFromDeliveryAddress(newDeliveryAddress, forUser: userProfile) { () -> Void in
            
            UserDefaults.setDidUserSetAddress(true)
            UserDefaults.setUserLoggedIn(true)
            UserDefaults.setLogInUserID(userProfile.dbID.stringValue)
            
            completion()
            // If the controller was shown from entry registration, we should navigate home
            // If it was shown after checkout, we should just dismiss it and show the basket
            //            switch self.dismissMode {
            //            case .dismissModal: self.presentingViewController?.dismiss(animated: true, completion: nil)
            //            case .navigateHome: (SDKManager.shared).showAppWithMenu()
            //            }
            //self.delegate?.registrationControllerDidRegisterUser(self)
            
        }
    }
    
    /** Adds a delivery address on the backend and on success saves the local instance in the db */
    func addAddressFromDeliveryAddress(_ deliveryAddress: DeliveryAddress, forUser: UserProfile, completionHandler: @escaping () -> Void) {
        
        // _ = SpinnerView.showSpinnerViewInView(self.view)
        
        ElGrocerApi.sharedInstance.addDeliveryAddress(deliveryAddress) { (result, responseObject) -> Void in
            
            SpinnerView.hideSpinnerView()
            GoogleAnalyticsHelper.trackDeliveryLocationAction(DeliveryLocationActionType.Add)
            
            // Remove the temporary delivery address
            DatabaseHelper.sharedInstance.mainManagedObjectContext.delete(deliveryAddress)
            
            if result == true {
                
                let addressDict = (responseObject!["data"] as! NSDictionary)["shopper_address"] as! NSDictionary
                
                let currentAddress = DeliveryAddress.insertOrUpdateDeliveryAddressForUser(forUser, fromDictionary: addressDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                _ = DeliveryAddress.setActiveDeliveryAddress(currentAddress, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                DatabaseHelper.sharedInstance.saveDatabase()
                completionHandler()
                
                
            } else {
                ElGrocerAlertView.createAlert(localizedString("registration_error_alert", comment: ""),
                                              description: nil,
                                              positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                              negativeButton: nil, buttonClickCallback: nil).show()
            }
        }
    }
    
}
