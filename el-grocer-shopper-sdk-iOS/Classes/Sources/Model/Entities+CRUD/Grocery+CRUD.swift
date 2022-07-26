//
//  Grocery+CRUD.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 08.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData

let GroceryEntity = "Grocery"

extension Grocery {
    
    // MARK: Get
    
    class func getGroceryById(_ id:String, context:NSManagedObjectContext) -> Grocery? {
        
        return DatabaseHelper.sharedInstance.getEntityWithName(GroceryEntity, entityDbId: id as AnyObject, keyId: "dbID", context: context) as? Grocery
    }
    
    class func getUpdateGroceryData(serverGroceries: Grocery , context:NSManagedObjectContext) -> Grocery? {
        
        var predicate:NSPredicate!
        
        predicate = NSPredicate(format: "dbID == %@", serverGroceries.dbID)
        
        let groceries = DatabaseHelper.sharedInstance.getEntitiesWithName(GroceryEntity, sortKey:nil, predicate: predicate, ascending: true, context: context) as! [Grocery]
        if groceries.count > 0 {
             return groceries[0]
        }else{
            return nil
        }
        
    }
    
    
    class func getAllGrocery(context:NSManagedObjectContext) -> [Grocery] {
        
        
        
        let groceries = DatabaseHelper.sharedInstance.getEntitiesWithName(GroceryEntity, sortKey:nil, predicate: nil , ascending: true, context: context) as! [Grocery]
        if groceries.count > 0 {
            return groceries
        }else{
            return []
        }
        
    }
    
    
    class func getAllGroceries(serverGroceries:[Grocery]?, context:NSManagedObjectContext) -> [Grocery] {
        
        var predicate:NSPredicate!
        
        if serverGroceries == nil {
            
            predicate = NSPredicate(format: "isArchive == %@", NSNumber(value: false as Bool))
            
        } else {
            
            let ids = (serverGroceries! as NSArray).value(forKeyPath: "dbID") as! [NSNumber]
            
            predicate = NSPredicate(format: "isArchive == %@ AND (dbID IN %@)", NSNumber(value: false as Bool), ids)
        }
        
        let groceries = DatabaseHelper.sharedInstance.getEntitiesWithName(GroceryEntity, sortKey:nil, predicate: predicate, ascending: true, context: context) as! [Grocery]

        return groceries
    }
    
    class func getAllFavouritesGroceries(_ context:NSManagedObjectContext) -> [Grocery] {
        
        let predicate = NSPredicate(format: "isFavourite == %@ AND isArchive == %@", NSNumber(value: true as Bool), NSNumber(value: false as Bool))
        
        return DatabaseHelper.sharedInstance.getEntitiesWithName(GroceryEntity, sortKey: "name", predicate: predicate, ascending: true, context: context) as! [Grocery]
    }
    
    // MARK: Insert
    
    class func insertOrReplaceGroceriesFromDictionary(_ dictionary:NSDictionary, context:NSManagedObjectContext , _ isDelivery : Bool = true) -> [Grocery] {
        
        var resultGroceries = [Grocery]()
        
        if let responseObjects = dictionary["retailers"] as? [NSDictionary] {
            for responseDict in responseObjects {
                let grocery = createGroceryFromDictionary(responseDict, context: context , isDelivery )
                resultGroceries.append(grocery)
            }
        }else{
            if let data = (dictionary["data"] as? NSDictionary) {
                if let responseObjects = data["retailers"] as? [NSDictionary] {
                    for responseDict in responseObjects {
                        let grocery = createGroceryFromDictionary(responseDict, context: context , isDelivery )
                        resultGroceries.append(grocery)
                    }
                }else if let data = (dictionary["data"] as? NSDictionary)  {
                    if (data["id"] as? Int) != nil {
                        let grocery = createGroceryFromDictionary(data, context: context , isDelivery )
                        resultGroceries.append(grocery)
                    }
                }
            }
        }
        //TODO: Make sure that data is saving after this
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
        
        return resultGroceries
    }
    
    class func insertOrReplaceGroceriesFromAlgoliaDictionary(_ dictionary:NSDictionary, context:NSManagedObjectContext , _ isDelivery : Bool = true) -> [Grocery] {
        
        var resultGroceries = [Grocery]()
        
