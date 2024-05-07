//
//  MainCategoriesViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 12/01/2023.
//

import Foundation
import RxSwift
import RxDataSources

protocol MainCategoriesViewModelInput {
    var scrollObserver: AnyObserver<IndexPath> { get }
    var refreshProductCellObserver: AnyObserver<Void> { get }
    var storiesLoadedObserver: AnyObserver<Void> { get }
}

protocol MainCategoriesViewModelOutput {
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var loading: Observable<Bool> { get }
    
    var viewAllCategories: Observable<Grocery?> { get }
    var viewAllProductsOfCategory: Observable<CategoryDTO?> { get }
    var viewAllProductOfRecentPurchase: Observable<Grocery?> { get }
    var categoryTap: Observable<CategoryDTO> { get }
    var bannerTap: Observable<BannerDTO> { get }
    var refreshBasket: Observable<Void> { get }
    var showEmptyView: Observable<Void> { get }
    var chefTap: Observable<CHEF?> { get }
    var viewAllRecipesTap: Observable<Void> { get }
    var categories: [CategoryDTO] { get }
    var startStorylyFetch: Observable<Grocery?> { get }
    
    func dataValidationForLoadedGroceryNeedsToUpdate(_ newGrocery: Grocery?) -> Bool
}

protocol MainCategoriesViewModelType: MainCategoriesViewModelInput, MainCategoriesViewModelOutput {
    var inputs: MainCategoriesViewModelInput { get }
    var outputs: MainCategoriesViewModelOutput { get }
}

extension MainCategoriesViewModelType {
    var inputs: MainCategoriesViewModelInput { self }
    var outputs: MainCategoriesViewModelOutput { self }
}


class MainCategoriesViewModel: MainCategoriesViewModelType {
    
    
    // MARK: Inputs
    var scrollObserver: AnyObserver<IndexPath> { self.scrollSubject.asObserver() }
    var refreshProductCellObserver: AnyObserver<Void> { refreshProductCellSubject.asObserver() }
    var storiesLoadedObserver: AnyObserver<Void> {  storiesLoadedSubject.asObserver() }
    
    // MARK: outputs
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { self.cellViewModelsSubject.asObservable() }
    var loading: Observable<Bool> { self.loadingSubject.asObservable() }
    var refreshBasket: Observable<Void> { self.refreshBasketSubject.asObserver() }
    var viewAllCategories: Observable<Grocery?> { viewAllCategoriesSubject.asObservable() }
    var viewAllProductsOfCategory: RxSwift.Observable<CategoryDTO?> { viewAllProductsOfCategorySubject.asObservable() }
    var viewAllProductOfRecentPurchase: Observable<Grocery?> {viewAllProductOfRecentPurchaseSubject.asObservable() }
    var bannerTap: Observable<BannerDTO> { bannerTapSubject.asObservable() }
    var categoryTap: Observable<CategoryDTO> { categoryTapSubject.asObservable() }
    var showEmptyView: Observable<Void> { showEmptyViewSubject.asObservable() }
    var chefTap: Observable<CHEF?> { chefTapSubject.asObservable() }
    var viewAllRecipesTap: Observable<Void> { viewAllRecipesTapSubject.asObservable() }
    var startStorylyFetch: Observable<Grocery?> { self.storylyFetchSubject.asObservable() }
    
    // MARK: subjects
    private var cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private var scrollSubject = PublishSubject<IndexPath>()
    private var refreshBasketSubject = PublishSubject<Void>()
    private var viewAllCategoriesSubject = PublishSubject<Grocery?>()
    private var viewAllProductsOfCategorySubject = PublishSubject<CategoryDTO?>()
    private var viewAllProductOfRecentPurchaseSubject = PublishSubject<Grocery?>()
    private var bannerTapSubject = PublishSubject<BannerDTO>()
    private var categoryTapSubject = PublishSubject<CategoryDTO>()
    private var refreshProductCellSubject = PublishSubject<Void>()
    private var showEmptyViewSubject = PublishSubject<Void>()
    private var chefTapSubject = PublishSubject<CHEF?>()
    private var viewAllRecipesTapSubject = PublishSubject<Void>()
    private var storylyFetchSubject = BehaviorSubject<Grocery?>(value: nil)
    private var storiesLoadedSubject = PublishSubject<Void>()
    private var location1BannersFetchSubject = PublishSubject<Void>()
    
