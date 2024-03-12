//
//  SubstitutionBasketItem+CRUD.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 21/09/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import Foundation
import CoreData

let SubstitutionBasketItemEntity = "SubstitutionBasketItem"

extension SubstitutionBasketItem {
    
    class func createSubstitutionBasketItemObject(_ context: NSManagedObjectContext) -> SubstitutionBasketItem {
        return NSEntityDescription.insertNewObject(forEntityName: SubstitutionBasketItemEntity, into: context) as! SubstitutionBasketItem
    }
    
    class func getSubstitutionBasketProductForSubtitutedProduct(_ order:Order, subtitutedProduct:Product, context: NSManagedObjectContext) -> Product {
        
        let predicate = NSPredicate(format: "orderId == %@ AND subtituteProductId == %@", order.dbID, subtitutedProduct.dbID)
        
        let substitutionBasketItems = DatabaseHelper.sharedInstance.getEntitiesWithName(SubstitutionBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [SubstitutionBasketItem]
        
        //collect products ids
        var productIds = [String]()
        for item in substitutionBasketItems {
            productIds.append(item.productId)
        }
        
        //get products
        let productPredicate = NSPredicate(format: "(dbID IN %@)", productIds)
        let product = DatabaseHelper.sharedInstance.getEntitiesWithName(ProductEntity, sortKey: nil, predicate: productPredicate, ascending: true, context: context).first as! Product
        
        return product
    }
    
    class func getSubstitutionBasketItemForSubtitutedProduct(_ order:Order, subtitutedProduct:Product, context: NSManagedObjectContext) -> SubstitutionBasketItem {
        
        let predicate = NSPredicate(format: "orderId == %@ AND subtituteProductId == %@", order.dbID, subtitutedProduct.dbID)
        
        let substitutionBasketItem = DatabaseHelper.sharedInstance.getEntitiesWithName(SubstitutionBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context).first as! SubstitutionBasketItem
        
        return substitutionBasketItem
    }
    
    
    class func getSubstitutionItemsForOrder(_ order:Order?, context: NSManagedObjectContext) -> [SubstitutionBasketItem] {
        
        let predicate = NSPredicate(format: "orderId == %@", order!.dbID)
        
        let substitutionBasketItems =  DatabaseHelper.sharedInstance.getEntitiesWithName(SubstitutionBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [SubstitutionBasketItem]
        
        return substitutionBasketItems
    }
    
    
    class func addOrUpdateProductInSubstitutionBasket(_ product:Product, subtitutedProduct:Product, grocery:Grocery?, order:Order, quantity:Int, context: NSManagedObjectContext) {
        
        //get items in basket
        let substitutionBasketItem = checkIfProductIsInSubstitutionBasket(product, grocery: grocery, order: order, context: context)
        
        if let item = substitutionBasketItem {
            
            //update quantity because item is in basket
            item.count = NSNumber(value: quantity as Int)
            
        } else {
            
            //add to basket
            //let item = SubstitutionBasketItem.createObject(context)
            let item = SubstitutionBasketItem.createSubstitutionBasketItemObject(context)
            item.orderId = order.dbID
            item.productId = product.dbID
            item.subtituteProductId = subtitutedProduct.dbID
            item.groceryId = Grocery.getGroceryIdForGrocery(grocery)
            item.count = NSNumber(value: quantity as Int)
        }
        
        do {
            try context.save()
        } catch (let _) {
            // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
    }
    
    
    
    
    
    
    class func checkIfProductIsInSubstitutionBasket(_ product:Product, grocery:Grocery?, order:Order, context: NSManagedObjectContext) -> SubstitutionBasketItem? {
        
        let groceryId = Grocery.getGroceryIdForGrocery(grocery)
        
        let predicate = NSPredicate(format: "productId == %@ AND orderId == %@ AND groceryId == %@", product.dbID, order.dbID, groceryId)
        
        let substitutionBasketItem = DatabaseHelper.sharedInstance.getEntitiesWithName(SubstitutionBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context).first as? SubstitutionBasketItem
        
        return substitutionBasketItem
    }
    
    class func removeProductFromSubstitutionBasket(_ product:Product, grocery:Grocery?, order:Order, context: NSManagedObjectContext) {
        
        let groceryId = Grocery.getGroceryIdForGrocery(grocery)
        
        let predicate = NSPredicate(format: "productId == %@ AND orderId == %@ AND groceryId == %@", product.dbID, order.dbID, groceryId)
        
        let substitutionBasketItem = DatabaseHelper.sharedInstance.getEntitiesWithName(SubstitutionBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context).first as? SubstitutionBasketItem
        
        if let itemToRemove = substitutionBasketItem {
            
            context.delete(itemToRemove)
            do {
                try context.save()
            } catch (let _) {
               // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
            }
        }
    }
    
    class func checkIfSuggestionIsAvailableForSubtitutedProduct(_ order:Order, subtitutedProduct:Product, product:Product, context: NSManagedObjectContext) -> Bool {
        
        let predicate = NSPredicate(format: "orderId == %@ AND subtituteProductId == %@ AND productId != %@", order.dbID, subtitutedProduct.dbID, product.dbID)
        
        let substitutionBasketItems = DatabaseHelper.sharedInstance.getEntitiesWithName(SubstitutionBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [SubstitutionBasketItem]
        
        return substitutionBasketItems.count > 0
    }
    
    class func clearAvailableSuggestionsForSubtitutedProduct(_ order:Order, subtitutedProduct:Product,context: NSManagedObjectContext) {
        
        let predicate = NSPredicate(format: "orderId == %@ AND subtituteProductId == %@", order.dbID, subtitutedProduct.dbID)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: SubstitutionBasketItemEntity)
        request.includesPropertyValues = false
        request.predicate = predicate
        
        let items:[NSManagedObject] = (try! context.fetch(request)) as! [NSManagedObject]
        
        for item in items {
            
            context.delete(item)
        }
        
        do {
            try context.save()
        } catch (let _) {
            // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
    }
}
