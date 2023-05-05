//
//  SearchDataSource.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 18/01/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation

// TODO: Move to their own file
struct SearchHistoryResponse: Codable {
    let status: String?
    let data: [SearchHistory]
}

struct SearchHistory: Codable {
    let productName: String
    let photoUrl: String
    
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case photoUrl = "photo_url"
    }
}



class SuggestionsModelDataSource {
    
    private var bannerWorkItem:DispatchWorkItem?
    var bannerFeeds:[Home] = [Home]()
    
    
    let maxBrandAndCateListCount = 3
    var isDebugOn : Bool = true
    var isProductApiCalling : Bool = false
    var displayList : ((_ dataList : [SuggestionsModelObj])->Void)?
    var productListNotFound : ((_ searchString : String)->Void)?
    var productListData : ((_ data : [Product] , _ searchString : String)->Void)?
    var productListDataWithRecipes : ((_ data : [Product] , _ searchString : String , _ recipes : [Recipe] , _ groceryA : [Grocery]? )->Void)?
    var groceryListData : ((_ data :  Dictionary<String, Array<Product>>  ,  _ searchString : String)->Void)?
    var NoResultForGrocery : (( _ searchString : String)->Void)?
    var MakeIncrementalIndexZero : ((_ index : Int?)->Void)?
    var BannerLoadedReload : (()->Void)?
    
    var appendLocationOneBanner : ((_ bannerHome : Home?)->Void)?
    var appendLocationTwoBanner : ((_ bannerHome : Home??)->Void)?
    
    
    var currentSearchString = ""
    var currentGrocery : Grocery?
    lazy var selectedIndex : NSIndexPath = NSIndexPath.init(row: 0, section: 0)
    var productsList : [Product] = []
    /// using for pagination in algolia search if it is equal to hits per page(20) call for more products , else no more calls
    var algoliaTotalProductCount: Int = 0
    /// -1 means it is in default condition, any other value is algolia last api call for products count.
    var algoliaCurrentCallProductCount: Int = -1
    var model : [SuggestionsModelObj] = []  {
        didSet {
            if let clouser = self.displayList {
                clouser(model)
            }
        }
    }
    
    func resetForNewGrocery () {
        self.bannerFeeds = []
        self.productsList = []
        self.algoliaTotalProductCount = 0
        self.algoliaCurrentCallProductCount = -1
        selectedIndex = NSIndexPath.init(row: 0, section: 0)
    }
    
    func resetForSegmentIndexChangeIfNeeded(newIndex: Int) {
        
        if self.selectedIndex.row != newIndex {
            self.algoliaTotalProductCount = 0
            self.algoliaCurrentCallProductCount = -1
        }
    }
    
    func removeSearchResultHistory(_ result : String) {
        self.currentSearchString = ""
        let filterA =  self.model.filter { (obj) -> Bool in
            if obj.modelType == .titleWithClearOption || obj.modelType == .searchHistory {
                if obj.modelType == .searchHistory {
                    if obj.title == result {
                        return false
                    }
                }
                return true
            }
            return true
        }
        self.model = filterA
        if let clouser = self.displayList {
            clouser(model)
        }
        
    }
    
 
    func clearSearchHistory() {
        self.currentSearchString = ""
       var filterA =  self.model.filter { (obj) -> Bool in
           if obj.modelType == .searchHistory || obj.modelType == .titleWithClearOption {
                return false
            }
            return true
        }
        
        filterA.append(contentsOf: [
            SuggestionsModelObj.init(type: .title, title: localizedString("lblSearchHistory", comment: "").uppercased()),
            SuggestionsModelObj.init(type: .noDataFound, title: "👀 Your search history will appear here...")
        ])
        self.model = filterA
//        if let clouser = self.displayList {
//            clouser(model)
//        }
    
    }
     
    func clearAllData() {
        self.currentSearchString = ""
        self.model.removeAll()
    }
    
    func getDefaultSearchData() {
        self.clearAllData()
        self.papulateUsersearchedData()
        self.papulateTrengingData(showTrendingProducts: false)
    }
    
