//
//  PickupLocation+CRUD.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import CoreData


let PickupLocationEntityName = "PickupLocation"

extension PickupLocation {
    
    
    class func insertOrReplaceOrderFromDictionary(_ locationDict:NSDictionary, context:NSManagedObjectContext) -> PickupLocation? {
        
        
        
        if let pickUpDetailID = locationDict["id"] as? NSNumber {
            
            let pickUpDetail = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(PickupLocationEntityName, entityDbId: pickUpDetailID, keyId: "dbID", context: context) as! PickupLocation
            pickUpDetail.details = locationDict["details"] as? String
            pickUpDetail.photo_url = locationDict["photo_url"] as? String
            pickUpDetail.retailer_id = locationDict["retailer_id"] as? NSNumber
            pickUpDetail.latitude = locationDict["latitude"] as? NSNumber
            pickUpDetail.longitude = locationDict["longitude"] as? NSNumber
            
            
            return pickUpDetail
            
        }
    
        return nil
    }
    
}
