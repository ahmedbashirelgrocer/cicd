//
//  DeliverySlots.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 07/08/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//


import Foundation
import CoreData

let DeliverySlotsEntity = "DeliverySlot"

class DeliverySlot: NSManagedObject, DBEntity {
    
    @NSManaged var groceryID: String?
    @NSManaged var dbID: NSNumber
    @NSManaged var usid: NSNumber
    @NSManaged var start_time: Date?
    @NSManaged var end_time: Date?
    @NSManaged var estimated_delivery_at: Date
    @NSManaged var time_milli: NSNumber
    @NSManaged var isInstant:NSNumber
    @NSManaged var backendDbId: NSNumber
    

}