    func papulateUsersearchedData() {
        
        let userId = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext).dbID.stringValue
        ElGrocerApi.sharedInstance.fetchPurchasedOrders(shopperId: userId) { result in
            switch result {
            case .success(let historyList):
                if historyList.isNotEmpty {
                    var modelA = [SuggestionsModelObj.init(type: .separator)]
                    modelA.append(SuggestionsModelObj.init(type: .title, title: localizedString("lblSearchHistory", comment: "").uppercased()))
                    
                    var historyItemCount = 1
                    
                    for history in historyList {
                        historyItemCount += 1
                        modelA.append(SuggestionsModelObj.init(type: .searchHistory, title: history.productName, imageUrl: history.photoUrl))
                        
                        if historyItemCount > 8 {
                            break
                        }
                    }
                    self.model.append(contentsOf: modelA)
                    return
                }
                
                self.fetchLocalHistory()
                
            case .failure(let elGrocerError):
                self.fetchLocalHistory()
            }
        }
    }
    
    private func fetchLocalHistory() {
        if let curreentdata = getUserSearchData() {
            guard curreentdata.count > 0 else {
                var modelA = [SuggestionsModelObj.init(type: .separator)]
                modelA.append(SuggestionsModelObj.init(type: .title, title: localizedString("lblSearchHistory", comment: "").uppercased()))
                modelA.append(SuggestionsModelObj.init(type: .noDataFound, title: "👀 Your search history will appear here..."))
                self.model.append(contentsOf: modelA)
                return
            }
            var modelA = [SuggestionsModelObj.init(type: .separator)]
            modelA.append(SuggestionsModelObj.init(type: .titleWithClearOption, title: localizedString("lblSearchHistory", comment: "").uppercased()))
            for suggestionString in curreentdata {
                modelA.append(SuggestionsModelObj.init(type: .searchHistory, title: suggestionString))
            }
            self.model.append(contentsOf: modelA)
        } else {
            var modelA = [SuggestionsModelObj.init(type: .separator)]
            modelA.append(SuggestionsModelObj.init(type: .title, title: localizedString("lblSearchHistory", comment: "").uppercased()))
            modelA.append(SuggestionsModelObj.init(type: .noDataFound, title: "👀 Your search history will appear here..."))
            self.model.append(contentsOf: modelA)
        }
    }
    
    
    func papulateTrengingData(_ isNeedToClear : Bool = false, showTrendingProducts: Bool = true) {
        if self.isDebugOn {
            GenericClass.print("debugdarta : \(currentSearchString)")
        }
        
        func callForRecipe(_ searchString : String) {
            
//            guard SDKManager.isSmileSDK == false else { return }
//
//            AlgoliaApi.sharedInstance.gettrendingSearchForRecipe(self.currentGrocery != nil ? nil : nil , searchText: searchString, isUniversal: currentGrocery == nil  ) { (data, error) in
//                if data != nil {
//                    if let algoliaObj = data!["hits"] as? [NSDictionary] {
//                        var modelA = [SuggestionsModelObj]()
//                        for (index , productDict) in algoliaObj.enumerated() {
//                            if let highlightResult = productDict["_highlightResult"] as? NSDictionary {
//                                if let query = highlightResult["query"] as? NSDictionary {
//                                    if index == 0 {
//                                        modelA = [SuggestionsModelObj.init(type: .title, title: localizedString("title_in_recipies", comment: ""))]
//                                    }
//                                    if let value = query["value"] as? String {
//                                        let str = value.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
//                                        modelA.append(SuggestionsModelObj.init(type: .recipeTitles, title: str))
//                                    }
//                                }
//                            }
//                        }
//                        self.model.append(contentsOf: modelA)
//                    }
//                }
//            }
            
        }
       
        AlgoliaApi.sharedInstance.gettrendingSearch(self.currentGrocery != nil ? nil : nil , searchText: currentSearchString, isUniversal: currentGrocery == nil  ) { (data, error) in
            
            
            func addProductSuggestion (_ algoliaObj  : [ NSDictionary], isNeedToShowBrand : Bool, currentString : String ) {
                
                var modelA = [SuggestionsModelObj]()
                modelA = [
                    SuggestionsModelObj.init(type: .separator),
                    SuggestionsModelObj.init(type: .title, title: localizedString("trending_searches", comment: "").uppercased())
                ]
                
                for (_ , productDict) in algoliaObj.enumerated() {
                    if let value = productDict["query"] as? String {
                        let imageUrl = ((((productDict["Product"] as? NSDictionary)?["facets"] as? NSDictionary)?["exact_matches"] as? NSDictionary)?["photo_url"] as? [NSDictionary])?.first?["value"] as? String
                        
                        
                        modelA.append(SuggestionsModelObj.init(type: .trendingSearch, title: value, imageUrl: imageUrl))
                    }
                }
                
                if algoliaObj.isEmpty {
                    modelA.append(SuggestionsModelObj.init(type: .noDataFound, title: "👀 No products found, try a different one..."))
                }
                
                self.model.append(contentsOf: modelA)
                
//                guard isNeedToShowBrand else {
//                    callForRecipe(currentString)
//                    return
//                }
//                if algoliaObj.count > 0 {
//                    let objForBrandAndCare = algoliaObj[0]
//                    if let Product : NSDictionary = objForBrandAndCare["Product"] as? NSDictionary {
//                        if let facets = Product["facets"] as? NSDictionary {
//                            var mySuggestionDataArray: [SuggestionsModelObj] = []
//                            if let exact_matches = facets["exact_matches"] as? NSDictionary {
////                                if let categoryNameA = exact_matches["subcategories.name"] as? [NSDictionary] {
////                                    var modelA = [SuggestionsModelObj.init(type: .title, title: localizedString("lbl_InCategories", comment: "").uppercased() )]
////                                    for suggestionString  in categoryNameA {
////                                        if let name = suggestionString["value"] as? String {
////                                            modelA.append(SuggestionsModelObj.init(type: .categoriesTitles, title: name))
////                                        }
////                                        if modelA.count == self.maxBrandAndCateListCount + 1 {
////                                            break
////                                        }
////                                    }
////                                        //self.model.append(contentsOf: modelA)
////                                    mySuggestionDataArray.append(contentsOf: modelA)
////                                }
////                                if let brandDataA = exact_matches["brand.name"] as? [NSDictionary] {
////                                    var modelA = [SuggestionsModelObj.init(type: .title , title: localizedString("lbl_InBrand", comment: "").uppercased() )]
////                                    for suggestionString  in brandDataA {
////                                        if let name = suggestionString["value"] as? String {
////                                            modelA.append(SuggestionsModelObj.init(type: .brandTitles, title: name))
////                                        }
////                                        if modelA.count == self.maxBrandAndCateListCount + 1 {
////                                            break
////                                        }
////                                    }
////                                        //self.model.append(contentsOf: modelA)
////                                    mySuggestionDataArray.append(contentsOf: modelA)
////                                    elDebugPrint("mySuggestionDataArray.count: \(mySuggestionDataArray.count)")
////                                }
//
//                                self.model.append(contentsOf: mySuggestionDataArray)
//
//                            }else{
//                                if let categoryA = objForBrandAndCare["subcategories.name"] {
//                                    var modelA = [SuggestionsModelObj.init(type: .title, title: localizedString("lbl_InCategories", comment: "").uppercased() )]
//                                    let categoryNameA = categoryA as? [String] ?? []
//                                    for suggestionString in categoryNameA {
//                                        modelA.append(SuggestionsModelObj.init(type: .categoriesTitles, title: suggestionString))
//                                        if modelA.count == self.maxBrandAndCateListCount + 1 {
//                                            break
//                                        }
//                                    }
//                                        //self.model.append(contentsOf: modelA)
//                                    mySuggestionDataArray.append(contentsOf: modelA)
//                                }
//                                if let brandDataA = objForBrandAndCare["brand.name"] {
//                                    var modelA = [SuggestionsModelObj.init(type: .title , title: localizedString("lbl_InBrand", comment: "").uppercased() )]
//                                    let brandNameA = brandDataA as? [String] ?? []
//                                    for suggestionString in brandNameA {
//                                        modelA.append(SuggestionsModelObj.init(type: .brandTitles, title: suggestionString))
//                                        if modelA.count == self.maxBrandAndCateListCount + 1 {
//                                            break
//                                        }
//                                    }
//                                        //self.model.append(contentsOf: modelA)
//                                    mySuggestionDataArray.append(contentsOf: modelA)
//                                }
//                                self.model.append(contentsOf: mySuggestionDataArray)
//                                elDebugPrint("mySuggestionDataArray.count: \(mySuggestionDataArray.count)")
//                            }
//                        }
//                    }
//                    if !SDKManager.isSmileSDK {
//                        callForRecipe(currentString)
//                    }
//                }
//                if self.model.count == 0 {
//                    if let clouser = self.displayList {
//                        clouser(self.model)
//                    }
//                }
            }
            
            
            if data != nil {
                let isNeedToShowBrand = self.currentSearchString.count > 0
                let currentString = self.currentSearchString
                if isNeedToClear {
                    let currentStringCount = self.currentSearchString.count
                    self.clearAllData()
                    if currentStringCount == 0 {
                        self.papulateUsersearchedData()
                    }
                }
                
                if let mainIndex = data!["results"] as? [NSDictionary] {
                    
                    for dict in mainIndex {
                        if let indexName = dict["index"] as? String {
                             if indexName  == AlgoliaIndexName.RetailerSuggestions.rawValue {
                                if let algoliaObj = dict["hits"] as? [NSDictionary] {
                                    elDebugPrint(algoliaObj)
                                    
                                    var mySuggestionDataArray: [SuggestionsModelObj] = []
                                    
                                    mySuggestionDataArray.append(contentsOf: [SuggestionsModelObj.init(type: .title , title: "popular stores".uppercased() )])
                                   
                                    for (_, retailer) in algoliaObj.enumerated() {
                                        if let query = retailer["query"] as? String {
                                            if let idDict  =  ((((retailer["Retailer"] as? NSDictionary)?["facets"] as? NSDictionary)?["exact_matches"] as? NSDictionary)?["id"] as? [NSDictionary]) {
                                                for data in idDict {
                                                    if let valueString =  data["value"] as? String {
                                                        let value : NSNumber = NSNumber(integerLiteral: Int(valueString) ?? -999)
                                                        let retailers = HomePageData.shared.groceryA?.filter({ grocery in
                                                            return grocery.getCleanGroceryID() == value.stringValue
                                                        })
                                                        if retailers != nil {
                                                            for data in retailers! {
                                                                
                                                                if mySuggestionDataArray.filter({ mode in
                                                                    return mode.retailerId == data.dbID
                                                                }).count > 0 {
                                                                    continue;
                                                                }
                                                                if mySuggestionDataArray.count > 3 {
                                                                    break
                                                                }
                                                                mySuggestionDataArray.append(SuggestionsModelObj.init(type: .retailer, title: data.name ?? query , retailerId: value.stringValue, retailerImageUrl: data.smallImageUrl))
                                                            }
                                                            
                                                        }
                                                    }
                                                    
                                                }
                                            } else {
                                                mySuggestionDataArray.append(SuggestionsModelObj.init(type: .noDataFound, title: "👀 No stores found, try a different one..."))
                                            }
                                        }
                                    }
                                    
                                    if algoliaObj.isEmpty {
                                        mySuggestionDataArray.append(SuggestionsModelObj.init(type: .noDataFound, title: "👀 No stores found, try a different one..."))
                                    }
                                    
                                    self.model.insert(contentsOf: mySuggestionDataArray, at: 0)
//                                    self.model.append(contentsOf: mySuggestionDataArray)
                                }
                            } else if indexName  == AlgoliaIndexName.productSuggestion.rawValue && showTrendingProducts {
                                if let algoliaObj = dict["hits"] as? [NSDictionary] {
                                    addProductSuggestion(algoliaObj, isNeedToShowBrand: isNeedToShowBrand, currentString: currentString)
                                }
                            }
                        }
                    }
                    
                    
                }else if let algoliaObj = data!["hits"] as? [NSDictionary] {
                    addProductSuggestion(algoliaObj, isNeedToShowBrand: isNeedToShowBrand, currentString: currentString)
                }
            }
        }
        
    
        
    }
    
    
    func fetchGroceryProductsList ( searchString : String = "" ,  storeIds : [String]) {
        
        guard !self.isProductApiCalling  else {
            return
        }
        self.isProductApiCalling = true
        let dbIDs = storeIds
        var spiner : SpinnerView?
//        if let topVc = UIApplication.topViewController() {
//            spiner =  SpinnerView.showSpinnerViewInView(topVc.view)
//        }
        AlgoliaApi.sharedInstance.searchProductQueryWithMultiStore(searchString, storeIDs: dbIDs, 0, 100 ,  "" ,  "", searchType: "single_search")  { (data, error) in
            self.isProductApiCalling  = false
            spiner?.removeFromSuperview()
            guard data != nil else {
                if let clouser = self.productListNotFound {
                    clouser(searchString)
                }
                return
            }
            if  let responseObject : NSDictionary = data as NSDictionary? {
                Thread.OnMainThread {
                    let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    
                    
                    if newProducts.products.count > 0 {
                        DatabaseHelper.sharedInstance.saveDatabase()
                        if let clouser = self.groceryListData {
                            clouser( self.getGroceryListFrom(newProducts.products)  , searchString)
                        }
                    }else{
                        if let clouser = self.NoResultForGrocery {
                            clouser(searchString)
                        }
                    }

                }
            }
        }
    }
    
    
    func getProductDataData(_ isNeedToClear : Bool = true , searchString : String = "" , _ brandId : String? = nil , _ categoryID : String? = nil ,  storeIds : [String] , typeIds : [String] , groupIds : [String]) {
    
        guard !self.isProductApiCalling  else {
            return
        }
        self.isProductApiCalling = true
        let dbIDs = storeIds
        var spiner : SpinnerView?
        if let topVc = UIApplication.topViewController() {
            spiner =  SpinnerView.showSpinnerViewInView(topVc.view)
        }
        
        func addProductData(_ responseObject : NSDictionary , recipeList : [Recipe] , groceryA : [Grocery]? ) {
            
            Thread.OnMainThread {
                let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
                if newProducts.products.count > 0 {
                    DatabaseHelper.sharedInstance.saveDatabase()
                    if let clouser = self.productListDataWithRecipes {
                        clouser(newProducts.products, searchString, recipeList, groceryA)
                    }
                }else if recipeList.count > 0 {
                    DatabaseHelper.sharedInstance.saveDatabase()
                    if let clouser = self.productListDataWithRecipes {
                        clouser([], searchString, recipeList, groceryA)
                    }
                }else if groceryA?.count ?? 0 > 0 {
                    DatabaseHelper.sharedInstance.saveDatabase()
                    if let clouser = self.productListDataWithRecipes {
                        clouser([], searchString, recipeList, groceryA)
                    }
                }else{
                    if let clouser = self.productListNotFound {
                        clouser(searchString)
                    }
                }
            }
            
        }
        
        self.getRecipeData(isNeedToClear , searchString: searchString, nil, nil, storeIds: storeIds, typeIds: typeIds, groupIds: groupIds) { (recipeList) in
            
            
            AlgoliaApi.sharedInstance.searchProductQueryWithMultiStoreMultiIndex(searchString, storeIDs: dbIDs, 0, 100 , brandId ?? "" , categoryID ?? "", searchType: "single_search")  { (data, error) in
                
                
                self.isProductApiCalling  = false
                DispatchQueue.main.async {
                    spiner?.removeFromSuperview()
                }
                
                guard data != nil else {
                    if let clouser = self.productListNotFound {
                        clouser(searchString)
                    }
                    return
                }
                
                
                if let dataA = data?["results"] as? NSArray {
                    var productsDictionary : NSDictionary = [:]
                    for data in dataA {
                        if let response = (data as? NSDictionary), (response["index"] as? String) == "Product" {
                            productsDictionary  = response
                        }else if let response = (data as? NSDictionary), (response["index"] as? String) == "Retailer" {
                            Thread.OnMainThread {
                            var responseGroceryIDA : [String] = []
                            if let responseObjects = response["hits"] as? [NSDictionary] {
                                    for responseDict in responseObjects {
                                        if  let groceryIntId = responseDict["id"] as? Int {
                                            responseGroceryIDA.append("\(groceryIntId)")
                                        }
                                    }
                                }
                                let groceryA = HomePageData.shared.groceryA?.filter({ grocery in
                                    return  responseGroceryIDA.filter { searchID in
                                        return searchID == grocery.dbID
                                    }.count > 0
                                })
                                addProductData(productsDictionary, recipeList: SDKManager.isSmileSDK ? [] : recipeList, groceryA: groceryA )
                            }
                           
                        }
                    }
                    return
                }else if  let responseObject : NSDictionary = data as NSDictionary? {
                    addProductData(responseObject, recipeList: recipeList, groceryA: nil)
                }
            }
            
        }
        
        
    }
    func getRecipeData(_ isNeedToClear : Bool = true , searchString : String = "" , _ brandId : String? = nil , _ categoryID : String? = nil ,  storeIds : [String] , typeIds : [String] , groupIds : [String] , completionHandler:@escaping (_ result: [Recipe]) -> Void) {
        
       
        let dbIDs = storeIds
        
        AlgoliaApi.sharedInstance.searchRecipeQueryWithMultiStore(searchString, storeIDs: dbIDs, typeIDs: typeIds, groupIds: groupIds, 0, 100 , brandId ?? "" , categoryID ?? "", searchType: "single_search")  { (data, error) in
            guard data != nil else {
                completionHandler([])
                return
            }
            if  let responseObject : NSDictionary = data as NSDictionary? {
                var recipeList = [Recipe]()
                if let categoryData = responseObject["hits"] as? [NSDictionary] {
                    for data:NSDictionary in categoryData {
                        let recipe : Recipe = Recipe.init(recipeData: data as! Dictionary<String, Any> )
                        recipeList.append(recipe)
                    }
                }
                completionHandler(recipeList)
                return
            }
            completionHandler([])
        }
    }
    
    
    func getProductDataForStore(_ isNeedToClear : Bool = false , searchString : String = "" , _ brandId : String? = nil , _ categoryID : String? = nil ,  storeIds : [String] , pageNumber : Int = 0 ,  hitsPerPage : UInt = 20 ) {
        
        guard !self.isProductApiCalling  else {
            return
        }
        self.isProductApiCalling = true
        let dbIDs = storeIds
        var spiner : SpinnerView?
        
        Thread.OnMainThread {
            if let topVc = UIApplication.topViewController() {
                if pageNumber == 0 {
                    spiner =  SpinnerView.showSpinnerViewInView(topVc.view)
                }
            }
        }
        
        
        GenericClass.print("=== getProductDataForStore === isNeedToClear : \(isNeedToClear) ,  searchString : \(searchString) , brandId : \(String(describing: brandId)) , categoryID : \(String(describing: categoryID)) , storeIds \(storeIds)  ,   pageNumber : \(pageNumber) hitsPerPage : \(hitsPerPage)   ")
    
        AlgoliaApi.sharedInstance.searchProductQueryWithMultiStore(searchString, storeIDs: dbIDs, pageNumber , hitsPerPage , brandId ?? "" , categoryID ?? "", searchType: "single_search")  { (data, error) in
            self.isProductApiCalling  = false
            Thread.OnMainThread { spiner?.removeFromSuperview() }
            guard data != nil else {
                if let clouser = self.productListNotFound {
                    clouser(searchString)
                }
                return
            }
            if  let responseObject : NSDictionary = data as NSDictionary? {
                Thread.OnMainThread {
                    let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext, searchString : searchString)
                    if newProducts.products.count > 0 {
                    DatabaseHelper.sharedInstance.saveDatabase()
                    if self.selectedIndex.row == 0 {
                        self.productsList += newProducts.products
                        self.algoliaTotalProductCount += newProducts.algoliaCount ?? 0
                        self.algoliaCurrentCallProductCount = newProducts.algoliaCount ?? -1
                    }else{
                        self.algoliaTotalProductCount += newProducts.algoliaCount ?? 0
                        self.algoliaCurrentCallProductCount = newProducts.algoliaCount ?? -1
                    }
                    if let clouser = self.productListData {
                        clouser(newProducts.products, searchString)
                    }
                }else{
                    // TODO: Below ticket can be fix here.
                    // weird purple bar at the bottom of the screen
                    // https://elgrocerdxb.atlassian.net/browse/EEN-1591
                    if pageNumber == 0 {
                        if let clouser = self.productListNotFound {
                            clouser(searchString)
                        }
                    }else{
                        self.algoliaCurrentCallProductCount = newProducts.algoliaCount ?? -1
                        if let clouser = self.productListData {
                            clouser(newProducts.products, searchString)
                        }
                    }
                }
            }
            }
        }
    }
}

