//
//  Product+CRUD.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 08.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import CoreData
import UIKit

let ProductEntity = "Product"

extension Product {
    
    // MARK: Get
    
    class func getProductsCountForBrand(_ brand:Brand, context:NSManagedObjectContext) -> Int {
        
        let predicate = NSPredicate(format: "brandId == %@ AND isArchive == %@", brand.dbID, NSNumber(value: false as Bool))

        return DatabaseHelper.sharedInstance.getEntitiesWithName(ProductEntity, sortKey: nil, predicate: predicate, ascending: false, context: context).count
    }
    
    class func getProducts(forBrand brand:Brand, andForSubcategory category:Category, andForGrocery grocery:Grocery?, context:NSManagedObjectContext) -> [Product] {
        
        var predicate:NSPredicate!
        
        if grocery == nil {
            
            predicate = NSPredicate(format: "brandId == %@ AND subcategoryId == %@ AND isArchive == %@", brand.dbID, category.dbID, NSNumber(value: false as Bool))
            
        } else {
            
           predicate =  NSPredicate(format: "brandId == %@ AND subcategoryId == %@ AND groceryId == %@ AND isArchive == %@", brand.dbID, category.dbID,  grocery!.dbID, NSNumber(value: false as Bool))
        }
        
        return DatabaseHelper.sharedInstance.getEntitiesWithName(ProductEntity, sortKey: "name", predicate: predicate, ascending: true, context: context) as! [Product]
    }
    
    class func getAllFavouritesProducts(_ sortedByName:Bool, context:NSManagedObjectContext) -> [Product] {
        
        let predicate = NSPredicate(format: "isFavourite == %@ AND isArchive == %@", NSNumber(value: true as Bool), NSNumber(value: false as Bool))
        let sortingKey:String? = sortedByName ? "name" : nil

        let products = DatabaseHelper.sharedInstance.getEntitiesWithName(ProductEntity, sortKey: sortingKey, predicate: predicate, ascending: true, context: context) as! [Product]
        
        //this is poor algorithm
        var unique = [Product]()
       /* for product in products {
            
            var isAlreadyAdded = false
            
            for uniqueProduct in unique {
                
                if uniqueProduct.productId.integerValue == product.productId.integerValue {
                    
                    isAlreadyAdded = true
                    break
                }
            }
            
            if !isAlreadyAdded {
                
                unique.append(product)
            }
        }*/
        
        for product in products {
            
            let uniqueProductId = "\(0)_\(product.productId)"
            if product.dbID == uniqueProductId {
                unique.append(product)
            }
        }
        
        return unique
    }
    
    
    class func markSimilarProductsAsFavourite(_ product:Product, markAsFavourite:Bool, context:NSManagedObjectContext) {
        
        let predicate = NSPredicate(format: "productId == %@", product.productId)

        let products = DatabaseHelper.sharedInstance.getEntitiesWithName(ProductEntity, sortKey: nil, predicate: predicate, ascending: false, context: context) as! [Product]
        
        for product in products {
            product.isFavourite = NSNumber(value: markAsFavourite as Bool)
        }
    }
    
    // MARK: Insert
    
    class func insertOrReplaceFavouriteProducts(_ dictionary:NSDictionary, context:NSManagedObjectContext) {
        
        let responseObjects = (dictionary["data"] as! NSDictionary)["products"] as! [NSDictionary]
        for productDict in responseObjects {
            
            let product = Product.createProductFromDictionary(productDict, context: context)
            product.isFavourite = NSNumber(value: true as Bool)

            if let brandDict = productDict["brand"] as? NSDictionary {
                
                let brandId = brandDict["id"] as! Int
                let brandName = brandDict["name"] as? String
                let brandImage = brandDict["image_url"] as? String
                let brandSlugName = brandDict["slug"] as? String
                let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
               
                brand.name = brandName
                brand.imageUrl = brandImage
                brand.nameEn = brandSlugName
                product.brandId = brand.dbID
                product.brandName = brandName
                product.brandNameEn = brand.nameEn
                product.brandImageUrl = brandImage
            }
        }
        
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
    }
    
    class func insertOrReplaceAllProductsFromDictionary(_ dictionary:NSDictionary, context:NSManagedObjectContext) -> (products: [Product], algoliaCount: Int) {
        
