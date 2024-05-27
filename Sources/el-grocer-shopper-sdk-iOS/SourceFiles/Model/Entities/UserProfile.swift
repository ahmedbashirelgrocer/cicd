//
//  UserProfile.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 06.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData

class UserProfile: NSManagedObject, DBEntity {

    @NSManaged var dbID: NSNumber
    @NSManaged var email: String
    @NSManaged var name: String?
    @NSManaged var phone: String?
    @NSManaged var language: String?
    @NSManaged var referralCode: String? // going to save loyaltyID in it for future use. 
    @NSManaged var deliveryAddresses: NSSet
}



