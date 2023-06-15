//
//  ProductBrowser.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 14/03/2023.
//

import Foundation

// MARK: - Product fetch from Algolia
class ProductBrowser {
    
    typealias ResponseBlock = (_ banners: (products: [Product], algoliaCount: Int?)?, _ error: Error?) -> ()
    static var shared = ProductBrowser()
    
    init() {
        
    }
    
    /// Browse products for category
    func searchProductListForStoreCategory(storeID: String,
                                           pageNumber: Int,
                                           categoryId: String,
                                           hitsPerPage: Int,
                                           _ subCategoryID: String = "",
                                           _ brandId: String = "",
                                           slots: Int,
                                           completion: @escaping ResponseBlock ) {
        
        AlgoliaApi.sharedInstance
            .searchProductListForStoreCategory(storeID: storeID,
                                               pageNumber: pageNumber,
                                               categoryId: categoryId,
                                               hitsPerPage,
                                               subCategoryID,
                                               brandId) { responseObject, error in
                if error == nil, let response = responseObject as? NSDictionary {
                    DispatchQueue.main.async {
                        let products = Product.insertOrReplaceProductsFromDictionary(response, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        self.fetchTopSortProducts(products.products, slots: slots) { productsOly in
                            DispatchQueue.main.async{ completion((productsOly, products.algoliaCount), nil) }
                        }
                    }
                } else {
                    completion(nil, error)
                }
            }
    }
    
    /// Browse products
    func searchOffersProductListForStoreCategory(storeID: String,
                                                 pageNumber: Int,
                                                 hitsPerPage: Int = 20,
                                                 _ slotTime: Int64,
                                                 slots: Int,
                                                 completion: @escaping ResponseBlock) -> Void {
        
        AlgoliaApi.sharedInstance
            .searchOffersProductListForStoreCategory(storeID: storeID,
                                                     pageNumber: pageNumber,
                                                     hitsPerPage,
                                                     slotTime) { responseObject, error in
                if error == nil, let response = responseObject as? NSDictionary {
                    DispatchQueue.main.async {
                        let products = Product.insertOrReplaceProductsFromDictionary(response, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        self.fetchTopSortProducts(products.products, slots: slots) { productsOly in
                            DispatchQueue.main.async{ completion((productsOly, products.algoliaCount), nil) }
                        }
                    }
                } else {
                    completion(nil, error)
                }
            }
    }
    
    /// Search product
    func searchRecipeQueryWithMultiStore (_ searchText : String , storeIDs : [String] , typeIDs : [String] , groupIds : [String]  , _ pageNumber : Int = 0 , _ hitsPerPage : UInt = 100 , _ brand : String = "" , _ category : String = "" , searchType: String  , completion: @escaping (_ result: [Recipe]) -> Void) -> Void {
        
        AlgoliaApi.sharedInstance
            .searchRecipeQueryWithMultiStore(searchText,
                                             storeIDs: storeIDs,
                                             typeIDs: typeIDs,
                                             groupIds: groupIds,
                                             pageNumber,
                                             hitsPerPage,
                                             brand,
                                             category,
                                             searchType: searchType) { responseObject, error in
                
                DispatchQueue.main.async {
                    if  let responseObject : NSDictionary = responseObject as NSDictionary? {
                        var recipeList = [Recipe]()
                        if let categoryData = responseObject["hits"] as? [NSDictionary] {
                            for data:NSDictionary in categoryData {
                                let recipe : Recipe = Recipe.init(recipeData: data as! Dictionary<String, Any> )
                                recipeList.append(recipe)
                            }
                        }
                        completion(recipeList)
                        return
                    }
                    completion([])
                }
            }
        
    }
    /// Search product
    func searchProductQueryWithMultiStoreMultiIndex(_ searchText: String,
                                                    storeIDs: [String],
                                                    _ pageNumber: Int = 0,
                                                    _ hitsPerPage: UInt = 100,
                                                    _ brand: String = "",
                                                    _ category: String = "",
                                                    searchType: String,
                                                    slots: Int,
                                                    completion : @escaping (_ product: (products: [Product],
                                                                                        algoliaCount: Int?),
                                                                            _ groceryA: [Grocery]) -> Void) -> Void {
        
        AlgoliaApi.sharedInstance
            .searchProductQueryWithMultiStoreMultiIndex(searchText,
                                                        storeIDs: storeIDs,
                                                        pageNumber,
                                                        hitsPerPage,
                                                        brand,
                                                        category,
                                                        searchType: searchType) { (data, error) in
                if data == nil {
                    
                    completion(([], nil), [])
                        
                } else if let dataA = data?["results"] as? NSArray {
                    
                    var productsDictionary : NSDictionary = [:]
                    for data in dataA {
                        if let response = (data as? NSDictionary), (response["index"] as? String) == "Product" {
                            productsDictionary  = response
                        }
                        else if let response = (data as? NSDictionary), (response["index"] as? String) == "Retailer" {
                            Thread.OnMainThread {
                                var responseGroceryIDA : [String] = []
                                if let responseObjects = response["hits"] as? [NSDictionary] {
                                    for responseDict in responseObjects {
                                        if  let groceryIntId = responseDict["id"] as? Int {
                                            responseGroceryIDA.append("\(groceryIntId)")
                                        }
                                    }
                                }
                                
                                let groceryA = HomePageData.shared.groceryA?
                                    .filter({ grocery in
                                        return  responseGroceryIDA
                                            .filter { searchID in return searchID == grocery.dbID }
                                            .count > 0
                                    })
                                
                                if ElGrocerUtility.sharedInstance.activeGrocery == nil {
                                    ElGrocerUtility.sharedInstance.activeGrocery = HomePageData.shared.groceryA?.first{ $0.featured == 1 } ?? HomePageData.shared.groceryA?.first
                                }
                                
                                let newProducts = Product.insertOrReplaceProductsFromDictionary(productsDictionary, context: DatabaseHelper.sharedInstance.mainManagedObjectContext, searchString: searchText, nil, storeIDs.count < 2)
                                
                                self.fetchTopSortProducts(newProducts.products, slots: slots) { productsOly in
                                    DispatchQueue.main.async{ completion((productsOly, newProducts.algoliaCount), groceryA ?? []) }
                                }
                            }
                        }
                    }
                
                } else if let responseObject : NSDictionary = data as NSDictionary? {
                    
                    if ElGrocerUtility.sharedInstance.activeGrocery == nil {
                        ElGrocerUtility.sharedInstance.activeGrocery = HomePageData.shared.groceryA?.first{ $0.featured == 1 } ?? HomePageData.shared.groceryA?.first
                    }
                    let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    self.fetchTopSortProducts(newProducts.products, slots: slots) { productsOly in
                        DispatchQueue.main.async{ completion((productsOly, newProducts.algoliaCount), []) }
                    }

                }
                    
            }
            
    }
    
    /// When tapped on view all items from a store after product search
    func searchProductQueryWithMultiStore(_ searchText: String,
                                          storeIDs: [String],
                                          _ pageNumber: Int = 0,
                                          _ hitsPerPage: UInt = 100,
                                          _ brand: String = "",
                                          _ category: String = "",
                                          searchType: String,
                                          slots: Int,
                                          completion: @escaping ResponseBlock) -> Void {
        
        AlgoliaApi.sharedInstance
            .searchProductQueryWithMultiStore (searchText,
                                               storeIDs: storeIDs,
                                               pageNumber,
                                               hitsPerPage,
                                               brand,
                                               category,
                                               searchType: searchType) { responseObject, error in
                if error == nil, let response = responseObject as? NSDictionary {
                    DispatchQueue.main.async {
                        let products = Product.insertOrReplaceProductsFromDictionary(response, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        self.fetchTopSortProducts(products.products, slots: slots) { productsOly in
                            DispatchQueue.main.async{ completion((productsOly, products.algoliaCount), nil) }
                        }
                    }
                } else {
                    completion(nil, error)
                }
            }
    }
}

// MARK: - Fetch Products from elGrocer Server
extension ProductBrowser {
    
    typealias SuccessResponse = (products: [Product], algoliaCount: Int?)
    
    func getProductsForBrand(_ brand: GroceryBrand,
                             forSubCategory parentSubCategory: SubCategory?,
                             andForGrocery grocery: Grocery,
                             limit: Int,
                             offset: Int,
                             slots: Int = 3,
                             completionHandler: @escaping (_ result: Either<SuccessResponse>) -> Void) {
        
        ElGrocerApi.sharedInstance
            .getProductsForBrand(brand,
                                 forSubCategory: parentSubCategory,
                                 andForGrocery: grocery,
                                 limit: limit,
                                 offset: offset) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        let products = Product.insertOrReplaceProductsFromDictionary(response, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        self.fetchTopSortProducts(products.products, slots: slots) { productsOly in
                            DispatchQueue.main.async{ completionHandler(.success((productsOly, products.algoliaCount))) }
                        }
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    func getAllProductsOfCategory(_ parentCategory: Category?,
                                  forGrocery grocery: Grocery?,
                                  limit: Int,
                                  offset: Int,
                                  slots: Int = 3,
                                  completionHandler: @escaping (_ result: Either<SuccessResponse>) -> Void) {
        
        ElGrocerApi.sharedInstance
            .getAllProductsOfCategory(parentCategory,
                                      forGrocery: grocery,
                                      limit: limit,
                                      offset: offset) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        let products = Product.insertOrReplaceProductsFromDictionary(response, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        self.fetchTopSortProducts(products.products, slots: slots) { productsOly in
                            DispatchQueue.main.async{ completionHandler(.success((productsOly, products.algoliaCount))) }
                        }
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        
    }
    
    func getAllProductsOfSubCategory(_ subCategoryId: Int,
                                     andWithGroceryID groceryId: String,
                                     limit: Int,
                                     offset: Int,
                                     slots: Int = 3,
                                     completionHandler: @escaping (_ result: Either<SuccessResponse>) -> Void) {
        
        ElGrocerApi.sharedInstance
            .getAllProductsOfSubCategory(subCategoryId,
                                         andWithGroceryID: groceryId,
                                         limit: limit,
                                         offset: offset) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        let products = Product.insertOrReplaceProductsFromDictionary(response, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        self.fetchTopSortProducts(products.products, slots: slots) { productsOly in
                            DispatchQueue.main.async{ completionHandler(.success((productsOly, products.algoliaCount))) }
                        }
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    func getTopSellingProductsOfGrocery(_ parameters: NSDictionary,
                                        _ isTopProductSearch: Bool = false,
                                        slots: Int = 3,
                                        completionHandler: @escaping (_ result: Either<SuccessResponse>) -> Void) {
        
        ElGrocerApi.sharedInstance
            .getTopSellingProductsOfGrocery(parameters,
                                            isTopProductSearch) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        let products = Product.insertOrReplaceProductsFromDictionary(response, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        self.fetchTopSortProducts(products.products, slots: slots) { productsOly in
                            DispatchQueue.main.async{ completionHandler(.success((productsOly, products.algoliaCount))) }
                        }
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
}

// MARK: - Fetch brands and products
extension ProductBrowser {
    
    func getBrandsForCategoryWithProducts(_ parentCategory: SubCategory?,
                                          forGrocery grocery: Grocery?,
                                          limit: Int,
                                          offset: Int,
                                          productLimmit: Int = 10,
                                          productOffset: Int = 0,
                                          subCategoryId: Int,
                                          completionHandler:@escaping (_ result: Either<[GroceryBrand]>) -> Void) {
        
        let slots = ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.sponsoredSlotsSubcategories ?? 3

        ElGrocerApi.sharedInstance
            .getBrandsForCategoryWithProducts(parentCategory,
                                              forGrocery : grocery,
                                              limit: limit,
                                              offset: offset,
                                              productLimmit: productLimmit,
                                              productOffset: productOffset) { result in
                
                switch result {
                case .success(let response):
                    if let serverBrandsArray = response["data"] as? [[String:AnyObject]] {
                        DispatchQueue.main.async {
                            var brands = [GroceryBrand]()
                            for dictBrand in serverBrandsArray {
                                let brand = GroceryBrand.getGroceryBrandFromResponse(dictBrand, subCategoryId)
                                brands.append(brand)
                            }
                            
                            let productIDs = brands.flatMap{ $0.products.map{ "\($0.productId)" } }
                            
                            self.fetchTopSortProducts(productIDs) { winners in
                                DispatchQueue.main.async {
                                    
                                    if winners.count > 0 {
                                        for index in 0..<brands.count {
                                            for index2 in 0..<brands[index].products.count {
                                                let id = brands[index].products[index2].productId
                                                brands[index].products[index2].winner = winners.first{ $0.id == "\(id)" }
                                            }
                                        }
                                        
                                        brands.sort { b1, b2 in
                                            let r1 = b1.products.reduce(0) { partialResult, p in
                                                return p.isSponsoredProduct ? 1 : 0
                                            }
                                            
                                            let r2 = b2.products.reduce(0) { partialResult, p in
                                                return p.isSponsoredProduct ? 1 : 0
                                            }
                                            return r1 > r2
                                        }
                                        
                                        for index in 0..<brands.count {
                                            brands[index].products.sort(by: { ($0.rank ?? 10000) < ($1.rank ?? 10000) })
                                        }
                                        
                                        for index in 0..<brands.count {
                                            if brands[index].products.count > slots {
                                                for index2 in slots..<brands[index].products.count where brands[index].products[index2].winner != nil {
                                                    brands[index].products[index2].winner = nil
                                                }
                                            }
                                        }
                                    }
                                    completionHandler(.success(brands))
                                }
                            }
                        }
                    } else {
                        completionHandler(.failure(ElGrocerError.parsingError()))
                    }
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
}

// MARK: - Fetch sponsored product winners from TopSort
fileprivate extension ProductBrowser {
    func fetchTopSortProducts(_ products: [Product], slots: Int, completion: @escaping ([Product]) -> Void) {
        guard products.count > 0 else {
            completion(products)
            return
        }
        
        var products = products
        
        let productIDs = products.map { "\($0.productId)" }
        TopsortManager.shared.auctionListings(productIDs, slots: slots) { result in
            switch result {
            case .success(let winners):
                if winners.count > 0 {
                    for index in 0..<products.count {
                        let id = products[index].productId
                        products[index].winner = winners.first{ $0.id == "\(id)" }
                    }
                }
                
                products = self.sortProducts(products: products)
                completion(products)
            case .failure(let error):
                debugPrint(error.localizedDescription)
                completion(products)
            }
        }
    }
    
    func fetchTopSortProducts(_ productIDs: [String], completion: @escaping ([Winner]) -> Void) {
        
        guard productIDs.count > 0 else {
            completion([])
            return
        }
        
        TopsortManager.shared.auctionListings(productIDs, slots: productIDs.count) { result in
            switch result {
            case .success(let winners):
                completion(winners)
            case .failure(let error):
                debugPrint(error.localizedDescription)
                completion([])
            }
        }
    }
    
    private func sortProducts(products: [Product]) -> [Product] {
        var sorted: [Product] = []
        
        let sponsored = products.filter { $0.isSponsoredProduct }
        let promotional = products.filter { $0.promotion?.boolValue == true && $0.isSponsoredProduct == false }.prefix(2)
        let otherProducts = products.filter { !($0.isSponsoredProduct || promotional.contains($0)) }

        if promotional.isNotEmpty {
            sorted = sponsored + promotional + otherProducts
        } else {
            sorted = sponsored + otherProducts
        }
        
        return sorted
    }
}
