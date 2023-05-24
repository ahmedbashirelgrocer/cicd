//
//  ShoppingBasketItem+CRUD.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 10.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData
import UIKit

let ShoppingBasketItemEntity = "ShoppingBasketItem"

let kTemporaryBasketId:NSNumber = -1

extension ShoppingBasketItem {
    
    class func createShoppingBasketItemObject(_ context: NSManagedObjectContext) -> ShoppingBasketItem {
        return NSEntityDescription.insertNewObject(forEntityName: ShoppingBasketItemEntity, into: context) as! ShoppingBasketItem
    }
    
    // MARK: Grocery
    
    class func getGroceryForActiveGroceryBasket(_ context: NSManagedObjectContext) -> Grocery? {
        
        let basketItem = getBasketItemsForActiveGroceryBasket(context).first
        if basketItem != nil {
            if let grocery = DatabaseHelper.sharedInstance.getEntityWithName(GroceryEntity, entityDbId: basketItem!.groceryId as AnyObject, keyId: "dbID", context: context) {
                return grocery as? Grocery
            }
        }
        return nil
    }


    // MARK: Basket products
    
    /// Passing not nil order return products for order which already was placed, it exists
    /// Passing nil order get one of two baskets - for items flow or for groccery flow, depends on grocery parameter (nil grocery returns products for items flow)
    class func getBasketProductsForOrder(_ order:Order?, grocery:Grocery?, context: NSManagedObjectContext) -> [Product] {
        
//       get basket items
//       let basketItems =  ShoppingBasketItem.getBasketItemsForOrder(order, grocery: grocery, context: context)
         let basketItems =  ShoppingBasketItem.getBasketItemsForOrder(order, grocery: grocery, context: context)
        //collect products ids
        var productIds = [String]()
        for item in basketItems {
           
//            if(order?.status.intValue == OrderStatus.inSubtitution.rawValue && item.wasInShop.boolValue == true){
//                productIds.append(item.productId)
//            }else{
//                 productIds.append(item.productId)
//            }
            
//            productIds.append(item.productId)
            // old logic
            
            if(order?.status.intValue == OrderStatus.canceled.rawValue || order?.status.intValue == OrderStatus.inSubtitution.rawValue ){
                productIds.append(item.productId)
            } else if( item.wasInShop.boolValue == true){
                productIds.append(item.productId)
            }
        }
        //get products
        let predicate = NSPredicate(format: "(dbID IN %@)", productIds)
        return DatabaseHelper.sharedInstance.getEntitiesWithName(ProductEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [Product]
    }
    
    class func getBasketProductsForActiveGroceryBasket(_ context: NSManagedObjectContext) -> [Product] {
        
        
        //get basket items
        let basketItems =  ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(context)
        
        //collect products ids
        var productIds = [String]()
        for item in basketItems {
            productIds.append(item.productId)
        }
        
        //get products
        let predicate = NSPredicate(format: "(dbID IN %@)", productIds)
        let productA = DatabaseHelper.sharedInstance.getEntitiesWithName(ProductEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [Product]
        ElGrocerUtility.sharedInstance.isItemInBasket = productA.count > 0
        return productA
    }
    
    
    
    class func getBasketProductsForActiveItemsBasket(_ context: NSManagedObjectContext) -> [Product] {
        
        //get basket items
        let basketItems =  ShoppingBasketItem.getBasketItemsForActiveItemsBasket(context)
        
        //collect products ids
        var productIds = [String]()
        for item in basketItems {
            productIds.append(item.productId)
        }
        
        //get products
        let predicate = NSPredicate(format: "(dbID IN %@)", productIds)
        return DatabaseHelper.sharedInstance.getEntitiesWithName(ProductEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [Product]
    }
    
    
    
    // MARK: Basket items
    
