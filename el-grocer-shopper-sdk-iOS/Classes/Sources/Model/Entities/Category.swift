//
//  Category.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 14.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData

class Category: NSManagedObject, DBEntity {
    
    @NSManaged var sortID: NSNumber
    @NSManaged var dbID: NSNumber
    @NSManaged var imageUrl: String?
    @NSManaged var isSubcategory: NSNumber
    @NSManaged var name: String?
    @NSManaged var nameEn: String?
    @NSManaged var desc: String?
    @NSManaged var parentCategoryId: NSNumber?
    @NSManaged var brands: NSSet
    @NSManaged var isPg18: NSNumber
    ///for color images in categories darkStore new UI-2.0
    @NSManaged var coloredImageUrl: String?

}
