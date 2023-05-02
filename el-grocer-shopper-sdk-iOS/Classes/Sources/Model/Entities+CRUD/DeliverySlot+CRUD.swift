//
//  DeliverySlots+CRUD.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 07/08/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import Foundation
import CoreData
import SwiftDate
let DeliverySlotEntity = "DeliverySlot"
let asapDbId = 0

extension DeliverySlot {
    
    // MARK: DBEntity
    @nonobjc static let entityName = DeliverySlotEntity
    // MARK: Insert
    class func insertOrReplaceDeliverySlotsFromDictionary(_ dictionary:NSDictionary,  groceryObj : Grocery? = nil, context:NSManagedObjectContext ) -> [DeliverySlot]{
        var deliverySlots = [DeliverySlot]()
        if  let response = dictionary["data"] as? NSDictionary {
            var grocery : Grocery? = groceryObj
            if let groceryDict = response["retailer"] as? NSDictionary{
                if let grocer = Grocery.updateGroceryOpeningStatus(groceryDict, context: context) {
                    grocery = grocer
                }
            }
            if let  responseObjects = response["delivery_slots"] as? [NSDictionary] {
                var jsonSlotIds = [Int]()
                for responseDict in responseObjects {
                    let deliverySlot = createDeliverySlotsFromDictionary(responseDict, groceryID: grocery?.dbID ?? "-1", context: context)
                    deliverySlots.append(deliverySlot)
                    jsonSlotIds.append(deliverySlot.dbID.intValue)
                }
                    do {
                        self.deleteSlotsNotInJSON(jsonSlotIds, groceryID:  grocery?.dbID ?? "-1" , context: context)
                        try context.save()
                    } catch (let error) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                        elDebugPrint("self.deleteSlotsNotInJSON(jsonSlotIds, context: context)")
                    }
            }

        } else if let  responseObjects = dictionary["delivery_slots"] as? [NSDictionary] {
            
            var grocery : Grocery? = groceryObj
            if let groceryDict = dictionary["retailer"] as? NSDictionary {
                if let grocer = Grocery.updateGroceryOpeningStatus(groceryDict, context: context) {
                    grocery = grocer
                }
            }
            
            var jsonSlotIds = [Int]()
            for responseDict in responseObjects {
                let deliverySlot = createDeliverySlotsFromDictionary(responseDict, groceryID: grocery?.dbID ?? "-1", context: context)
                deliverySlots.append(deliverySlot)
                jsonSlotIds.append(deliverySlot.dbID.intValue)
            }
                do {
                    self.deleteSlotsNotInJSON(jsonSlotIds, groceryID:  grocery?.dbID ?? "-1" , context: context)
                    try context.save()
                } catch (let error) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                    elDebugPrint("self.deleteSlotsNotInJSON(jsonSlotIds, context: context)")
                }
        }
        return deliverySlots
    }
    
    class func createDeliverySlotsFromDictionary(_ responseDict:NSDictionary, orderId: NSNumber? = nil , groceryID : String, context:NSManagedObjectContext) -> DeliverySlot {
        let emptySlot = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(DeliverySlotEntity, entityDbId: 0 as AnyObject , keyId: "dbID", context: context) as! DeliverySlot
        if let dbID = responseDict["usid"] as? NSNumber {
             let deliverySlot = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(DeliverySlotEntity, entityDbId: dbID , keyId: "dbID", context: context) as! DeliverySlot
            if let idIs = responseDict["id"] as? NSNumber {
                if idIs == 0 {
                    deliverySlot.isInstant = true
                }else{
                    deliverySlot.isInstant = false
                }
            }
            deliverySlot.usid = dbID
            deliverySlot.backendDbId = responseDict["id"] as? NSNumber ?? 0
            deliverySlot.groceryID = groceryID
            deliverySlot.time_milli = responseDict["time_milli"] as? NSNumber ?? 0
            deliverySlot.start_time = (responseDict["start_time"] as? String)?.convertStringToCurrentTimeZoneDate() ?? Date()
            deliverySlot.end_time = (responseDict["end_time"] as? String)?.convertStringToCurrentTimeZoneDate() ?? Date()
            deliverySlot.estimated_delivery_at = (responseDict["estimated_delivery_at"] as? String)?.convertStringToCurrentTimeZoneDate() ?? Date()
            return deliverySlot
        }
        return emptySlot
    }
    
    
    class func createDeliverySlotFromCustomDictionary(_ responseDict:NSDictionary, orderId: NSNumber? = nil, context:NSManagedObjectContext) -> DeliverySlot {
        let emptySlot = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(DeliverySlotEntity, entityDbId: 0 as AnyObject , keyId: "dbID", context: context) as! DeliverySlot
        if let dbID = responseDict["usid"] as? NSNumber {
            let deliverySlot = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(DeliverySlotEntity, entityDbId: dbID , keyId: "dbID", context: context) as! DeliverySlot
            deliverySlot.start_time = (responseDict["start_time"] as? String)?.convertStringToCurrentTimeZoneDate() ?? Date()
            deliverySlot.end_time = (responseDict["end_time"] as? String)?.convertStringToCurrentTimeZoneDate() ?? Date()
            deliverySlot.time_milli = responseDict["time_milli"] as? NSNumber ?? 0
            deliverySlot.estimated_delivery_at = (responseDict["estimated_delivery_at"] as? String)?.convertStringToCurrentTimeZoneDate() ?? Date()
            if let idIs = responseDict["isInstant"] as? NSNumber {
                if idIs.boolValue {
                    deliverySlot.isInstant = true
                }else{
                    deliverySlot.isInstant = false
                }
            }
            return deliverySlot
        }
        return emptySlot
    }
    
    class func insertOrUpdateDeliverySlotsForGrocery(_ grocery:Grocery, deliverySlotsArray:[NSDictionary], context:NSManagedObjectContext) {
        grocery.clearDeliverySlots(context: context)
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
            elDebugPrint(error.localizedDescription)
        }
        
        for responseDict in deliverySlotsArray {
            let deliverySlot = DeliverySlot.createDeliverySlotsFromDictionary(responseDict, groceryID: grocery.dbID, context: context)
            //   grocery.addDeliverySlot(deliverySlot) // change here
        }
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
            elDebugPrint(error.localizedDescription)
        }
    }

    
    // MARK: Delete
    
    class func deleteSlotsNotInJSON(_ jsonSlotsIds:[Int] , groceryID : String ,context:NSManagedObjectContext) {
        
       
        
        let predicate = NSPredicate(format: "NOT (dbID IN %@) AND groceryID == %@", jsonSlotsIds, groceryID)
    
        let slotsToDelete = DatabaseHelper.sharedInstance.getEntitiesWithName(DeliverySlotEntity, sortKey: nil, predicate: predicate, ascending: false, context: context)
        
        for object in slotsToDelete {
            context.delete(object)
        }
    }

    // MARK: Time Formatting
    
    
    func getSlotFormattedWithNewLineString(_ isNeedToAddToString : Bool = false , isDeliveryMode : Bool ) -> String {
        
        guard let startDate =  self.start_time , let endDate =  self.end_time else { return ""}
        var orderTypeDescription = ( isDeliveryMode ?  startDate.formatDateForDeliveryHAFormateString() : startDate.formatDateForCandCFormateString() ) + ( isNeedToAddToString ? " \(localizedString("to_title", comment: "")) " : " - ") + ( isDeliveryMode ?  endDate.formatDateForDeliveryHAFormateString() : endDate.formatDateForCandCFormateString())
        
        if self.isInstant.boolValue  {
            return  localizedString("today_title", comment: "") + "\n" + localizedString("60_min", comment: "")
        }else if  self.isToday() {
            let name =    localizedString("today_title", comment: "")
            orderTypeDescription = String(format: "%@ \n %@", name ,orderTypeDescription)
        }else if self.isTomorrow()  {
            let name =    localizedString("tomorrow_title", comment: "")
            orderTypeDescription = String(format: "%@ \n %@", name,orderTypeDescription)
        }else{
            orderTypeDescription =  (startDate.getDayName() ?? "") + " \n " + orderTypeDescription
        }
        return orderTypeDescription
        
    }
    
    
    func getSlotFormattedString(_ isNeedToAddToString : Bool = false , isDeliveryMode : Bool ) -> String {
        guard self.dbID != nil  else {
            return  localizedString("today_title", comment: "") + " " + localizedString("60_min", comment: "")
        }
        
        guard let startDate =  self.start_time, let endDate = self.end_time else { return "" }
        
        var orderTypeDescription = ( (isDeliveryMode ?  startDate.formatDateForDeliveryHAFormateString() : startDate.formatDateForCandCFormateString())) + ( isNeedToAddToString ? " \(localizedString("to_title", comment: "")) " : " - ") + ( isDeliveryMode ?  endDate.formatDateForDeliveryHAFormateString() : endDate.formatDateForCandCFormateString())
        
        if self.isInstant.boolValue {
            return  localizedString("today_title", comment: "") + " " + localizedString("60_min", comment: "")
        }else if  self.isToday() {
            let name =    localizedString("today_title", comment: "")
            orderTypeDescription = String(format: "%@ %@", name ,orderTypeDescription)
        }else if self.isTomorrow()  {
            let name =    localizedString("tomorrow_title", comment: "")
            orderTypeDescription = String(format: "%@ %@", name,orderTypeDescription)
        }else{
            orderTypeDescription =  (startDate.getDayName() ?? "") + " " + orderTypeDescription
        }
        return orderTypeDescription
        
    }
    
    
    
    // MARK: Helpers
    
    
    class func getDeliverySlot(_ context:NSManagedObjectContext , forGroceryID : String , slotId : String) -> DeliverySlot? {
        var predicate = NSPredicate(format: "groceryID == %@ AND dbID == %@", forGroceryID , slotId)
        if slotId == "0" {
            predicate = NSPredicate(format: "groceryID == %@ AND isInstant == 1", forGroceryID)
        }
        
        if let deliverySlots = DatabaseHelper.sharedInstance.getEntitiesWithName(DeliverySlotEntity, sortOneKey: "start_time", boolKey: "isInstant", boolKeyOrderAscending : false ,  predicate: predicate, ascending: true, context: context , 1) as? [DeliverySlot] {
            if deliverySlots.count > 0 {
                return deliverySlots[0]
            }
        }
        return nil
    }
    
    class func getFirstDeliverySlots(_ context:NSManagedObjectContext , forGroceryID : String) -> DeliverySlot? {
        let predicate = NSPredicate(format: "groceryID == %@", forGroceryID)
        if let deliverySlots = DatabaseHelper.sharedInstance.getEntitiesWithName(DeliverySlotEntity, sortOneKey: "start_time", boolKey: "isInstant" , boolKeyOrderAscending : false , predicate: predicate, ascending: true, context: context , 1) as? [DeliverySlot] {
            if deliverySlots.count > 0 {
                return deliverySlots[0]
            }
        }
        return nil
    }
    
    
    class func getAllDeliverySlots(_ context:NSManagedObjectContext , forGroceryID : String) -> [DeliverySlot] {
        
        let predicate = NSPredicate(format: "groceryID == %@", forGroceryID)
        if let deliverySlots = DatabaseHelper.sharedInstance.getEntitiesWithName(DeliverySlotEntity, sortOneKey: "start_time", boolKey: "isInstant" , boolKeyOrderAscending : false , predicate: predicate, ascending: true, context: context) as? [DeliverySlot] {
            return deliverySlots
        }
        return []
 
    }
    
    class func sortFilterA (_ deliverySlots :  [DeliverySlot] ) -> [DeliverySlot] {
        var slotsA = deliverySlots
        slotsA.sort { $0.isInstant > $1.isInstant }
        slotsA.sort { $0.start_time ?? Date() < $1.end_time ?? Date()}
        return slotsA
    }
    
    func getdbID () -> NSNumber {
        return self.dbID
    }
    func isToday() -> Bool {
        return self.start_time?.isToday ?? false
    }
    func isTomorrow() -> Bool {
        return self.start_time?.isTomorrow ?? false
    }
    func getSlotDisplayStringOnOrder(_ grocery : Grocery) -> String {
        return self.getSlotFormattedString(isDeliveryMode: ElGrocerUtility.sharedInstance.isDeliveryMode)
    }



}

