//
//  DeliveryAddress+CRUD.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 06.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
//import Intercom

let DeliveryAddressEntity = "DeliveryAddress"

extension DeliveryAddress {
    
    class func createDeliveryAddressObject(_ context: NSManagedObjectContext) -> DeliveryAddress {
        return NSEntityDescription.insertNewObject(forEntityName: DeliveryAddressEntity, into: context) as! DeliveryAddress
    }

    // MARK: Get
    
    class func getActiveDeliveryAddress(_ context:NSManagedObjectContext) -> DeliveryAddress? {
        
        let predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true as Bool))
        
        let activeDeliveryAddress = DatabaseHelper.sharedInstance.getEntitiesWithName(DeliveryAddressEntity, sortKey: nil, predicate: predicate, ascending: false, context: context) as! [DeliveryAddress]
        
        return activeDeliveryAddress.first
        
       // return DeliveryAddress.getObjects(predicate: predicate, sortDescriptors: [], context: context).first
    }
    
    /** Sets the delivery address as the active (default) user address. */
    class func setActiveDeliveryAddress(_ deliveryAddress: DeliveryAddress, context: NSManagedObjectContext) -> DeliveryAddress {
        
        if let oldActiveDeliveryAddress = DeliveryAddress.getActiveDeliveryAddress(context) {
            oldActiveDeliveryAddress.isActive = false
        }
        deliveryAddress.isActive = true
        
        DatabaseHelper.sharedInstance.saveDatabase()
        
        return deliveryAddress
    }

    class func getAllDeliveryAddresses(_ context:NSManagedObjectContext) -> [DeliveryAddress] {
        
        let predicate = NSPredicate(format: "isArchive == %@ AND isInvoiceAddress == %@", NSNumber(value: false as Bool), NSNumber(value: false as Bool))
        
        //return DeliveryAddress.getObjects(predicate: predicate, sortDescriptors: [], context: context)
        
        let allDeliveryAddresses = DatabaseHelper.sharedInstance.getEntitiesWithName(DeliveryAddressEntity, sortKey: nil, predicate: predicate, ascending: false, context: context) as! [DeliveryAddress]
        
        return allDeliveryAddresses
    }
    
    // MARK: Insert
    
    class func insertOrUpdateDeliveryAddressesForUser(_ userProfile:UserProfile, fromDictionary dictionary:NSDictionary, context:NSManagedObjectContext) -> [DeliveryAddress] {
        
        var results = [DeliveryAddress]()
        var jsonLocationsIds = [String]()
        
        let addressesArray = (dictionary["data"] as! NSDictionary)["addresses"] as! [NSDictionary]
        for adressDict in addressesArray {
            
            let location = DeliveryAddress.insertOrUpdateDeliveryAddressForUser(userProfile, fromDictionary: adressDict, context: context)
            jsonLocationsIds.append(location.dbID)
            results.append(location)
        }
        
        //mark one location as active if currently we dont have selected one
        if DeliveryAddress.getActiveDeliveryAddress(context) == nil {
            if let location = userProfile.deliveryAddresses.allObjects.first as? DeliveryAddress {
              _ = DeliveryAddress.setActiveDeliveryAddress(location, context: context)
            }
        }
        
        deleteLocatiosNotInJSON(jsonLocationsIds,context: context)
        
        do {
            try context.save()
        } catch (let error) {
             //elDebugPrint(error.localizedDescription)
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
            //FireBaseEventsLogger.cu
        }
    
        DatabaseHelper.sharedInstance.saveDatabase()
        
        return results
    }
    
    
    class func insertOrUpdateDeliveryAddressForUser(_ userProfile:UserProfile, fromDictionary adressDict:NSDictionary, context:NSManagedObjectContext) -> DeliveryAddress {
        
        var dbIDString: String!
        if ElGrocerUtility.isAddressCentralisation {
            dbIDString = adressDict["smiles_address_id"] as? String ?? ""
        } else {
            let dbID = adressDict["id"] as! NSNumber
            dbIDString = "\(dbID)"
        }
        
        let location = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(DeliveryAddressEntity, entityDbId: dbIDString as AnyObject, keyId: "dbID", context: context) as! DeliveryAddress
        
        location.locationName = adressDict["address_name"] as! String
        location.shopperName = adressDict["shopper_name"] as? String
        location.phoneNumber = adressDict["phone_number"] as? String
        location.nickName = adressDict["nick_name"] as? String
        
        if let dataIDc = adressDict["address_tag"] as? NSDictionary {
            location.addressTagId = dataIDc["id"] as? String
        }
   
        location.latitude = adressDict["latitude"] as! Double
        location.longitude = adressDict["longitude"] as! Double
        if ElGrocerUtility.isAddressCentralisation {
            location.address = adressDict["city"] as? String ?? ""
        } else {
            location.address = adressDict["location_address"] as? String ?? ""
        }
        location.isCovered = adressDict["is_covered"] as? Bool ?? true
        
        
        
        if let city =    adressDict["city"] as? String {
            location.city = city
        }else{
            location.city = "null"
        }
        
        location.street = adressDict["street"] as? String
        location.building = adressDict["building_name"] as? String
        location.apartment = adressDict["apartment_number"] as? String
        location.isActive = adressDict["default_address"] as? Bool as NSNumber? ?? false as NSNumber
        location.isSmilesDefault = adressDict["default_address"] as? Bool as NSNumber? ?? false as NSNumber
        
        if let addressType = adressDict["address_type_id"] as? Int {
            location.addressType = String(addressType)
        }else{
            location.addressType = "0"
        }
        
        if let floor = adressDict["floor"] as? String {
            location.floor = floor
        }else{
            location.floor = ""
        }
        
        if let houseNumber = adressDict["house_number"] as? String {
            location.houseNumber = houseNumber
        }else{
            location.houseNumber = ""
        }
        
        if let additionalDirection = adressDict["additional_direction"] as? String {
            location.additionalDirection = additionalDirection
        }else{
           location.additionalDirection = ""
        }
        
        location.isArchive = NSNumber(value: false as Bool)

//        userProfile.addDeliveryAddress(location)
        #if DEBUG
        print("IsSmilesDefault: \(adressDict["default_address"]), Nick: \(location.nickName ?? "Null")")
        #endif
        return location
    }
    
    // MARK: Delete
    
    class func deleteLocatiosNotInJSON(_ jsonLocationsIds:[String], context:NSManagedObjectContext) {
        
        let predicate = NSPredicate(format: "NOT (dbID IN %@)", jsonLocationsIds)
        
        let locationsToDelete = DatabaseHelper.sharedInstance.getEntitiesWithName(DeliveryAddressEntity, sortKey: nil, predicate: predicate, ascending: false, context: context) as! [DeliveryAddress]
        for object in locationsToDelete {
            context.delete(object)
        }
    }
    
    // MARK: Address formating
    
    func addressString() -> String {
        
        var baseString = ""
        /* -----  Building Name,Floor #,Apartment #,Street #, Address ----*/
        baseString += (self.building != nil && !self.building!.isEmpty) ? "\(self.building!)" : ""
        baseString += (self.floor != nil && !self.floor!.isEmpty) ? ", \(self.floor!)" : ""
        baseString += (self.apartment != nil && !self.apartment!.isEmpty) ? ", \(self.apartment!)" : ""
        baseString += (self.street != nil && !self.street!.isEmpty) ? ", \(self.street!)," : ""
        baseString += (baseString.isEmpty) ?  self.address: " \(self.address)"
        
        return baseString
    }
    
    func houseAddressString() -> String {
        
        var baseString = ""
        /* -----  House #, Street, Address ----*/
        baseString += (self.houseNumber != nil && !self.houseNumber!.isEmpty) ? "\(self.houseNumber!)" : ""
        baseString += (self.street != nil && !self.street!.isEmpty) ? ", \(self.street!)," : ""
        baseString += (baseString.isEmpty) ?  self.address: " \(self.address)"
        
        return baseString
    }
    
    // MARK: Utils
    
    class func getAddressIdForDeliveryAddress(_ deliveryAddress:DeliveryAddress?) -> String {
        
        var addressId = "0"
        if deliveryAddress != nil {
            //we can have Delivery Address with orderId as first part
            let addressSplittedIds = (deliveryAddress!.dbID.split {$0 == "_"}.map { String($0) })
            if addressSplittedIds.count == 1 {
                 addressId = addressSplittedIds[0]
            }else if addressSplittedIds.count > 1 {
                addressId = addressSplittedIds[1]
            }
            //addressId = addressSplittedIds.count == 1 ? addressSplittedIds[0] : addressSplittedIds[1]
        }
        
        return addressId
    }
    
    static func clearDeliveryAddressEntity(_ context: NSManagedObjectContext = DatabaseHelper.sharedInstance.mainManagedObjectContext) {
        DatabaseHelper.sharedInstance.clearEntity(DeliveryAddressEntity, context: context)
    }
    
}
