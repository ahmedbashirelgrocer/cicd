//
//  Brand.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 14.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData

class Brand: NSManagedObject, DBEntity {

    @NSManaged var dbID: NSNumber
    @NSManaged var imageUrl: String?
    @NSManaged var name: String?
    @NSManaged var nameEn: String?


}
