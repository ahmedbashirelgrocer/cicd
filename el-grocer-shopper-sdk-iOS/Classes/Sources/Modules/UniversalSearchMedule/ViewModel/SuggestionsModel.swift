//
//  SuggestionsModel.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 18/01/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation


enum SearchResultSuggestionType {
    case title
    case titleWithClearOption
    case searchHistory
    case trendingSearch
    case categoriesTitles
    case brandTitles
    case recipeTitles
    case retailer
}

struct SuggestionsModelObj {
    var modelType : SearchResultSuggestionType = .title
    var title : String = ""
    var brandID : String = ""
    var brandName : String = ""
    var categoryID : String = ""
    var categoryName : String = ""
    var retailerId : String = ""
    var retailerImageUrl : String = ""
}

extension SuggestionsModelObj {
    init( type : SearchResultSuggestionType , title : String = ""){
        self.modelType = type
        self.title = title
    }
    init( type : SearchResultSuggestionType , title : String = "", brandID : String, brandName: String, categoryID: String, categoryName : String ){
        self.modelType = type
        self.title = title
        self.brandID = brandID
        self.brandName  = brandName
        self.categoryID  = categoryID
        self.categoryName  = categoryName
    }
    init( type : SearchResultSuggestionType , title : String = "", retailerId : String, retailerImageUrl : String?){
        self.modelType = type
        self.title = title
        self.retailerId = retailerId
        self.retailerImageUrl =  retailerImageUrl ?? ""
    }
}


