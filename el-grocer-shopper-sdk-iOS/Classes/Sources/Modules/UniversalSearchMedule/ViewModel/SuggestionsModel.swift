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
}

struct SuggestionsModelObj {
    var modelType : SearchResultSuggestionType = .title
    var title : String = ""
    var brandID : String = ""
    var brandName : String = ""
    var categoryID : String = ""
    var categoryName : String = ""
}

extension SuggestionsModelObj {
    init( type : SearchResultSuggestionType , title : String = ""){
        self.modelType = type
        self.title = title
    }
}


