//
//  GroceryBrand.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 28/10/2016.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit

class GroceryBrand {
    
    var subCatID:Int = 0
    var brandId:Int = 0
    var name:String = ""
    var nameEn:String = ""
    var imageURL:String = ""
    var logoURL:String = ""
    var productsCount:NSNumber = 0
    var isNextProducts = false
    var products = [Product]()
    
    
    class func getGroceryBrandFromResponse(_ dictionary:[String:AnyObject] , _ subcateID : Int = 0) -> GroceryBrand {
        
        let brand:GroceryBrand = GroceryBrand.init()
        
        brand.subCatID = subcateID
        brand.brandId           = dictionary["id"] as! Int
        brand.imageURL          = (dictionary["image_url"] as? String)!
        //brand.logoURL           = (dictionary["logo_url"] as? String)!
        //brand.productsCount     = (dictionary["products_count"] as? NSNumber)!
        //brand.isNextProducts    =  dictionary["products_is_next"] as! Bool
        brand.name              = (dictionary["name"] as? String)!
        if let brandNameEn = dictionary["slug"] as? String {
            brand.nameEn = brandNameEn
        }


        
        //Parsing All Products Response here
        let responseObjects = dictionary["products"] as! [NSDictionary]
        
        let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
        
        context.performAndWait({ () -> Void in
            
            let newProduct = Product.insertOrReplaceSixProductsFromDictionary(responseObjects as NSArray, context: context)
            brand.products = newProduct
            print("Brands Product Count:%d",brand.products.count)
        })
        
        return brand
    }
    
    class func createGroceryBrandFromDictionary(_ brandDict:NSDictionary) -> GroceryBrand {

        let brand:GroceryBrand = GroceryBrand.init()
        
        brand.brandId = brandDict["id"] as! Int
        
        if let brandName = brandDict["name"] as? String {
            brand.name = brandName
        }
        
        if let brandImage = brandDict["image_url"] as? String {
            brand.imageURL = brandImage
        }
        if let brandNameEn = brandDict["slug"] as? String {
            brand.nameEn = brandNameEn
        }
        
        return brand
    }
    
    /*init(dictionary:[String:AnyObject]) {
     
     brandId           = dictionary["id"] as! Int
     name              = (dictionary["name"] as? String)!
     imageURL          = (dictionary["image_url"] as? String)!
     logoURL           = (dictionary["logo_url"] as? String)!
     productsCount     = (dictionary["products_count"] as? NSNumber)!
     isNextProducts    =  dictionary["products_is_next"] as! Bool
     
     //Parsing All Products Response here
     let responseObjects = dictionary["products"] as! [NSDictionary]
     
     let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
     
     context.performAndWait({ () -> Void in
     
     let newProduct = Product.insertOrReplaceSixProductsFromDictionary(responseObjects as NSArray, context: context)
     self.products = newProduct
     print("Brands Product Count:%d",self.products.count)
     })
     }*/
}
