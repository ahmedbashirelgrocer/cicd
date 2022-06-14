//
//  SignInViewModel.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 01/02/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
//import Intercom

enum SignInState {
    
    /** Initial state of the model */
    case initial
    
    /** The user clicked the login button */
    case login
    
    /** Login ended with an error */
    case loginError(errorMessage: String)
    
    /** Login ended with a sucess */
    case loginSuccess
    
}

class SignInViewModel {
    
    // MARK: Properties
    
    let state = Variable<SignInState>(.initial)
    
    let username = Variable<String>("")
    let password = Variable<String>("")
    
    let usernameValid = Variable<Bool>(false)
    let passwordValid = Variable<Bool>(false)
    let formValid = Variable<Bool>(false)
    
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: Initializer
    
    init() {
        
        username.asObservable()
        .map { (username) -> Bool in
            return username != ""
            }.bind(to: usernameValid).disposed(by: disposeBag)
        
        password.asObservable()
        .map { (password) -> Bool in
            return password != ""
            }.bind(to: passwordValid).disposed(by: disposeBag)
        
        Observable.combineLatest(usernameValid.asObservable(), passwordValid.asObservable()) { (usernameValid, passwordValid) -> Bool in
            return usernameValid && passwordValid
            }.bind(to: formValid).disposed(by: disposeBag)
        
        // Save database changes and login user on success
        state.asObservable().bind { (loginState) -> Void in
            
            switch loginState {
            case .loginSuccess:
                DatabaseHelper.sharedInstance.saveDatabase()
                UserDefaults.setUserLoggedIn(true)
                UserDefaults.setDidUserSetAddress(true)
                AlgoliaApi.sharedInstance.reStartInsights()
                
                // Intercom.registerUser(withEmail: self.username.value)
                // IntercomeHelper.updateUserProfileInfoToIntercom()
                // IntercomeHelper.updateIntercomWithUserCurrentLanguage()
                // PushWooshTracking.updateUserProfileInfo()
                // PushWooshTracking.updateUserCurrentLanguage()
                //ZohoChat.custimzedZohoView()
                
                
            case .loginError(errorMessage: _):
                DatabaseHelper.sharedInstance.mainManagedObjectContext.rollback()
                UserDefaults.setUserLoggedIn(false)
                UserDefaults.setLogInUserID("0")
            default:
                break
            }
            
            }.disposed(by: disposeBag)
        
    }
    
    // MARK: Methods
    
    func signIn(_ completionHandler: @escaping () -> Void) {
        
        guard formValid.value else {return}
        
        self.state.value = .login
        ElGrocerApi.sharedInstance.loginUser(self.username.value, password: self.password.value) { (result, responseObject) -> Void in
    
            if result {
               let  locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                if (locations.count > 0) {
                    self.updateProfileAndData(responseObject!, completionHandler: {
                        ElGrocerUtility.sharedInstance.addDeliveryToServerWithBlock(locations) { (isResult) in
                            completionHandler()
                        }
                    })
                }else{
                    self.getUserDeliveryAddresses(responseObject!, completionHandler: {
                        completionHandler()
                    })
                  }
                
            } else {
                
                self.state.value = .loginError(errorMessage: NSLocalizedString("login_error_alert", comment: ""))
                
            }
            
        }
    }
    
    fileprivate func loadGroceryiesAgain() {
        
        ElGrocerUtility.sharedInstance.delay(1) {
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: KReloadProfileGenericView), object: nil)
        }
    
    }
    

    func getUserDeliveryAddresses(_ responseObject:NSDictionary?,completionHandler:@escaping () -> Void){
        
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
              _ = DeliveryAddress.insertOrUpdateDeliveryAddressesForUser(userProfile, fromDictionary: responseObject!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                self.state.value = .loginSuccess
                completionHandler()
                
            } else {
                completionHandler()
                self.state.value = .loginError(errorMessage: NSLocalizedString("registration_error_alert", comment: ""))
            }
        })
    }
    
    
    func updateProfileAndData(_ responseObject:NSDictionary?,completionHandler:@escaping () -> Void){
        
        // Set the user profile
        let userProfile = UserProfile.createOrUpdateUserProfile(responseObject!, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        ElGrocerEventsLogger.sharedInstance.setUserProfile(userProfile)
        UserDefaults.setLogInUserID(userProfile.dbID.stringValue)
        //ZohoChat.loginZohoWith(userProfile.dbID.stringValue)
        // PushWooshTracking.setUserID(userID: userProfile.dbID.stringValue)
        FireBaseEventsLogger.setUserID(userProfile.dbID.stringValue)
        self.state.value = .loginSuccess
        completionHandler()

    }
    
    
}
