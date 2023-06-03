//
// LoginSignupService.swift
// ElGrocerShopper
//
// Created by Sarmad Abbas on 30/08/2022.
// Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import AVFoundation

struct LoginSignupService {
    static func verifyPhone(phoneNumber: String,
                            completion: ((_ isSuccess: Bool, _ errorMsg: String) -> Void)? ) {
        ElGrocerApi.sharedInstance.verifyPhone(phoneNumber) { result in
            switch result {
            case .success(let responseObject):
                let status = responseObject["status"] as! String
                var isSuccess = false
                if status ==  "success"{
                    if let data = responseObject["data"] as? NSDictionary {
                        if (data["is_blocked"] as? Bool) == false {
                            // let isPhoneExsists = data["is_phone_exists"] as? Bool
                            // if isPhoneExsists ?? false {
                            // self.isPhoneExsists = false
                            // phoneErrorLabel.isHidden = false
                            // phoneErrorLabel.text = NSLocalizedString("registration_account_Phone_exists_error_alert", comment: "")
                            // } else {
                            // self.isPhoneExsists = false
                            // phoneErrorLabel.isHidden = true
                            // }
                            isSuccess = true
                        }
                    }
                }
                completion?(isSuccess, "")
            case .failure(let error):
                
                // self.isPhoneExsists = true
                // self.phoneNumberTextField.layer.borderColor = UIColor.redValidationErrorColor().cgColor
                // self.phoneNumberTextField.layer.borderWidth = 1
                // self.phoneErrorLabel.isHidden = false
                var errorMessage = ""
                if  let errorDict = error.jsonValue,
                    let msgDict = errorDict["messages"] as? NSDictionary ,
                    let errorMsg = msgDict["error_message"] as? String  {
                    errorMessage = errorMsg
                } else {
                    errorMessage = error.localizedMessage
                }
                completion?(false, errorMessage)
            }
        }
    }
    
