//
//  Brand+CRUD.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 08.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData

let BrandEntity = "Brand"

extension Brand {
 
    // MARK: Get
    
    class func getBrandForProduct(_ product:Product, context:NSManagedObjectContext) -> Brand? {
        
        print("Product Brand Id:%@",product.brandId ?? "NULL")
        if let brandId = product.brandId {
            let predicate = NSPredicate(format: "dbID == %@", brandId)
            let brand = DatabaseHelper.sharedInstance.getEntitiesWithName(BrandEntity, sortKey: nil, predicate: predicate, ascending: false, context: context).first as? Brand
            return brand
        }else{
            return nil
        }
    }
    
    class func getBrandsForSubCategory(_ category:Category, fromGroceryBrandsIds brandsIds:[NSNumber], sortedByName:Bool, context:NSManagedObjectContext) -> [Brand] {
        
        var resultBrands = [Brand]()
        
        //let categoryBrands = category.brands.allObjects as! [Brand]
        
        let categoryBrands = DatabaseHelper.sharedInstance.getEntitiesWithName(BrandEntity, sortKey: "name", predicate: nil, ascending: true, caseInsensitiveCompare: false, context: context) as! [Brand]
        
        for categoryBrand in categoryBrands {
            for groceryBrandId in brandsIds {
                
                if categoryBrand.dbID.intValue == groceryBrandId.intValue {
                    
                    resultBrands.append(categoryBrand)
                    break
                }
            }
        }
        
        return resultBrands
    }
    
    // MARK: Insert
    class func insertOrUpdateBrandsFromDictionary(_ dictionary:NSDictionary, forCategory category:Category, context:NSManagedObjectContext) -> [Brand] {
        
        let brandsCategory = DatabaseHelper.sharedInstance.getEntityWithName(CategoryEntity, entityDbId: category.dbID, keyId: "dbID", context: context) as! Category
        
        //fetch once and search array (for performance reasons)
        var allBrands = DatabaseHelper.sharedInstance.getEntitiesWithName(BrandEntity, sortKey: nil, predicate: nil, ascending: false, caseInsensitiveCompare: false, context: context) as! [Brand]
        
        var resultBrands = [Brand]()
        
        let responseObjects = (dictionary["data"] as! NSDictionary)["brands"] as! [NSDictionary]
        for brandDict in responseObjects {
            
            let brand = insertOrUpdateBrandFromDictionary(brandDict, allBrands: &allBrands,  context: context)
            
            brandsCategory.addBrand(brand)
            
            resultBrands.append(brand)
        }
        
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }

        return resultBrands
    }
    
    class func insertOrUpdateBrandsFromDictionaryForGrocery(_ dictionary:NSDictionary, forCategory category:Category, forGrocery grocery:Grocery, context:NSManagedObjectContext) {
        
        let brandsGrocery = DatabaseHelper.sharedInstance.getEntityWithName(GroceryEntity, entityDbId: grocery.dbID as AnyObject, keyId: "dbID", context: context) as! Grocery
        let brandsCategory = DatabaseHelper.sharedInstance.getEntityWithName(CategoryEntity, entityDbId: category.dbID, keyId: "dbID", context: context) as! Category
        
        //fetch once and search array (for performance reasons)
        var allBrands = DatabaseHelper.sharedInstance.getEntitiesWithName(BrandEntity, sortKey: nil, predicate: nil, ascending: false, caseInsensitiveCompare: false, context: context) as! [Brand]
        
        //remove old grocery brands
        grocery.clearBrands()
        GroceryCategoryBrands.clearBrandsForGrocery(grocery, context: context)
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
        
        //insert new ones
        let responseObjects = (dictionary["data"] as! NSDictionary)["brands"] as! [NSDictionary]
        for brandDict in responseObjects {

            let brand = insertOrUpdateBrandFromDictionary(brandDict, allBrands: &allBrands,  context: context)

            GroceryCategoryBrands.addBrand(grocery, category: brandsCategory, brand: brand, context: context)
            brandsGrocery.addBrand(brand)
        }
        
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
    }
    
    fileprivate class func insertOrUpdateBrandFromDictionary(_ brandDict:NSDictionary, allBrands:inout [Brand], context:NSManagedObjectContext) -> Brand {
        
        //extract from json
        let brandId = brandDict["id"] as! Int
        let brandName = brandDict["name"] as? String
        let brandImage = brandDict["image_url"] as? String
        
        //insert
        //var brand = searchForBrand(allBrands, brandId: NSNumber(brandId))
        var brand = searchForBrand(allBrands, brandId: NSNumber(value:brandId))
        if brand == nil {
            brand = DatabaseHelper.sharedInstance.insertNewObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as? Brand
            allBrands.append(brand!)
        }
        
        brand?.name = brandName
        brand?.imageUrl = brandImage
        
        return brand!
    }
    
    // MARK: Helpers
    
    fileprivate class func searchForBrand(_ brands:[Brand], brandId:NSNumber) -> Brand? {
        
        for brand in brands {
            
            if brand.dbID.intValue == brandId.intValue {
                
                return brand
            }
        }
        
        return nil
    }
}
