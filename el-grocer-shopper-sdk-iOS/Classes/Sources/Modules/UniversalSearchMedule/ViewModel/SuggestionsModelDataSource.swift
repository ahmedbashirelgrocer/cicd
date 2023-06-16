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
    
    var searchFor: searchType = .isForStoreSearch
    
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
            SuggestionsModelObj.init(type: .noDataFound, title: localizedString("search_no_search_history_found_message", bundle: .resource, comment: ""))
        ])
        self.model = filterA
    }
     
    func clearAllData() {
        self.currentSearchString = ""
        self.model.removeAll()
    }
    
    func getDefaultSearchData() {
        self.clearAllData()
        self.papulateUsersearchedData()
        
        // For universal search the top 3 stores in home page will be shown
        if self.searchFor == .isForUniversalSearch {
            let featuredStores = HomePageData.shared.groceryA?
                .filter{ $0.featured == 1 }
                .sorted(by: { ($0.priority ?? 0) < ($1.priority ?? 0) })
            
            let notFeaturedStores = HomePageData.shared.groceryA?
                    .filter{ $0.featured != 1 }
                    .sorted(by: { ($0.priority ?? 0) < ($1.priority ?? 0) })
            
            let sortedStores = (featuredStores ?? []) + (notFeaturedStores ?? [])
            self.insertRetailerSuggestions(retailers: sortedStores, query: "", isPopular: true)
        }
    }
    
    func papulateUsersearchedData() {
        
        ElGrocerApi.sharedInstance.fetchPurchasedOrders(retailerId: self.currentGrocery?.dbID) { result in
            switch result {
            case .success(let historyList):
                if historyList.isNotEmpty {
                    var modelA: [SuggestionsModelObj] = []
                    
                    if self.searchFor != .isForStoreSearch {
                        modelA = [SuggestionsModelObj.init(type: .separator)]
                    }
                    modelA.append(SuggestionsModelObj.init(type: .title, title: localizedString("lblSearchHistory", comment: "").uppercased()))
                    
                    // Takes first 8 element
                    modelA.append(contentsOf: historyList.prefix(8).map { SuggestionsModelObj.init(type: .searchHistory, title: $0.productName, imageUrl: $0.photoUrl) })
                    self.model.append(contentsOf: modelA)
                    return
                }
                
                self.fetchLocalHistory()
                
            case .failure(_):
                self.fetchLocalHistory()
            }
        }
    }
    
    private func fetchLocalHistory() {
        let title: SearchResultSuggestionType = getUserSearchData() != nil && getUserSearchData()?.isEmpty == false ? .titleWithClearOption : .title
        var modelA: [SuggestionsModelObj] = []
        
        if self.searchFor != .isForStoreSearch {
            modelA.append(SuggestionsModelObj(type: .separator))
        }
        
        modelA.append(SuggestionsModelObj(type: title, title: localizedString("lblSearchHistory", comment: "").uppercased()))
            if let currentData = self.getUserSearchData(), !currentData.isEmpty {
                modelA.append(contentsOf: currentData.map { SuggestionsModelObj(type: .searchHistory, title: $0) })
                self.model.append(contentsOf: modelA)
            } else {
                self.papulateTrengingData(fetchRetailers: false, isTrendingProducts: false)
            }
    }
    
    func papulateTrengingData(_ isNeedToClear : Bool = false, fetchRetailers: Bool = true, isTrendingProducts: Bool = true, completion: @escaping (([SuggestionsModelObj])->()) = { _ in }) {
        if self.isDebugOn {
            GenericClass.print("debugdarta : \(currentSearchString)")
        }
       
        AlgoliaApi.sharedInstance.gettrendingSearch(self.currentGrocery != nil ? nil : nil , searchText: currentSearchString, isUniversal: currentGrocery == nil  ) { (data, error) in
            
            
            func addProductSuggestion (_ algoliaObj  : [ NSDictionary], isNeedToShowBrand : Bool, currentString : String ) {
                
                var modelA = [SuggestionsModelObj]()
                
                if self.searchFor != .isForStoreSearch {
                    modelA.append(SuggestionsModelObj.init(type: .separator))
                }
                
                // Hide the title if it is store search not search history (isTrendingProducts is false)
                if (self.searchFor == .isForStoreSearch && isTrendingProducts == false) || (self.searchFor == .isForUniversalSearch) {
                    modelA.append(SuggestionsModelObj(
                        type: .title,
                        title: isTrendingProducts ? localizedString("trending_searches", comment: "").uppercased() : localizedString("lblSearchHistory", comment: "").uppercased())
                    )
                }
                
                
                for (_ , productDict) in algoliaObj.enumerated() {
                    if let value = productDict["query"] as? String {
                        modelA.append(SuggestionsModelObj.init(type: isTrendingProducts ? .trendingSearch : .searchHistory, title: value))
                    }
                }
                
                if algoliaObj.isEmpty {
                    modelA.append(SuggestionsModelObj.init(type: .noDataFound, title: localizedString("search_no_products_found_message", bundle: .resource, comment: "")))
                }
                
                self.model.append(contentsOf: modelA)
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
                                    // returning from function because we are not showing stores for
                                    //  - Store search
                                    //  - When search query is empty (Here we have to show top 3 stores shown in home screen)
                                    if self.searchFor == .isForStoreSearch || fetchRetailers == false { return }
                                    elDebugPrint(algoliaObj)
                                    
                                    var currentLocationsStores: [Grocery] = []
                                    var queryString: String = ""
                                   
                                    for (_, retailer) in algoliaObj.enumerated() {
                                        if let query = retailer["query"] as? String {
                                            queryString = query
                                            if let idDict  =  ((((retailer["Retailer"] as? NSDictionary)?["facets"] as? NSDictionary)?["exact_matches"] as? NSDictionary)?["id"] as? [NSDictionary]) {

                                                let retailerIds = idDict.compactMap { $0["value"] as? String }
                                                
                                                let retailers = HomePageData.shared.groceryA?.filter({ grocery in
                                                    return retailerIds.contains(grocery.getCleanGroceryID())
                                                })
                                                
                                                if let retailers = retailers {
                                                    for retailer in retailers {
                                                        if currentLocationsStores.filter({ retailer.dbID == $0.dbID }).isEmpty {
                                                            currentLocationsStores.append(retailer)
                                                        }
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                    
                                    self.insertRetailerSuggestions(retailers: currentLocationsStores, query: queryString, isPopular: false)
                                }
                            } else if indexName  == AlgoliaIndexName.productSuggestion.rawValue {
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
        ProductBrowser.shared.searchProductQueryWithMultiStore(searchString, storeIDs: dbIDs, 0, 100 ,  "" ,  "", searchType: "single_search", slots: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.globalPlacementsSponsored ?? 3)  { (data, error) in
            self.isProductApiCalling  = false
            spiner?.removeFromSuperview()
            guard data != nil else {
                if let clouser = self.productListNotFound {
                    clouser(searchString)
                }
                return
            }
            if  let newProducts = data {
                Thread.OnMainThread {
                    // let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    
                    
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
        
        func addProductData(_ newProducts: (products: [Product], algoliaCount: Int?) , recipeList : [Recipe] , groceryA : [Grocery] ) {
            
            Thread.OnMainThread {
                // let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                
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
                }else if groceryA.count > 0 {
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
            
            
            ProductBrowser.shared.searchProductQueryWithMultiStoreMultiIndex(searchString, storeIDs: dbIDs, 0, 100 , brandId ?? "" , categoryID ?? "", searchType: "single_search", slots: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.globalPlacementsSponsored ?? 3)  { (product, groceryA) in
                
                self.isProductApiCalling  = false
                DispatchQueue.main.async {
                    spiner?.removeFromSuperview()
                }
                
                if product.algoliaCount == nil {
                    if let clouser = self.productListNotFound {
                        clouser(searchString)
                    }
                    return
                }
                addProductData(product, recipeList: SDKManager.shared.isSmileSDK ? [] : recipeList, groceryA: groceryA)
            }
            
        }
        
        
    }
    func getRecipeData(_ isNeedToClear : Bool = true , searchString : String = "" , _ brandId : String? = nil , _ categoryID : String? = nil ,  storeIds : [String] , typeIds : [String] , groupIds : [String] , completionHandler:@escaping (_ result: [Recipe]) -> Void) {
        
       
        let dbIDs = storeIds
        
        ProductBrowser.shared.searchRecipeQueryWithMultiStore(searchString, storeIDs: dbIDs, typeIDs: typeIds, groupIds: groupIds, 0, 100 , brandId ?? "" , categoryID ?? "", searchType: "single_search")  { recipeList in
            completionHandler(recipeList)
//            guard data != nil else {
//                completionHandler([])
//                return
//            }
//            if  let responseObject : NSDictionary = data as NSDictionary? {
//                var recipeList = [Recipe]()
//                if let categoryData = responseObject["hits"] as? [NSDictionary] {
//                    for data:NSDictionary in categoryData {
//                        let recipe : Recipe = Recipe.init(recipeData: data as! Dictionary<String, Any> )
//                        recipeList.append(recipe)
//                    }
//                }
//                completionHandler(recipeList)
//                return
//            }
//            completionHandler([])
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
    
        ProductBrowser.shared.searchProductQueryWithMultiStore(searchString, storeIDs: dbIDs, pageNumber , hitsPerPage , brandId ?? "" , categoryID ?? "", searchType: "single_search", slots: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.globalPlacementsSponsored ?? 3)  { (data, error) in
            self.isProductApiCalling  = false
            Thread.OnMainThread { spiner?.removeFromSuperview() }
            guard data != nil else {
                if let clouser = self.productListNotFound {
                    clouser(searchString)
                }
                return
            }
            if  let newProducts = data {
                Thread.OnMainThread {
                    // let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext, searchString : searchString)
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

fileprivate extension SuggestionsModelDataSource {
    // Insert Retailers Suggestions
    func insertRetailerSuggestions(retailers: [Grocery], query: String, isPopular: Bool) {
        let storesSectionTitle = isPopular
            ? localizedString("text_popular_stores", bundle: .resource, comment: "")
            : localizedString("text_stores", bundle: .resource, comment: "")
        
        var retailerSuggestions: [SuggestionsModelObj] = [SuggestionsModelObj(type: .title, title: storesSectionTitle)]
        
        if retailers.isNotEmpty {
            let sortedRetailersSuggestions = retailers
                .map { SuggestionsModelObj(type: .retailer, title: $0.name ?? query, retailerId: $0.dbID, retailerImageUrl: $0.smallImageUrl) }
                .prefix(3)
            
            retailerSuggestions.append(contentsOf: sortedRetailersSuggestions)
        } else {
            retailerSuggestions.append(SuggestionsModelObj(type: .noDataFound, title: localizedString("search_no_stores_found_message", comment: "")))
        }
        
        self.model.insert(contentsOf: retailerSuggestions, at: 0)
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
        let storeType = ElGrocerUtility.sharedInstance.activeGrocery?.storeType.map{ "\($0)" } ?? []
        
        ElGrocerApi.sharedInstance.getBanners(for: location , retailer_ids: [ElGrocerUtility.sharedInstance.cleanGroceryID(gorceryId)], store_type_ids: storeType , retailer_group_ids: nil  , category_id: nil , subcategory_id: nil, brand_id: nil, search_input: searchInput ) { (result) in
            switch result {
                case .success(let response):
                    self.saveBannersResponseData(response, withHomeTitle: homeTitle, andWithGroceryId: gorceryId, searchInput: searchInput)
                case.failure(let _):
                    self.saveBannersResponseData([], withHomeTitle: homeTitle, andWithGroceryId: gorceryId, searchInput: searchInput)
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
    
    func saveBannersResponseData(_ banners: [BannerCampaign], withHomeTitle homeTitle:String, andWithGroceryId gorceryId:String , searchInput : String ) {
        
        if (self.currentGrocery?.dbID == gorceryId){
            self.bannerFeeds.removeAll()
            if  banners.count > 0 {
                let homeFeed = Home.init(homeTitle, withCategory: nil, withBanners: banners, withType:HomeType.Banner, products: [])
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
        ElGrocerApi.sharedInstance.getBanners(for: location , retailer_ids: [ElGrocerUtility.sharedInstance.cleanGroceryID(gorceryId)], store_type_ids: nil , retailer_group_ids: nil  , category_id: nil , subcategory_id: nil, brand_id: nil, search_input: searchInput ) { (result) in
            switch result {
                case .success(let response):
                    self.saveBannersTierTwoResponseData(response, withHomeTitle: homeTitle, andWithGroceryId: gorceryId, searchInput: searchInput)
                case.failure(let _):
                    elDebugPrint("banner failure")
            }
        }
        
    }
    
    func saveBannersTierTwoResponseData(_ banners: [BannerCampaign], withHomeTitle homeTitle:String, andWithGroceryId gorceryId:String , searchInput : String ) {
        
        if (self.currentGrocery?.dbID == gorceryId){
            if  banners.count > 0 {
                let homeFeed = Home.init(homeTitle, withCategory: nil, withBanners: banners, withType:HomeType.Banner,  products: [])
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
