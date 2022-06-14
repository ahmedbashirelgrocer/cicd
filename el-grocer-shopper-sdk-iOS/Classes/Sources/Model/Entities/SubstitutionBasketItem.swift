//
//  SubstitutionBasketItem.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 21/09/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import Foundation
import CoreData

class SubstitutionBasketItem: NSManagedObject, DBEntity {
    
    @NSManaged var count: NSNumber
    @NSManaged var groceryId: String
    
    @NSManaged var orderId: NSNumber
    
    @NSManaged var productId: String
    @NSManaged var subtituteProductId: String
}
