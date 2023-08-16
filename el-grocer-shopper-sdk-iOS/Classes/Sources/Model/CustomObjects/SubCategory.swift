//
//  SubCategory.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 27/10/2016.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit

class SubCategory: NSObject {
    
    var subCategoryName: String = ""
    var subCategoryNameEn: String = ""
    var subCategoryImageUrl: String = ""
    var subCategoryId: NSNumber = 0.0
    var isShowBrand: Bool = false
    var message : String = ""
    var subCategoryImageUrlForList: String = ""
    
    // Used for SubCategory from All SubCategory API
   class func getAllSubCategoriesFromResponse(_ dictionary:NSDictionary) -> [SubCategory] {
        
        var resultSubCategories = [SubCategory]()
        
        //Parsing All Products Response here
        //sab
        //let dataDict = dictionary["data"] as! NSDictionary
        //let responseObjects = dataDict["categories"] as! [NSDictionary]
    //let dataDict = dictionary["data"] as! [NSDictionary]
    let responseObjects = dictionary["data"] as! [NSDictionary]
        
        
        for responseDict in responseObjects {
            
            let subCategory = createSubCategoryFromDictionary(responseDict)
            
            //add subCategory to the list
            resultSubCategories.append(subCategory)
        }
        
        return resultSubCategories
    }
    
   class func createSubCategoryFromDictionary(_ subCategoryDict:NSDictionary) -> SubCategory {
        
    let subCategory:SubCategory = SubCategory.init()
    
    subCategory.subCategoryId = subCategoryDict["id"] as! NSNumber
    subCategory.subCategoryName = subCategoryDict["name"] as! String
    if let slugName = subCategoryDict["slug"] as? String {
        subCategory.subCategoryNameEn = slugName
    }
    if let message = subCategoryDict["message"] as? String {
        subCategory.message = message
    }
    
    if Platform.isDebugBuild {
        subCategory.message = "This is the debug msg to check will display in debug build only test"
    }
    
    subCategory.subCategoryImageUrlForList = subCategoryDict["photo_url"] as! String
    
    //subCategory.subCategoryImageUrl = subCategoryDict["image_url"] as! String
    subCategory.subCategoryImageUrl = subCategoryDict["photo_url"] as! String
    subCategory.isShowBrand = subCategoryDict["is_show_brand"] as! Bool
    
    return subCategory
    }
    
    convenience init(id: NSNumber, name: String) {
        self.init()
        
        self.subCategoryId = id
        self.subCategoryName = name
    }
}
