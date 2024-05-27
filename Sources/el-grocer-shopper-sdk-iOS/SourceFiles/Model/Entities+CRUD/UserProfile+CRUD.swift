//
//  UserProfile+CRUD.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 06.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData

let UserProfileEntity = "UserProfile"

extension UserProfile {
    
    // MARK: DBEntity
    
    @nonobjc static let entityName = UserProfileEntity
    
    // MARK: Get
    
    class func getOptionalUserProfile(_ context:NSManagedObjectContext) -> UserProfile? {
        
        return DatabaseHelper.sharedInstance.getEntitiesWithName(UserProfileEntity, sortKey: nil, predicate: nil, ascending: false, context: context).first as? UserProfile
    }
    
    class func getUserProfile(_ context:NSManagedObjectContext) -> UserProfile! {
        
        return DatabaseHelper.sharedInstance.getEntitiesWithName(UserProfileEntity, sortKey: nil, predicate: nil, ascending: false, context: context).first as? UserProfile
    }
    
   
    
    // MARK: Create
    
    /** Creates a user profile from login response */
    class func createOrUpdateUserProfile(_ dictionary:NSDictionary, context:NSManagedObjectContext) -> UserProfile {
        
        let userDictionary = (dictionary["data"] as! NSDictionary)["shopper"] as! NSDictionary
        
        let userId = userDictionary["id"] as! Int
        
        let userProfile = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(UserProfileEntity, entityDbId: userId as AnyObject, keyId: "dbID", context: context) as! UserProfile
        userProfile.email = userDictionary["email"] as! String
        userProfile.name = userDictionary["name"] as? String
        userProfile.phone = userDictionary["phone_number"] as? String
        userProfile.language = userDictionary["language"] as? String
        
//        if let referral_code = userDictionary["referral_code"] as? String {
//             userProfile.referralCode = referral_code
//        }
        
        //create invoice address
//        let invoiceAddress = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(DeliveryAddressEntity, entityDbId: "0" as AnyObject, keyId: "dbID", context: context) as! DeliveryAddress
//        invoiceAddress.isInvoiceAddress = NSNumber(value: true as Bool)
//        invoiceAddress.street = userDictionary["invoice_street"] as? String
//        invoiceAddress.building = userDictionary["invoice_building_name"] as? String
//        invoiceAddress.apartment = userDictionary["invoice_apartment_number"] as? String
        
        return userProfile
    }
    
    // MARK: Delivery addresses helper methods
    
    func addDeliveryAddress(_ value: DeliveryAddress) {
        
        let items = self.mutableSetValue(forKey: "deliveryAddresses")
        items.add(value)
    }
    
    func removeDeliveryAddress(_ value: DeliveryAddress) {
        
        let items = self.mutableSetValue(forKey: "deliveryAddresses")
        items.remove(value)
    }
    
    func clearDeliveryAddresses() {
        
        let items = self.mutableSetValue(forKey: "deliveryAddresses")
        items.removeAllObjects()
    }

}
