//
//  SearchSuggestion.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 03/04/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

class SearchSuggestion: NSObject {

    var suggestionId:NSNumber = 0
    var suggestionName:String = ""
    var suggestionType:String = ""
    
    class func getAllSearchSuggestionFromResponse(_ dictionary:NSDictionary) -> [SearchSuggestion] {
        
        var searchSuggestions = [SearchSuggestion]()
        
        //Parsing All Products Response here
        let dataDict = dictionary["data"] as! NSDictionary
        let aggregationDict = dataDict["aggregation"] as! NSDictionary
        
        var suggestionCount = 0
       elDebugPrint("Suggestion Count At Start:%d",suggestionCount)
        
      /*  let responseCategories = aggregationDict["categories"] as! [NSDictionary]
        for responseDict in responseCategories {
            
            let searchSuggestion = createSearchSuggestionFromDictionary(responseDict)
            searchSuggestion.suggestionType = "Category"
            
            //add searchSuggestion to the list
            searchSuggestions.append(searchSuggestion)
            suggestionCount += 1
            if(suggestionCount == 3){break}
            break
        }
        
       elDebugPrint("Suggestion Count after categories:%d",suggestionCount)*/
        
        let responseSubcategories = aggregationDict["subcategories"] as! [NSDictionary]
        for responseDict in responseSubcategories {
            
            let searchSuggestion = createSearchSuggestionFromDictionary(responseDict)
            searchSuggestion.suggestionType = "SubCategory"
            
            //add searchSuggestion to the list
            searchSuggestions.append(searchSuggestion)
            suggestionCount += 1
            if(suggestionCount == 6){break}
        }
        
       elDebugPrint("Suggestion Count after SubCategories:%d",suggestionCount)
        
        let responseBrands = aggregationDict["brands"] as! [NSDictionary]
        for responseDict in responseBrands {
            
            let searchSuggestion = createSearchSuggestionFromDictionary(responseDict)
            searchSuggestion.suggestionType = "Brand"
            
            //add searchSuggestion to the list
            searchSuggestions.append(searchSuggestion)
            suggestionCount += 1
            if(suggestionCount == 10){break}
        }
        
       elDebugPrint("Suggestion Count after Brands:%d",suggestionCount)
        
        return searchSuggestions
    }
    
    class func createSearchSuggestionFromDictionary(_ subCategoryDict:NSDictionary) -> SearchSuggestion {
        
        let searchSuggestion:SearchSuggestion = SearchSuggestion.init()
        
        searchSuggestion.suggestionId = subCategoryDict["id"] as! NSNumber
        searchSuggestion.suggestionName = subCategoryDict["name"] as! String
        
        return searchSuggestion
    }
}