    static func signin(with phoneNumber: String, otp: String,
                       completion: ((_ isSuccess: Bool, _ errorMsg: String, _ code: Int, _ isNew: Bool?) -> Void)? ) {
        ElGrocerApi.sharedInstance.signinWithOTP(phoneNum: phoneNumber, otp: otp) { result in
            switch result {
            case .success(let responseDict):
                var errorMessage: String = ""
                var isSuccess = false
                var isNewUser = false
                
                if let success = responseDict["status"] as? String {
                    if success == "success" {   //otp verified
                        updateProfileAndData(responseDict)
                        isSuccess = true
                        if let data = responseDict["data"] as? [String: Any], let shopper = data["shopper"] as? [String: Any], let isNew = shopper["is_new"] as? Bool {
                            isNewUser = isNew
                        }
                    } else {                    //otp un verified
                        isSuccess = false
                        SpinnerView.hideSpinnerView()
                        errorMessage = localizedString("error_PinCode", comment: "")
                    }
                }
                completion?(isSuccess, errorMessage, 199, isNewUser)
            case .failure(let error):
                var errorMessage = localizedString("error_PinCode", comment: "")
                var errorCode = 0
                if let errorDict = error.jsonValue, let msgDict = errorDict["messages"] as? NSDictionary {
                    if let errorCod = msgDict["error_code"] as? Int {
                        if let errorMsg = (msgDict["error_message"] as? String) {
                            errorMessage = errorMsg
                        }
                        errorCode = errorCod
                    }
                }
                completion?(false, errorMessage, errorCode, nil)
            }
        }
        
        func updateProfileAndData(_ responseObject:NSDictionary?) {
            let userProfile = UserProfile.createOrUpdateUserProfile(responseObject!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            ElGrocerEventsLogger.sharedInstance.setUserProfile(userProfile)
            UserDefaults.setLogInUserID(userProfile.dbID.stringValue)
            
            FireBaseEventsLogger.setUserID(userProfile.dbID.stringValue)
            
            DatabaseHelper.sharedInstance.saveDatabase()
            UserDefaults.setUserLoggedIn(true)
        }
    }
    
    static func getDeliveryAddresses(completionHandler: ((_ addresses: [DeliveryAddress], _ isSuccess: Bool, _ errorMsg: String )-> Void)? = nil) {
        
        let  locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if (locations.count > 0) {
            ElGrocerUtility.sharedInstance.addDeliveryToServerWithBlock(locations) { (isSuccess, errorMessage) in
                if isSuccess {
                    UserDefaults.setDidUserSetAddress(true)
                    completionHandler?([], true, errorMessage)
                } else {
                    UserDefaults.setDidUserSetAddress(false)
                    completionHandler?(locations, false, errorMessage)
                }
            }
        } else {
            getUserDeliveryAddresses(completionHandler: completionHandler)
        }
        
        func getUserDeliveryAddresses(completionHandler: ((_ addresses: [DeliveryAddress], _ isSuccess: Bool, _ errorMsg: String ) -> Void)?){
            
            // Set the user profile
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)!
            ElGrocerEventsLogger.sharedInstance.setUserProfile(userProfile)
            UserDefaults.setLogInUserID(userProfile.dbID.stringValue)
            FireBaseEventsLogger.setUserID(userProfile.dbID.stringValue)
            ElGrocerApi.sharedInstance.getDeliveryAddresses({ (result, responseObject) -> Void in
                if result {
                    let address = DeliveryAddress.insertOrUpdateDeliveryAddressesForUser(userProfile, fromDictionary: responseObject!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    if address.count != 0 {
                        UserDefaults.setDidUserSetAddress(true)
                    }else {
                        UserDefaults.setDidUserSetAddress(false)
                    }
    
                    completionHandler?(address, true , "")
                } else {
                    UserDefaults.setDidUserSetAddress(false)
                    DatabaseHelper.sharedInstance.mainManagedObjectContext.rollback()
                    completionHandler?([],false, "")
                }
            })
        }
    }
    
    static func goToBasketView(from contextView: UIViewController) -> Void {
        let myBasketViewController = ElGrocerViewControllers.myBasketViewController()
         myBasketViewController.isComingFromLocation = true
        contextView.navigationController?.pushViewController(myBasketViewController, animated: true)
    }
    
    static func setHomeViewWithUserDidSetAddress(from contextView: UIViewController) -> Void {
        
        ElGrocerUtility.sharedInstance.setDefaultGroceryAgain()
        sdkManager.showAppWithMenu()
    }
    
    
    static func setHomeView(from contextView: UIViewController) -> Void {
        
        guard !SDKManager.shared.isSmileSDK else {
            contextView.navigationController?.popViewController(animated: true)
            return
        }
        ElGrocerUtility.sharedInstance.setDefaultGroceryAgain()
        sdkManager.showAppWithMenu(false)
    }
    
    static func goToDashBoard(from contextView: UIViewController) -> Void {
        
        guard !SDKManager.shared.isSmileSDK else {
            contextView.navigationController?.popViewController(animated: true)
            return
        }
        ElGrocerUtility.sharedInstance.setDefaultGroceryAgain()
        contextView.navigationController?.popToRootViewController(animated: true)
    }
    
    
    static func setAddLocationView(from contextView: UIViewController) -> Void {
      
        let viewController = ElGrocerViewControllers.addLocationViewController()
        let navigationController:ElGrocerNavigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [viewController]
        navigationController.setLogoHidden(true)
        navigationController.modalPresentationStyle = .fullScreen
        contextView.present(navigationController, animated: true) { }
    }
    
    static func addDeliveryAddress(_ deliveryAddress: DeliveryAddress, completionHandler: ((_ code: Int)->Void)? ) {
        
        UserDefaults.setDidUserSetAddress(true)
        
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if userProfile != nil {
            deliveryAddress.userProfile = userProfile!
        }
        
        
        
        let email: String = userProfile?.email ?? ""
       
        ElGrocerApi.sharedInstance.addOrUpdateDeliveryAddress(withEmail: email, and: deliveryAddress) { result, responseObject in
            
            GoogleAnalyticsHelper.trackDeliveryLocationAction(DeliveryLocationActionType.Add)
            
            if result {
                
                let addressDict = (responseObject!["data"] as! NSDictionary)["shopper_address"] as! NSDictionary
                
                let dbID = addressDict["id"] as! NSNumber
                let dbIDString = "\(dbID)"
                deliveryAddress.dbID = dbIDString
                DatabaseHelper.sharedInstance.saveDatabase()
                
                if userProfile != nil {
                    let newAddress = DeliveryAddress.insertOrUpdateDeliveryAddressForUser(userProfile!, fromDictionary: addressDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    
                    DatabaseHelper.sharedInstance.saveDatabase()
                    // We need to set the new address as the active address
                    ElGrocerApi.sharedInstance.setDefaultDeliveryAddress(newAddress, completionHandler: { (result) in
                        UserDefaults.setDidUserSetAddress(true)
                    })
                }
                completionHandler?(200)
                
            } else {
                if let code = (responseObject?["messages"] as? [String: Any])?["error_code"] as? NSNumber {
                    if code == 4200 {
                        completionHandler?(code.intValue)
                        return
                    }
                    
                    completionHandler?(code.intValue)
                } else {
                    completionHandler?(0)
                }
                DatabaseHelper.sharedInstance.mainManagedObjectContext.delete(deliveryAddress)
                DatabaseHelper.sharedInstance.saveDatabase()
                
                var errorMsg = localizedString("my_account_saving_error", comment: "")
                if let errorStr = (responseObject?["messages"] as? NSDictionary)?["error_message"] as? String {
                    errorMsg =  errorStr
                }
                ElGrocerAlertView.createAlert(errorMsg,
                                              description: nil,
                                              positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                              negativeButton: nil, buttonClickCallback: nil).show()
            }
        }
    }
    
    static func updateDeliveryAddress(_ deliveryAddress: DeliveryAddress, userProfile : UserProfile , completionHandler: ((_ code: Int)->Void)? ) {
        
        UserDefaults.setDidUserSetAddress(true)
        
        let email: String = userProfile.email
        
        ElGrocerApi.sharedInstance.addOrUpdateDeliveryAddress(withEmail: email, and: deliveryAddress) { result, responseObject in
            
            GoogleAnalyticsHelper.trackDeliveryLocationAction(DeliveryLocationActionType.Add)
            
            if result {
                
                let addressDict = (responseObject!["data"] as! NSDictionary)["shopper_address"] as! NSDictionary
                let dbID = addressDict["id"] as! NSNumber
                let dbIDString = "\(dbID)"
                deliveryAddress.dbID = dbIDString
                let newAddress = DeliveryAddress.insertOrUpdateDeliveryAddressForUser(userProfile, fromDictionary: addressDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                DatabaseHelper.sharedInstance.saveDatabase()
                
                    // We need to set the new address as the active address
                ElGrocerApi.sharedInstance.setDefaultDeliveryAddress(newAddress, completionHandler: { (result) in
                    UserDefaults.setDidUserSetAddress(true)
                        // self.refreshData()
                        // self.presentContactInfoViewController(newAddress)
                })
                completionHandler?(200)
                
            } else {
                
                if let code = (responseObject?["messages"] as? [String: Any])?["error_code"] as? NSNumber {
                    if code == 4200 {
                        completionHandler?(code.intValue)
                        return
                    }
                    
                    completionHandler?(code.intValue)
                } else {
                    completionHandler?(0)
                }
                
                DatabaseHelper.sharedInstance.mainManagedObjectContext.delete(deliveryAddress)
                DatabaseHelper.sharedInstance.saveDatabase()
                
                var errorMsg = localizedString("my_account_saving_error", comment: "")
                if let errorStr = (responseObject?["messages"] as? NSDictionary)?["error_message"] as? String {
                    errorMsg =  errorStr
                }
                ElGrocerAlertView.createAlert(errorMsg,
                                              description: nil,
                                              positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
                                              negativeButton: nil, buttonClickCallback: nil).show()
            }
        }
    }
}

