//
//  HomePageData.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 03/10/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import CleverTapSDK

protocol HomePageDataLoadingComplete : class {
    func loadingDataComplete(type : loadingType?)
    func refreshMessageView(msg: String) -> Void
}
extension HomePageDataLoadingComplete  {
    func refreshMessageView(msg: String) -> Void {}
}

enum loadingType {
    case CategoryAndStoreList
    case CategoryList
    case RetailerTypeList
    case StoreList
    case HomePageLocationOneBanners
    case HomePageLocationTwoBanners
    case AllChefForDeliveryStores
    case FeatureRecipesOfAllDeliveryStore
}

extension HomePageData : HomePageDataLoadingComplete {
    func loadingDataComplete(type : loadingType?) {
        elDebugPrint("DataLoaded: \(String(describing: type)) : \(String(describing: self.delegate))")
    }
}

class HomePageData  {
    
    static let shared: HomePageData = {
        let instance = HomePageData()
        instance.dataSource = StoresDataHandler()
        instance.dataSource?.delegate = instance
        instance.delegate = instance
        instance.recipeDataHandler = RecipeDataHandler()
        instance.recipeDataHandler?.delegate = instance
        return instance
    }()
    private var dataSource : StoresDataHandler?
    private lazy var recipeDataHandler : RecipeDataHandler? = nil
    private var storeListWorkItem:DispatchWorkItem?
    private var chefAndRecipeItem:DispatchWorkItem?
    weak var delegate : HomePageDataLoadingComplete?
    lazy var serviceA : [[MainCategoryCellType : Any]] = []
    lazy var categoryServiceA : [[MainCategoryCellType : Any]] = []
    lazy var storeTypeA : [StoreType]? = nil
    lazy var retailerTypeA : [RetailerType]? = nil
    lazy var groceryA : [Grocery]? = nil {
        didSet {
            self.createGenericStoresDictionary()
        }
    }
    var storyTypeBaseDataDict : [Int64 : [Grocery]] = [:]
    var genericAllStoreDictionary: [String: Any]? // key against each grocery is its id.
    
    lazy var hyperMarketA : [Grocery]? = nil
    lazy var superMarketA : [Grocery]? = nil
    lazy var specialityStoreA : [Grocery]? = nil
    
    lazy var locationOneBanners : [BannerCampaign]? = nil
    lazy var locationTwoBanners : [BannerCampaign]? = nil
    lazy var chefList : [CHEF] = [CHEF]()
    lazy var recipeList : [Recipe] = [Recipe]()
    lazy var featureGroceryBanner : [BannerCampaign] = []
    private var fetchOrder : [loadingType]  = []
            var isDataLoading : Bool = false
    private var isFetchingTimeLogEnable : Bool = false
    private lazy var startFetchingTime : Date = Date()
    private lazy var endFetchFetchingTime : Date = Date()
    lazy var ctConfig : CleverTapConfig = {
        let config = CleverTapConfig()
        config.setInitialData()
        return config
    }()
    
    init() {
        self.dataSource = StoresDataHandler()
        self.dataSource?.delegate = self
        self.delegate = self
        self.recipeDataHandler = RecipeDataHandler()
        self.recipeDataHandler?.delegate = self
    }
    
    func fetchHomeData( _ logEnable : Bool = false) {
        self.isFetchingTimeLogEnable = logEnable
        self.resetHomeDataHandler()
        self.fetchOrder = []
        self.fetchOrder = SDKManager.isSmileSDK ?  [.CategoryAndStoreList , .HomePageLocationOneBanners ,  .HomePageLocationTwoBanners] : [.CategoryAndStoreList , .HomePageLocationOneBanners ,  .HomePageLocationTwoBanners , .AllChefForDeliveryStores , .FeatureRecipesOfAllDeliveryStore]
        self.isDataLoading = true
        if self.isFetchingTimeLogEnable { self.startFetchingTime = Date() }
        self.startFetching()
        SDKManager.shared.homeLastFetch = Date()
        
    }
    
    func fetchStoreData( _ logEnable : Bool = false) {
        self.isFetchingTimeLogEnable = logEnable
        self.fetchOrder = [.StoreList]
        self.isDataLoading = true
        if self.isFetchingTimeLogEnable { self.startFetchingTime = Date() }
        self.startFetching()
    }
    
