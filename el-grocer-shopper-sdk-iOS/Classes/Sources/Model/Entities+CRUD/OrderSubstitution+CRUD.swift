//
//  OrderSubstitution1.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 19/09/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import Foundation
import CoreData

let OrderSubstitutionEntity = "OrderSubstitution"

extension OrderSubstitution {
    
    class func createOrderSubstitutionObject(_ context: NSManagedObjectContext) -> OrderSubstitution {
        return NSEntityDescription.insertNewObject(forEntityName: OrderSubstitutionEntity, into: context) as! OrderSubstitution
    }

    // MARK: Subtituted Basket Products
    class func getSubtitutedProductsForOrderBasket(_ order:Order?, grocery:Grocery?, context: NSManagedObjectContext) -> [Product] {
        
        //get basket items
        let basketItems =  ShoppingBasketItem.getBasketItemsForOrder(order, grocery: grocery, context: context)
        
        //collect products ids
        var productIds = [String]()
        for item in basketItems {
            
            if item.hasSubtitution.boolValue == true {
                productIds.append(item.productId)
            }
        }
        
        //get products
        let predicate = NSPredicate(format: "(dbID IN %@)", productIds)
        return DatabaseHelper.sharedInstance.getEntitiesWithName(ProductEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [Product]
    }
    
    class func getSubtitutedProductsForOrderBasketWithCancelProduct(_ order:Order?, grocery:Grocery?, context: NSManagedObjectContext) -> [Product] {
        
        //get basket items
        let basketItems =  ShoppingBasketItem.getBasketItemsForOrder(order, grocery: grocery, context: context)
        
        //collect products ids
        var productIds = [String]()
        for item in basketItems {
            
            if item.hasSubtitution.boolValue == true {
                productIds.append(item.productId)
            }else if (!item.hasSubtitution.boolValue  && !item.wasInShop.boolValue  ){
                productIds.append(item.productId)
            }
        }
        
        //get products
        let predicate = NSPredicate(format: "(dbID IN %@)", productIds)
        return DatabaseHelper.sharedInstance.getEntitiesWithName(ProductEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [Product]
    }
    
    
    // MARK: Suggested Products
    
    class func getSuggestedProductsForSubtitutedProductFromOrder(_ order:Order?, product:Product, context: NSManagedObjectContext) -> [Product] {
    
        let orderSubstitutions = OrderSubstitution.getOrderSubtitutionForOrder(order!, context: context)
        
        //collect products ids
        var productIds = [String]()
        
        for substitution in orderSubstitutions {
            
            print("Substitution Product Id",substitution.productId)
            print("Product Id",product.dbID)
            
            if substitution.productId == product.dbID {
                productIds.append(substitution.subtitutingProductId)
            }
        }
        
        //get products
        let predicate = NSPredicate(format: "(dbID IN %@)", productIds)
        return DatabaseHelper.sharedInstance.getEntitiesWithName(ProductEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [Product]
    }
    
    
    class func getOrderSubtitutionForOrder(_ order:Order, context: NSManagedObjectContext) -> [OrderSubstitution] {
        
        let predicate = NSPredicate(format: "orderId == %@", order.dbID)
        
        let orderSubstitutions =  DatabaseHelper.sharedInstance.getEntitiesWithName(OrderSubstitutionEntity, sortKey: nil, predicate: predicate, ascending: true, context: context) as! [OrderSubstitution]
        
        return orderSubstitutions
    }
    
    
    class func getBasketItemForOrder(_ order:Order, product:Product, context: NSManagedObjectContext) -> ShoppingBasketItem? {
        
        let predicate = NSPredicate(format: "orderId == %@ AND productId == %@", order.dbID, product.dbID)
        
        let basketItem =  DatabaseHelper.sharedInstance.getEntitiesWithName(ShoppingBasketItemEntity, sortKey: nil, predicate: predicate, ascending: true, context: context).first as? ShoppingBasketItem
        
        return basketItem
    }
}