        if let responseObjects = dictionary["retailers"] as? [NSDictionary] {
            for responseDict in responseObjects {
                let grocery = createGroceryFromDictionary(responseDict, context: context , isDelivery )
                resultGroceries.append(grocery)
            }
        }else{
            if let data = (dictionary["data"] as? NSDictionary) {
                if let responseObjects = data["retailers"] as? [NSDictionary] {
                    for responseDict in responseObjects {
                        let grocery = createGroceryFromDictionary(responseDict, context: context , isDelivery )
                        resultGroceries.append(grocery)
                    }
                }else if let data = (dictionary["data"] as? NSDictionary)  {
                    if (data["id"] as? Int) != nil {
                        let grocery = createGroceryFromDictionary(data, context: context , isDelivery )
                        resultGroceries.append(grocery)
                    }
                }
            }
        }
            //TODO: Make sure that data is saving after this
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
        
        return resultGroceries
    }
    
    class func insertGroceriesWithNotAvailableProducts(_ dictionary:NSDictionary, context:NSManagedObjectContext) -> (groceries:[Grocery], notAvailableProducts:[[Int]], availableProductsPrices:NSDictionary) {
        
        var resultGroceries = [Grocery]()
        var notAvailableProducts = [[Int]]()
        let availableProductsPrices = NSMutableDictionary()
        
        let responseObjects = (dictionary["data"] as! NSDictionary)["retailers"] as! [NSDictionary]
        for responseDict in responseObjects {
            var groceryDict : NSDictionary = NSDictionary()
            if let data = responseDict["retailer"] as? NSDictionary {
                elDebugPrint("groceryDict")
                groceryDict = data
            }else{
                groceryDict = responseDict
            }

            let grocery = createGroceryFromDictionary(groceryDict, context: context )
            
            let pricesDict = NSMutableDictionary()
            var products : [Int] = [Int]()
            
            if  let data = responseDict["unavailable_products"] as? [Int] {
                products = data
                //get available products for prices
                let availableProducts = responseDict["available_products"] as! [NSDictionary]
                for availableProduct in availableProducts {
                    //insert product prices for retailer
                    let productPrice = availableProduct["price"] as! NSDictionary
                    pricesDict[availableProduct["id"] as! Int] = productPrice
                }
            }
            
            if (grocery.isShowRecipe == true) {
                resultGroceries.append(grocery)
                notAvailableProducts.append(products)
                availableProductsPrices[grocery.dbID] = pricesDict
            }
            
//            //do not return shops which don't have available products
//            if availableProducts.count > 0 {
//                    if (grocery.isShowRecipe == true) {
//                        resultGroceries.append(grocery)
//                        notAvailableProducts.append(products)
//                        availableProductsPrices[grocery.dbID] = pricesDict
//                    }
//            }
        }
        
        return (resultGroceries, notAvailableProducts, availableProductsPrices)
    }
    