    private func startFetching() {
        guard self.fetchOrder.count > 0 else {
            self.isDataLoading = false
            if self.isFetchingTimeLogEnable { self.endFetchFetchingTime = Date()
                elDebugPrint("DataLoaded: Home Page Call time Duration : \(self.endFetchFetchingTime.timeIntervalSince(self.startFetchingTime))")
            }
            return
        }
        let type = self.fetchOrder[0]
        self.fetchOrder.remove(at: 0)
        switch type {
            case .StoreList:
                self.getStoreData(isOnGlobalDispatch : false)
            case .CategoryAndStoreList:
                self.getStoreData(isOnGlobalDispatch : true)
            case .HomePageLocationOneBanners:
                self.getBannerLocationOne()
            case .HomePageLocationTwoBanners:
                self.getBannersLocationTwo()
            case .AllChefForDeliveryStores:
                self.callForHomeChefs()
            case .FeatureRecipesOfAllDeliveryStore:
                self.callForRecipeForFeatureCategory()
            default:
                return
        }
    }
    
    
    
    
    private func getStoreData( isOnGlobalDispatch : Bool = true) {
        guard let currentAddress = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress() else {
            self.startFetching()
            return
        }
        
        guard isOnGlobalDispatch else {
            self.dataSource?.getRetailerData(for: currentAddress)
            return
        }
        
        if let item = self.storeListWorkItem {
            item.cancel()
        }
        self.storeListWorkItem = DispatchWorkItem {
            self.dataSource?.getRetailerData(for: currentAddress)
        }
        DispatchQueue.global(qos: .userInitiated).async(execute: self.storeListWorkItem!)
    }
    
    private func getBannerLocationOne () {
        guard self.groceryA?.count ?? 0 > 0 else {
            self.startFetching()
            return
        }
        
        if let item = self.storeListWorkItem {
            item.cancel()
        }
        self.storeListWorkItem = DispatchWorkItem {
            self.dataSource?.getGenericBanners(for: self.groceryA ?? [])
        }
        DispatchQueue.global(qos: .userInitiated).async(execute: self.storeListWorkItem!)
        
    }
    
    private func getBannersLocationTwo () {
        guard self.groceryA?.count ?? 0 > 0 else {
            self.startFetching()
            return
        }
        if let item = self.storeListWorkItem {
            item.cancel()
        }
        self.storeListWorkItem = DispatchWorkItem {
            self.dataSource?.getGreatDealsBanners(for: self.groceryA ?? [], and: self.storeTypeA ?? [])
        }
        DispatchQueue.global(qos: .userInitiated).async(execute: self.storeListWorkItem!)
       
    }
    
    // Please make sure to get delivery grocery array first before calling these methods.  or assign value to groceryA object
    func callForHomeChefs() {
        
        guard self.groceryA?.count ?? 0 > 0 else {
            self.startFetching()
            return
        }
        if let item = self.chefAndRecipeItem {
            item.cancel()
        }
        self.chefAndRecipeItem = DispatchWorkItem {
            let retailerString = self.GenerateRetailerIdString(groceryA: self.groceryA ?? [])
            if retailerString.count > 0 {
                self.recipeDataHandler?.getAllChefList(retailerString: retailerString , true)
            }
            
        }
        DispatchQueue.global(qos: .utility).async(execute: self.chefAndRecipeItem!)
    }
    
    
    func callForRecipeForFeatureCategory() {
        
        guard self.groceryA?.count ?? 0 > 0 else {
            self.startFetching()
            return
        }
        if let item = self.chefAndRecipeItem {
            item.cancel()
        }
        self.chefAndRecipeItem = DispatchWorkItem {
            let retailerString = self.GenerateRetailerIdString(groceryA: self.groceryA ?? [])
            if retailerString.count > 0 {
                self.recipeDataHandler?.getNextRecipeList(retailersId: retailerString, categroryId: kfeaturedCategoryId , limit: "100" , true)
            }
        }
        DispatchQueue.global(qos: .utility).async(execute: self.chefAndRecipeItem!)
    }
    
    
    
    
 
}
//Mark:- Helpers
extension HomePageData {
   
    private func GenerateRetailerIdString(groceryA : [Grocery]?) -> String{
        
        var retailerIDString = ""
        if groceryA?.count ?? 0 > 0{
            var i = 0
            while i < groceryA!.count {
                if i == 0 {
                    retailerIDString.append((groceryA?[i].dbID)!)
                }else{
                    retailerIDString.append("," + (groceryA?[i].dbID)!)
                }
                i = i + 1
            }
        }
        return retailerIDString
    }
    
    private func getHomeVc () -> GenericStoresViewController? {
        //if let SDKManager = SDKManager.shared {
            let tabVc = SDKManager.shared.getTabbarController(isNeedToShowChangeStoreByDefault: false)
            if tabVc.viewControllers.count > 0 ,  let tabbar = (tabVc.viewControllers[0] as? UITabBarController) , let tabController = (tabbar.viewControllers?[0] as? ElGrocerNavigationController) , tabController.viewControllers.count > 0 ,  let HomeVc = (tabController.viewControllers[0] as? GenericStoresViewController) {
                return HomeVc
            }
        //}
        return nil
    }
    
