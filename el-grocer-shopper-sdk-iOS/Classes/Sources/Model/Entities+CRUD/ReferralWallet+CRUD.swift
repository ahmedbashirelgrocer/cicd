//
//  ReferralWallet+CRUD.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 01/03/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import Foundation
import CoreData

let ReferralWalletEntity = "ReferralWallet"

extension ReferralWallet {
    
    // MARK: DBEntity
    @nonobjc static let entityName = ReferralWalletEntity
    
    // MARK: Insert
    class func insertOrUpdateWalletHistoryForReferral(_ referral:Referral,walletHistory:[NSDictionary], context:NSManagedObjectContext) {
        
        //Here wea are deleting the previous wallet history data
        referral.clearWalletHistory()
        
        //insert wallet data
        for walletDict in walletHistory {
            
            let wallet = insertOrUpdateWalletHistoryFromDictionary(walletDict, context: context)
            referral.addWallet(wallet)
        }
        do {
            try context.save()
        } catch (let _) {
            // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
    }
    
    
    fileprivate class func insertOrUpdateWalletHistoryFromDictionary(_ walletDict:NSDictionary!, context:NSManagedObjectContext) -> ReferralWallet {
        
        let dbID = walletDict["id"] as! NSNumber
        
        let referralWallet = DatabaseHelper.sharedInstance.insertNewObjectForEntityForName(ReferralWalletEntity, entityDbId: dbID, keyId: "dbID", context: context) as? ReferralWallet
        
        referralWallet?.walletAmount = (walletDict["amount"] as? NSNumber)?.stringValue
        referralWallet?.walletInfo = walletDict["info"] as? String
        
        let date = (walletDict["expire_date"] as! String).convertStringToCurrentTimeZoneDate()
        referralWallet?.walletExpireDate = date != nil ? date! : Date()
        
        referralWallet?.referralRuleId = (walletDict["referral_rule_id"] as? NSNumber)?.stringValue
        
        return referralWallet!
    }
}
