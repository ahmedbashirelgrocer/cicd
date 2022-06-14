//
//  Category+CRUD.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 07.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData

let CategoryEntity = "Category"

private var addingIndex: UInt = 0

extension Category {
    
    // MARK: Get
    
    class func getAllMajorCategories(_ sortedByName:Bool, context:NSManagedObjectContext) -> [Category] {
        
        let predicate = NSPredicate(format: "isSubcategory == %@", NSNumber(value: false as Bool))
        let sortingKey:String? = sortedByName ? "name" : nil
        
        return DatabaseHelper.sharedInstance.getEntitiesWithName(CategoryEntity, sortKey: sortingKey, predicate: predicate, ascending: true, context: context) as! [Category]
    }
    
    class func getSubcategoriesForCategory(_ category:Category, sortedByName:Bool, context:NSManagedObjectContext) -> [Category] {
        
        let predicate = NSPredicate(format: "parentCategoryId == %@", category.dbID)
        let sortingKey:String? = sortedByName ? "name" : nil

        return DatabaseHelper.sharedInstance.getEntitiesWithName(CategoryEntity, sortKey: sortingKey, predicate: predicate, ascending: true, context: context) as! [Category]
    }
    
    class func getAllCategories (_ grocery : Grocery , context : NSManagedObjectContext) -> [Category] {
        
        
         let predicate = NSPredicate(format: "parentCategoryId == %@", grocery.dbID)
        
        //fetch once and search array (for performance reasons)
        var allCategories = DatabaseHelper.sharedInstance.getEntitiesWithName(CategoryEntity, sortKey: nil, predicate: nil, ascending: false, caseInsensitiveCompare: false, context: context) as! [Category]
        
        return allCategories
        
        
    }
    
    
    class func getSubcategoriesForCategory(_ category:Category, fromGrocerySubcategories subcategories:[Category], sortedByName:Bool, context:NSManagedObjectContext) -> [Category] {
        
        //collect subcategories ids
        var subcategoriesIds = [NSNumber]()
        for item in subcategories {
            subcategoriesIds.append(item.dbID)
        }
        
        //get subcategories
        let predicate = NSPredicate(format: "parentCategoryId == %@ AND (dbID IN %@)", category.dbID, subcategoriesIds)
        let sortingKey:String? = sortedByName ? "name" : nil

        return DatabaseHelper.sharedInstance.getEntitiesWithName(CategoryEntity, sortKey: sortingKey, predicate: predicate, ascending: true, context: context) as! [Category]
    }
    
    // MARK: Insert
    
    class func insertOrUpdateCategoriesFromDictionary(_ dictionary:NSDictionary, parentCategory:Category?, context:NSManagedObjectContext) {

        //fetch once and search array (for performance reasons)
        var allCategories = DatabaseHelper.sharedInstance.getEntitiesWithName(CategoryEntity, sortKey: nil, predicate: nil, ascending: false, caseInsensitiveCompare: false, context: context) as! [Category]
        
        //insert from dictionary
        let categoriesArray = (dictionary["data"] as! NSDictionary)["categories"] as! [NSDictionary]
        
        for categoryDict in categoriesArray {
            
            let category = insertOrUpdateCategoryFromDictionary(categoryDict, allCategories: &allCategories, context: context)
            //AWAIS -- Swift4
           // category.isSubcategory = NSNumber(value: parentCategory != [:] as Bool)
            category.parentCategoryId = NSNumber(value: 0 as Int)
            if parentCategory != nil {
                category.parentCategoryId = parentCategory!.dbID
            }
        }
        
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
    }
    @discardableResult
    class func insertOrUpdateCategoriesForGrocery(_ grocery:Grocery, categoriesArray:[NSDictionary], context:NSManagedObjectContext) -> [Category]? {
        
        //fetch once and search array (for performance reasons)
        var allCategories = DatabaseHelper.sharedInstance.getEntitiesWithName(CategoryEntity, sortKey: nil, predicate: nil, ascending: false, caseInsensitiveCompare: false, context: context) as! [Category]
        
        //remove old grocery categories
        //TODO: check time when we clear the categories or update.
        grocery.clearCategories()
        
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
        var catA : [Category] = []
        //insert new ones
        for categoryDict in categoriesArray {
            let category = insertOrUpdateCategoryFromDictionary(categoryDict, allCategories: &allCategories, context: context)
            category.isSubcategory = NSNumber(value: false as Bool)
            grocery.addCategory(category)
            catA.append(category)
        }
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
        return catA
    }
    
    class func insertOrUpdateSubcategoriesForGroceryCategory(_ grocery:Grocery, parentCategory:Category, categoriesArray:[NSDictionary], context:NSManagedObjectContext) {
        
        //fetch once and search array (for performance reasons)
        var allCategories = DatabaseHelper.sharedInstance.getEntitiesWithName(CategoryEntity, sortKey: nil, predicate: nil, ascending: false, caseInsensitiveCompare: false, context: context) as! [Category]
        