extension SuggestionsModelDataSource {
    
    func setUsersearchData(_ data : String) {
        UserDefaults.setUserSearchData(data)
//        self.clearSearchHistory()
//        self.papulateUsersearchedData()
    }
    func getUserSearchData() -> [String]? {
        let data = UserDefaults.getUserSearchData()
        if self.isDebugOn {
            elDebugPrint("SuggestionsModel Current Saved Data in usersearch : \(String(describing: data))")
        }
        return data
    }
    
}

extension SuggestionsModelDataSource {
   
    func filterOutSegmentSubcateFrom () ->  (Dictionary<String, Array<Product>> , [String])  {
        var dataDict : Dictionary<String, Array<Product>> = [:]
        var stringA : [String] = []
        for product in self.productsList {
            let subcategoryName  = ElGrocerUtility.sharedInstance.isArabicSelected() ? (product.subcategoryName ?? "") : (product.subcategoryNameEn ?? "")
            if var isContain = dataDict[subcategoryName] {
                isContain.append(product)
                dataDict[subcategoryName] = isContain
            }else{
                dataDict[subcategoryName] = [product]
                stringA.append(subcategoryName)
            }
        }
        return (dataDict , stringA)
    }
    
    
    func getGroceryListFrom (_ list : [Product]) -> Dictionary<String, Array<Product>>  {
        
        var groceryList : Dictionary<String, Array<Product>>  = [:]
        let finalGroceryA =  ElGrocerUtility.sharedInstance.groceries.filter { (grocery) -> Bool in
            return grocery.dbID != ElGrocerUtility.sharedInstance.activeGrocery?.dbID
        }
        var dbIdA =  finalGroceryA.map{(NSNumber(value: UInt32($0.dbID) ?? 0))}
        for product in list {
            let shop = product.shopIds ?? []
            for groceryId in dbIdA {
                if shop.contains(groceryId) {
                    if var isContain = groceryList[groceryId.stringValue]{
                        isContain.append(product)
                        groceryList[groceryId.stringValue] = isContain
                    }else{
                        groceryList[groceryId.stringValue] = [product]
                    }
                }
            }
        }
        return groceryList
    }
 
}


