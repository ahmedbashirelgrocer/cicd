//
//  CollectorDetail+CRUD.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import CoreData


let CollectorDetailEntityName = "CollectorDetail"

extension CollectorDetail {
    
    
    class func insertOrReplaceOrderFromDictionary(_ collectorDict:NSDictionary, context:NSManagedObjectContext) -> CollectorDetail? {
        
        if let collectorId = collectorDict["id"] as? NSNumber {
        let collectorDetail = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(CollectorDetailEntityName, entityDbId: collectorId, keyId: "dbID", context: context) as! CollectorDetail
        collectorDetail.name = collectorDict["name"] as? String
        collectorDetail.phone_number = collectorDict["phone_number"] as? String
        
            return collectorDetail
            
        }
        return nil
        
        
    }
    
}
