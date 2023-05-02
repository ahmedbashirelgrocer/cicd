//
//  ElGrocerAppState.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 15/07/2022.
//

import Foundation


class ElGrocerAppState {
    
    /**This will check is sdk alreeady loadeed with valid data**/
    class func isSDKLoadedAndDataAvailable(_ launchOptions: LaunchOptions?) -> Bool {
        
        guard let launchOptions = launchOptions else {
            return false
        }
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let  locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        guard (userProfile == nil || userProfile?.phone?.count == 0) || launchOptions.accountNumber != userProfile?.phone || locations.count == 0  else {
            return true
        }
        return false
    }
    
    
    class func checkDBCanBeLoaded() -> Bool {
       // let _ = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let _ = DatabaseHelper.sharedInstance.persistentStoreCoordinator
        return DatabaseHelper.sharedInstance.ispersistentStoreCoordinatorAvailable
    }
    
    
}
