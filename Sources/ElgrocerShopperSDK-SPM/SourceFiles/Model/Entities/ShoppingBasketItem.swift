//
//  ShoppingBasketItem.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 10.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData

class ShoppingBasketItem: NSManagedObject, DBEntity {

    @NSManaged var orderId: NSNumber
    @NSManaged var groceryId: String
    
    @NSManaged var productId: String
    @NSManaged var count: NSNumber
    @NSManaged var brandName: String?
    
    @NSManaged var subStituteItemID: String?
    
    //flag used to mark products in order details as available/not available
    @NSManaged var wasInShop: NSNumber
    
    //flag used to mark product in order if they have any subtitution
    @NSManaged var hasSubtitution: NSNumber
    
    //flag used to mark product isSubtituted, 0 = not substitued, 1 = substituted, 2 = Don't substitute
    @NSManaged var isSubtituted: NSNumber
    
    @NSManaged var updatedAt : Date?
}