    public func resetHomeDataHandler() {
        self.storeTypeA?.removeAll()
        self.groceryA?.removeAll()
        self.locationOneBanners?.removeAll()
        self.locationTwoBanners?.removeAll()
        if let item = self.storeListWorkItem {
            item.cancel()
        }
        self.isDataLoading = false
    }
    
    public func sortServiceArray() {
        
        self.serviceA = self.serviceA.sorted { serviceOne, serviceTwo in
            var priorityOne: Int64 = 0
            var priorityTwo: Int64 = 0
            if let retailerType = serviceOne[MainCategoryCellType.Services] as? RetailerType {
                priorityOne =  retailerType.priority
            }
            if let retailerType = serviceTwo[MainCategoryCellType.Services] as? RetailerType {
                priorityTwo =  retailerType.priority
            }
            if let retailerType = serviceOne[MainCategoryCellType.ClickAndCollect] as? ClickAndCollectService {
                priorityOne =  retailerType.priority
            }
            if let retailerType = serviceTwo[MainCategoryCellType.ClickAndCollect] as? ClickAndCollectService {
                priorityTwo =  retailerType.priority
            }
            if let retailerType = serviceOne[MainCategoryCellType.Recipe] as? RecipeService {
                priorityOne =  retailerType.priority
            }
            if let retailerType = serviceTwo[MainCategoryCellType.Recipe] as? RecipeService {
                priorityTwo =  retailerType.priority
            }
            
            if let retailerType = serviceOne[MainCategoryCellType.Deals] as? StorylyDeals {
                priorityOne =  retailerType.priority
            }
            if let retailerType = serviceTwo[MainCategoryCellType.Deals] as? StorylyDeals {
                priorityTwo =  retailerType.priority
            }
            
            return priorityOne < priorityTwo
        }
        
    }
    
    private func setFeatureGrocery() {
        
        self.featureGroceryBanner.removeAll()
        
        if let grocery = self.groceryA?.first(where: { grocery in
            return grocery.featured?.boolValue ?? false
        }) {
            let campaign = BannerCampaign.init()
            campaign.imageUrl = grocery.featureImageUrl  ?? ""
            if let groceryID = Int(grocery.getCleanGroceryID()) {
                if groceryID > 0 {
                    campaign.retailerIds = [groceryID]
                    campaign.campaignType = NSNumber.init(integerLiteral: BannerCampaignType.priority.rawValue)
                }
            }
            self.featureGroceryBanner = [campaign]
        }
        if self.featureGroceryBanner.count == 0 {
            FireBaseEventsLogger.trackNoPriorityStore()
        }
    }
    
    private func updateDataInStoreTypeDict () {
        
        let dataA = self.storeTypeA ?? []
        for type in dataA {
            if type.storeTypeid == 0 {
                self.storyTypeBaseDataDict[type.storeTypeid] = self.groceryA
            } else {
            
                let groceryFiltered = (self.groceryA ?? []).filter { (grocery) -> Bool in
                    return grocery.storeType.contains(NSNumber(value: type.storeTypeid))
                }
                self.storyTypeBaseDataDict[type.storeTypeid] = groceryFiltered
            }
        }
        
    }
    
    
}


extension HomePageData : RecipeDataHandlerDelegate {
    
    func chefList(chefTotalA : [CHEF]) -> Void {
        self.chefList = chefTotalA
        self.addRecipeInServices(chefTotalA: self.chefList)
        self.delegate?.loadingDataComplete(type: .AllChefForDeliveryStores)
        self.startFetching()
        
    }

    func recipeList(recipeTotalA : [Recipe]) -> Void {
        self.recipeList = recipeTotalA
        self.delegate?.loadingDataComplete(type: .FeatureRecipesOfAllDeliveryStore)
        self.startFetching()
        if self.recipeList.count == 0  {
            FireBaseEventsLogger.trackNoRecipe()
        }
    }
    
    private func addRecipeInServices(chefTotalA : [CHEF]) {
        if SDKManager.isSmileSDK { return }
        
        if chefTotalA.count > 0 {
        let recipe = RecipeService.init(isRecipeEnable: true, priority: 6)
        self.serviceA.append([MainCategoryCellType.Recipe : recipe])
        self.sortServiceArray()
        }
        
    }
    
