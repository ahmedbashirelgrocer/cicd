//
//  StoreFeeds.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 14/09/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import RxSwift





protocol StoreFeedsDelegate {
    func categoriesFetchingCompleted (_ index : Int , categories : [Category])
    func fetchingCompleted (_ index : Int)
}

class StoreFeeds {
    fileprivate let disposeBag = DisposeBag()
    
    var fetchCategoryWorkItem:DispatchWorkItem?
    var fetchProductsWorkItem:DispatchWorkItem?
    var delegate : StoreFeedsDelegate?
    var index : Int = 0
    var type : HomeType = .TopSelling
    var data : Home?
    var isRunning : Bool = false
    var grocery : Grocery?
    var isLoaded : Variable<Bool> = Variable(false)
    
    var offset: Int = 0
    var limit: Int = 20
    var isFirstPage: Bool = true
    
    init(type : HomeType  , index : Int , grocery : Grocery? , delegate : StoreFeedsDelegate? ) {
        self.delegate = delegate
        self.grocery = grocery
        self.index = index
        self.type = type
        self.isLoaded.asObservable().bind { (state) -> Void in
            if state {
                self.delegate?.fetchingCompleted(self.index)
            }
            
        }.disposed(by: disposeBag)
    }
    init(type : HomeType  , category : Category? , index : Int , grocery : Grocery? , delegate : StoreFeedsDelegate? ) {
        self.delegate = delegate
        self.grocery = grocery
        self.index = index
        self.type = type
        let homeFeed = Home.init(category?.name ?? "" , withCategory: category, andWithResponse: nil)
        self.data = homeFeed
        self.data?.category = category
        self.isLoaded.asObservable().bind { (state) -> Void in
            if state {
                elDebugPrint("reload tableview data Loaded")
                self.delegate?.fetchingCompleted(self.index)
            }
            
        }.disposed(by: disposeBag)
    }
    
    private func getCurrentDeliveryAddress() -> DeliveryAddress? {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    func getData() {
        
        
        if self.type == .ListOfCategories {
            self.getCategories()
        }else if self.type == .Banner && self.index == 0 {
            self.getLocationStoreTier1Banners()
        }else if self.type == .Banner{
            self.getLocationStoreTier2Banners()
        }else if self.type == .Purchased {
            self.getPreviousPurchase()
        }else if self.type == .TopSelling {
            self.getCategoryProducts()
        }
    }
    

    
    
}


//categories data
extension StoreFeeds {
    
    
    func getCategoryProducts() {
        guard !self.isRunning else {
            return
        }
        self.isRunning = true
        if let workItem = self.fetchProductsWorkItem {
            workItem.cancel()
        }
        self.fetchProductsWorkItem = DispatchWorkItem {
            let parameters = NSMutableDictionary()
            parameters["limit"] = self.limit
            parameters["offset"] = self.offset
            parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)
            if let tempCategory = self.data?.category {
                parameters["category_id"] = tempCategory.dbID
            }
            let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
            parameters["delivery_time"] =  time as AnyObject
            
        
            guard let tempCategory = self.data?.category else {
                self.isRunning = false
                self.isLoaded.value = true
                return
            }
            
            // find weather this 2nd page
            // if so we need to refresh specific cell instead of refresing whole table
            self.isFirstPage = self.offset < self.limit
            
            guard let config = ElGrocerUtility.sharedInstance.appConfigData, config.fetchCatalogFromAlgolia else {
                
                
                 ElGrocerApi.sharedInstance.getTopSellingProductsOfGrocery(parameters , true) { [weak self] (result) in
                 switch result {
                 case .success(let response):
                 self?.saveResponseDataOfCategoryWithTitle( response, category: self?.data?.category ?? nil)
                 case .failure(let error):
                 elDebugPrint(error.localizedMessage)
                 }
                 }
                
                return
                
            }
            
            // calculating the page number for algolia
            // for first request 0 / 20  = 0
            // for first request 20 / 20 = 1
            // for first request 60 / 20 = 2
            let pageNumber = self.offset / self.limit
            
            guard (self.data?.category?.dbID.intValue ?? 0) > 1 else {
                AlgoliaApi.sharedInstance.searchOffersProductListForStoreCategory(storeID: ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID), pageNumber: pageNumber, self.limit, ElGrocerUtility.sharedInstance.getCurrentMillis(), completion: { [weak tempCategory] (content, error) in
                    if  let responseObject : NSDictionary = content as NSDictionary? {
                        self.saveAlgoliaResponseDataOfCategoryWithTitle(responseObject, category: tempCategory)
                    } else {
                        self.isRunning = false
                        self.isLoaded.value = true
                        return
                    }
                })
                return
            }
            