    // MARK: properties
    private var apiClient: ElGrocerApi
    private var recipeAPIClient: ELGrocerRecipeMeduleAPI
    private var deliveryAddress: DeliveryAddress?
    private var grocery: Grocery?
    
    private var viewModels: [SectionModel<Int, ReusableTableViewCellViewModelType>] = []
    
    var categories = [CategoryDTO]()
    private var isCategoriesApiCompleted = false
    
    private var categoriesCellVMs = [ReusableTableViewCellViewModelType]()
    private var location1BannerVMs = [ReusableTableViewCellViewModelType]()
    private var location2BannerVMs = [ReusableTableViewCellViewModelType]()
    private var homeCellVMs = [ReusableTableViewCellViewModelType]()
    private var recentPurchasedVM = [ReusableTableViewCellViewModelType]()
    private var chefCellVMs = [ReusableTableViewCellViewModelType]()
    private var recipeCellVMs = [ReusableTableViewCellViewModelType]()
    
    private var dispatchGroup = DispatchGroup()
    private var bannersDispatchGroup = DispatchGroup()
    private let dispatchGroupRecipe = DispatchGroup()
    private var disposeBag = DisposeBag()
    private var apiCallingStatus: [IndexPath: Bool] = [:]
    
    private var isStorylyBannerAdded = false
    
    private var showProductsSection = ABTestManager.shared.storeConfigs.showProductsSection
   
    
    // MARK: initlizations
    init(apiClient: ElGrocerApi = ElGrocerApi.sharedInstance, recipeAPIClient: ELGrocerRecipeMeduleAPI = ELGrocerRecipeMeduleAPI(), grocery: Grocery?, deliveryAddress: DeliveryAddress?) {
        self.apiClient = apiClient
        self.recipeAPIClient = recipeAPIClient
        self.grocery = grocery
        self.deliveryAddress = deliveryAddress
        self.isCategoriesApiCompleted = false
     
        self.fetchGroceryDeliverySlots()
        self.storylyFetchSubject.onNext(grocery)
        self.fetchBanners(for: .store_tier_1.getType())
        self.fetchBanners(for: .store_tier_2.getType())
        
        self.loadingSubject.onNext(true)
        bannersDispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            elDebugPrint("bannersLoaded")
        }
        
        Observable
            .combineLatest(storiesLoadedSubject, location1BannersFetchSubject)
            .map { _ in () }
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                let bannerStorely = BannerDTO(id: 0, name: "Storyly Banner", priority: -1, campaignType: .storely, imageURL: nil, bannerImageURL: nil, url: nil, categories: nil, subcategories: nil, brands: nil, retailerIDS: nil, locations: [28, 19, 3], storeTypes: nil, retailerGroups: nil, customScreenId: nil, isStoryly: true)

