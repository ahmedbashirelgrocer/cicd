//
//  Picker.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 30/06/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import CoreData

class Picker: NSManagedObject, DBEntity {
    @NSManaged var dbID: NSNumber
    @NSManaged var name: String?
    @NSManaged var registrationID: String?
    
    
}