            AlgoliaApi.sharedInstance.searchProductListForStoreCategory(storeID: ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID), pageNumber: pageNumber, categoryId: tempCategory.dbID.stringValue , completion: { [weak tempCategory] (content, error) in
                
                if  let responseObject : NSDictionary = content as NSDictionary? {
                    self.saveAlgoliaResponseDataOfCategoryWithTitle(responseObject, category: tempCategory)
                } else {
                    self.isRunning = false
                    self.isLoaded.value = true
                    return
                }
                
                
            })
            
            
          
        }
        DispatchQueue.global(qos: .utility).async(execute: self.fetchProductsWorkItem!)
    }
    
    func saveResponseDataOfCategoryWithTitle( _  responseObject:NSDictionary , category : Category?) {
        if let forceCategory = category {
            let existingProducts = self.data?.products ?? []
            self.data = Home.init(forceCategory.name ?? "", withCategory: forceCategory , withBanners: nil, withType: HomeType.Category, andWithResponse: responseObject, self.grocery)
            self.data?.products.append(contentsOf: existingProducts)
            
            self.data?.hasMoreProduct = ((self.data?.products.count ?? 0) - existingProducts.count) == self.limit ? true : false
        }
        self.isRunning = false
        self.isLoaded.value = true
       
    }
    
    func saveAlgoliaResponseDataOfCategoryWithTitle( _  responseObject:NSDictionary , category : Category?) {
        
        Thread.OnMainThread { [category , responseObject]
            if let forceCategory = category {
                let newProducts = Product.insertOrReplaceProductsFromDictionary(responseObject, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                let home = Home.init(forceCategory.name ?? "", withCategory: forceCategory, withType: HomeType.Category)
                home.products.append(contentsOf: self.data?.products ?? [])
                home.products.append(contentsOf: newProducts.products)
                home.attachGrocery = self.grocery
                home.hasMoreProduct = newProducts.products.count == self.limit ? true : false
                self.data = home
            }
        }
        
        Thread.OnMainThread {
            
            self.isRunning = false
            self.isLoaded.value = true
        }
      
        
    }
    
    
}



// previous purchase
extension StoreFeeds {
    
    func getPreviousPurchase() {
        guard !self.isRunning else {
            return
        }
        self.isRunning = true
        
        if !UserDefaults.isUserLoggedIn() {
            self.isRunning = false
            self.isLoaded.value = true
            return
        }
    
        let parameters = NSMutableDictionary()
        parameters["limit"] = self.limit
        parameters["offset"] = self.offset
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)
        parameters["shopper_id"] = UserDefaults.getLogInUserID()
        let time = ElGrocerUtility.sharedInstance.getCurrentMillis()
        parameters["delivery_time"] =  time as AnyObject
        
        // find weather this 2nd page
        // if so we need to refresh specific cell instead of refresing whole table
        self.isFirstPage = self.offset < self.limit
        
        ElGrocerApi.sharedInstance.getTopSellingProductsOfGrocery(parameters , false) { [weak self] (result) in
            switch result {
                case .success(let response):
                    self?.saveResponseDataWithTitle(localizedString("previously_purchased_products_title", comment: "") , withServerResponse: response)
                case .failure(let error):
                    elDebugPrint(error.localizedMessage)
                    self?.isRunning = false
                    self?.isLoaded.value = true
                    
            }
        }
    }
    
    func saveResponseDataWithTitle(_ homeTitle:String, withServerResponse  responseObject:NSDictionary) {
        let existingProducts = self.data?.products ?? []
        self.data = Home.init(homeTitle, withCategory: nil, withBanners: nil, withType: .Purchased, andWithResponse: responseObject, self.grocery)
        self.data?.products.append(contentsOf: existingProducts)
    
        // check the new
        self.data?.hasMoreProduct = ((self.data?.products.count ?? 0) - existingProducts.count) == self.limit ? true : false
        
        self.isRunning = false
        self.isLoaded.value = true
        
    }
    
}

// categories
extension StoreFeeds {
    
    
    private  func getCategories() {
        guard !self.isRunning else {
            return
        }
        self.isRunning = true
        guard let currentAddress = getCurrentDeliveryAddress() else {
            //self.tabBarController?.selectedIndex = 0
            return
        }
        if let workItem = self.fetchCategoryWorkItem {
            workItem.cancel()
        }
        
        self.fetchCategoryWorkItem = DispatchWorkItem {
            ElGrocerApi.sharedInstance.getAllCategories(currentAddress,
                                                        parentCategory:nil , forGrocery: self.grocery) { (result) -> Void in
                switch result {
                    case .success(let response):
                        self.saveAllCategories(responseDict: response, grocery: self.grocery)
                    case .failure( _):
                        self.isRunning = false
                        self.isLoaded.value = true
                   
                }
            }
        }
        DispatchQueue.global(qos: .userInitiated).async(execute: self.fetchCategoryWorkItem!)
        
        
    }
    