    /// Passing not nil order return basket items for order which already was placed, it exists
    /// Passing nil order get one of two baskets items - for items flow or for groccery flow, depends on grocery parameter (nil grocery returns products for items flow)
    class func getBasketItemsForOrder(_ order:Order?, grocery:Grocery?, context: NSManagedObjectContext) -> [ShoppingBasketItem] {
        var predicate:NSPredicate!
        if order?.dbID != nil {
            //get items for existing order
            predicate = NSPredicate(format: "orderId == %@", order!.dbID)

        } else {
            //get items for temporary basket
            predicate = NSPredicate(format: "orderId == %@ AND groceryId == %@", kTemporaryBasketId, grocery == nil ? "0" : grocery!.dbID)
        }
        let basketItems =  DatabaseHelper.sharedInstance.getEntitiesWithName(ShoppingBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [ShoppingBasketItem]
        return basketItems
    }
    
    class func getBasketItemsForActiveGroceryBasket(_ context: NSManagedObjectContext) -> [ShoppingBasketItem] {
        
        let predicate = NSPredicate(format: "orderId == %@ AND groceryId != %@", kTemporaryBasketId, "0")
        let basketItems =  DatabaseHelper.sharedInstance.getEntitiesWithName(ShoppingBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [ShoppingBasketItem]
        
        return basketItems
    }
    
    class func getBasketItemsForActiveItemsBasket(_ context: NSManagedObjectContext , orderID : NSNumber? = nil) -> [ShoppingBasketItem] {
        
        let predicate = NSPredicate(format: "orderId == %@ AND groceryId == %@", kTemporaryBasketId, "0")
        let basketItems =  DatabaseHelper.sharedInstance.getEntitiesWithName(ShoppingBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [ShoppingBasketItem]
        
        return basketItems
    }
    
    class func checkIfProductIsInBasket(_ product:Product, grocery:Grocery?, context: NSManagedObjectContext) -> ShoppingBasketItem? {
        
        let groceryId = Grocery.getGroceryIdForGrocery(grocery)

         let predicate = NSPredicate(format: "productId == %@ AND orderId == %@ AND groceryId == %@", product.dbID, kTemporaryBasketId, groceryId)
        
        let shoppingBasketItem = DatabaseHelper.sharedInstance.getEntitiesWithName(ShoppingBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context).first as? ShoppingBasketItem
        
        return shoppingBasketItem
    }
    
    // Created to remove dependency on DB product model
    class func checkIfProductIsInBasket(productId: Int, grocery: Grocery, context: NSManagedObjectContext) -> ShoppingBasketItem? {
        
        let cleanGroceryId = Grocery.getGroceryIdForGrocery(grocery)
        let combinedGroceryId = "\(cleanGroceryId)_\(productId)"

         let predicate = NSPredicate(format: "productId == %@ AND orderId == %@ AND groceryId == %@", combinedGroceryId, kTemporaryBasketId, cleanGroceryId)
        
        let shoppingBasketItem = DatabaseHelper.sharedInstance.getEntitiesWithName(ShoppingBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context).first as? ShoppingBasketItem
        
        return shoppingBasketItem
    }
    
    class func checkIfProductIsInBasketWithProductId(_ product: String , groceryId: String , context: NSManagedObjectContext) -> ShoppingBasketItem? {
        
    
        
        let predicate = NSPredicate(format: "productId == %@ AND orderId == %@ AND groceryId == %@", product , kTemporaryBasketId, groceryId)
        
        let shoppingBasketItem = DatabaseHelper.sharedInstance.getEntitiesWithName(ShoppingBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context).first as? ShoppingBasketItem
        
        return shoppingBasketItem
    }
    

    class func checkIfBasketForCurrentGroceryIsActive(_ grocery:Grocery, context: NSManagedObjectContext) -> Bool {

        let predicate = NSPredicate(format: "orderId == %@ AND groceryId == %@ AND groceryId != %@", kTemporaryBasketId, grocery.dbID, "0")

        let shoppingBasketItems = DatabaseHelper.sharedInstance.getEntitiesWithName(ShoppingBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [ShoppingBasketItem]

        return shoppingBasketItems.count > 0
    }

    class func checkIfBasketForOtherGroceryIsActive(_ grocery:Grocery, context: NSManagedObjectContext) -> Bool {
        
        let predicate = NSPredicate(format: "orderId == %@ AND groceryId != %@ AND groceryId != %@", kTemporaryBasketId, grocery.dbID, "0")

