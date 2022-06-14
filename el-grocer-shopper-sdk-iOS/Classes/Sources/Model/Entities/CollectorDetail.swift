//
//  CollectorDetail.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import CoreData



class CollectorDetail: NSManagedObject, DBEntity {

    @NSManaged var dbID: NSNumber
    @NSManaged var name: String?
    @NSManaged var phone_number: String?
 
}


