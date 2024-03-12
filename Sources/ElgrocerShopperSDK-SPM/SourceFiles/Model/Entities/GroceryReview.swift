//
//  GroceryReview.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 21.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData

class GroceryReview: NSManagedObject, DBEntity {

    @NSManaged var dbID: NSNumber
    @NSManaged var score: NSNumber
    @NSManaged var reviewer: String
    @NSManaged var reviewText: String
    @NSManaged var grocery: Grocery

}