        let shoppingBasketItems = DatabaseHelper.sharedInstance.getEntitiesWithName(ShoppingBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [ShoppingBasketItem]
                
        return shoppingBasketItems.count > 0
    }
    
    /// Checks if there are active baskets available for the given groceries.
    ///
    /// - Parameters:
    ///   - groceries: An array of `Grocery` objects to check against.
    ///   - context: The `NSManagedObjectContext` used for the database operations.
    ///
    /// - Returns: A boolean value indicating if there are active baskets available for the given groceries.
    ///
    /// - Note: This function uses a predicate to query the database for `ShoppingBasketItem` objects with specific conditions. It checks if there are any items where the `orderId` is equal to `kTemporaryBasketId` and the `groceryId` is in the array of grocery IDs extracted from the `groceries` array. If such items exist, it returns `true`; otherwise, it returns `false`.
    class func checkActiveBasketsAvailable(_ groceries: [Grocery], context: NSManagedObjectContext) -> Bool {
        let predicate = NSPredicate(format: "orderId == %@ AND groceryId IN %@", kTemporaryBasketId, groceries.map { $0.dbID }, "0")

        let shoppingBasketItems = DatabaseHelper.sharedInstance.getEntitiesWithName(ShoppingBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [ShoppingBasketItem]
                
        
        return shoppingBasketItems.count > 0
    }
   
    class func addOrUpdateProductInBasketWithIncrement(_ product:Product, grocery:Grocery?, brandName:String?, quantity:Int, context: NSManagedObjectContext) {
        

        var shoppingItem: ShoppingBasketItem?
        //get items in basket
        let shoppingBasketItem = checkIfProductIsInBasket(product, grocery: grocery, context: context)
        
        if let item = shoppingBasketItem {

            shoppingItem = item
            
        } else {
            
            //add to basket
            //AWAIS -- Swift4
            //let item = ShoppingBasketItem.createObject(context)
            let shoppingBasketItem = ShoppingBasketItem.createShoppingBasketItemObject(context)
            shoppingBasketItem.orderId = kTemporaryBasketId
            shoppingBasketItem.productId = product.dbID
            shoppingBasketItem.groceryId = Grocery.getGroceryIdForGrocery(grocery)
            shoppingBasketItem.count = NSNumber(value: quantity as Int)
            shoppingBasketItem.brandName = brandName
            shoppingItem = shoppingBasketItem
        }
        
        updateBasketToServerWithGrocery(grocery, withProduct: product, andWithQuantity: quantity, item: shoppingItem)
        
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
    }
    
    class func addOrUpdateProductInBasket(_ product:Product, grocery:Grocery?, brandName:String?, quantity:Int, context: NSManagedObjectContext , orderID : NSNumber? = nil , _ updatedAt : Date? = nil , _ isServerCalling : Bool = true) {
        
        //get items in basket
        let shoppingBasketItem = checkIfProductIsInBasket(product, grocery: grocery, context: context)
        var shoppingItem : ShoppingBasketItem?
        if let item = shoppingBasketItem {
            //update quantity because item is in basket
            item.count = NSNumber(value: quantity as Int)
            if let finalDate = updatedAt {
                 item.updatedAt = finalDate
            }
            shoppingItem = item
       //    elDebugPrint("Already exsits Item With Product Id: ",item.productId)
        } else {
            
            //add to basket
            //AWAIS -- Swift4
            //let item = ShoppingBasketItem.createObject(context)
            let item = ShoppingBasketItem.createShoppingBasketItemObject(context)
            item.orderId = kTemporaryBasketId
            item.productId = product.dbID
            item.groceryId = Grocery.getGroceryIdForGrocery(grocery)
            item.count = NSNumber(value: quantity as Int)
            item.brandName = brandName
           elDebugPrint("Create new Item With Product Id: ",item.productId)
            if let finalDate = updatedAt {
                item.updatedAt = finalDate
            }
            shoppingItem = item
        }
        if isServerCalling {
            updateBasketToServerWithGrocery(grocery, withProduct: product, andWithQuantity: quantity, item: shoppingItem)
        }
       
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
    }
    
    
    
    
   /* class func addOrUpdateProductInBasketWithOrderID(_ product:Product, grocery:Grocery?, brandName:String?, quantity:Int , orderID : NSNumber, context: NSManagedObjectContext) {
        
        //get items in basket
        let shoppingBasketItem = checkIfProductIsInBasket(product, grocery: grocery, context: context)
        
        if let item = shoppingBasketItem {
            //update quantity because item is in basket
            item.count = NSNumber(value: quantity as Int)
           elDebugPrint("Already exsits Item With Product Id: ",item.productId)
        } else {
            
            //add to basket
            //AWAIS -- Swift4
            //let item = ShoppingBasketItem.createObject(context)
            let item = ShoppingBasketItem.createShoppingBasketItemObject(context)
            item.orderId = kTemporaryBasketId
            item.productId = product.dbID
            item.groceryId = Grocery.getGroceryIdForGrocery(grocery)
            item.count = NSNumber(value: quantity as Int)
            item.brandName = brandName
            item.orderId = orderID
            
           elDebugPrint("Create new Item With Product Id: ",item.productId)
        }
        
        updateBasketToServerWithGrocery(grocery, withProduct: product, andWithQuantity: quantity)
        
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
    }*/

