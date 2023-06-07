//
//  BannerLink.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 02/06/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

public class BannerLink: NSObject {

    var bannerLinkId: NSNumber = 0.0
    
    var bannerCategoryId: NSNumber = 0.0
    var bannerCategory: Category?
    
    var bannerSubCategoryId: NSNumber = 0.0
    var bannerSubCategory: SubCategory?
    
    var bannerbrandId: NSNumber = 0.0
    var bannerBrand: GroceryBrand?
    
    var bannerLinkImageUrl: String = ""
    var bannerLinkImageUrlAr: String = ""
    var bannerLinkTitle: String = ""
    
    var bannerLinkCustomImageUrl: String = ""
    var bannerLinkCustomImageUrlAr: String = ""
    
    var isDeals : Bool = false
    
    // Used for save Banner Links from API Response
    class func getBannerLinksFromResponse(_ dictionary:[NSDictionary] , _ isDeals : Bool = false) -> [BannerLink] {
        
        var bannerLinks = [BannerLink]()
        
        //Parsing Banner Link Response here
        for responseDict in dictionary {
            
            let bannerLink = createBannerLinkFromDictionary(responseDict , isDeals)
            //add banner link to the list
            bannerLinks.append(bannerLink)
        }
        
        return bannerLinks
    }
    
    class func createBannerLinkFromDictionary(_ bannerLinkDict:NSDictionary , _ isDeals : Bool = false) -> BannerLink {
        
        let bannerLink:BannerLink  =    BannerLink.init()
        bannerLink.bannerLinkId    =    bannerLinkDict["id"] as! NSNumber
        bannerLink.isDeals = isDeals
        bannerLink.bannerCategoryId  =    bannerLinkDict["category_id"] as! NSNumber
        if let categoryDict = bannerLinkDict["category"] as? NSDictionary {
            let context = DatabaseHelper.sharedInstance.backgroundManagedObjectContext
            let categoryObj = Category.insertOrUpdateCategoryFromDictionary(categoryDict, context: context)
            if let category = categoryObj {
                bannerLink.bannerCategory = category
            }
        }
        
        
        bannerLink.bannerSubCategoryId    =    bannerLinkDict["subcategory_id"] as! NSNumber
        if let subCategoryDict = bannerLinkDict["subcategory"] as? NSDictionary {
            let subCategory = SubCategory.createSubCategoryFromDictionary(subCategoryDict)
            bannerLink.bannerSubCategory = subCategory
        }
        
        bannerLink.bannerbrandId          =    bannerLinkDict["brand_id"] as! NSNumber
        if let barndDict = bannerLinkDict["brand"] as? NSDictionary {
            let brand = GroceryBrand.createGroceryBrandFromDictionary(barndDict)
            bannerLink.bannerBrand = brand
        }
        
        bannerLink.bannerLinkImageUrl     =    bannerLinkDict["photo_url"] as! String
        
        return bannerLink
    }
}
