//
//  GroceryCategoryBrands.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 09.09.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData

class GroceryCategoryBrands: NSManagedObject, DBEntity {

    @NSManaged var groceryId: String
    @NSManaged var categoryId: NSNumber
    @NSManaged var brandId: NSNumber

}
