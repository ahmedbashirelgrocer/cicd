//
//  AlgoliaApi.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 18/09/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//


import AlgoliaSearchClient
import InstantSearch


private let AlgoliaSharedInstance = AlgoliaApi()


enum AlgoliaEventName : String {
    
    case view = "ViewItem"
    case ATC = "add_to_cart"
    case Purchased = "order_purchased"
    
}

class AlgoliaApi {
    
    
    typealias responseBlock = (_ content: [String: Any]?, _ error: Error?) -> ()
    
    
   
     private var algoliaAddToCartProducts : Dictionary <String, [String]> = [:]
   
    var algoliaApplicationID  =  ApplicationID(rawValue: "AS47I7FT15")
    private let algoliadefaultIndexName  = IndexName.init(stringLiteral: "Product")
 //   private let algoliadefaultIndexName  = IndexName.init(stringLiteral: "ProductReplica")
    private let algoliaRecipeIndexName  = IndexName.init(stringLiteral: "RecipeBoutique")
    private let algoliaProductSuggestionIndexName = IndexName.init(stringLiteral: "Product_query_suggestions")
    private let algoliaRecipeSuggestionIndexName = IndexName.init(stringLiteral: "RecipeBoutique_query_suggestions")
    var algoliaProductIndex : AlgoliaSearchClient.Index
    var algoliaProductBrowserIndex : AlgoliaSearchClient.Index
    var algoliaRecipeIndex : AlgoliaSearchClient.Index
    var algoliaSearchSuggestionIndex : AlgoliaSearchClient.Index
    var algoliaRecipeSuggestionIndex : AlgoliaSearchClient.Index
    //var insight : Insights?
    
    let OROperator = " OR "
    let ANDOperator = " AND "
    
    
    init() {
        
        var client = SearchClient(appID:  algoliaApplicationID , apiKey: "f64accc4672a9125533fc1d64baf93ab")
        if ElGrocerApi.sharedInstance.baseApiPath == "https://el-grocer-staging-dev.herokuapp.com/api/" {
           algoliaApplicationID = "3LIB7IY3OL"
           client = SearchClient(appID: algoliaApplicationID , apiKey: "688bccc1dcc7f10e040c36ec148557b6")
        }
        self.algoliaProductIndex =  client.index(withName:  algoliadefaultIndexName)
        self.algoliaRecipeIndex =  client.index(withName: algoliaRecipeIndexName )
        self.algoliaSearchSuggestionIndex = client.index(withName: algoliaProductSuggestionIndexName )
        self.algoliaRecipeSuggestionIndex =  client.index(withName: algoliaRecipeSuggestionIndexName )
        
        let browserClient = SearchClient(appID:  algoliaApplicationID , apiKey: "7c36787b0c09ef094db8a3ba93871ce7")
        self.algoliaProductBrowserIndex =  browserClient.index(withName:  algoliadefaultIndexName)
        
    }
    
    
    class var sharedInstance : AlgoliaApi {
        
        return AlgoliaSharedInstance
    }
    
    func reStartInsights () {
        
        var versionNumber = "10000"
        if let version = Bundle.resource.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumber = version
        }
        var token = String(format: "%.0f", Date.timeIntervalSinceReferenceDate) + "_" + versionNumber
        token = token.replacingOccurrences(of: "-", with: "_")
        token = token.replacingOccurrences(of: ".", with: "_")
        let unsafeChars = CharacterSet.alphanumerics.inverted
        token = token.components(separatedBy: unsafeChars).joined(separator: "")

