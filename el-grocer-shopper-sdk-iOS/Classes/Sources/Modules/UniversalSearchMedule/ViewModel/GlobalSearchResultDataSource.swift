//
//  GlobalSearchResultDataSource.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 25/01/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
class GlobalSearchResultDataSource {
    
    var searchString = ""
    var displayList : ((_ filterList : Dictionary<String, Array<Product>> , _ homeList : [Home] , _ filterGroceryList : [Grocery] )->Void)?
    var recipeList : [Recipe]?
    var productList : [Product]?
    var matchedGroceryList : [Grocery]?
    var filterData  : Dictionary<String, Array<Product>> = [:]
    var groceryAndBannersList : [Home] = []
    var filterGroceryList  : [Grocery] = ElGrocerUtility.sharedInstance.groceries
    let queue = OperationQueue()
    deinit {
        self.queue.cancelAllOperations()
    }
    func startFilterProcess() {
        let bannerWorkItem = DispatchWorkItem {
            self.filterAndSavedata()
        }
        DispatchQueue.global(qos: .utility).async(execute: bannerWorkItem)
    }
    func filterAndSavedata() {
        
        let groeryIdA = HomePageData.shared.groceryA?.map { (groery) -> String in
            return groery.dbID
        } ?? []
        for prodcut in productList! {
            if groeryIdA.count < prodcut.shopIds?.count ?? 0 {
                for groceryID in groeryIdA {
                    let grocerIdNumber = NSNumber(value: Int(groceryID) ?? 0)
                    if let isContain = prodcut.shopIds?.contains(grocerIdNumber) {
                        if isContain {
                            if var productList = filterData[groceryID] {
                                productList.append(prodcut)
                                filterData[groceryID] = productList
                            }else{
                                filterData[groceryID] = [prodcut]
                            }
                        }
                    }
                }
            }else{
                for shopId in prodcut.shopIds ?? [] {
                    if groeryIdA.contains(shopId.stringValue) {
                        if var productList = filterData[shopId.stringValue] {
                            productList.append(prodcut)
                            filterData[shopId.stringValue] = productList
                        }else{
                            filterData[shopId.stringValue] = [prodcut]
                        }
                    }
                }
            }
        }
        
        self.filterGroceryList = HomePageData.shared.groceryA?.filter { (grocery) -> Bool in
            if filterData.keys.contains(grocery.dbID) {
                return true
            }
            return false
        } ?? []
        self.groceryAndBannersList = []
        
        let featuredStores = filterGroceryList
            .filter{ $0.featured == 1 }
            .sorted(by: { ($0.priority ?? 0) < ($1.priority ?? 0) })
        
        let notFeaturedStores = filterGroceryList
                .filter{ $0.featured != 1 }
                .sorted(by: { ($0.priority ?? 0) < ($1.priority ?? 0) })
        
        self.filterGroceryList = (featuredStores) + (notFeaturedStores)
        
        filterGroceryList.forEach { grocery in
            let sortedProducts = ProductBrowser.shared.sortProductsOnTheBasisOfGrocery(products: filterData[grocery.dbID] ?? [], grocery: grocery)
            filterData[grocery.dbID] = sortedProducts
        }
        
        for data in self.filterGroceryList {
            
            let homeObj = Home.init(data.name ?? "" , withImageString: data.smallImageUrl ?? "" , withType: .universalSearchProducts, andWithProduct: self.filterData[data.dbID] ?? [] , grocery: data)
            groceryAndBannersList.append(homeObj)
            self.getBanners(searchInput: self.searchString, grocery: data)
        }
        
      
        
        self.displayList?(self.filterData , self.groceryAndBannersList  , self.filterGroceryList)
        queue.waitUntilAllOperationsAreFinished()
       
        
    }
    
    
    func getBanners(searchInput : String , grocery : Grocery? ){
        let updateA = BlockOperation {
            self.getBannersFromServer(grocery , searchInput: searchInput)
        }
        queue.addOperation(updateA)
        
    }
    
    private func getBannersFromServer(_ gorcery:Grocery? , searchInput : String){
        guard !searchInput.isEmpty else {
            return
        }
        let homeTitle = "Banners"
        if let gorceryId =  gorcery?.dbID {
            let location = BannerLocation.in_search_tier_1.getType()
            ElGrocerApi.sharedInstance.getBanners(for: location , retailer_ids: [ElGrocerUtility.sharedInstance.cleanGroceryID(gorceryId)], store_type_ids: nil , retailer_group_ids: nil  , category_id: nil , subcategory_id: nil, brand_id: nil, search_input: searchInput ) { (result) in
                switch result {
                    case .success(let response):
                        self.saveBannersResponseData(response, withHomeTitle: homeTitle, andWithGroceryId: gorcery)
                    case.failure(let error):
                        GenericClass.print(error.localizedMessage)
                }
            }
        }
        
        //        let parameters = NSMutableDictionary()
        //        parameters["limit"] = 10
        //        parameters["offset"] = 0
//        parameters["search_input"] = searchInput
//        parameters["banner_type"] = SearchBannerType.Serach.getString()
        /*
        ElGrocerApi.sharedInstance.getBannersOfGrocery(parameters) { (result) in
            
            switch result {
                
                case .success(let response):
                    self.saveBannersResponseData(response, withHomeTitle: homeTitle, andWithGroceryId: gorcery)
                    
                case .failure(let error):
                    GenericClass.print(error.localizedMessage)
                //  error.showErrorAlert()
            }
        }*/
    }
    
    func saveBannersResponseData(_ banners: [BannerCampaign], withHomeTitle homeTitle:String, andWithGroceryId gorcery : Grocery?) {
        if banners.count > 0 {
            let homeFeed = Home.init(homeTitle, withCategory: nil, withBanners: banners, withType:HomeType.Banner,  products: [], gorcery)
            if let groceryIndex =  groceryAndBannersList.firstIndex(where: { (home) -> Bool in
                return home.attachGrocery?.dbID == gorcery?.dbID
            }) {
                self.groceryAndBannersList.insert(homeFeed, at: groceryIndex + 1)
                self.displayList?(self.filterData , self.groceryAndBannersList  , self.filterGroceryList)
            }
        }
    }
}