    func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
               elDebugPrint(error)
            }
        }
        return nil
    }
    
    class func createGroceryFromDictionary(_ responseDict:NSDictionary, orderId: NSNumber? = nil, context:NSManagedObjectContext , _ isDelivery : Bool = true ) -> Grocery {
        
        let groceryIntId = responseDict["id"] as! Int
        var groceryId: String
        
        // If the grocery came with an order, we need to append the order id to the grocery id
        if let orderId = orderId {
            groceryId = Order.getDbIdForSnappedGrocery(orderId, groceryId: NSNumber(value:groceryIntId))
        } else {
            groceryId = "\(groceryIntId)"
        }
        
        let grocery = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(GroceryEntity, entityDbId: groceryId as AnyObject, keyId: "dbID", context: context) as! Grocery
        grocery.name = responseDict["company_name"] as? String
        grocery.address = responseDict["company_address"] as? String
        grocery.reviewScore = responseDict["average_rating"] as? NSNumber ?? 0
        grocery.isFavourite = responseDict["is_favourite"] as? NSNumber ?? 0
        grocery.minBasketValue = responseDict["min_basket_value"] as? Double ?? 0.0
        grocery.serviceFee = responseDict["service_fee"] as? Double ?? 0.0
        grocery.isDelivery = isDelivery as NSNumber
        grocery.latitude = responseDict["latitude"] as? Double ?? 0.0
        grocery.longitude = responseDict["longitude"] as? Double ?? 0.0
        
        grocery.smileSupport = false
        if let supported = responseDict["smile_Support"] as? NSNumber {
            grocery.smileSupport = supported
        }
        
        if let isShowRecipe = responseDict["is_show_recipe"] as? NSNumber {
            grocery.isShowRecipe = isShowRecipe
        }else{
             grocery.isShowRecipe = false
        }
        // grocery.isShowRecipe = false
        
        if let featured = responseDict["featured"] as? NSNumber {
            grocery.featured = featured
        }else{
            grocery.featured = false
        }
        
        if let inventory_controlled = responseDict["inventory_controlled"] as? NSNumber {
            grocery.inventoryControlled = inventory_controlled
        }else{
            grocery.inventoryControlled = false
        }
       
        if let featureImageUrl = responseDict["bg_photo_url"] as? String {
            grocery.featureImageUrl = featureImageUrl
        }else{
            grocery.featureImageUrl = nil
        }
        
        
        if let ranking  = responseDict["ranking"] as? NSNumber {
            grocery.ranking = ranking
        }
        if let distance  = responseDict["distance"] as? NSNumber {
            grocery.distance = distance
        }
        
        if let valueAddedTex = responseDict["vat"] as? NSNumber {
            grocery.vat = valueAddedTex
        }

        if let valueAddedTex = responseDict["vat"] as? NSNumber {
            grocery.vat = valueAddedTex
        }
        
        if let retailer_type = responseDict["retailer_type"] as? NSNumber {
            grocery.retailerType = retailer_type
        }
        if let store_type = responseDict["store_type"] as? [NSNumber] {
            grocery.storeType = store_type
        }
    
        if let groceryImgUrl = responseDict["photo1_url"] as? String {
             grocery.imageUrl = groceryImgUrl
        }
        
        if let photoUrl = responseDict["photo_url"] as? String {
            grocery.smallImageUrl = photoUrl
        }
        
        if let photoUrl = responseDict["retailer_photo"] as? String {
            grocery.smallImageUrl = photoUrl
        }
        
        
        
        if let top_search = responseDict["top_searches"] as? [String] {
            
            grocery.topSearch = top_search
        }
        
        
        if let retailerGroupName = responseDict["retailer_group_name "] as? String {
            grocery.retailerGroupName = retailerGroupName
        }else{
            grocery.retailerGroupName = "null"
        }

        if let isOpen = responseDict["is_opened"] as? NSNumber {
            grocery.isOpen = isOpen
        }
        
        if let add_day = responseDict["add_day"] as? NSNumber {
            grocery.addDay = add_day
        }
        
        if let parent_id = responseDict["parent_id"] as? NSNumber {
            grocery.parentID = parent_id
        }else{
          grocery.parentID = -1
        }
        
        if let groupId = responseDict["retailer_group_id"] as? NSNumber {
            grocery.groupId = groupId
        }else{
            grocery.groupId = -1
        }
        
        
        if let isSchedule = responseDict["is_schedule"] as? NSNumber {
            grocery.isSchedule = isSchedule
        }
        
        if let opening_times = responseDict["opening_time"] as? String {
            grocery.openingTime = opening_times
        }
        
        if let isInRange = responseDict["is_in_range"] as? NSNumber {
            grocery.isInRange = isInRange
        }
        
        if let delivery_type_id = responseDict["delivery_type_id"] as? NSNumber {
            grocery.deliveryTypeId = delivery_type_id.stringValue
        }
        
        if let delivery_type = responseDict["delivery_type"] as? String {
            grocery.deliveryType = delivery_type
        }
        
        if let deliveryZoneDict = responseDict["retailer_delivery_zone"] as? NSDictionary {
            
            if let delivery_zone_id = deliveryZoneDict["id"] as? NSNumber {
                grocery.deliveryZoneId = "\(delivery_zone_id)"
            }
            
            grocery.deliveryFee = deliveryZoneDict["delivery_fee"] as? Double ?? 0.0
            grocery.riderFee = deliveryZoneDict["rider_fee"] as? Double ?? 0.0
        }
        
        //available payments, saved as bitmask
        if let paymentsArray = responseDict["available_payment_types"] as? [NSDictionary] {
            
            var typesId = [UInt32]()
            for payment in paymentsArray {
                let paymentId:UInt32 = (payment["id"] as! NSNumber).uint32Value
                typesId.append(paymentId)
            }
            var mask:UInt32 = 0
            if typesId.count > 0 {
                if typesId.count == 1 {
                     mask =  typesId[0]
                } else{
                     mask = typesId[0] | typesId[1]
                }
            }
            grocery.availablePayments = NSNumber(value: mask as UInt32)
            
            var typesNumberId = [NSNumber]()
            for payment in paymentsArray {
                let paymentId = (payment["id"] as! NSNumber)
                typesNumberId.append(paymentId)
            }
            grocery.paymentAvailableID = typesNumberId
            
        }
        //save categories of grocery ---
        if let categoryArray = responseDict["categories"] as? [NSDictionary] {
                let groceryBgContext = DatabaseHelper.sharedInstance.getEntityWithName(GroceryEntity, entityDbId: grocery.dbID as AnyObject, keyId: "dbID", context: context) as! Grocery
                //save grocery categories
                Category.insertOrUpdateCategoriesForGrocery(groceryBgContext, categoriesArray: categoryArray, context: context)
                DatabaseHelper.sharedInstance.saveDatabase()
        }
        
        grocery.genericSlot  =  localizedString("lbl_no_timeSlot_available", comment: "")
        if  (grocery.isOpen.boolValue && (grocery.isInstant() || grocery.isInstantSchedule())) {
            grocery.genericSlot = localizedString("today_title", comment: "") + "\n"   +  localizedString("60_min", comment: "")
        }else{
            if let deliverySlotA = responseDict["delivery_slots"] as? [NSDictionary] {
                for data in deliverySlotA {
                    grocery.genericSlot =  grocery.getDeliverySlotFormatterTimeStringWithDictionary(data)
                    grocery.initialDeliverySlotData = grocery.jsonToString(json: data)
                    break
                }
            }
        }
        if let deliverySlotA = responseDict["delivery_slots"] as? [NSDictionary] {
            for data in deliverySlotA {
                grocery.initialDeliverySlotData = grocery.jsonToString(json: data)
                break
            }
        }
        
         DatabaseHelper.sharedInstance.saveDatabase()
        return grocery
    }
    
    class func updateGroceryOpeningStatus(_ responseDict:NSDictionary, context:NSManagedObjectContext) -> Grocery? {
        
        if let groceryIntId = responseDict["id"] as? Int {
            let groceryId = "\(groceryIntId)"
            let grocery = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(GroceryEntity, entityDbId: groceryId as AnyObject, keyId: "dbID", context: context) as! Grocery
            
            if let isOpen = responseDict["is_opened"] as? NSNumber {
                grocery.isOpen = isOpen
            }
            if let add_day = responseDict["add_day"] as? NSNumber {
                grocery.addDay = add_day
            }
            
             return grocery
        }
         return nil
    
    }
    
    // MARK: Utils
    
    class func getGroceryIdForGrocery(_ grocery:Grocery?) -> String {

        var groceryId = "0"
        if grocery != nil {
            //we can have grocery with orderId as first part
            let grocerySplittedIds = (grocery!.dbID.split {$0 == "_"}.map { String($0) })
            if grocerySplittedIds.count > 0 {
                 groceryId = grocerySplittedIds.count == 1 ? grocerySplittedIds[0] : grocerySplittedIds[1]
            }
        }
        return groceryId
        
    }

    class func updateActiveGroceryDeliverySlots (_ grocery : Grocery?=ElGrocerUtility.sharedInstance.activeGrocery,   with ResponseDict : NSDictionary , context:NSManagedObjectContext) -> Void {
        
        var currentGrocery = grocery
        if currentGrocery == nil {
           currentGrocery =  ElGrocerUtility.sharedInstance.activeGrocery
        }
        guard currentGrocery != nil else {return }
        if  let groceryDict = ResponseDict["data"] as? NSDictionary {
            if let deliverySlotA = groceryDict["delivery_slots"] as? [NSDictionary] {
                if let groceryID = currentGrocery?.dbID {
                    if let groceryBgContext = DatabaseHelper.sharedInstance.getEntityWithName(GroceryEntity, entityDbId: groceryID as AnyObject, keyId: "dbID", context: context) as? Grocery {
                        DeliverySlot.insertOrUpdateDeliverySlotsForGrocery(groceryBgContext , deliverySlotsArray: deliverySlotA, context: context)
                    }
                }
            }
            DatabaseHelper.sharedInstance.saveDatabase()
            NotificationCenter.default.post(name: Notification.Name(rawValue: KSlotsUpdate), object: nil)
        }
    }
    
    class func updateGroceryPaymentFromDictioanry (_ responseDict:NSDictionary, orderId: NSNumber? = nil, context:NSManagedObjectContext ) -> Grocery {
        
        let groceryIntId = responseDict["id"] as! Int
        var groceryId: String
        
        // If the grocery came with an order, we need to append the order id to the grocery id
        if let orderId = orderId {
            groceryId = Order.getDbIdForSnappedGrocery(orderId, groceryId: NSNumber(value:groceryIntId))
        } else {
            groceryId = "\(groceryIntId)"
        }
        
        let grocery = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(GroceryEntity, entityDbId: groceryId as AnyObject, keyId: "dbID", context: context) as! Grocery
        //available payments, saved as bitmask
        if let paymentsArray = responseDict["available_payment_types"] as? [NSDictionary] {
            
            var typesId = [UInt32]()
            for payment in paymentsArray {
                let paymentId:UInt32 = (payment["id"] as! NSNumber).uint32Value
                typesId.append(paymentId)
            }
            var mask:UInt32 = 0
            if typesId.count > 0 {
                if typesId.count == 1 {
                    mask =  typesId[0]
                } else{
                    mask = typesId[0] | typesId[1]
                }
            }
            grocery.availablePayments = NSNumber(value: mask as UInt32)
            
            var typesNumberId = [NSNumber]()
            for payment in paymentsArray {
                let paymentId = (payment["id"] as! NSNumber)
                typesNumberId.append(paymentId)
            }
            grocery.paymentAvailableID = typesNumberId
            
        }
        DatabaseHelper.sharedInstance.saveDatabase()
        
        return grocery
        
        
    }

    

    // MARK: Categories helper methods


    func addDeliverySlot(_ value: DeliverySlot) {
        let items = self.mutableSetValue(forKey: "deliverySlots")
        items.add(value)
    }
    
    func addDeliverySlots(_ data: [DeliverySlot]) {
        let items = self.mutableSetValue(forKey: "deliverySlots")
        for value in data {
             items.add(value)
        }
    }

    func addCategory(_ value: Category) {
        
        let items = self.mutableSetValue(forKey: "categories")
        items.add(value)
    }
    
    func removeCategory(_ value: Category) {
        
        let items = self.mutableSetValue(forKey: "categories")
        items.remove(value)
    }
    
    func clearCategories() {
        
        let items = self.mutableSetValue(forKey: "categories")
        items.removeAllObjects()
    }
    func clearDeliverySlots(context:NSManagedObjectContext) {

        let items = self.mutableSetValue(forKey: "deliverySlots")
        items.removeAllObjects()

    }
    
    func clearDeliverySlotsTable(context:NSManagedObjectContext) {
                let predicate = NSPredicate(format: "groceryID == %@", self.dbID)
                let slotsToDelete = DatabaseHelper.sharedInstance.getEntitiesWithName(DeliverySlotEntity, sortKey: nil, predicate: predicate, ascending: false, context: context)
                for object in slotsToDelete {
                    context.delete(object)
                }
    }

    
    func addSubCategory(_ value: Category) {
        
        let items = self.mutableSetValue(forKey: "subcategories")
        items.add(value)
    }
    
    func removeSubCategory(_ value: Category) {
        
        let items = self.mutableSetValue(forKey: "subcategories")
        items.remove(value)
    }
    
    func clearSubCategories() {
        
        let items = self.mutableSetValue(forKey: "subcategories")
        items.removeAllObjects()
    }
    
    func addBrand(_ value: Brand) {
        
        let items = self.mutableSetValue(forKey: "brands")
        items.add(value)
    }
    
    func addBrands(_ brands:[Brand]) {
        
        let items = self.mutableSetValue(forKey: "brands")
        for brand in brands {
            
            items.add(brand)
        }
    }
    
    func clearBrands() {
        
        let items = self.mutableSetValue(forKey: "brands")
        items.removeAllObjects()
    }
    
    func removeBrand(_ value: Brand) {
        
        let items = self.mutableSetValue(forKey: "brands")
        items.remove(value)
    }
    
    func addReview(_ value: GroceryReview) {
        
        let items = self.mutableSetValue(forKey: "reviews")
        items.add(value)
    }
    
    func removeReview(_ value: GroceryReview) {
        
        let items = self.mutableSetValue(forKey: "reviews")
        items.remove(value)
    }
    
    func clearReviews() {
        
        let items = self.mutableSetValue(forKey: "reviews")
        items.removeAllObjects()
    }
    //MARK:- Helpers
    
    func isInstant() -> Bool {
        return self.deliveryTypeId == "0"
    }
    func isInstantSchedule() -> Bool {
        return self.deliveryTypeId == "2"
    }
    func isScheduleType() -> Bool {
        return self.deliveryTypeId == "1"
    }
    func getAllDeliverySlots () -> [DeliverySlot] {
        return DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: self.dbID)
    }
    
   
        
    func getDeliverySlotFormatterTimeStringWithDictionary (_ slotDict : NSDictionary ) -> String {
        var groceryNextDeliveryString =  localizedString("lbl_no_timeSlot_available", comment: "")
        if (slotDict["id"] as? String) == "0" {
            groceryNextDeliveryString =  localizedString("today_title", comment: "") + "\n"  +  localizedString("60_min", comment: "")
        } else {
            
            var dayTitle = ""
            if let startDate = (slotDict["start_time"] as? String)?.convertStringToCurrentTimeZoneDate() {
                if let endDate = (slotDict["end_time"] as? String)?.convertStringToCurrentTimeZoneDate() {
                    if startDate.isToday {
                        dayTitle = localizedString("today_title", comment: "")
                    }else if startDate.isTomorrow {
                        dayTitle = localizedString("tomorrow_title", comment: "")
                    }else {
                        dayTitle = startDate.getDayName() ?? ""
                    }
                    let timeSlot = ( self.isDelivery.boolValue ?  startDate.formatDateForDeliveryFormateString() : startDate.formatDateForCandCFormateString() ) + " - " + ( self.isDelivery.boolValue ?  endDate.formatDateForCandCFormateString() : endDate.formatDateForCandCFormateString())
                    groceryNextDeliveryString =  "\(dayTitle)" + (dayTitle.count > 0 ? "\n" : "") + "\(timeSlot)"
                }
            }
        }
        return groceryNextDeliveryString
    }
    
    static func isSameGrocery (_ lhs : Grocery? , rhs : Grocery? ) -> Bool {
        guard lhs != nil && rhs != nil else {return false}
        return lhs!.getCleanGroceryID() == rhs!.getCleanGroceryID() && lhs!.deliveryZoneId == rhs!.deliveryZoneId
    }
    
    func getCleanGroceryID () -> String {
        return ElGrocerUtility.sharedInstance.cleanGroceryID(self.dbID)
    }
    
    func isSuperMarket() -> Bool {
        return self.retailerType.int64Value == GroceryRetailerMarketType.supermarket.rawValue
    }
    func isHyperMarket() -> Bool {
        return self.retailerType.int64Value == GroceryRetailerMarketType.hypermarket.rawValue
    }
    func isSpecialityMarket() -> Bool {
        return self.retailerType.int64Value == GroceryRetailerMarketType.speciality.rawValue
    }
    

}

extension Grocery {
        static func equals (lhs: Grocery?, rhs: Grocery?) -> Bool {
        return lhs?.dbID == rhs?.dbID && lhs?.deliveryZoneId == rhs?.deliveryZoneId
    }
}

extension Grocery {
    
    
    func jsonToString(json: AnyObject)->String{
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            return convertedString! // <-- here is ur string
            
        } catch let myJSONError {
           elDebugPrint(myJSONError)
        }
        
        return ""
    }
    
        // Convert JSON String to Dict
    func convertToDictionary(text: String) -> NSDictionary? {
        if let data = text.data(using: .utf8) {
            do {
                
                return try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
            } catch {
               elDebugPrint(error.localizedDescription)
            }
        }
        return nil
    }
    
    
}
