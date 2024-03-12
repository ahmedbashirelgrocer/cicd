//
//  Picker+CRUD.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 30/06/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation

import Foundation
import CoreData


let PickerEntityName = "Picker"

extension Picker {
    class func insertOrReplaceOrderFromDictionary(_ pickerDict:NSDictionary, context:NSManagedObjectContext) -> Picker? {
        if let pickUpDetailID = pickerDict["id"] as? NSNumber {
            let pickUpDetail = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(PickerEntityName, entityDbId: pickUpDetailID as AnyObject , keyId: "dbID", context: context) as! Picker
            pickUpDetail.name = pickerDict["name"] as? String ?? ""
            pickUpDetail.registrationID = pickerDict["registration_id"] as? String ?? ""
            return pickUpDetail
        }
        return nil
    }
}