    private func saveAllCategories(responseDict : NSDictionary , grocery : Grocery?) {
        
        ElGrocerUtility.sharedInstance.basketFetchDict[grocery?.dbID ?? ""] = false
        if let categoryArray = responseDict["data"] as? [NSDictionary] {
            if let groceryBgContext = DatabaseHelper.sharedInstance.getEntityWithName(GroceryEntity, entityDbId: grocery?.dbID as AnyObject, keyId: "dbID", context: DatabaseHelper.sharedInstance.mainManagedObjectContext) as? Grocery {
                Category.insertOrUpdateCategoriesForGrocery(groceryBgContext, categoriesArray: categoryArray, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                DatabaseHelper.sharedInstance.saveDatabase()
            }else{
                elDebugPrint("check here");
            }
        }
        if let updateGrocery = Grocery.getGroceryById(grocery?.dbID ?? "", context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            if var categories = updateGrocery.categories.allObjects as? [Category] {
                categories.sort { $0.sortID < $1.sortID}
                self.data = Home.init(localizedString("lbl_Shop_Category", comment: ""), withCategory: categories, withType: .ListOfCategories)
            }
        }else{
            if var categories = grocery?.categories.allObjects as? [Category] {
                categories.sort { $0.sortID < $1.sortID}
                self.data = Home.init(localizedString("lbl_Shop_Category", comment: ""), withCategory: categories, withType: .ListOfCategories)
            }
        }
        
        self.delegate?.categoriesFetchingCompleted(self.index, categories: self.data?.categories ?? [])
        self.isRunning = false
        self.isLoaded.value = true
       
       
    }
    
    
    
}




// Banners
extension StoreFeeds {
    
    
    private  func getLocationStoreTier2Banners() {
        
        guard !self.isRunning else {
            return
        }
        self.isRunning = true
        let groceryId = ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID ?? "")
        let homeTitle = "Banners"
        let parameters = NSMutableDictionary()
        parameters["limit"] = 1000
        parameters["offset"] = 0
        parameters["retailer_id"] = groceryId
        parameters["banner_type"] = SearchBannerType.Home.getString()
        parameters["date_filter"] = true
        let location = BannerLocation.store_tier_2.getType()
        ElGrocerApi.sharedInstance.getBannersFor(location: location , retailer_ids: [ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])], store_type_ids: nil , retailer_group_ids: nil  , category_id: nil , subcategory_id: nil, brand_id: nil, search_input: nil) { (result) in
            switch result {
                case .success(let response):
                    self.saveCustomBanner(response, withHomeTitle: homeTitle, andWithGroceryId: groceryId)
                case.failure( _):
                    self.isRunning = false
                    self.isLoaded.value = true
            }
        }
        
    }
    
    
    private  func getLocationStoreTier1Banners() {
        
        guard !self.isRunning else {
            return
        }
        self.isRunning = true
        let groceryId = ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID ?? "")
        let homeTitle = "Banners"
        let parameters = NSMutableDictionary()
        parameters["limit"] = 1000
        parameters["offset"] = 0
        parameters["retailer_id"] = groceryId
        parameters["banner_type"] = SearchBannerType.Home.getString()
        parameters["date_filter"] = true
        let location = BannerLocation.store_tier_1.getType()
        ElGrocerApi.sharedInstance.getBannersFor(location: location , retailer_ids: [ElGrocerUtility.sharedInstance.cleanGroceryID(parameters["retailer_id"])], store_type_ids: nil , retailer_group_ids: nil  , category_id: nil , subcategory_id: nil, brand_id: nil, search_input: nil) { (result) in
            switch result {
                case .success(let response):
                    self.saveCustomBanner(response, withHomeTitle: homeTitle, andWithGroceryId: groceryId)
                case.failure( _):
                    self.isRunning = false
                    self.isLoaded.value = true
            }
        }
        
    }
    
    func saveCustomBanner(_ responseObject:NSDictionary, withHomeTitle homeTitle:String, andWithGroceryId gorceryId:String) {
        
        if (self.grocery?.dbID == gorceryId){
            let banners = BannerCampaign.getBannersFromResponse(responseObject)
            self.data = Home.init(withBanners: banners, withType: .Banner, grocery: self.grocery)
        }
        self.isRunning = false
        self.isLoaded.value = true
        
    }
  
}
