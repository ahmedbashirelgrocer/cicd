//
//  VehicleDetail.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import CoreData



class VehicleDetail: NSManagedObject, DBEntity {
    
    @NSManaged var dbID: NSNumber?
    @NSManaged var plate_number: String?
    @NSManaged var company: String?
    
    @NSManaged var color_dbID: NSNumber?
    @NSManaged var color_code: String?
    @NSManaged var color_name: String?
        
    @NSManaged var vehicleModel_name: String?
    @NSManaged var vehicleModel_dbID: NSNumber?
    @NSManaged var vehicleModel_color: String?

}