                if self.isStorylyBannerAdded == false {
                    if let bannerCellVM = (self.location1BannerVMs.first as? any GenericBannersCellViewModelType) {
                        bannerCellVM.addBanner(banner: bannerStorely)
                    } else {
                        let bannerCellVM = GenericBannersCellViewModel(banners: [bannerStorely])
                        bannerCellVM.outputs.bannerTap.bind(to: self.bannerTapSubject).disposed(by: self.disposeBag)
                        self.viewModels.insert(SectionModel(model: 0, items: [bannerCellVM]), at: 0)
                    }
                    
                    self.isStorylyBannerAdded = true
                }
            }).disposed(by: disposeBag)
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            if self.location1BannerVMs.isNotEmpty {
                self.viewModels.append(SectionModel(model: 0, items: self.location1BannerVMs))
            }
            
            self.viewModels.append(SectionModel(model: 1, items: self.categoriesCellVMs))
            
            
            if self.recentPurchasedVM.isNotEmpty {
                self.viewModels.append(SectionModel(model: 2, items: self.recentPurchasedVM))
            }
            
            // Show Tier 2 Banners after categories section for all varient / experiment except baseline
            // for baseline showProductsSection value is true
            if self.showProductsSection == false && self.location2BannerVMs.isNotEmpty {
                self.viewModels.append(SectionModel(model: 3, items: self.location2BannerVMs))
            }
            
            // Show Produt Section for base varient only
            if self.showProductsSection && self.homeCellVMs.isNotEmpty {
                var result: [ReusableTableViewCellViewModelType] = []
                for index in 0...self.homeCellVMs.count - 1 {
                    result.append(self.homeCellVMs[index])
                    
                    if let bannerVM = self.location2BannerVMs.first {
                        if self.recentPurchasedVM.isEmpty {
                            if index == 2 {
                                result.append(bannerVM)
                            }
                        } else {
                            if index == 1 {
                                result.append(bannerVM)
                            }
                        }
                    }
                }
                
                self.viewModels.append(SectionModel(model: 3, items: result))
            }
            
            if self.isCategoriesApiCompleted && self.categoriesCellVMs.isEmpty {
                self.showEmptyViewSubject.onNext(())
            } else {
                self.cellViewModelsSubject.onNext(self.viewModels)
                
                // checking recipes and fetched if availability and fetch if available
                self.checkRecipes()
            }
            self.loadingSubject.onNext(false)
        }
        
        self.scrollSubject.asObservable().subscribe(onNext: { [weak self] indexPath in
            guard let self = self, self.showProductsSection else { return }
            
            if self.apiCallingStatus[indexPath] == nil, self.homeCellVMs.count >  indexPath.row {
                guard let vm = self.homeCellVMs[indexPath.row] as? HomeCellViewModel else { return }
                
                vm.inputs.fetchProductsObserver.onNext(())
                vm.outputs.basketUpdated.bind(to: self.refreshBasketSubject).disposed(by: self.disposeBag)
                
                self.apiCallingStatus[indexPath] = true
            }
        }).disposed(by: self.disposeBag)
    }
}

// MARK: Helper Methods
private extension MainCategoriesViewModel {
    func fetchGroceryDeliverySlots() {
        self.dispatchGroup.enter()

        self.apiClient.getGroceryDeliverySlotsWithGroceryId(self.grocery?.dbID, andWithDeliveryZoneId: self.grocery?.deliveryZoneId, false) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    if let rootJson = response as? [String: Any] {
                        let data = try JSONSerialization.data(withJSONObject: rootJson)
                        let deliverySlotsResponse = try JSONDecoder().decode(DeliverySlotsResponse.self, from: data)

                        if let selectedSlot = deliverySlotsResponse.data.deliverySlots?.first, let deliveryTime = selectedSlot.timeMilli {
                            self.fetchCategories(deliveryTime: deliveryTime)
                            self.fetchPreviousPurchasedProducts(deliveryTime: deliveryTime)
                            self.fetchCustomCatogires(for: BannerLocation.custom_campaign_shopper.getType())
                        } else {
                            let currentTime = Int(Date().getUTCDate().timeIntervalSince1970 * 1000)
                            self.fetchCategories(deliveryTime: currentTime)
                            self.fetchPreviousPurchasedProducts(deliveryTime: currentTime)
                            self.fetchCustomCatogires(for: BannerLocation.custom_campaign_shopper.getType())
                        }
                        return
                    }

                    // handle parsing error
                } catch {
                    // handle parsing error
                    //  print("parsing error >> \(error)")
                }
                
                break
                
