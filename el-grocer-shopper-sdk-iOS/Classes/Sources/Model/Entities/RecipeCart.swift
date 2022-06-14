//
//  RecipeCart.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 27/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import Foundation
import CoreData

class RecipeCart: NSManagedObject, DBEntity {
    
    @NSManaged var retailerID: Int64
    @NSManaged var recipeID: Int64
    @NSManaged var dbID: Int64
    @NSManaged var ingredients: [NSNumber]
    @NSManaged var recipeName: String

}

let RecipeCartEntity = "RecipeCart"

extension RecipeCart {
    
    // MARK: Get
    
   
    class func getFilteredRecipeCart(_ context:NSManagedObjectContext , predicate : NSPredicate?) -> [RecipeCart]? {
        return DatabaseHelper.sharedInstance.getEntitiesWithName(RecipeCartEntity, sortKey: nil, predicate: predicate , ascending: false, context: context) as? [RecipeCart]
    }
    
    class func getAllRecipeCart(_ context:NSManagedObjectContext) -> [RecipeCart]? {
        return DatabaseHelper.sharedInstance.getEntitiesWithName(RecipeCartEntity, sortKey: nil, predicate: nil, ascending: false, context: context) as? [RecipeCart]
    }
    
    // MARK: Create
    class func createOrUpdateRecipeCart(dbID : Int64 , retailerID : Int64 , recipeID : Int64 , ingredients : [NSNumber]? , recipeName : String , context:NSManagedObjectContext) -> RecipeCart? {
        
        let recipeCart = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(RecipeCartEntity, entityDbId: recipeID as AnyObject, keyId: "recipeID", context: context) as! RecipeCart
        recipeCart.retailerID = retailerID
        recipeCart.recipeID = recipeID
        recipeCart.dbID = dbID
        recipeCart.recipeName = recipeName
        
        if let ingredientA = ingredients {
            recipeCart.ingredients = ingredientA
        }

        do {
            try context.save()
        } catch let error {
            debugPrint(error.localizedDescription)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
            return nil
        }
        DatabaseHelper.sharedInstance.saveDatabase()
        return recipeCart
    }

    class func DeleteAll(forDBID : Int64  ,_ context:NSManagedObjectContext) -> Void {

        let recipeA =  DatabaseHelper.sharedInstance.getEntitiesWithName(RecipeCartEntity, sortKey: nil, predicate: nil, ascending: false, context: context) as? [RecipeCart]

        let filterA =   recipeA?.filter() { $0.dbID == forDBID }

        guard filterA?.count ?? 0 > 0 else { return }

        for object in filterA! {
            context.delete(object)
        }


        // we save 0 as dbid when user is not logged in
        let notLoginAddedData =   recipeA?.filter() { $0.dbID == 0 }


        if notLoginAddedData?.count ?? 0 > 0 {

            for object in notLoginAddedData! {
                context.delete(object)
            }

        }

        DatabaseHelper.sharedInstance.saveDatabase()


    }
    
    
    
    class func GETAddToCartListRecipes(completion : ([RecipeCart]?) ->Void) {
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        let userProfile = UserProfile.getUserProfile(context)
        context.performAndWait {
            let predicate = NSPredicate(format: "dbID == %@", userProfile?.dbID ?? "")
            completion(RecipeCart.getFilteredRecipeCart(context, predicate: predicate))
        }
    }
    
    
    
    class func GETSpecficUserAddToCartListRecipes(forDBID : NSNumber  , _ context:NSManagedObjectContext , completion : ([RecipeCart]?) ->Void) {
        context.performAndWait {
            let predicate = NSPredicate(format: "dbID == %@ OR dbID == 0",forDBID )
            completion(RecipeCart.getFilteredRecipeCart(context, predicate: predicate))
        }
    }

}
