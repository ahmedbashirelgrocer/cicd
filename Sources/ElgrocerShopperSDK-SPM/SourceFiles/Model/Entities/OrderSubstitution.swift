//
//  OrderSubstitution.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 19/09/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import Foundation
import CoreData

class OrderSubstitution: NSManagedObject, DBEntity {
    
    @NSManaged var orderId: NSNumber
    @NSManaged var groceryId: String
    @NSManaged var productId: String
    @NSManaged var subtitutingProductId: String
}

