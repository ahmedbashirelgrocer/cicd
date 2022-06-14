//
//  Grocery.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 15.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//  Updated with elgrocer_5

import Foundation
import CoreData

class Grocery: NSManagedObject, DBEntity  {
    
    @NSManaged var retailerGroupName: String?
    @NSManaged var genericSlot: String?
    @NSManaged var address: String?
    @NSManaged var dbID: String
    @NSManaged var imageUrl: String?
    @NSManaged var smallImageUrl: String?
    @NSManaged var name: String?
    @NSManaged var categories: NSSet
    @NSManaged var subcategories: NSSet
    @NSManaged var brands: NSSet
    @NSManaged var deliverySlots: NSSet
    @NSManaged var isFavourite: NSNumber
    @NSManaged var reviewScore: NSNumber
    @NSManaged var reviews: NSSet
    @NSManaged var isArchive: NSNumber
    @NSManaged var availablePayments: NSNumber
    @NSManaged var minBasketValue: Double
    @NSManaged var deliveryFee: Double
    @NSManaged var riderFee: Double
    @NSManaged var serviceFee: Double
    @NSManaged var isOpen: NSNumber
    @NSManaged var isSchedule: NSNumber
    @NSManaged var isInRange: NSNumber
    @NSManaged var openingTime: String?
    @NSManaged var deliveryType: String?
    @NSManaged var deliveryTypeId: String?
    @NSManaged var deliveryZoneId: String?
    @NSManaged var vat: NSNumber
    @NSManaged var topSearch: [String]
    @NSManaged var isShowRecipe: NSNumber
    @NSManaged var addDay: NSNumber
    @NSManaged var paymentAvailableID: [NSNumber]
    @NSManaged var retailerType: NSNumber  /* retailer_type:  supermarket: 0, hypermarket: 1, speciality: 2 */
    @NSManaged var parentID: NSNumber
    @NSManaged var groupId: NSNumber
    @NSManaged var storeType: [NSNumber]
    @NSManaged var distance: NSNumber
    @NSManaged var ranking: NSNumber
    @NSManaged var isDelivery : NSNumber
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    
    @NSManaged var featured : NSNumber?
    @NSManaged var inventoryControlled : NSNumber?
    
    
    @NSManaged var featureImageUrl : String?
    @NSManaged var initialDeliverySlotData : String?
    
    @NSManaged var smileSupport: NSNumber?
   
}
