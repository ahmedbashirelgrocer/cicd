//
//  PickupLocation.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import CoreData

class PickupLocation: NSManagedObject, DBEntity {
    
    @NSManaged var dbID: NSNumber
    @NSManaged var retailer_id: NSNumber?
    @NSManaged var details: String?
    @NSManaged var photo_url: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    
}