            case .failure(_):
                self.dispatchGroup.leave()
                break
            }
        }
    }
    // Fetch Brand Catogories
    func fetchCategories(deliveryTime: Int) {
        self.apiClient.getAllCategories(self.deliveryAddress, parentCategory: nil, forGrocery: self.grocery, deliveryTime: deliveryTime) { [weak self] result in
            guard let self = self else { return }
            self.isCategoriesApiCompleted = true
            switch result {
                
            case .success(let response):
                guard let categoriesDictionary = response["data"] as? [NSDictionary], let grocery = self.grocery else {
                    // TODO: Show error message
                    self.dispatchGroup.leave()
                    return
                }
                
                guard let categoriesDB = Category.insertOrUpdateCategoriesForGrocery(grocery, categoriesArray: categoriesDictionary, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) else {
                    // TODO: Show error message
                    self.dispatchGroup.leave()
                    return
                }
                DatabaseHelper.sharedInstance.saveDatabase()
                
                categoriesDB.forEach { categoryDB in
                    self.categories.append(CategoryDTO(category: categoryDB))
                }
                
                let shoppingList = CategoryDTO(dic: ["id": -1, "image_url": "ic_shopping_list", "name": localizedString("search_by_shopping_list_text", comment: "") , "name_ar": "البحث بقائمة التسوق"])
                let buyItAgain = CategoryDTO(dic: ["id" : -2, "image_url" : "ic_buy_it_again", "name" : localizedString("buy_it_again_text", comment: ""), "name_ar" : "البحث بقائمة التسوق"])
                
                if self.showProductsSection {
                    self.categories.insert(shoppingList, at: 0)
                } else {
                    
                    if UserDefaults.isUserLoggedIn() { self.categories.insert(buyItAgain, at: 0) }
                    self.categories.insert(shoppingList, at: 1)
                }
                
                let categoriesCellVM = CategoriesCellViewModel(categories: self.categories)
               
                categoriesCellVM.outputs.viewAll.map { self.grocery }.bind(to: self.viewAllCategoriesSubject).disposed(by: self.disposeBag)
                //bind(to: self.viewAllCategoriesSubject).disposed(by: self.disposeBag)
                categoriesCellVM.outputs.tap.bind(to: self.categoryTapSubject).disposed(by: self.disposeBag)
                self.categoriesCellVMs = [categoriesCellVM]
                
                if self.showProductsSection {
                    // TODO: Need to update the logic of for shopping list
                
                    self.homeCellVMs = self.categories.filter { $0.id != -1 && $0.customPage == nil }.map({
                        let viewModel = HomeCellViewModel(deliveryTime: deliveryTime, category: $0, grocery: self.grocery)
                        
                        viewModel.outputs.viewAll
                            .bind(to: self.viewAllProductsOfCategorySubject)
                            .disposed(by: self.disposeBag)
                        
                        self.refreshProductCellSubject.bind(to: viewModel.inputs.refreshProductCellObserver).disposed(by: self.disposeBag)
                        
                        return viewModel
                    })
                }
                self.dispatchGroup.leave()
                // get custom compagin categories
               
                break
            case .failure(let error):
                // TODO: Show error message
                self.dispatchGroup.leave()
                break
            }
           
        }
    }
    
    func fetchBanners(for location: BannerLocation) {
        guard let grocery = self.grocery else { return }
        
        self.bannersDispatchGroup.enter()
        // self.dispatchGroup.enter()
        
        let storeTypes = grocery.getStoreTypes()?.map{ "\($0)" } ?? []
        
        self.apiClient.getBanners(for: location,
                                  retailer_ids: [ElGrocerUtility.sharedInstance.cleanGroceryID(grocery.dbID)],
                                  store_type_ids: storeTypes) { [weak self] result in
            
            guard let self = self else { return }
            
            self.bannersDispatchGroup.leave()
            
            switch result {
            case .success(let response):
                
                let banners = response.map { $0.toBannerDTO() }
                
                if banners.isNotEmpty {
                    if location == .store_tier_1.getType()  {
                        let bannerCellVM = GenericBannersCellViewModel(banners: banners)
                        bannerCellVM.outputs.bannerTap.bind(to: self.bannerTapSubject).disposed(by: self.disposeBag)
                        self.location1BannerVMs.append(bannerCellVM)
                    } else if location == .store_tier_2.getType() {
                        let bannerCellVM = GenericBannersCellViewModel(banners: banners)
                        bannerCellVM.outputs.bannerTap.bind(to: self.bannerTapSubject).disposed(by: self.disposeBag)
                        self.location2BannerVMs.append(bannerCellVM)
                    }
                }
                
                if location == .store_tier_1.getType() { self.location1BannersFetchSubject.onNext(()) }
                
            case .failure(_):
                break
            }
        }
    }
    
    func fetchCustomCatogires(for location: BannerLocation) {
        
        self.dispatchGroup.enter()
       
        // self.dispatchGroup.enter()
        
        let storeTypes = ElGrocerUtility.sharedInstance.activeGrocery?.getStoreTypes()?.map{ "\($0)" } ?? []
        
        self.apiClient.getCustomCategories(for: location,
                                  retailer_ids: [ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)],
                                  store_type_ids: storeTypes) { [weak self] result in
            
            guard let self = self else {  self?.dispatchGroup.leave(); return }
        
            switch result {
            case .success(let response):
                let banners = response.map { $0.toBannerDTO() }
                guard banners.count > 0 else { self.dispatchGroup.leave(); return }
                let customCategories = banners.map { $0.toCategoryDTO() }
                
                var index = 1
                for category in customCategories {
                    if index < self.categories.count {
                        if category.customPage != nil { self.categories.insert(category, at: index) }
                    }else {
                        if category.customPage != nil { self.categories.append(category) }
                    }
                    index += 1
                }
                let categoriesCellVM = CategoriesCellViewModel(categories: self.categories)
                categoriesCellVM.outputs.viewAll.map { self.grocery }.bind(to: self.viewAllCategoriesSubject).disposed(by: self.disposeBag)
                categoriesCellVM.outputs.tap.bind(to: self.categoryTapSubject).disposed(by: self.disposeBag)
                self.categoriesCellVMs = [categoriesCellVM]
                self.dispatchGroup.leave()
            case .failure(let _):
                self.dispatchGroup.leave()
                break
            }
            
        }
    }
    
    func fetchPreviousPurchasedProducts(deliveryTime: Int?) {
        // As for varient other than baseline we are not showing
        if !UserDefaults.isUserLoggedIn() || self.showProductsSection == false {
            return
        }
    
        let parameters = NSMutableDictionary()
        parameters["limit"] = 10
        parameters["offset"] = 0
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)
        parameters["shopper_id"] = UserDefaults.getLogInUserID()
        parameters["delivery_time"] =  deliveryTime as AnyObject
        
        self.dispatchGroup.enter()
        ElGrocerApi.sharedInstance.getTopSellingProductsOfGrocery(parameters , false) { [weak self] (result) in
            guard let self = self else { return }
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let response):
                let products = Product.insertOrReplaceProductsFromDictionary(response, context: DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
                
                let productDTOs = products.products.map { ProductDTO(product: $0) }
                
                if productDTOs.isNotEmpty {
                    let title = localizedString("previously_purchased_products_title", bundle: .resource, comment: "")
                    let homeCellViewModel = HomeCellViewModel(title: title, products: productDTOs, grocery: self.grocery)
                    
                    homeCellViewModel.outputs.viewAll.map { _ in self.grocery }.bind(to: self.viewAllProductOfRecentPurchaseSubject).disposed(by: self.disposeBag)
                    homeCellViewModel.outputs.basketUpdated.bind(to: self.refreshBasketSubject).disposed(by: self.disposeBag)
                    self.refreshProductCellSubject.bind(to: homeCellViewModel.inputs.refreshProductCellObserver).disposed(by: self.disposeBag)
                    
                    self.recentPurchasedVM.append(homeCellViewModel)
                }
                
                break
            case .failure(let error):
                //    print("handle error >> \(error)")
                break
            }
        }
    }
}