extension SuggestionsModelDataSource {
    
    
    func removeBannerCall () {
        if let bannerWork = self.bannerWorkItem {
            bannerWork.cancel()
        }
    }
    
    
    func getBanners(searchInput : String ){
        
        self.removeBannerCall()
        self.bannerWorkItem = DispatchWorkItem {
            if let gorceryId = self.currentGrocery?.dbID {
                self.getBannersFromServer(gorceryId , searchInput: searchInput)
            }
        }
        DispatchQueue.global().async(execute: self.bannerWorkItem!)
        
    }
    
    private func getBannersFromServer(_ gorceryId:String , searchInput : String){
        
        
        guard !searchInput.isEmpty else {
            return
        }
        let homeTitle = "Banners"
        let location = BannerLocation.in_search_tier_1.getType()
        ElGrocerApi.sharedInstance.getBannersFor(location: location , retailer_ids: [ElGrocerUtility.sharedInstance.cleanGroceryID(gorceryId)], store_type_ids: nil , retailer_group_ids: nil  , category_id: nil , subcategory_id: nil, brand_id: nil, search_input: searchInput ) { (result) in
            switch result {
                case .success(let response):
                    self.saveBannersResponseData(response, withHomeTitle: homeTitle, andWithGroceryId: gorceryId, searchInput: searchInput)
                case.failure(let _):
                    self.saveBannersResponseData([:], withHomeTitle: homeTitle, andWithGroceryId: gorceryId, searchInput: searchInput)
            }
        }
        
        /*
        ElGrocerApi.sharedInstance.getBannersOfGrocery(parameters) { (result) in
            
            switch result {
                
                case .success(let response):
                    self.saveBannersResponseData(response, withHomeTitle: homeTitle, andWithGroceryId: gorceryId)
                    
                case .failure(let error):
                    error.showErrorAlert()
            }
        }*/
    }
    