        var resultProducts = [Product]()
        var algoliaProductCount: Int = 0
        //Parsing All Products Response here
            //sab
//            if let  productDict = dataDict["products"] as? NSDictionary {
//                if let responseObjects = productDict["products"] as? [NSDictionary] {
            if let  responseObjects = dictionary["data"] as? [NSDictionary] {
               // if let responseObjects = productDict as? [NSDictionary] {
                for responseDict in responseObjects {
                    let product = Product.createProductFromDictionary(responseDict, context: context)
                    //insert brand
                    if let brandDict = responseDict["brand"] as? NSDictionary {
                        let brandId = brandDict["id"] as! Int
                        let brandName = brandDict["name"] as? String
                        let brandImage = brandDict["image_url"] as? String
                        let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
                        brand.name = brandName
                        brand.imageUrl = brandImage
                        product.brandId = brand.dbID
                        product.brandName = brandName
                        let brandSlugName = brandDict["slug"] as? String
                        brand.nameEn = brandSlugName
                        product.brandNameEn = brand.nameEn
                        product.brandImageUrl = brandImage
                    }else {
                        
                        product.brandId = nil
                    }
                    
                    //set subcategory id
                    if let categories = responseDict["categories"] as? [NSDictionary] {
                        if let subcategory = categories.first?["children"] as? [NSDictionary] {
                            product.subcategoryId = subcategory.first?["id"] as! NSNumber
                        }
                    }
                    
                    //add product to the list
                    if(product.isPublished.boolValue == true ){
                        resultProducts.append(product)
                    }
                    
                    
                }
               // }
            }else  if let responseObjects = dictionary["data"] as? [NSDictionary] {//dataDict["products"] as? [NSDictionary] {
                for responseDict in responseObjects {
                    
                    let product = Product.createProductFromDictionary(responseDict, context: context)
                    
                    //insert brand
                    if let brandDict = responseDict["brand"] as? NSDictionary {
                        
                        let brandId = brandDict["id"] as! Int
                        let brandName = brandDict["name"] as? String
                        
                        let brandImage = brandDict["image_url"] as? String
                        
                        let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
                        brand.name = brandName
                        brand.imageUrl = brandImage
                        product.brandId = brand.dbID
                        product.brandName = brandName
                        let brandSlugName = brandDict["slug"] as? String
                        brand.nameEn = brandSlugName
                        product.brandNameEn = brand.nameEn
                        product.brandImageUrl = brandImage
                    }else {
                        
                        product.brandId = nil
                    }
                    
                    //set subcategory id
                    if let categories = responseDict["categories"] as? [NSDictionary] {
                        if let subcategory = categories.first?["children"] as? [NSDictionary] {
                            product.subcategoryId = subcategory.first?["id"] as! NSNumber
                        }
                    }

                    if(product.isPublished.boolValue == true && product.isAvailable.boolValue == true){
                        resultProducts.append(product)
                    }
                }
            } else  if let _ = dictionary["hits"] as? [NSDictionary] {//dataDict["products"] as? [NSDictionary] {
                
                let products = Product.insertOrReplaceProductsFromDictionary(dictionary, context: context)
                algoliaProductCount = products.algoliaCount ?? 0
                for product in products.products {
                    if(product.isPublished.boolValue == true && product.isAvailable.boolValue == true){
                        resultProducts.append(product)
                    }
                }
                
                
               /*    for responseDict in responseObjects {
                    
                    let product = Product.insertOrReplaceProductsFromDictionary(responseDict, context: context)
                    
                        //insert brand
                    if let brandDict = responseDict["brand"] as? NSDictionary {
                        
                        let brandId = brandDict["id"] as! Int
                        let brandName = brandDict["name"] as? String
                        
                        let brandImage = brandDict["image_url"] as? String
                        
                        let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
                        brand.name = brandName
                        brand.imageUrl = brandImage
                        product.brandId = brand.dbID
                        product.brandName = brandName
                        let brandSlugName = brandDict["slug"] as? String
                        brand.nameEn = brandSlugName
                        product.brandNameEn = brand.nameEn
                    }else {
                        
                        product.brandId = nil
                    }
                    
                        //set subcategory id
                    if let categories = responseDict["categories"] as? [NSDictionary] {
                        if let subcategory = categories.first?["children"] as? [NSDictionary] {
                            product.subcategoryId = subcategory.first?["id"] as! NSNumber
                        }
                    }
                    
                    if(product.isPublished.boolValue == true && product.isAvailable.boolValue == true){
                        resultProducts.append(product)
                    }
                }*/
            }

        try? context.save()
        return (resultProducts, algoliaProductCount)
        
    }

    class func insertOrReplaceCarouselFromDictionary(_ dictionary:NSDictionary, context:NSManagedObjectContext) -> [Product] {

        var resultProducts = [Product]()

        //Parsing All Products Response here
//        if let dataDict = dictionary["data"] as? NSDictionary {
            if let responseObjects = dictionary["data"] as? [NSDictionary] {
                for responseDict in responseObjects {

                    let product = Product.createProductFromDictionary(responseDict, context: context)

                    //insert brand
                    if let brandDict = responseDict["brand"] as? NSDictionary {

                        let brandId = brandDict["id"] as! Int
                        let brandName = brandDict["name"] as? String
                        let brandImage = brandDict["image_url"] as? String

                        let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
                        brand.name = brandName
                        brand.imageUrl = brandImage
                        product.brandId = brand.dbID
                        product.brandName = brandName
                        product.brandImageUrl = brandImage
                        let brandSlugName = brandDict["slug"] as? String
                        brand.nameEn = brandSlugName
                        product.brandNameEn = brand.nameEn

                    }else {

                        product.brandId = nil
                    }

                    //set subcategory id
                    if let categories = responseDict["categories"] as? [NSDictionary] {
                        if let subcategory = categories.first?["children"] as? [NSDictionary] {
                            product.subcategoryId = subcategory.first?["id"] as! NSNumber
                        }
                    }

                    //add product to the list
                    if(product.isPublished.boolValue == true && product.brandId != nil){
                        resultProducts.append(product)
                    }
                }

               //elDebugPrint("Result Products Array Count %@ Before Filtering Brand ID",resultProducts.count)

                for product in resultProducts {

                    if product.brandId == nil {
                        let removedObjectIndex = resultProducts.firstIndex(of: product)!
                       //elDebugPrint("Object Remove Index:%@",removedObjectIndex)
                        resultProducts.remove(at: removedObjectIndex)
                    }
                }
              // elDebugPrint("Result Products Array Count is %@ After Filtering Brand ID",resultProducts.count)


                do {
                    try context.save()
                } catch (let error) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
                }
            }
//        }