    class func removeProductFromBasket(_ product:Product, grocery:Grocery? ,orderID : NSNumber? = nil , context: NSManagedObjectContext) {
        
        
        
        let groceryId = Grocery.getGroceryIdForGrocery(grocery)
        let predicate = NSPredicate(format: "productId == %@ AND orderId == %@ AND groceryId == %@", product.dbID, kTemporaryBasketId, groceryId)

        let shoppingBasketItem = DatabaseHelper.sharedInstance.getEntitiesWithName(ShoppingBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context).first as? ShoppingBasketItem
        
        updateBasketToServerWithGrocery(grocery, withProduct: product, andWithQuantity: 0, item: shoppingBasketItem)
        
        if let itemToRemove = shoppingBasketItem {
            
            context.performAndWait {
                 context.delete(itemToRemove)
                do {
                    try context.save()
                } catch let error {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                    elDebugPrint(error.localizedDescription)
                }
            }

        }
    }
    
    
    class func removeProductFromBasketLocally(_ product:Product, grocery:Grocery? ,orderID : NSNumber? = nil , context: NSManagedObjectContext) {
        
        
        
        let groceryId = Grocery.getGroceryIdForGrocery(grocery)
        let predicate = NSPredicate(format: "productId == %@ AND orderId == %@ AND groceryId == %@", product.dbID, kTemporaryBasketId, groceryId)
        
        let shoppingBasketItem = DatabaseHelper.sharedInstance.getEntitiesWithName(ShoppingBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context).first as? ShoppingBasketItem
        
        if let itemToRemove = shoppingBasketItem {
            
            context.performAndWait {
                context.delete(itemToRemove)
                do {
                    try context.save()
                } catch let error {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                    elDebugPrint(error.localizedDescription)
                }
            }
            
        }
    }
    

    class func clearCurrentActiveGroceryShoppingBasket(_ context: NSManagedObjectContext) {

        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("clear_active_grocery_basket")
        UserDefaults.setBasketInitiated(false)

         let groceryId  = "0"
//        if let activeGrocery = ElGrocerUtility.sharedInstance.activeGrocery {
//            groceryId = activeGrocery.dbID
//        }
        let predicate = NSPredicate(format: "orderId == %@ AND groceryId > %@", kTemporaryBasketId, groceryId)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ShoppingBasketItemEntity)
        request.includesPropertyValues = false
        request.predicate = predicate
        let items:[NSManagedObject] = (try! context.fetch(request)) as! [NSManagedObject]

        for item in items {
            context.perform {
                context.delete(item)
            }
        }


        context.perform {
            do {
                try context.save()
            } catch  {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                elDebugPrint(error.localizedDescription)
            }
        }


    }

