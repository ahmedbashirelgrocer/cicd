//
//  Referral.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 01/03/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import Foundation
import CoreData

class Referral: NSManagedObject, DBEntity {
    
    @NSManaged var dbID: NSNumber
    @NSManaged var referralMessage: String?
    @NSManaged var referralCode: String?
    @NSManaged var referralUrl: String?
    @NSManaged var referrerAmount: String?
    @NSManaged var walletTotal: String?
    @NSManaged var referralWallet: NSSet
}
