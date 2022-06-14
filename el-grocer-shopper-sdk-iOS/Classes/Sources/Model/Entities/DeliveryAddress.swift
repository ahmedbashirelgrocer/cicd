//
//  DeliveryAddress.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 13.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData

class DeliveryAddress: NSManagedObject, DBEntity {

    @NSManaged var dbID: String
    @NSManaged var locationName: String
    @NSManaged var isActive: NSNumber
    @NSManaged var isArchive: NSNumber
    @NSManaged var isInvoiceAddress: NSNumber

    @NSManaged var apartment: String?
    @NSManaged var building: String?
    @NSManaged var street: String?
    @NSManaged var floor: String?
    @NSManaged var houseNumber: String?
    @NSManaged var additionalDirection: String?
    @NSManaged var address: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var isCovered: Bool
    @NSManaged var addressType: String
    @NSManaged var userProfile: UserProfile
    
    @NSManaged var phoneNumber: String?
    @NSManaged var shopperName: String?
    @NSManaged var addressTagId: String?
    @NSManaged var city: String?
    
    
    
    
 
}