        if let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            token = userProfile.dbID.stringValue
        }
        Insights.register(appId:  algoliaApplicationID , apiKey: APIKey(rawValue: "f64accc4672a9125533fc1d64baf93ab") , userToken: UserToken(rawValue: token))
        if ElGrocerApi.sharedInstance.baseApiPath == "https://el-grocer-staging-dev.herokuapp.com/api/" {
            Insights.register(appId:  algoliaApplicationID , apiKey: APIKey(rawValue: "7df145d4ee0d2219199fe615cb2100cd") , userToken:  UserToken(rawValue: token))
        }
        Insights.shared?.isLoggingEnabled =  Platform.isDebugBuild ? true : false
        
        Insights.flushDelay = 10.0
    }
    
    func searchQueryWithCurrentStoreItems (_ searchText : String , storeID : String , pageNumber : Int , seachSuggestion : SearchSuggestion? , searchType: String , _ hitsPerPage : Int = 20  , completion : @escaping responseBlock ) -> Void {
        
 
        let facetFiltersForCurrentStoreID : String = "shops.retailer_id:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
        var query = Query(searchText)
            .set(\.filters, to: facetFiltersForCurrentStoreID )
            .set(\.clickAnalytics, to: true)
            .set(\.getRankingInfo, to: true)
            .set(\.analytics, to: true)
            .set(\.analyticsTags, to: self.getAlgoliaTags(isUniversal: false , searchType: searchType))
         
        query.page = pageNumber
        query.hitsPerPage = hitsPerPage
        var requestOptions = RequestOptions()
        requestOptions.headers["X-Algolia-UserToken"] = (Insights.shared(appId:  algoliaApplicationID)?.userToken).map { $0.rawValue }
        self.algoliaProductIndex.search(query: query, requestOptions: requestOptions) { (content) in
            if case .success(let response) = content {
                completion(response.convertHits() , nil)
            }else if case .failure (let error) = content{
                completion(nil , error)
            }
        }
        
    }

    func searchQueryForOOSItemsCurrentStoreItems (_ searchText : String , storeID : String , pageNumber : Int , isFood  : Bool = false , subCategoryID : String? , searchType: String , completion : @escaping responseBlock ) -> Void {
        
     
        var facetFiltersA : [SingleOrList<String>] = []
        let facetFiltersForCurrentStoreID : String = "shops.retailer_id:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
        facetFiltersA.append(SingleOrList.single(facetFiltersForCurrentStoreID))
        if isFood {
            let facetFiltersForFoodItems : String = "categories.is_food:\(true)"
            facetFiltersA.append(SingleOrList.single(facetFiltersForFoodItems))
        }
        
        if let subID = subCategoryID {
            if !subID.isEmpty {
                let facetFiltersForOOSItems : String = "subcategories.id:\(subID)"
                facetFiltersA.append(SingleOrList.single(facetFiltersForOOSItems))
            }
        }
        var query = Query(searchText)
            .set(\.facetFilters, to: FiltersStorage.init(rawValue: facetFiltersA))
            .set(\.clickAnalytics, to: true)
            .set(\.getRankingInfo, to: true)
            .set(\.analytics, to: true)
            .set(\.analyticsTags, to: self.getAlgoliaTags(isUniversal: false , searchType: searchType))
        query.page = pageNumber
        query.hitsPerPage = 7
        var requestOptions = RequestOptions()
        requestOptions.headers["X-Algolia-UserToken"] = (Insights.shared(appId: algoliaApplicationID)?.userToken).map { $0.rawValue }
        self.algoliaProductIndex.search(query: query, requestOptions: requestOptions)  { (content) in
            if case .success(let response) = content {
                completion(response.convertHits() , nil)
            }else if case .failure (let error) = content{
                completion(nil , error)
            }
        }
        
    }
    

    func searchProductQueryWithMultiStore (_ searchText : String , storeIDs : [String] , _ pageNumber : Int = 0 , _ hitsPerPage : UInt = 100 , _ brand : String = "" , _ category : String = "" , searchType: String  , completion : @escaping responseBlock ) -> Void {
       
       
        var filterString = ""
        
        for storeID in storeIDs{
            let facetFiltersForCurrentStoreID : String = "shops.retailer_id:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(OROperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        
        for storeID in storeIDs{
            let facetFiltersForCurrentStoreID : String = "promotional_shops.retailer_id:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(OROperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        if brand.count > 0 {
            let facetFiltersForCurrentStoreID : String = "brand.name:'\(brand)'"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(ANDOperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        if category.count > 0 {
            let facetFiltersForCurrentStoreID : String = "subcategories.name:'\(category)'"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(ANDOperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
       
        var query = Query(searchText)
            .set(\.filters, to: filterString)
            .set(\.clickAnalytics, to: true)
            .set(\.getRankingInfo, to: true)
            .set(\.analytics, to: true)
            .set(\.analyticsTags, to: self.getAlgoliaTags(isUniversal: storeIDs.count > 1 , searchType: searchType))
        
        query.page = pageNumber
        query.hitsPerPage = Int(hitsPerPage)
        var requestOptions = RequestOptions()
        requestOptions.headers["X-Algolia-UserToken"] = (Insights.shared(appId: algoliaApplicationID)?.userToken).map { $0.rawValue }
        self.algoliaProductIndex.search(query: query, requestOptions: requestOptions) { (content) in
            if case .success(let response) = content {
                completion(response.convertHits() , nil)
            }else if case .failure (let error) = content{
                completion(nil , error)
            }
        }
 
    }
    
    func searchRecipeQueryWithMultiStore (_ searchText : String , storeIDs : [String] , typeIDs : [String] , groupIds : [String]  , _ pageNumber : Int = 0 , _ hitsPerPage : UInt = 100 , _ brand : String = "" , _ category : String = "" , searchType: String  , completion : @escaping responseBlock ) -> Void {
        
        var filterString = ""
        
        for storeID in storeIDs{
            let facetFiltersForCurrentStoreID : String = "retailer_ids:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(OROperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        for typeId in typeIDs{
            let facetFiltersForCurrentStoreID : String = "store_type_ids:\(typeId)"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(OROperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        
        for typeId in groupIds {
            let facetFiltersForCurrentStoreID : String = "retailer_group_ids:\(typeId)"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(OROperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        if brand.count > 0 {
            let facetFiltersForCurrentStoreID : String = "brand.name:'\(brand)'"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(ANDOperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        if category.count > 0 {
            let facetFiltersForCurrentStoreID : String = "subcategories.name:'\(category)'"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(ANDOperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        
        var query = Query(searchText)
            .set(\.filters, to: filterString)
            .set(\.clickAnalytics, to: true)
            .set(\.getRankingInfo, to: true)
            .set(\.analytics, to: true)
            .set(\.analyticsTags, to: self.getAlgoliaTags(isUniversal: storeIDs.count > 1 , searchType: searchType))
        query.page = pageNumber
        query.hitsPerPage = Int(hitsPerPage)
        var requestOptions = RequestOptions()
        requestOptions.headers["X-Algolia-UserToken"] = (Insights.shared(appId: algoliaApplicationID)?.userToken).map { $0.rawValue }
        self.algoliaRecipeIndex.search(query: query, requestOptions: requestOptions ) { (content) -> Void in
            if case .success(let response) = content {
                completion(response.convertHits() , nil)
            }else if case .failure (let error) = content{
                completion(nil , error)
            }
        }
    }

    func searchQueryForRecipe (_ searchText : String  , pageNumber : Int , retailerId : String , storeIds : String , groupIds : [String] , categoryId : Int64? , chefId : Int64? , completion : @escaping responseBlock ) -> Void {
        
        
        var filterString = ""
        var retailerIdA = retailerId.split(separator: ",")
        retailerIdA = retailerIdA.filter { (value) -> Bool in
            return !value.isEmpty
        }
        for storeID in retailerIdA{
            let facetFiltersForCurrentStoreID : String = "retailer_ids:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(OROperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        
        var storeIdA = storeIds.split(separator: ",")
        storeIdA = storeIdA.filter { (value) -> Bool in
            return !value.isEmpty
        }
        for storeID in storeIdA{
            let facetFiltersForCurrentStoreID : String = "store_type_ids:\(storeID)"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            } else {
                filterString.append(OROperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        
        for typeId in groupIds {
            let facetFiltersForCurrentStoreID : String = "retailer_group_ids:\(typeId)"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(OROperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        if let cateID = chefId {
            let facetFiltersForCurrentStoreID = ("chef.id:\(cateID)")
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(ANDOperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        if let cateID = categoryId {
            let facetFiltersForCurrentStoreID = "categories.id:\(cateID)"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(ANDOperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        
        var isUniversal = retailerIdA.count > 1
        if retailerIdA.count == 1 {
           let storeId = retailerIdA[0]
            if storeId == ElGrocerUtility.sharedInstance.cleanGroceryID(ElGrocerUtility.sharedInstance.activeGrocery) {
                isUniversal = false
            }
        }
        
        var query = Query(searchText)
            .set(\.filters, to: filterString)
            .set(\.clickAnalytics, to: true)
            .set(\.getRankingInfo, to: true)
            .set(\.analytics, to: true)
            .set(\.analyticsTags, to: self.getAlgoliaTags(isUniversal: isUniversal , searchType: "recipe"))
        query.page = pageNumber
        query.hitsPerPage = 10
        var requestOptions = RequestOptions()
        requestOptions.headers["X-Algolia-UserToken"] = (Insights.shared(appId: algoliaApplicationID)?.userToken).map { $0.rawValue }
        self.algoliaRecipeIndex.search(query: query, requestOptions: requestOptions ) { (content) -> Void in
            if case .success(let response) = content {
                completion(response.convertHits() , nil)
            }else if case .failure (let error) = content{
                completion(nil , error)
            }
        }
    }
 
    func gettrendingSearch (_ retailerID : String? = nil , searchText : String = "" , isUniversal : Bool , completion : @escaping responseBlock  )  {
   
        var filterString = ""
        if let storeID = retailerID {
            let facetFiltersForCurrentStoreID : String = "shops.retailer_id:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
            filterString.append(facetFiltersForCurrentStoreID)
        }
        var query = Query(searchText)
            .set(\.filters, to: filterString)
            .set(\.clickAnalytics, to: true)
            .set(\.getRankingInfo, to: true)
            .set(\.analytics, to: true)
            .set(\.analyticsTags, to: self.getAlgoliaTags(isUniversal: isUniversal  , searchType: "suggestion"))
        query.hitsPerPage =  searchText.count > 0 ? 6 : 12
        var requestOptions = RequestOptions()
        requestOptions.headers["X-Algolia-UserToken"] = (Insights.shared(appId: algoliaApplicationID)?.userToken).map { $0.rawValue }
        
       
        self.algoliaSearchSuggestionIndex.search(query: query, requestOptions: requestOptions ) { (content) -> Void in
            debugPrint(content)
            if case .success(let response) = content {
                completion(response.convertHits() , nil)
            }else if case .failure (let error) = content{
                completion(nil , error)
            }
        }
    }
    
    func gettrendingSearchForRecipe (_ retailerID : String? = nil , searchText : String = "" , isUniversal : Bool , completion : @escaping responseBlock  )  {
        
        var filterString = ""
        if let storeID = retailerID {
            let facetFiltersForCurrentStoreID : String = "shops.retailer_id:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
            filterString.append(facetFiltersForCurrentStoreID)
        }
        var query = Query(searchText)
            .set(\.filters, to: filterString)
            .set(\.clickAnalytics, to: true)
            .set(\.getRankingInfo, to: true)
            .set(\.analytics, to: true)
            .set(\.analyticsTags, to: self.getAlgoliaTags(isUniversal: isUniversal  , searchType: "suggestion"))
        query.hitsPerPage =  searchText.count > 0 ? 6 : 12
        var requestOptions = RequestOptions()
        requestOptions.headers["X-Algolia-UserToken"] = (Insights.shared(appId: algoliaApplicationID)?.userToken).map { $0.rawValue }
        self.algoliaRecipeSuggestionIndex.search(query: query, requestOptions: requestOptions ) { (content) -> Void in
            if case .success(let response) = content {
                completion(response.convertHits() , nil)
            }else if case .failure (let error) = content{
                completion(nil , error)
            }
        }
    }
    
 
}

extension AlgoliaApi {
    
    
    func resetAlgoliaLocalData() {
        if let gorcer =  ElGrocerUtility.sharedInstance.activeGrocery {
            UserDefaults.removeAddToCartInAlgoliaData(groceryID: gorcer.dbID)
        }
    }
 
  
    func addItemToAlgolia (product : Product, possitionIndex : Int?) {
        let cleanProductID = Product.getCleanProductIdString(fromId: product.dbID)
        let cleanGroceryID = Product.getCleanGroceryIdString(fromId: product.dbID)
        guard product.queryID?.count ?? 0 > 0 else {return}
        guard cleanProductID.count > 0 else {return}
        guard possitionIndex != nil else {return}
        Insights.shared(appId: algoliaApplicationID)?.clickedAfterSearch(eventName: EventName(rawValue : AlgoliaEventName.ATC.rawValue) , indexName:  algoliadefaultIndexName , objectID: ObjectID.init(rawValue: cleanProductID)  , position: possitionIndex! + 1 , queryID: QueryID.init(stringLiteral: product.queryID!))
        UserDefaults.setAddToCartInAlgolia(productID: [cleanProductID] , querIDs: product.queryID! , in: cleanGroceryID)
     }
    
    func viewItemAlgolia (product : Product) {
        let cleanProductID = Product.getCleanProductIdString(fromId: product.dbID)
        guard cleanProductID.count > 0 else {return}
        Insights.shared(appId: algoliaApplicationID)?.viewed(eventName: EventName(rawValue : AlgoliaEventName.view.rawValue) , indexName:  algoliadefaultIndexName, objectID: ObjectID.init(stringLiteral: cleanProductID))
        
    }

    func purchase ( productQueryIDsList : [String] , productIDsList : [String]  ,  cleanGroceryID : String) {
         let data = UserDefaults.getAddToCartInAlgolia(groceryID: cleanGroceryID)
        for queryID  in productQueryIDsList {
            if let productIDs =  data[queryID] {
                debugPrint(productIDs)
                let objectIDs = productIDsList.filter(productIDs.contains)
                if objectIDs.count > 0 {
                    var objIdsA : [ObjectID] = []
                    for ids in objectIDs {
                        objIdsA.append(ObjectID.init(stringLiteral: ids))
                    }
                    Insights.shared(appId: algoliaApplicationID)?.convertedAfterSearch(eventName: EventName(rawValue : AlgoliaEventName.Purchased.rawValue) , indexName:  algoliadefaultIndexName , objectIDs: objIdsA , queryID: QueryID.init(stringLiteral:  queryID ))
                }
            }
        }
        UserDefaults.removeAddToCartInAlgoliaData(groceryID: cleanGroceryID)
    }
    
    
    func getAlgoliaTags(isUniversal : Bool , searchType : String  ) -> [String] {
        
        var tags : [String] = []
        let lan =   "ln_" + (ElGrocerUtility.sharedInstance.isArabicSelected() ? "ar" : "en")
        tags.append(lan)
        var rt = "rt_"
        let selectedType =  ElGrocerUtility.sharedInstance.storeTypeA.filter { (type) -> Bool in
            if let storeType = ElGrocerUtility.sharedInstance.activeGrocery?.storeType {
                return storeType.contains(NSNumber(value: type.storeTypeid))
            }
            return false
        }

        if !isUniversal {
            if selectedType.count > 0 {
                for storeName in selectedType {
                    if storeName.storeTypeid == 0 {
                        let finalName = rt + "Other"
                        tags.append(finalName)
                    }else{
                        let finalName = rt + (storeName.name ?? "Other")
                        tags.append(finalName)
                    }
                }
            }else{
                tags.append(rt + "Other")
            }
        }else{
            let stypeTypeName = "universal_search"
            rt = rt + stypeTypeName
            tags.append(rt)
        }
       
        
        let rn = "rn_" + ((isUniversal ? "universal_search" : ElGrocerUtility.sharedInstance.activeGrocery?.name) ?? "null")
        tags.append(rn)
        
        // universal case
        let groupName = "rg_" + ((isUniversal ? "universal_search" : ElGrocerUtility.sharedInstance.activeGrocery?.retailerGroupName) ?? "null")
        tags.append(groupName)
        
        var city = "ct_" + "null"
        if let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            city = "ct_" + (currentAddress.city ?? "null")
        }
        tags.append(city)
        tags.append("pf_ios")
        let logIn = UserDefaults.isUserLoggedIn() ? "logged_in" : "logged_out"
        tags.append("ls_" + logIn)
        
    
        let deliverySrvc =  (ElGrocerUtility.sharedInstance.isDeliveryMode ? "delivery" : "click_and_collect");
        tags.append("srvc_" + deliverySrvc)
        
        let type =  "styp_" + searchType;
        tags.append(type)
        
     
        
        var finalTags : [String] = []
        for data in tags {
            let dataToAdd = data.replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "-", with: "_").replacingOccurrences(of: "\\'", with: "")
            finalTags.append(dataToAdd)
        }
        
        if Platform.isDebugBuild {debugPrint("ALgolia Insights Tags: \(finalTags)")}
        return finalTags
    }

}

// MARK: Deeplinks

extension AlgoliaApi {
    
        // BrandDeeplinks
    func searchProductQueryWithMultiStoreBrandId (_ searchText : String , storeIDs : [String] , _ pageNumber : Int = 0 , _ hitsPerPage : UInt = 100 , _ brand : String = "" , _ category : String = "" , searchType: String  , completion : @escaping responseBlock ) -> Void {
        
        
        var filterString = ""
        
        for storeID in storeIDs{
            let facetFiltersForCurrentStoreID : String = "shops.retailer_id:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(OROperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        
        for storeID in storeIDs{
            let facetFiltersForCurrentStoreID : String = "promotional_shops.retailer_id:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(OROperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        
        if brand.count > 0 {
            let facetFiltersForCurrentStoreID : String = "brand.id:\(brand)"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(ANDOperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        if category.count > 0 {
            let facetFiltersForCurrentStoreID : String = "subcategories.name:\(category)"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(ANDOperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        
        var query = Query(searchText)
            .set(\.filters, to: filterString)
            .set(\.clickAnalytics, to: true)
            .set(\.getRankingInfo, to: true)
            .set(\.analytics, to: true)
            .set(\.analyticsTags, to: self.getAlgoliaTags(isUniversal: storeIDs.count > 1 , searchType: searchType))
        
        query.page = pageNumber
        query.hitsPerPage = Int(hitsPerPage)
        var requestOptions = RequestOptions()
        requestOptions.headers["X-Algolia-UserToken"] = (Insights.shared(appId: algoliaApplicationID)?.userToken).map { $0.rawValue }
        self.algoliaProductBrowserIndex.browse(query: query, requestOptions: requestOptions) { (content) in
            if case .success(let response) = content {
                completion(response.convertHits() , nil)
            }else if case .failure (let error) = content{
                completion(nil , error)
            }
        }
    }
    
    
        // Product - BarCode
    func searchProductWithBarCode (_ barCode : String ,_ productId: String, storeIDs : [String], searchType: String  , completion : @escaping responseBlock ) -> Void {
        var facetFiltersA : [SingleOrList<String>] = []
//        let cleanProductId = Product.getCleanProductIdString(fromId: productId)
        let facetFiltersForBarcodeItems : String = "barcode:\(barCode)"
        let facetFiltersForProductId : String = "id:\(productId)"
        
        var filterString = ""
        
        for storeID in storeIDs{
            let facetFiltersForCurrentStoreID : String = "shops.retailer_id:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
            if filterString.count == 0 {
                filterString.append(facetFiltersForCurrentStoreID)
            }else{
                filterString.append(OROperator)
                filterString.append(facetFiltersForCurrentStoreID)
            }
        }
        
        
        
        
        if productId.count > 0 {
            facetFiltersA.append(SingleOrList.single(facetFiltersForProductId))
        }else if barCode.count > 0{
            facetFiltersA.append(SingleOrList.single(facetFiltersForBarcodeItems))
        }
        let query = Query()
            .set(\.facetFilters, to: FiltersStorage.init(rawValue: facetFiltersA))
            .set(\.filters, to: filterString)
            .set(\.clickAnalytics, to: true)
            .set(\.getRankingInfo, to: true)
            .set(\.analytics, to: true)
            .set(\.analyticsTags, to: self.getAlgoliaTags(isUniversal: storeIDs.count > 1 , searchType: searchType))
        
        var requestOptions = RequestOptions()
        requestOptions.headers["X-Algolia-UserToken"] = (Insights.shared(appId: algoliaApplicationID)?.userToken).map { $0.rawValue }
        
        self.algoliaProductBrowserIndex.browse(query: query, requestOptions: requestOptions) { (content) in
            
            if case .success(let response) = content {
                completion(response.convertHits() , nil)
            } else if case .failure (let error) = content{
                completion(nil , error)
            }
        }
    }
    
}


// MARK: Helpers

extension SearchResponse {
    func convertHits() -> [String: Any]? {
        return self.dictionary
    }
}
extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}



extension AlgoliaApi {
    
    
    
    func searchProductListForStoreCategory ( storeID : String , pageNumber : Int , categoryId: String , _ hitsPerPage : Int = 20, _ subCategoryID : String = "", _ brandId : String = ""  , completion : @escaping responseBlock ) -> Void {
        
        
        var facetFiltersA : [SingleOrList<String>] = []
        let facetFiltersForCurrentStoreID : String = "shops.retailer_id:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
        facetFiltersA.append(SingleOrList.single(facetFiltersForCurrentStoreID))
        
        let facetFiltersForCategoryId : String = "categories.id:\(categoryId)"
        facetFiltersA.append(SingleOrList.single(facetFiltersForCategoryId))
        
        if subCategoryID.count > 0 {
            let facetFiltersForCategoryId : String = "subcategories.id:\(subCategoryID)"
            facetFiltersA.append(SingleOrList.single(facetFiltersForCategoryId))
        }
        
        if brandId.count > 0 {
            let facetFiltersForCategoryId : String = "brand.id:\(brandId)"
            facetFiltersA.append(SingleOrList.single(facetFiltersForCategoryId))
        }
        
        var query = Query("")
            .set(\.facetFilters, to: FiltersStorage.init(rawValue: facetFiltersA) )
            .set(\.clickAnalytics, to: true)
            .set(\.getRankingInfo, to: true)
            .set(\.analytics, to: true)
            .set(\.analyticsTags, to: self.getAlgoliaTags(isUniversal: false , searchType: "ProductListing"))
        
        query.page = pageNumber
        query.hitsPerPage = hitsPerPage
        var requestOptions = RequestOptions()
        requestOptions.headers["X-Algolia-UserToken"] = (Insights.shared(appId:  algoliaApplicationID)?.userToken).map { $0.rawValue }
        
        self.algoliaProductBrowserIndex.browse(query: query, requestOptions: requestOptions) { (content) in
            if case .success(let response) = content {
                completion(response.convertHits() , nil)
            }else if case .failure (let error) = content{
                completion(nil , error)
            }
        }
  
    }
    
    
    func searchOffersProductListForStoreCategory ( storeID : String , pageNumber : Int, _ hitsPerPage : Int = 20, _ slotTime : Int64  , completion : @escaping responseBlock ) -> Void {
        
        // Algolia query
        // promotional_shops.retailer_id={retailer_id} AND {slot_time} BETWEEN promotional_shops.start_time AND promotional_shops.end_time
        
        var facetFiltersA : [SingleOrList<String>] = []
        let facetFiltersForCurrentStoreID : String = "promotional_shops.retailer_id:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
        facetFiltersA.append(SingleOrList.single(facetFiltersForCurrentStoreID))
        
        let facetFiltersForCurrentShopsID : String = "shops.retailer_id:\(ElGrocerUtility.sharedInstance.cleanGroceryID(storeID))"
        facetFiltersA.append(SingleOrList.single(facetFiltersForCurrentShopsID))
        
        
        let currentTime =  Int64(Date().getUTCDate().timeIntervalSince1970 * 1000)
        if slotTime > currentTime {
            let facetFiltersForCategoryId : String = "\(slotTime) BETWEEN promotional_shops.start_time AND promotional_shops.end_time"
            facetFiltersA.append(SingleOrList.single(facetFiltersForCategoryId))
        }else {
            let facetFiltersForCategoryId : String = "\(currentTime) BETWEEN promotional_shops.start_time AND promotional_shops.end_time"
            facetFiltersA.append(SingleOrList.single(facetFiltersForCategoryId))
        }
        
        
        
        
        var query = Query("")
            .set(\.facetFilters, to: FiltersStorage.init(rawValue: facetFiltersA) )
            .set(\.clickAnalytics, to: true)
            .set(\.getRankingInfo, to: true)
            .set(\.analytics, to: true)
            .set(\.analyticsTags, to: self.getAlgoliaTags(isUniversal: false , searchType: "ProductListing"))
        
        query.page = pageNumber
        query.hitsPerPage = hitsPerPage
        var requestOptions = RequestOptions()
        requestOptions.headers["X-Algolia-UserToken"] = (Insights.shared(appId:  algoliaApplicationID)?.userToken).map { $0.rawValue }
        
        self.algoliaProductBrowserIndex.browse(query: query, requestOptions: requestOptions) { (content) in
            if case .success(let response) = content {
                completion(response.convertHits() , nil)
            }else if case .failure (let error) = content{
                completion(nil , error)
            }
        }
        
    }
    
    
    
}
