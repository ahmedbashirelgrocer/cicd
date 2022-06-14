//
//  VehicleDetail+CRUD.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import CoreData


let VehicleDetailEntity = "VehicleDetail"

extension VehicleDetail {
    
    
    class func insertOrReplaceOrderFromDictionary(_ vehicleDict:NSDictionary, context:NSManagedObjectContext) -> VehicleDetail? {
        
        
        
        if let pickUpDetailID = vehicleDict["id"] as? NSNumber {
            
            let vehicle = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(VehicleDetailEntity, entityDbId: pickUpDetailID, keyId: "dbID", context: context) as! VehicleDetail
            vehicle.company = vehicleDict["company"] as? String
            vehicle.plate_number = vehicleDict["plate_number"] as? String
            if let colorDict = vehicleDict["vehicle_color"] as? NSDictionary {
                vehicle.color_code = colorDict["color_code"] as? String
                vehicle.color_dbID = colorDict["id"] as? NSNumber
                vehicle.color_name = colorDict["name"] as? String
            }
            
            if let model = vehicleDict["vehicle_model"] as? NSDictionary {
                vehicle.vehicleModel_name = model["name"] as? String
                vehicle.vehicleModel_dbID = model["id"] as? NSNumber
            }
           
            return vehicle
            
        }
        
        return nil
    }
    
}
/*
 "vehicle_detail" =             {
 company = sdfsfdsfds;
 id = 19;
 "plate_number" = sdfsdfds;
 "vehicle_color" =                 {
 "color_code" = ffffff;
 id = 1;
 name = White;
 };
 "vehicle_model" =                 {
 id = 1;
 name = Sedan;
 };
 };
 
 **/