    private func setCategoryServiceA (_ storeTypeA : [StoreType]) {
        
        let queue = DispatchQueue(label: "self.categoryServiceA-thread-safe-obj", attributes: .concurrent)
        queue.async(flags: .barrier) {
            self.categoryServiceA.removeAll()
            for data in storeTypeA {
                let dataObj = [MainCategoryCellType.Categories : data]
                self.categoryServiceA.append(dataObj)
                if self.categoryServiceA.count == 5 {
                    let dataObj = [MainCategoryCellType.ViewAllCategories : storeTypeA]
                    self.categoryServiceA.append(dataObj)
                    break
                }
            }
        }
        
    }
    
    
    func filterOutStoreArrayOnTheBasisOfMarketType(_ groceryA : [Grocery]) {
        
        if self.hyperMarketA == nil {
            self.hyperMarketA = []
        }
        if self.specialityStoreA == nil {
            self.specialityStoreA = []
        }
        if self.superMarketA == nil {
            self.superMarketA = []
        }
        
        self.hyperMarketA?.removeAll()
        self.specialityStoreA?.removeAll()
        self.superMarketA?.removeAll()
        
        for grocery in groceryA {
            if grocery.isHyperMarket() {
                self.hyperMarketA?.append(grocery)
            } else if grocery.isSuperMarket() {
                self.superMarketA?.append(grocery)
            } else if grocery.isSpecialityMarket() {
                self.specialityStoreA?.append(grocery)
            }
        }
        
    }
    
}

extension HomePageData : StoresDataHandlerDelegate {
    
    func refreshMessageView(msg: String) -> Void {
        guard !(self.delegate is HomePageData) else {return}
        self.delegate?.refreshMessageView(msg: msg)
    }
    
    func storeRetailerTypeData(retailerTypeA : [RetailerType]) -> Void {
        
        self.retailerTypeA = retailerTypeA
        
        let queue = DispatchQueue(label: "self.serviceA-thread-safe-obj", attributes: .concurrent)
        queue.async(flags: .barrier) {
            self.serviceA.removeAll()
            for retailerType in retailerTypeA {
                let data = [MainCategoryCellType.Services : retailerType]
                self.serviceA.append(data)
            }
            self.sortServiceArray()
        }
        self.delegate?.loadingDataComplete(type: .RetailerTypeList)
    }
    
    func storeCategoryData(storeTypeA : [StoreType]) -> Void  {
        self.storeTypeA = storeTypeA
        self.storeTypeA = self.storeTypeA?.sorted(by: { typeOne, typeTwo in
            return typeOne.priority < typeTwo.priority
        })
        self.setCategoryServiceA(self.storeTypeA ?? [])
        self.delegate?.loadingDataComplete(type: .CategoryList)
    }
    func allRetailerData(groceryA : [Grocery]) -> Void {
       
        let queue = DispatchQueue(label: "self.groceryA-thread-safe-obj", attributes: .concurrent)
        queue.sync(flags: .barrier) {
            self.groceryA = groceryA
            self.groceryA = ElGrocerUtility.sharedInstance.sortGroceryArray(storeTypeA: self.groceryA ?? [] )
        }
        queue.async(flags: .barrier) {
            self.setFeatureGrocery()
            self.updateDataInStoreTypeDict()
            self.filterOutStoreArrayOnTheBasisOfMarketType(groceryA)
        }
        self.delegate?.loadingDataComplete(type: .StoreList)
        queue.async(flags: .barrier) {
            self.startFetching()
        }
        
    }
    func genericBannersList(list : [BannerCampaign]) -> Void {
        self.locationOneBanners = list
        self.locationOneBanners?.sort { (banner1, banner2) -> Bool in
            return banner1.priority.intValue < banner2.priority.intValue
        }
        self.delegate?.loadingDataComplete(type: .HomePageLocationOneBanners)
        self.startFetching()
    }
    func getGreatDealsBannersList(list: [BannerCampaign]) {
        self.locationTwoBanners = list
        self.locationTwoBanners?.sort { (banner1, banner2) -> Bool in
            return banner1.priority.intValue < banner2.priority.intValue
        }
        self.delegate?.loadingDataComplete(type: .HomePageLocationTwoBanners)
        self.startFetching()
    }
    
    func createGenericStoresDictionary() {
        guard let groceryA = self.groceryA else{
            return
        }
        var dict: [String: Any] = [:]
        for grocery in groceryA {
            let groceryDict = ["id": grocery.getCleanGroceryID(),
                               "name": grocery.name ?? "",
                               "image": grocery.imageUrl ?? ""]
            dict[grocery.getCleanGroceryID()] = groceryDict
        }
        self.genericAllStoreDictionary = dict
    }
    

    
}