    class func clearActiveGroceryShoppingBasket(_ context: NSManagedObjectContext , orderID : NSNumber? = nil) {
        
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("clear_active_grocery_basket")
        UserDefaults.setBasketInitiated(false)
        var predicate : NSPredicate
            predicate = NSPredicate(format: "orderId == %@ AND groceryId > %@", kTemporaryBasketId, "0")
        if let finalOrderID = orderID  {
            predicate = NSPredicate(format: "orderId == %@" , finalOrderID)
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ShoppingBasketItemEntity)
        request.includesPropertyValues = false
        request.predicate = predicate
        // var items:[NSManagedObject] = (try! context.fetch(request)) as! [NSManagedObject]
        var items:[NSManagedObject] = []
        do {
            if let data =  try context.fetch(request) as? [NSManagedObject] {
                 items = data
            }
        }catch{
            
        }
    
        for item in items {
            context.performAndWait {
                 context.delete(item)
            }
        }

        do {
            try context.save()
        } catch  {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
            elDebugPrint(error.localizedDescription)
        }

    }
    
    class func clearActiveItemsShoppingBasket(_ context: NSManagedObjectContext , orderID : NSNumber? = nil) {
        
        
//        var predicate : NSPredicate
//        
//        if let notNumberOrderID = orderID {
//            predicate = NSPredicate(format: "orderId == %@ OR orderId == %@ AND groceryId > %@", kTemporaryBasketId, notNumberOrderID , "0")
//        }else{
//            predicate = NSPredicate(format: "orderId == %@ AND groceryId > %@", kTemporaryBasketId, "0")
//        }
        
//        
        let predicate = NSPredicate(format: "orderId == %@ AND groceryId == %@", kTemporaryBasketId, "0")
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ShoppingBasketItemEntity)
        request.includesPropertyValues = false
        request.predicate = predicate
        
        let items:[NSManagedObject] = (try! context.fetch(request)) as! [NSManagedObject]
        
        for item in items {
            
            context.delete(item)
        }
        
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
    }
    
    class func updateBasketToServerWithGrocery(_ grocery:Grocery?, withProduct product:Product, andWithQuantity quantity:Int , item : ShoppingBasketItem? ){
    
        
        guard UserDefaults.isUserLoggedIn() else {
            
            NotificationCenter.default.post(name: KProductNotification, object: product)
            return
            
        }
        if quantity > 0 {
            
            guard product.availableQuantity != 0 else {
                
                NotificationCenter.default.post(name: KProductNotification, object: product)
                return
                
            }
        }
       
    
        ElGrocerApi.sharedInstance.updateBasketProductsToServer(grocery, withProduct: product, andWithQuantity: quantity) { (result) in
            
            switch result {
            case .success(let responseDict):
                        let data = responseDict
                    if let available_quantity = (data["data"] as? NSDictionary)?["available_quantity"] as? NSNumber {
                        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                        
                        product.availableQuantity = available_quantity
                        if available_quantity == -1 {
                           elDebugPrint("Basket update to SERVER with Response:%@",responseDict)
                        } else if available_quantity == 0 {
                            if quantity > 0 {
                                ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: grocery , brandName: product.brandNameEn , quantity: (item?.count.intValue ?? quantity) , context: context)
                            }
                        }
                        do {
                            try context.save()
                        } catch (let error) {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                        }
                    }
                    NotificationCenter.default.post(name: KProductNotification, object: product)
            case .failure(let error):
                    var msg = localizedString("lbl_edit_delete", comment: "")
                    if let jsonData = error.jsonValue?["messages"] as? NSDictionary {
                        if let available_quantity = jsonData["available_quantity"] as? NSNumber {
                            product.availableQuantity = available_quantity
                        }
                        msg = error.message ?? msg
                    }
                    
                    FireBaseEventsLogger.trackAddItemFailure(product: product, reason: msg)
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                    ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: grocery, brandName: nil, quantity: (item?.count.intValue ?? quantity)  , context: context, orderID: nil, nil , false)
                    do {
                        try context.save()
                    } catch (let error) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                    }
                    NotificationCenter.default.post(name: KProductNotification, object: product)
                    ShoppingBasketItem.showMessage(msg)
               elDebugPrint("Error while basket update to SERVER:%@",error.localizedMessage)
            }
        }
    }
    
    class func showMessage (_ msg : String) {
        
        ElGrocerUtility.sharedInstance.showTopMessageView(msg, image: UIImage(name: "MyBasketOutOfStockStatusBar"), backButtonClicked:  {  (sender , index , isUnDo) in
            
        })

    }
}