        //remove old grocery subcategories
        grocery.clearSubCategories()
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
        
        //insert new ones
        for subcategoryDict in categoriesArray {
            
            let subcategory = insertOrUpdateCategoryFromDictionary(subcategoryDict, allCategories: &allCategories, context: context)
            subcategory.isSubcategory = NSNumber(value: true as Bool)
            subcategory.parentCategoryId = parentCategory.dbID
            
            grocery.addSubCategory(subcategory)
        }
        
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
    }
    
    fileprivate class func insertOrUpdateCategoryFromDictionary(_ categoryDict:NSDictionary!, allCategories:inout [Category], context:NSManagedObjectContext) -> Category {
        
        /* var category = searchForCategory(allCategories, categoryId: dbID)
        if category == nil {
            
            category = DatabaseHelper.sharedInstance.insertNewObjectForEntityForName(CategoryEntity, entityDbId: dbID, keyId: "dbID", context: context) as? Category
            allCategories.append(category!)
            
            addingIndex += 1
            let sortID = addingIndex
            category?.sortID = sortID 
         }*/
        
        let dbID = categoryDict["id"] as! NSNumber
        let category = DatabaseHelper.sharedInstance.insertNewObjectForEntityForName(CategoryEntity, entityDbId: dbID, keyId: "dbID", context: context) as? Category
        allCategories.append(category!)
        
        addingIndex += 1
        let sortID = addingIndex
        category?.sortID = NSNumber(value:sortID)
        
        
        if let pg18 = categoryDict["pg_18"] as? NSNumber {
            if pg18.boolValue == true {
                category?.isPg18 = pg18
            }
        }
        
        if let categoryName = categoryDict["name"] as? String {
            category?.name = categoryName
        }
        if let slug = categoryDict["slug"] as? String {
            category?.nameEn = slug
        }
        
        if let categoryDescription = categoryDict["description"] as? String {
            category?.desc = categoryDescription
        }
        
        var categoryImageUrl = categoryDict["logo1_url"] as? String
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            categoryImageUrl = categoryDict["image_url"] as? String
        }
        
        if let photuUrl =  categoryDict["photo_url"] as? String {
            categoryImageUrl = photuUrl
        }
        
        category?.imageUrl = categoryImageUrl
        //colored_img_url
        if let colorImgUrl =  categoryDict["colored_img_url"] as? String {
            category?.coloredImageUrl = colorImgUrl
        }
    
        return category!
    }
    
    // MARK: Category Insert Or Update
    class func insertOrUpdateCategoryFromDictionary(_ categoryDict:NSDictionary!, context:NSManagedObjectContext) -> Category? {
        
        let dbID = categoryDict["id"] as! NSNumber
        let category = DatabaseHelper.sharedInstance.insertNewObjectForEntityForName(CategoryEntity, entityDbId: dbID, keyId: "dbID", context: context) as? Category
        
        if let categoryName = categoryDict["name"] as? String {
            category?.name = categoryName
        }
        if let slugName = categoryDict["slug"] as? String {
            category?.nameEn = slugName
        }
        
        if let categoryDescription = categoryDict["description"] as? String {
            category?.desc = categoryDescription
        }
        
        var categoryImageUrl = categoryDict["logo1_url"] as? String
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            categoryImageUrl = categoryDict["image_url"] as? String
        }
        
        if let photuUrl =  categoryDict["photo_url"] as? String {
            categoryImageUrl = photuUrl
        }
        
        
        category?.imageUrl = categoryImageUrl
        
        return category
    }
    
    // MARK: Delete
    
    class func deleteCategoriesNotInJSON(_ jsonCategoriesIds:[Int], parentCategoryId:NSNumber?, context:NSManagedObjectContext) {
        
        var predicate:NSPredicate!
        
        if let id = parentCategoryId {
            
            predicate = NSPredicate(format: "parentCategoryId == %@ AND NOT (dbID IN %@)", id, jsonCategoriesIds)
            
        } else {
            
            predicate = NSPredicate(format: "NOT (dbID IN %@)", jsonCategoriesIds)
        }
        
        let categoriesToDelete = DatabaseHelper.sharedInstance.getEntitiesWithName(CategoryEntity, sortKey: nil, predicate: predicate, ascending: false, context: context)
        for object in categoriesToDelete {
            
            context.delete(object)
        }
    }
    
    // MARK: Brand helper methods
    
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
    
    func removeBrand(_ value: Brand) {
        
        let items = self.mutableSetValue(forKey: "brands")
        items.remove(value)
    }
    
    func clearBrands() {
        
        let items = self.mutableSetValue(forKey: "brands")
        items.removeAllObjects()
    }

    // MARK: Helpers
    
    fileprivate class func searchForCategory(_ categories:[Category], categoryId:NSNumber) -> Category? {
        
        for category in categories {
            
            if category.dbID.intValue == categoryId.intValue {
                
                return category
            }
        }
        
        return nil
    }
    
}
