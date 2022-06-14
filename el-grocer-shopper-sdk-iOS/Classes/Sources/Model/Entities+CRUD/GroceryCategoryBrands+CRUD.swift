//
//  GroceryCategoryBrands+CRUD.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 09.09.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let GroceryCategoryBrandsEntity = "GroceryCategoryBrands"

extension GroceryCategoryBrands {
    
    class func createGroceryCategoryBrandsObject(_ context: NSManagedObjectContext) -> GroceryCategoryBrands {
        return NSEntityDescription.insertNewObject(forEntityName: GroceryCategoryBrandsEntity, into: context) as! GroceryCategoryBrands
    }
    
    class func getBrandsIds(_ grocery:Grocery, category:Category, context:NSManagedObjectContext) -> [NSNumber] {
        
        let predicate = NSPredicate(format: "groceryId == %@ AND categoryId == %@", grocery.dbID, category.dbID)
        let entities = DatabaseHelper.sharedInstance.getEntitiesWithName(GroceryCategoryBrandsEntity, sortKey: nil, predicate: predicate, ascending: false, caseInsensitiveCompare: false, context: context) as! [GroceryCategoryBrands]

        var results = [NSNumber]()
        
        for entity in entities {
            
            results.append(entity.brandId)
        }
        
        return results
    }
    
    class func clearBrandsForGrocery(_ grocery:Grocery, context:NSManagedObjectContext) {
        
        let predicate = NSPredicate(format: "groceryId == %@", grocery.dbID)

        let entities = DatabaseHelper.sharedInstance.getEntitiesWithName(GroceryCategoryBrandsEntity, sortKey: nil, predicate: predicate, ascending: false, caseInsensitiveCompare: false, context: context)
        
        for entity in entities {
            
            context.delete(entity)
        }
    }
    
    class func addBrand(_ grocery:Grocery, category:Category, brand:Brand, context:NSManagedObjectContext) {
        
        let predicate = NSPredicate(format: "groceryId == %@ AND categoryId == %@ AND brandId == %@", grocery.dbID, category.dbID, brand.dbID)
        
        var entity = DatabaseHelper.sharedInstance.getEntitiesWithName(GroceryCategoryBrandsEntity, sortKey: nil, predicate: predicate, ascending: false, caseInsensitiveCompare: false, context: context).first as? GroceryCategoryBrands
        
        if entity == nil {
            
//            entity = DatabaseHelper.sharedInstance.insertNewObjectForEntityForName(GroceryCategoryBrandsEntity, context: context) as? GroceryCategoryBrands

            
            //entity = GroceryCategoryBrands.createObject(context)
            entity = GroceryCategoryBrands.createGroceryCategoryBrandsObject(context)
            entity?.groceryId = grocery.dbID
            entity?.categoryId = category.dbID
            entity?.brandId = brand.dbID
        }
    }
    
}