    func saveBannersResponseData(_ responseObject:NSDictionary, withHomeTitle homeTitle:String, andWithGroceryId gorceryId:String , searchInput : String ) {
        
        if (self.currentGrocery?.dbID == gorceryId){
            let banners = BannerCampaign.getBannersFromResponse(responseObject)
            self.bannerFeeds.removeAll()
            if  banners.count > 0 {
                let homeFeed = Home.init(homeTitle, withCategory: nil, withBanners: banners, withType:HomeType.Banner,  andWithResponse: nil)
                self.bannerFeeds.append(homeFeed)
                if let cloure = self.appendLocationOneBanner {
                    cloure(homeFeed)
                }
            }
            
            if let clouser = self.BannerLoadedReload {
                clouser()
            }
        
        }
        
        let homeTitle = "Banners"
        let location = BannerLocation.in_search_tier_2.getType()
        ElGrocerApi.sharedInstance.getBannersFor(location: location , retailer_ids: [ElGrocerUtility.sharedInstance.cleanGroceryID(gorceryId)], store_type_ids: nil , retailer_group_ids: nil  , category_id: nil , subcategory_id: nil, brand_id: nil, search_input: searchInput ) { (result) in
            switch result {
                case .success(let response):
                    self.saveBannersTierTwoResponseData(response, withHomeTitle: homeTitle, andWithGroceryId: gorceryId, searchInput: searchInput)
                case.failure(let _):
                    elDebugPrint("banner failure")
            }
        }
        
    }
    
    func saveBannersTierTwoResponseData(_ responseObject:NSDictionary, withHomeTitle homeTitle:String, andWithGroceryId gorceryId:String , searchInput : String ) {
        
        if (self.currentGrocery?.dbID == gorceryId){
            let banners = BannerCampaign.getBannersFromResponse(responseObject)
            if  banners.count > 0 {
                let homeFeed = Home.init(homeTitle, withCategory: nil, withBanners: banners, withType:HomeType.Banner,  andWithResponse: nil)
                let currentFeedCount = self.bannerFeeds.count
                self.bannerFeeds.append(homeFeed)
                if let cloure = self.appendLocationTwoBanner {
                    cloure(homeFeed)
                }
                
                if currentFeedCount == 0 {
                    if let clouser = self.MakeIncrementalIndexZero {
                        clouser(3)
                    }
                }
            }
            if let clouser = self.BannerLoadedReload {
                clouser()
            }
        }
        
        
        
    }
    
    
}
