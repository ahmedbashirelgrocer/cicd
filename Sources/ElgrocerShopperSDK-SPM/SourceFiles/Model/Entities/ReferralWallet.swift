//
//  ReferralWallet.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 01/03/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import Foundation
import CoreData

class ReferralWallet: NSManagedObject, DBEntity {
    
    @NSManaged var dbID: NSNumber
    @NSManaged var walletInfo: String?
    @NSManaged var walletAmount: String?
    @NSManaged var referralRuleId: String?
    @NSManaged var walletExpireDate: Date?
}