        return resultProducts
    }

    
    // MARK: Insert Products
    
    class func insertOrReplaceSixProductsFromDictionary(_ brandsArray:NSArray, context:NSManagedObjectContext) -> [Product] {
        
        var resultProducts = [Product]()
        
        for responseDict in brandsArray {
            
            let product = Product.createProductFromDictionary(responseDict as! NSDictionary, context: context)
            let respone = responseDict as? [String:Any]
            //insert brand
            if let brandDict = respone!["brand"] as? NSDictionary {
                
                let brandId = brandDict["id"] as! Int
                let brandName = brandDict["name"] as? String
                let brandSlugName = brandDict["slug"] as? String
                let brandImage = brandDict["image_url"] as? String
                
                let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
                brand.name = brandName
                brand.nameEn = brandSlugName
                brand.imageUrl = brandImage
                product.brandImageUrl = brandImage
                product.brandId = brand.dbID
                product.brandName = brand.name
                product.brandNameEn = brand.nameEn

                
            } else {
                product.brandId = nil
            }
       
            if(product.isPublished.boolValue == true && product.brandId != nil){
                //add product to the list
                resultProducts.append(product)
            }
        }
        
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
            elDebugPrint(error.localizedDescription)
        }
        
        return resultProducts
    }
    
    /// Used for products from elastic_search
    class func insertOrReplaceProductsFromDictionary(_ dictionary:NSDictionary, context:NSManagedObjectContext, searchString : String? = "" ,  _ currentProduct : Product? = nil, _ onlyCurrentStoreProducts : Bool = true) -> (products: [Product], algoliaCount: Int?) {
        
        var resultProducts = [Product]()
        var algoliaProductsCount: Int = 0
        var queryID = ""
        if let isQueryID = dictionary["queryID"] as? String {
            queryID = isQueryID
        }
        if let algoliaObj = dictionary["hits"] as? [NSDictionary] {
            
            algoliaProductsCount = algoliaObj.count
            for productDict in algoliaObj {
                
                if let productID = productDict["id"] as? Int , productID ==  currentProduct?.getCleanProductId() {
                        continue;
                }
                
                if onlyCurrentStoreProducts {
                    
                    if let shopsA = productDict["shops"] as? [NSDictionary] {
                        let finalData =  shopsA.filter { (dict) -> Bool in
                            let dbid : String = ElGrocerUtility.sharedInstance.cleanGroceryID(ElGrocerUtility.sharedInstance.activeGrocery?.dbID)
                            return "\(String(describing: dict["retailer_id"] ?? 0))" == dbid
                        }
                        if finalData.count == 0 {
                            if let promotionA = productDict["promotional_shops"] as? [NSDictionary]{
                                let promotionalShopFinalData =  promotionA.filter { (dict) -> Bool in
                                    let dbid : String = ElGrocerUtility.sharedInstance.cleanGroceryID(ElGrocerUtility.sharedInstance.activeGrocery?.dbID)
                                    return "\(String(describing: dict["retailer_id"] ?? 0))" == dbid
                                }
                                if promotionalShopFinalData.count == 0 {
                                    if UIApplication.topViewController() is UniversalSearchViewController {
                                        if (UIApplication.topViewController() as! UniversalSearchViewController).searchFor == .isForStoreSearch {
                                            continue
                                        }
                                    }
                                }
                                
                            }
                        }
                    }

                }
                
    
              //  let productDict = responseDict["_source"] as! NSDictionary
                var is_P = false
                let product = Product.createProductForSearchFromDictionary(productDict, context: context,searchString: searchString, queryID)
               
                if let shopsA = productDict["shops"] as? [NSDictionary]{
                    let finalData =  shopsA.filter { (dict) -> Bool in
                        let dbid : String = ElGrocerUtility.sharedInstance.cleanGroceryID(ElGrocerUtility.sharedInstance.activeGrocery?.dbID)
                        return "\(String(describing: dict["retailer_id"] ?? 0))" == dbid
                    }
                    if finalData.count > 0 {
                        let promotion = finalData[0]
                        
                        if let availableQuantity = promotion["available_quantity"] as? NSNumber {
                            product.availableQuantity = availableQuantity
                        } else {
                            product.availableQuantity = NSNumber(-1)
                        }
                        
                        if let promotion_only = promotion["promotion_only"] as? NSNumber{
                            product.promotionOnly = promotion_only
                        }else{
                            product.promotionOnly = false
                        }
                        
                        if let isP = promotion["is_p"] as? Bool {
                            if isP {
                                is_P = true
                            }
                        }
                    }else{
                        product.promotionOnly = false
                       
                    }
                    
                }else{
                    product.promotionOnly = false
                }
                
                
                if let promotionA = productDict["promotional_shops"] as? [NSDictionary]{
                    let finalData =  promotionA.filter { (dict) -> Bool in
                         let dbid : String = ElGrocerUtility.sharedInstance.cleanGroceryID(ElGrocerUtility.sharedInstance.activeGrocery?.dbID)
                            return "\(String(describing: dict["retailer_id"] ?? 0))" == dbid
                    }
                    if finalData.count > 0 {
                        
                        
                        for promotion in finalData {
                            if let startTime = promotion["start_time"] as? NSNumber , let endTime = promotion["end_time"] as? NSNumber  {
                                let currentSlot = ElGrocerUtility.sharedInstance.getCurrentMillis()
                                if  currentSlot > startTime.int64Value  &&  currentSlot < endTime.int64Value {
                                    if let standard_price = promotion["standard_price"] as? NSNumber{
                                        if product.promotionOnly.boolValue || is_P {
                                            product.price = standard_price
                                        }
                                    }
                                    product.promotion = 1
                                    
                                    if let startTime = promotion["start_time"] as? NSNumber   {
                                        
                                        let epochTime = TimeInterval(startTime.doubleValue) / 1000
                                        let date = Date(timeIntervalSince1970: epochTime)
                                        product.promoStartTime =  date
                                    }else{
                                        product.promoStartTime = nil
                                    }
                                    
                                    if let endTime = promotion["end_time"] as? NSNumber {
                                        let epochTime = TimeInterval(endTime.doubleValue) / 1000
                                        let date = Date(timeIntervalSince1970: epochTime)
                                        product.promoEndTime =  date
                                    }else{
                                        product.promoEndTime = nil
                                    }
                                    
                                    if let promoPrice = promotion["price"] as? NSNumber{
                                        product.promoPrice = promoPrice
                                    }else{
                                        product.promoPrice = NSNumber(0)
                                    }
                                    
                                    
                                    
                                    if let productLimit = promotion["product_limit"] as? NSNumber{
                                        product.promoProductLimit =  productLimit
                                    }else{
                                        product.promoProductLimit = NSNumber(0)
                                        
                                    }
                                    
                                    break;
                                }
                               
                            }
                        
                        }
                
                    }else{
                        product.promotion = 0
                    }
                }else{
                    
                    product.promotion = 0
                }
                
                if product.promotionOnly.boolValue && product.promotion == 0 {
                    context.delete(product)
                    continue
                }
              
                
                //insert brand
                if let brandDict = productDict["brand"] as? NSDictionary {
                    
                    
                    var brandName = ""
                    var brandNameEn = ""
                    let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
                    if currentLang == "ar" {
                        if let arabicBrandName = brandDict["name_ar"] as? String {
                            brandName = arabicBrandName
                            brandNameEn = brandDict["name"] as? String ?? ""
                        } else {
                            brandName = (brandDict["name"] as? String)!
                            brandNameEn = brandName
                        }
                    }else{
                        brandName =  brandDict["name"] as? String ?? ""
                        brandNameEn = brandName
                    }
                    
                    if let brandId = brandDict["id"] as? Int {
                     
                        let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
                        // brand.name = brandName != nil ? brandName! : ""
                        brand.name = brandName
                        product.brandId = brand.dbID
                        product.brandName = brandName
                        brand.imageUrl = brandDict["image_url"] as? String ?? ""
                        
                        var brandSlugName = brandDict["slug"] as? String ?? ""
                        brandSlugName = brandSlugName.isEmpty ? brandNameEn : brandSlugName
                        brand.nameEn = brandSlugName
                        product.brandNameEn = brand.nameEn
                        product.brandImageUrl = brand.imageUrl
                      
                    }
         

                } else {
                    
                    product.brandId = -100
                }
        
                if(product.isPublished.boolValue == true && product.brandId != nil && product.availableQuantity != 0 ){
                    //add product to the list
                    resultProducts.append(product)
                }else {
                    elDebugPrint("printing append product")
                }
            }
            
        } else if  let responseObjects = dictionary["data"] as? [NSDictionary] {
            for responseDict in responseObjects {
                
                let productDict = responseDict
                
                
                let product = Product.createProductForSearchFromDictionary(productDict, context: context)

              //  let product = Product.createProductFromDictionary(productDict, context: context)
                
                //insert brand
                if let brandDict = productDict["brand"] as? NSDictionary {
                    
                    let brandId = brandDict["id"] as! Int
                    
                    var brandName = ""
                    let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
                    if currentLang == "ar" {
                        if let arabicBrandName = brandDict["name_ar"] as? String {
                            brandName = arabicBrandName
                        } else {
                            brandName = (brandDict["name"] as? String)!
                        }
                    }else{
                        brandName = (brandDict["name"] as? String)!
                    }


                    
                    let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
                    // brand.name = brandName != nil ? brandName! : ""
                    brand.name = brandName
                    brand.nameEn = brandDict["name"] as? String
                    product.brandId = brand.dbID
                    product.brandName = brandName
                    product.brandNameEn = brandDict["name"] as? String
                    product.brandImageUrl = brandDict["image_url"] as? String
                } else {
                    
                    product.brandId = nil
                }
                
                if(product.isPublished.boolValue == true && product.brandId != nil){
                    //add product to the list
                    resultProducts.append(product)
                }
            }
            
        }
   
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
        
        return (resultProducts, algoliaProductsCount)
    }
    
    class func createProductForSearchFromDictionary(_ productDict:NSDictionary, context:NSManagedObjectContext, searchString : String? = "" , _ queryID : String = "") -> Product {
        
        let productID = productDict["id"] as! Int
        
        var shopsDict : NSDictionary? = nil
        var groceryID = ""
        var shopIdsA = [NSNumber]()
        
        if let retailerIntId = productDict["retailer_id"] as? Int {
            groceryID = "\(retailerIntId)"
        }else if let retailerStringId = productDict["retailer_id"] as? String {
            groceryID = retailerStringId
        }else if let shopsA = productDict["shops"] as? [NSDictionary] {
            for shop in shopsA {
                if let reID = shop["retailer_id"] as? NSNumber {
                    shopIdsA.append(reID)
                }
            }
            let finalData =  shopsA.filter { (dict) -> Bool in
                if let dbid : String = ElGrocerUtility.sharedInstance.cleanGroceryID(ElGrocerUtility.sharedInstance.activeGrocery?.dbID) as? String {
                    return "\(String(describing: dict["retailer_id"] ?? 0))" == dbid
                }
                return false
            }
            if finalData.count > 0 {
                let data = finalData[0]
                groceryID = "\(String(describing: data["retailer_id"] ?? 0))"
                shopsDict = data
            }
        }else {
            groceryID = "0"
        }
        
        if shopIdsA.isEmpty {
            if let shopsA = productDict["promotional_shops"] as? [NSDictionary] {
                for shop in shopsA {
                    if let reID = shop["retailer_id"] as? NSNumber {
                        shopIdsA.append(reID)
                    }
                }
                let finalData =  shopsA.filter { (dict) -> Bool in
                     let dbid : String = ElGrocerUtility.sharedInstance.cleanGroceryID(ElGrocerUtility.sharedInstance.activeGrocery?.dbID)
                        return "\(String(describing: dict["retailer_id"] ?? 0))" == dbid
                }
                if finalData.count > 0 {
                    let data = finalData[0]
                    groceryID = "\(String(describing: data["retailer_id"] ?? 0))"
                    shopsDict = data
                }
            }
            
        }
        
         

        let uniqueProductId = "\(groceryID)_\(productID)"
        let product = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(ProductEntity, entityDbId: uniqueProductId as AnyObject, keyId: "dbID", context: context) as! Product
        
        product.shopIds = shopIdsA
        if let shopsList = productDict["shops"] as? [NSDictionary] {
            product.shops = product.jsonToString(json: shopsList as AnyObject)
        }
        
        if let shopsList = productDict["promotional_shops"] as? [NSDictionary] {
            product.promotionalShops = product.jsonToString(json: shopsList as AnyObject)
        }
        
        if let objectID = productDict["objectID"] as? String {
            product.objectId = objectID
        }
 
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            if let arabicProductName = productDict["name_ar"] as? String {
                product.name = arabicProductName
            } else {
                product.name = productDict["name"] as? String
            }
        }else{
            product.name = productDict["name"] as? String
        }
        product.nameEn = productDict["name"] as? String
        
        if currentLang == "ar" {
            if let arabicProductDescription = productDict["size_unit_ar"] as? String {
                product.descr = arabicProductDescription
            } else {
                product.descr = productDict["size_unit"] as? String
            }
        }else{
            product.descr = productDict["size_unit"] as? String
        }
    
        if let urlstr = productDict["photo_url"] as? String {
              product.imageUrl = urlstr
        }else{
              product.imageUrl = productDict["image_url"] as? String
        }
       
        product.groceryId = groceryID
        product.productId = NSNumber(value:productID)
        
        if let priceDict = productDict["price"] as? NSNumber {
            
            product.price = priceDict
            product.currency =  CurrencyManager.getCurrentCurrency()
            
        }else if let priceDict = productDict["full_price"] as? NSNumber {
            
            product.price = priceDict
            product.currency =  CurrencyManager.getCurrentCurrency()
            
        }else if let priceDict = shopsDict {
           
            product.currency =  CurrencyManager.getCurrentCurrency()
            product.price = priceDict["price"] as? NSNumber ?? NSNumber(value: 0 as Int)
            
        } else {
            
            product.currency = ""
            product.price = NSNumber(value: 0 as Int)
        }
        if let currency = productDict["price_currency"] as? String{
            product.currency = currency
        }
        
        if let isProductAvailable = productDict["is_available"] as? NSNumber {
            product.isAvailable = isProductAvailable
        }else{
            product.isAvailable = 1
        }
        
        if let isProductPublished = productDict["is_published"] as? NSNumber {
            product.isPublished = isProductPublished
        }else{
            product.isPublished = 1
        }
        
        if let promotion = productDict["promotion"] as? NSDictionary {
            product.promotion = 1
            if let promoPrice = promotion["price"] as? Double{
                product.promoPrice = NSNumber(value: promoPrice)
               elDebugPrint("product.promoprice: \(product.promoPrice) , promoPrice : \(promoPrice) , final price  :\(0)")
            }else{
                product.promoPrice = NSNumber(0)
            }

            if let startTime = promotion["start_time"] as? Date{
                product.promoStartTime =  startTime
            }else{
                product.promoStartTime = nil
            }

            if let endTime = promotion["end_time"] as? Date{
                product.promoEndTime =  endTime
            }else{
                product.promoEndTime = nil
            }

            if let productLimit = promotion["product_limit"] as? NSNumber{
                product.promoProductLimit =  productLimit
            }else{
                product.promoProductLimit = NSNumber(0)

            }
        }else{
            product.promotion = 0
        }
        
        if let isPromotion = productDict["is_promotion"] as? NSNumber {
            product.isPromotion = isPromotion
        }else if let priceDict = shopsDict {
            if let isPromotion = priceDict["is_p"] as? NSNumber {
                product.isPromotion = isPromotion
            }else{
                product.isPromotion = 0
            }
        }else if let isPromotion = productDict["is_p"] as? NSNumber {
            product.isPromotion = isPromotion
        }else{
            product.isPromotion = 0
        }
        
        /*
        if let isSponsored = productDict["is_sponsored"] as? NSNumber {
            product.isSponsored = isSponsored
        }else{
            product.isSponsored =  0  //product.isSponsored != nil ?  product.isSponsored :
        }*/
        
        
         product.isSponsored = false
        if let _rankingInfo = productDict["_rankingInfo"] as? NSDictionary {
           // elDebugPrint("_rankingInfo : \(String(describing: _rankingInfo["promoted"]))")
            if let promoted = _rankingInfo["promoted"] as? Bool {
                if promoted {
                    product.isSponsored = NSNumber(booleanLiteral: promoted)
                }
                if let promotedByReRanking = _rankingInfo["promotedByReRanking"] as? Bool {
                    if promotedByReRanking {
                        product.isSponsored = NSNumber(booleanLiteral: false)
                    }
                }
            }
        }
        
        
        
       /*
        var searchKeyWord = searchString ?? ""
        if !(searchKeyWord.isEmpty) {
            if var sponsoredkeywords = productDict["sponsored_keywords"] as? String {
                sponsoredkeywords = sponsoredkeywords.replacingOccurrences(of: "،", with: ",")
                let array = sponsoredkeywords.split(separator: ",");
                let result = array.contains(where: searchKeyWord.lowercased().contains)
                if result {
                     product.isSponsored = result as NSNumber
                }
            }
        } else if let topController = UIApplication.topViewController() {
            if topController is SearchViewController || topController is ShoppingListViewController   {
                if let searchController = topController as? SearchViewController {
                         searchKeyWord = searchController.searchTextField.text ?? ""
                    if var sponsoredkeywords = productDict["sponsored_keywords"] as? String {
                        sponsoredkeywords = sponsoredkeywords.replacingOccurrences(of: "،", with: ",")
                        let array = sponsoredkeywords.split(separator: ",");
                        let result = array.contains(where: searchKeyWord.lowercased().contains)
                        if result {
                            product.isSponsored = result as NSNumber
                        }
                    }
                }else if let _ = topController as? ShoppingListViewController {
                    if var sponsoredkeywords = productDict["sponsored_keywords"] as? String {
                        sponsoredkeywords = sponsoredkeywords.replacingOccurrences(of: "،", with: ",")
                        let array = sponsoredkeywords.split(separator: ",");
                        let result = array.contains(where: searchKeyWord.lowercased().contains)
                        if result {
                            product.isSponsored = result as NSNumber
                        }
                    }
                }
            }
        }*/
        
        
        
        
        
        if let subCatDictA = productDict["subcategories"] as? [NSDictionary] {
            if subCatDictA.count > 0 {
                if let subCatDict = subCatDictA.first {
                    product.subcategoryId = subCatDict["id"] as? NSNumber ?? -1
                    product.subcategoryName = subCatDict["name_ar"] as? String
                    product.subcategoryNameEn = subCatDict["name"] as? String
                   
                }
                
            }
        }else if let subcategoryID = productDict["subcategory_id"] as? NSNumber {
            product.subcategoryId = subcategoryID
        } else {
            product.subcategoryId = -1
        }
        
        if let categories = productDict["categories"] as? [NSDictionary] {
            
            if let subcategory = categories.first?["children"] as? NSDictionary {
                product.subcategoryName = subcategory["name_ar"] as? String
                product.subcategoryNameEn = subcategory["name"] as? String
                product.subcategoryId = subcategory["id"] as! NSNumber
            }
            if let category = categories.first {
                product.categoryName = category["name"] as? String
                product.categoryNameEn = category["name"] as? String
                product.categoryId = category["id"] as? NSNumber
            }
        }
        
        product.availableQuantity = -1
        product.queryID = queryID
  
        return product
    }
    
    // Used for products in brand details (for both flows)
    class func insertOrReplaceProductsFromDictionary(_ dictionary:NSDictionary, forBrand brand:Brand, forSubcategory subcategory:Category, context:NSManagedObjectContext) -> [Product] {
    
        var resultProducts = [Product]()
        var jsonProductsIds = [String]()
        
      // elDebugPrint("Response Dict:%@",dictionary)
        
        let dataDict = dictionary["data"] as! NSDictionary
        let productDict = dataDict["products"] as! NSDictionary
        
        let responseObjects = productDict["products"] as! [NSDictionary]

        for productDict in responseObjects {
            
            let product = Product.createProductFromDictionary(productDict, context: context)
            product.brandId = brand.dbID
            
            //set subcategory id
            if let categories = productDict["categories"] as? [NSDictionary] {
                
                if let subcategory = categories.first?["children"] as? NSDictionary {
                    
                    product.subcategoryId = subcategory["id"] as! NSNumber
                }
            }
            
            //if category was not in response, save from parameter passed to method
            if product.subcategoryId == 0 {
                
                product.subcategoryId = subcategory.dbID
            }
            
            jsonProductsIds.append(product.dbID)
            
            //add product to the list
            resultProducts.append(product)
        }
        
        deleteProductsNotInJSON(jsonProductsIds, forBrand:brand, forSubcategory:subcategory, context: context)
        
        do {
            try context.save()
        } catch (let error) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
        }
        
        return resultProducts
    }

    class func createProductFromDictionary(_ productDict:NSDictionary, context:NSManagedObjectContext , _ createdData : Date? = nil , _ updateDate : Date? = nil) -> Product {
        
        
        let productID = productDict["id"] as! Int
        
        var groceryID = ""
        
        if let retailerIntId = productDict["retailer_id"] as? Int {
            groceryID = "\(retailerIntId)"
        }else if let retailerStringId = productDict["retailer_id"] as? String {
            groceryID = retailerStringId
        }else{
            groceryID = "0"
        }
        
        let uniqueProductId = "\(groceryID)_\(productID)"
        
        let product = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(ProductEntity, entityDbId: uniqueProductId as AnyObject, keyId: "dbID", context: context) as! Product
        
        if let shopsList = productDict["shops"] as? [NSDictionary] {
            product.shops = product.jsonToString(json: shopsList as AnyObject)
        }
        if let shopsList = productDict["promotional_shops"] as? [NSDictionary] {
            product.promotionalShops = product.jsonToString(json: shopsList as AnyObject)
        }

        product.createdAt = createdData //!= nil ? createdData : Date()
        product.updatedAt = updateDate  // != nil ? updateDate : Date()
        
        product.name = productDict["name"] as? String
        product.descr = productDict["size_unit"] as? String
        product.imageUrl = productDict["image_url"] as? String
        
        if let slugName = productDict["slug"] as? String {
              product.nameEn = slugName
        }
      
        product.groceryId = groceryID
        product.productId = NSNumber(value:productID)
        
        if let isProductAvailable = productDict["is_available"] as? NSNumber {
            product.isAvailable = isProductAvailable
        } else {
            product.isAvailable = 1
        }
        
        if let availableQuantity = productDict["available_quantity"] as? NSNumber {
            product.availableQuantity = availableQuantity
        } else {
            product.availableQuantity = -1
        }
        
        if let isProductPublished = productDict["is_published"] as? NSNumber {
            product.isPublished = isProductPublished
        }else{
            product.isPublished = 1
        }
        
        if let promotion = productDict["promotion"] as? NSDictionary{
            product.promotion = 1
            if let promoPrice = promotion["price"] as? Double{
                product.promoPrice = NSNumber(value: promoPrice)
      
            }else{
                product.promoPrice = NSNumber(0)
            }

            if let startTime = promotion["start_time"] as? Int{
                let date = Date(milliseconds: startTime)
                product.promoStartTime =  date
            }else{
                product.promoStartTime = nil
            }

            if let EndTime = promotion["end_time"] as? Int{
                let date = Date(milliseconds: EndTime)
                product.promoEndTime =  date
            }else{
                product.promoEndTime = nil
            }

            if let productLimit = promotion["product_limit"] as? NSNumber{
                product.promoProductLimit =  productLimit
            }else{
                product.promoProductLimit = NSNumber(0)

            }
        }else{
            product.promotion = 0
        }
        
        /*
        if let isSponsored = productDict["is_sponsored"] as? NSNumber {
            product.isSponsored = isSponsored
        }else{
            product.isSponsored =  0  // product.isSponsored != nil ?  product.isSponsored :
        }
        */
        product.isSponsored = false
       
        if let _rankingInfo = productDict["_rankingInfo"] as? NSDictionary {
            //elDebugPrint("_rankingInfo : \(String(describing: _rankingInfo["promoted"]))")
            if let promoted = _rankingInfo["promoted"] as? Bool , let promotedByReRanking = _rankingInfo["promotedByReRanking"] as?  Bool {
                if !promotedByReRanking && promoted {
                    product.isSponsored = NSNumber(booleanLiteral: promoted)
                }
            }
        }
        product.isPromotion = false
        if let isPromotion = productDict["is_promotion"] as? NSNumber {
            product.isPromotion = isPromotion
        }else if let isPromotion = productDict["is_p"] as? NSNumber {
            product.isPromotion = isPromotion
        }else{
            product.isPromotion = 0
        }
        
        if let price = productDict["full_price"]  {
            let finalPrice = Double("\(price)")
            product.price =  NSNumber.init(floatLiteral: finalPrice ?? 0.0)
            product.currency = CurrencyManager.getCurrentCurrency()
        }else if let priceDict = productDict["price"] as? NSNumber {
            product.price = priceDict//["price_full"] as! NSNumber
           
        } else {
            product.currency = ""
            product.price = NSNumber(value: 0 as Int)
        }
        
        if let currency = productDict["price_currency"] as? String{
            product.currency = currency
        }
        
        if let brandID = productDict["brand_id"] as? NSNumber {
            product.brandId = brandID
         }else{
            product.brandId = -1
        }
        
        if let brandDict = productDict["brand"] as? NSDictionary {
            
            let brandId = brandDict["id"] as! Int
            let brandName = brandDict["name"] as? String
            let brandNameEn = brandDict["slug"] as? String
            product.brandId = brandId as NSNumber
            product.brandName = brandName
            product.brandNameEn = brandNameEn
            product.brandImageUrl = brandDict["image_url"] as? String
        }
        
        if let subCatDictA = productDict["subcategories"] as? [NSDictionary] {
            if subCatDictA.count > 0 {
                
                for subCatDict in subCatDictA {
                    if let pg18 = subCatDict["pg_18"] as? NSNumber {
                        if pg18.boolValue == true {
                            product.isPg18 = pg18
                        }
                    }
                }
                
                
                if let subCatDict = subCatDictA.first {
                    product.subcategoryId = subCatDict["id"] as? NSNumber ?? -1
                    product.subcategoryName = subCatDict["name"] as? String
                    product.subcategoryNameEn = subCatDict["slug"] as? String
                    if let pg18 = subCatDict["pg_18"] as? NSNumber {
                        if pg18.boolValue == true {
                              product.isPg18 = pg18
                        }
                    }
                }
                
            }
        }else if let subcategoryID = productDict["subcategory_id"] as? NSNumber {
            product.subcategoryId = subcategoryID
        } else {
            product.subcategoryId = -1
        }
        
        if let categories = productDict["categories"] as? [NSDictionary] {
            
            if let subcategory = categories.first?["children"] as? NSDictionary {
                
                for subCatDict in categories {
                    if let pg18 = subCatDict["pg_18"] as? NSNumber {
                        if pg18.boolValue == true {
                            product.isPg18 = pg18
                        }
                    }
                }
            
                product.subcategoryName = subcategory["name"] as? String
                product.subcategoryId = subcategory["id"] as! NSNumber
                product.subcategoryName = subcategory["slug"] as? String
                if let pg18 = subcategory["pg_18"] as? NSNumber {
                    if pg18.boolValue == true {
                        product.isPg18 = pg18
                    }
                }
               
            }
            if let category = categories.first {
                product.categoryName = category["name"] as? String
                product.categoryId = category["id"] as? NSNumber
                product.categoryNameEn = category["slug"] as? String
                if let pg18 = category["pg_18"] as? NSNumber {
                    if pg18.boolValue == true {
                        product.isPg18 = pg18
                    }
                }
            }
        }
        
        
        if product.availableQuantity.intValue > 0 &&  product.availableQuantity.intValue < ProductQuantiy.availableQuantityLimit{
            FireBaseEventsLogger.trackLimitedStockItems(product: product)
        }

        return product
    }
    
    // MARK: Delete
    
    class func deleteProductsNotInJSON(_ jsonProductsIds:[String], forBrand brand:Brand, forSubcategory subcategory:Category, context:NSManagedObjectContext) {
        
        let predicate = NSPredicate(format: "NOT (dbID IN %@) AND brandId == %@  AND subcategoryId == %@ AND isArchive == %@", jsonProductsIds, brand.dbID, subcategory.dbID, NSNumber(value: false as Bool))
        
        let productsToDelete = DatabaseHelper.sharedInstance.getEntitiesWithName(ProductEntity, sortKey: nil, predicate: predicate, ascending: false, context: context) as! [Product]
        
        checkForOldProductsInBasket(productsToDelete, context: context)
        
        for object in productsToDelete {
            
            context.delete(object)
        }
    }
    
    class func checkForOldProductsInBasket(_ oldProducts:[Product], context:NSManagedObjectContext) {
        
        for product in oldProducts {
            
            let grocery = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(GroceryEntity, entityDbId: product.groceryId as AnyObject, keyId: "dbID", context: context) as! Grocery
            
            ShoppingBasketItem.removeProductFromBasket(product, grocery: nil, context: context)
            ShoppingBasketItem.removeProductFromBasket(product, grocery: grocery, context: context)
        }
    }
    
    /** There might be cases where the product id is prefixed with order or grocery ids. Use this function if you want the clean product id */
    class func getCleanProductId(fromId id: String) -> Int {
        
        //2 for normal productId, 3 for product from order history, orderId_groceryId_productId, 1 from favourites
        let splittedIds = id.split(separator: "_").map({String($0)}).compactMap({Int($0)})
        return splittedIds.last ?? 0
    }
    
    class func getCleanProductIdString(fromId id: String) -> String {
        
        //2 for normal productId, 3 for product from order history, orderId_groceryId_productId, 1 from favourites
        let splittedIds = id.split(separator: "_").map({String($0)})
        return splittedIds.last ?? "0"
    }
    
    class func getCleanGroceryIdString(fromId id: String) -> String {
        let splittedIds = id.split(separator: "_").map({String($0)})
        return splittedIds.first ?? "0"
    }
    
    
    func getCleanProductId() -> Int {
        return Product.getCleanProductId(fromId: self.dbID)
    }
    
    
    
}


extension Product {
    
    
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
    func convertToDictionaryArray(text: String) -> [NSDictionary]? {
        if let data = text.data(using: .utf8) {
            do {
                
                return try JSONSerialization.jsonObject(with: data, options: []) as? [NSDictionary]
            } catch {
               elDebugPrint(error.localizedDescription)
            }
        }
        return nil
    }
    
    
}
