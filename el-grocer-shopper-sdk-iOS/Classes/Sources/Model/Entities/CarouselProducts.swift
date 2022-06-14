//
//  CarouselProducts.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 05/07/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import Foundation
import CoreData

let CarouselProductsEntity = "CarouselProducts"
class CarouselProducts: NSManagedObject, DBEntity {
    
    @NSManaged var dbID: Int64
    @NSManaged var groceryID: Int64
    @NSManaged var name: String
    @NSManaged var userID: Int64
   
}
extension CarouselProducts {
   
    class func getAllCarouselAddedProducts(_ context:NSManagedObjectContext) -> [CarouselProducts]? {
        return DatabaseHelper.sharedInstance.getEntitiesWithName(CarouselProductsEntity, sortKey: nil, predicate: nil, ascending: false, context: context) as? [CarouselProducts]
    }
    
    // MARK: Create
    @discardableResult class func createOrUpdateCarouselCart(dbID : Int64 , groceryID : Int64 , userID : Int64=0 , name : String , context:NSManagedObjectContext) -> CarouselProducts? {
        
        guard dbID != -1 else {
            return nil
        }
    
        let  cProduct = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(CarouselProductsEntity, entityDbId: dbID as AnyObject , keyId: "dbID", context: context) as! CarouselProducts
        
        cProduct.groceryID = groceryID
        cProduct.name = name
        cProduct.userID = userID
        
        do {
            try context.save()
        } catch let error {
           // debugPrint(error.localizedDescription)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
            return nil
        }
        DatabaseHelper.sharedInstance.saveDatabase()
        return cProduct
        
    }
    
    class func DeleteAll(forDBID : Int64 ,_ context:NSManagedObjectContext) -> Void {
        
        let recipeA =  DatabaseHelper.sharedInstance.getEntitiesWithName(CarouselProductsEntity, sortKey: nil, predicate: nil, ascending: false, context: context) as? [CarouselProducts]
        
        let filterA =   recipeA?.filter() { $0.dbID == forDBID }
        
        guard filterA?.count ?? 0 > 0 else { return }
        
        for object in filterA! {
            context.delete(object)
        }
        
        
        // we save 0 as dbid when user is not logged in
        let notLoginAddedData =   recipeA?.filter() { $0.userID == 0 }
        
        
        if notLoginAddedData?.count ?? 0 > 0 {
            
            for object in notLoginAddedData! {
                context.delete(object)
            }
            
        }
        
        DatabaseHelper.sharedInstance.saveDatabase()
        
        
    }
    
    
    class func GetSpecficUserAddToCartListCarousel(forUserDBID : NSNumber  , _ context:NSManagedObjectContext , completion : ([CarouselProducts]?) ->Void) {
        context.performAndWait {
            let predicate = NSPredicate(format: "userID == %@ OR userID == 0",forUserDBID )
            completion(CarouselProducts.getAllCarouselAddedProductsWithPredicate(context , predicate: predicate))
        }
    }
    
    class func getAllCarouselAddedProductsWithPredicate(_ context:NSManagedObjectContext , predicate : NSPredicate? ) -> [CarouselProducts]? {
        return DatabaseHelper.sharedInstance.getEntitiesWithName(CarouselProductsEntity, sortKey: nil, predicate: predicate , ascending: false, context: context) as? [CarouselProducts]
    }

//    class func GETAddToCartListRecipes(completion : ([RecipeCart]?) ->Void) {
//        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
//        let userProfile = UserProfile.getUserProfile(context)
//        context.performAndWait {
//            let predicate = NSPredicate(format: "dbID == %@", userProfile?.dbID ?? "")
//            completion(RecipeCart.getFilteredRecipeCart(context, predicate: predicate))
//        }
//    }
    
}
