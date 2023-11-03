//
//  Referral+CRUD.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 01/03/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import Foundation
import CoreData

let ReferralEntity = "Referral"

extension Referral {
    
    // MARK: DBEntity
    @nonobjc static let entityName = ReferralEntity
    
    // MARK: Get
    
    class func getReferralObject(_ context:NSManagedObjectContext) -> Referral! {
        
        return DatabaseHelper.sharedInstance.getEntitiesWithName(entityName, sortKey: nil, predicate: nil, ascending: false, context: context).first as? Referral
    }
    
    // MARK: Insert
    
    class func insertOrReplaceReferral(_ dictionary:NSDictionary, context:NSManagedObjectContext){
        
        let responseDict = (dictionary["data"] as! NSDictionary)
        
        let referral = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(entityName, entityDbId: 1 as AnyObject, keyId: "dbID", context: context) as! Referral
        
        referral.referralCode = responseDict["referral_code"] as? String
        referral.referralMessage = responseDict["invite_message"] as? String
        referral.referralUrl = responseDict["referral_url"] as? String
        referral.walletTotal = (responseDict["wallet_total"] as? NSNumber)?.stringValue
        referral.referrerAmount = (responseDict["referrer_amount"] as? NSNumber)?.stringValue
        
        ElGrocerUtility.sharedInstance.walletTotal = String(format: "%0.2f %@",Double(referral.walletTotal!)!,CurrencyManager.getCurrentCurrency())
        
        ElGrocerUtility.sharedInstance.referrerAmount = String(format: "%@ %@",CurrencyManager.getCurrentCurrency(),referral.referrerAmount!)
        
        //save Wallet History of User ---
        if let referralWalletArray = responseDict["referral_wallets"] as? [NSDictionary] {
            
             let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
             context.perform({ () -> Void in
               ReferralWallet.insertOrUpdateWalletHistoryForReferral(referral, walletHistory: referralWalletArray, context: context)
             DatabaseHelper.sharedInstance.saveDatabase()
           })
        }
        
        do {
            try context.save()
        } catch (let _) {
            // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
    }
    
    // MARK: Referral helper methods
    
    func addWallet(_ value: ReferralWallet) {
        
        let items = self.mutableSetValue(forKey: "referralWallet")
        items.add(value)
    }
    
    func removeWallet(_ value: ReferralWallet) {
        
        let items = self.mutableSetValue(forKey: "referralWallet")
        items.remove(value)
    }
    
    func clearWalletHistory() {
        
        let items = self.mutableSetValue(forKey: "referralWallet")
        items.removeAllObjects()
    }
    
}