// MARK: Fetching reciipe section data
fileprivate extension MainCategoriesViewModel {
    func checkRecipes() {
        if sdkManager.isSmileSDK { return }
        
        guard let grocery = self.grocery else { return }
        let retailerString = ElGrocerUtility.sharedInstance.GenerateRetailerIdString(groceryA: [grocery])
        
        ELGrocerRecipeMeduleAPI().getRecipeListNew(offset: "0" , Limit: "1", recipeID: nil, ChefID: nil, shopperID: nil, categoryID: nil, retailerIDs: retailerString) { [weak self] (result) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                
                if let dataDictionary = response["data"] as? [NSDictionary] {
                    if dataDictionary.isNotEmpty {
                        self.fetchRecipeAndChef()
                    }
                }
            case .failure( _):
                break
                
            }
        }
    }
    
    func fetchRecipeAndChef() {
        self.fetchChefs()
        self.fetchRecipes()
        
        self.dispatchGroupRecipe.notify(queue: .main) {
            ElGrocerUtility.sharedInstance.delay(0.2) {
                let title = localizedString("shop_by_ingredients_text", comment: "")
                
                let titleVM = TableViewTitleCellViewModel(title: title, showViewMore: true)
                titleVM.outputs.viewAll
                    .bind(to: self.viewAllRecipesTapSubject)
                    .disposed(by: self.disposeBag)
                
                if self.recipeCellVMs.isNotEmpty {
                    let recipeSectionVMs = [titleVM] + self.chefCellVMs + self.recipeCellVMs
                    
                    self.viewModels.append(SectionModel(model: 4, items: recipeSectionVMs))
                    self.cellViewModelsSubject.onNext(self.viewModels)
                }
            }
        }
    }
    
    func fetchChefs() {
        guard let grocery = self.grocery else { return }
        let retailerIDString = ElGrocerUtility.sharedInstance.GenerateRetailerIdString(groceryA: [grocery])
        

        self.dispatchGroupRecipe.enter()
        self.recipeAPIClient.getChefList(offset: "0" , Limit: "1000", chefID: "" , retailerIDs: retailerIDString) { [weak self] (result) in
            guard let self = self else { return }
            
            self.dispatchGroupRecipe.leave()
            
            switch result {
                
            case .success(let response):
                if let dataDictionary = response["data"] as? [NSDictionary] {
                    if dataDictionary.isNotEmpty {
                        let chefs: [CHEF] = dataDictionary.map { CHEF.init(chefDict: $0 as! Dictionary<String, Any>) }
                        let chefCellVM = ElgrocerCategorySelectViewModel(chefList: chefs, selectedChef: nil)
                        chefCellVM.outputs.chefTap
                            .bind(to: self.chefTapSubject)
                            .disposed(by: self.disposeBag)
                        
                        self.chefCellVMs = [chefCellVM]
                    }
                }
                
            case .failure(let error):
                error.showErrorAlert()
            }
            
        }
    }
    
    func fetchRecipes() {
        guard let grocery = self.grocery else { return }
        let retailerIDString = ElGrocerUtility.sharedInstance.GenerateRetailerIdString(groceryA: [grocery])
        let kfeaturedCategoryId : Int64 = 0
        
        self.dispatchGroupRecipe.enter()
        self.recipeAPIClient.getRecipeListNew(offset: "0", Limit: "100", recipeID: nil, ChefID: nil, shopperID: nil, categoryID: kfeaturedCategoryId, retailerIDs: retailerIDString) {
            [weak self] (result) in
            
            self?.dispatchGroupRecipe.leave()
            
            switch result {
                
            case .success(let response):
                if let dataDictionary = response["data"] as? [NSDictionary] {
                    
                    if dataDictionary.isNotEmpty {
                        let recipes: [Recipe] = dataDictionary.map { Recipe.init(recipeData: $0 as! Dictionary<String, Any>) }
                        let recipeCellVM = RecipeCellViewModel(recipeList: recipes)
                        self?.recipeCellVMs = [recipeCellVM]
                    }
                }
            case .failure(let error):
                error.showErrorAlert()
            }
            
        }
    }
}
//MARK:- Utils
extension MainCategoriesViewModel {
    
    func dataValidationForLoadedGroceryNeedsToUpdate(_ newGrocery: Grocery?) -> Bool {
        if newGrocery?.dbID == self.grocery?.dbID {
            return false
        }
        return true
    }
    
}
