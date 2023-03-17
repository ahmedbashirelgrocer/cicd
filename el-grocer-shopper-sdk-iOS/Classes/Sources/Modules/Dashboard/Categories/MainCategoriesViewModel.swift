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
}

protocol MainCategoriesViewModelOutput {
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var loading: Observable<Bool> { get }
    func heightForCell(indexPath: IndexPath) -> CGFloat
    
    var viewAllCategories: Observable<Grocery?> { get }
    var viewAllProductsOfCategory: Observable<CategoryDTO?> { get }
    var viewAllProductOfRecentPurchase: Observable<Grocery?> { get }
    var categoryTap: Observable<CategoryDTO> { get }
    var bannerTap: Observable<BannerDTO> { get }
    var reloadTable: Observable<Void> { get }
    var refreshBasket: Observable<Void> { get }
    var showEmptyView: Observable<Void> { get }
    
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
    
    // MARK: outputs
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { self.cellViewModelsSubject.asObservable() }
    var loading: Observable<Bool> { self.loadingSubject.asObservable() }
    var refreshBasket: Observable<Void> { self.refreshBasketSubject.asObserver() }
    var viewAllCategories: Observable<Grocery?> { viewAllCategoriesSubject.asObservable() }
    var viewAllProductsOfCategory: RxSwift.Observable<CategoryDTO?> { viewAllProductsOfCategorySubject.asObservable() }
    var viewAllProductOfRecentPurchase: Observable<Grocery?> {viewAllProductOfRecentPurchaseSubject.asObservable() }
    var bannerTap: Observable<BannerDTO> { bannerTapSubject.asObservable() }
    var categoryTap: Observable<CategoryDTO> { categoryTapSubject.asObservable() }
    var reloadTable: Observable<Void> { reloadTableSubject.asObservable() }
    var showEmptyView: Observable<Void> { showEmptyViewSubject.asObservable() }
    
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
    private var reloadTableSubject = PublishSubject<Void>()
    private var refreshProductCellSubject = PublishSubject<Void>()
    private var showEmptyViewSubject = PublishSubject<Void>()
    
    // MARK: properties
    private var apiClient: ElGrocerApi
    private var deliveryAddress: DeliveryAddress?
    private var grocery: Grocery?
    
    private var viewModels: [SectionModel<Int, ReusableTableViewCellViewModelType>] = []
    
    private var categories = [CategoryDTO]()
    private var isCategoriesApiCompleted = false
    
    private var categoriesCellVMs = [ReusableTableViewCellViewModelType]()
    private var location1BannerVMs = [ReusableTableViewCellViewModelType]()
    private var location2BannerVMs = [ReusableTableViewCellViewModelType]()
    private var homeCellVMs = [ReusableTableViewCellViewModelType]()
    private var recentPurchasedVM = [ReusableTableViewCellViewModelType]()
    
    private var dispatchGroup = DispatchGroup()
    private var bannersDispatchGroup = DispatchGroup()
    private var disposeBag = DisposeBag()
    private var apiCallingStatus: [IndexPath: Bool] = [:]

    // MARK: initlizations
    init(apiClient: ElGrocerApi = ElGrocerApi.sharedInstance, grocery: Grocery?, deliveryAddress: DeliveryAddress?) {
        self.apiClient = apiClient
        self.grocery = grocery
        self.deliveryAddress = deliveryAddress
        self.isCategoriesApiCompleted = false
        
        self.fetchGroceryDeliverySlots()
        self.fetchBanners(for: .store_tier_1.getType())
        self.fetchBanners(for: .store_tier_2.getType())
        
        self.loadingSubject.onNext(true)
        bannersDispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            elDebugPrint("bannersLoaded")
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            //
            if self.homeCellVMs.isNotEmpty {
                
                if self.location1BannerVMs.isNotEmpty {
                    self.viewModels.append(SectionModel(model: 0, items: self.location1BannerVMs))
                }
                
                self.viewModels.append(SectionModel(model: 1, items: self.categoriesCellVMs))
                
                if self.recentPurchasedVM.isNotEmpty {
                    self.viewModels.append(SectionModel(model: 2, items: self.recentPurchasedVM))
                }
                
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
                self.cellViewModelsSubject.onNext(self.viewModels)
            } else {
                if self.isCategoriesApiCompleted {
                    self.showEmptyViewSubject.onNext(())
                }
            }
             if self.isCategoriesApiCompleted {
                self.loadingSubject.onNext(false)
            }
            
        }
        
        self.scrollSubject.asObservable().subscribe(onNext: { [weak self] indexPath in
            guard let self = self else { return }
            
            if self.apiCallingStatus[indexPath] == nil, self.homeCellVMs.count >  indexPath.row {
                guard let vm = self.homeCellVMs[indexPath.row] as? HomeCellViewModel else { return }
                
                vm.inputs.fetchProductsObserver.onNext(())
                vm.outputs.basketUpdated.bind(to: self.refreshBasketSubject).disposed(by: self.disposeBag)
                
                self.apiCallingStatus[indexPath] = true
            }
        }).disposed(by: self.disposeBag)
    }
    
    func heightForCell(indexPath: IndexPath) -> CGFloat {
        switch self.viewModels[indexPath.section].items.first {

        case is GenericBannersCellViewModel:
            return (ScreenSize.SCREEN_WIDTH / CGFloat(2)) + 20
        
        case is CategoriesCellViewModel:
            return categories.count > 5 ? 290 : 180
        
        case is HomeCellViewModel:
            if indexPath.row == 0 && self.recentPurchasedVM.isNotEmpty {
                return 309
            }
            
            if self.viewModels[indexPath.section].items[indexPath.row] is HomeCellViewModel {
                return (self.viewModels[indexPath.section].items[indexPath.row] as! HomeCellViewModel).outputs.isProductsAvailable() ? 309 : .leastNonzeroMagnitude
            } else if self.viewModels[indexPath.section].items[indexPath.row] is GenericBannersCellViewModel {
                return (ScreenSize.SCREEN_WIDTH / CGFloat(2)) + 20
            } else {
                return 0
            }
        
        default:
            return 0
        }
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
                        } else {
                            let currentTime = Int(Date().getUTCDate().timeIntervalSince1970 * 1000)
                            self.fetchCategories(deliveryTime: currentTime)
                            self.fetchPreviousPurchasedProducts(deliveryTime: currentTime)
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
                
                self.categories.append(CategoryDTO(dic: ["id" : -1, "image_url" : "shoping_list_cell_icon", "name" : "Search by Shopping List" , "name_ar" : "البحث بقائمة التسوق"]))
                categoriesDB.forEach { categoryDB in
                    self.categories.append(CategoryDTO(category: categoryDB))
                }
                
                let categoriesCellVM = CategoriesCellViewModel(categories: self.categories)
               
                categoriesCellVM.outputs.viewAll.map { self.grocery }.bind(to: self.viewAllCategoriesSubject).disposed(by: self.disposeBag)
                //bind(to: self.viewAllCategoriesSubject).disposed(by: self.disposeBag)
                categoriesCellVM.outputs.tap.bind(to: self.categoryTapSubject).disposed(by: self.disposeBag)
                self.categoriesCellVMs = [categoriesCellVM]
                
                // creating home cell view models
                // TODO: Need to update the logic of for shopping list
                self.homeCellVMs = self.categories.filter { $0.id != -1 }.map({
                    let viewModel = HomeCellViewModel(deliveryTime: deliveryTime, category: $0, grocery: self.grocery)
                    viewModel.outputs.viewAll.bind(to: self.viewAllProductsOfCategorySubject).disposed(by: self.disposeBag)
                    self.refreshProductCellSubject.bind(to: viewModel.inputs.refreshProductCellObserver).disposed(by: self.disposeBag)
                    
                    viewModel.outputs.isProductAvailable
                        .filter { !$0 }
                        .map { _ in () }
                        .bind(to: self.reloadTableSubject)
                        .disposed(by: self.disposeBag)
                    
                    return viewModel
                })
                self.dispatchGroup.leave()
                break
            case .failure(let error):
                // TODO: Show error message
                self.dispatchGroup.leave()
                break
            }
        }
    }
    
    func fetchBanners(for location: BannerLocation) {
        self.bannersDispatchGroup.enter()
        self.apiClient.getBannersFor(location: location, retailer_ids: [ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)]) { [weak self] result in
            guard let self = self else { return }
            
            self.bannersDispatchGroup.leave()
            
            switch result {
            case .success(let response):
                do {
                    if let rootJson = response as? [String: Any] {
                        let data = try JSONSerialization.data(withJSONObject: rootJson)
                        let banners = try JSONDecoder().decode(CampaignsResponse.self, from: data).data
                        
                        if banners.isNotEmpty {
                            if location == .store_tier_1.getType() {
                                let bannerCellVM = GenericBannersCellViewModel(banners: banners)
                                bannerCellVM.outputs.bannerTap.bind(to: self.bannerTapSubject).disposed(by: self.disposeBag)
                                self.location1BannerVMs.append(bannerCellVM)
                            } else if location == .store_tier_2.getType() {
                                let bannerCellVM = GenericBannersCellViewModel(banners: banners)
                                bannerCellVM.outputs.bannerTap.bind(to: self.bannerTapSubject).disposed(by: self.disposeBag)
                                self.location2BannerVMs.append(bannerCellVM)
                            }
                        }
                        return
                    }
                    
                    // handle parsing error
                } catch {
                    // handle parsing error
                    //  print("parsing error >> \(error)")
                }
                break
                
            case .failure(let error):
                break
            }
        }
    }
    
    func fetchPreviousPurchasedProducts(deliveryTime: Int?) {
        if !UserDefaults.isUserLoggedIn() {
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
//MARK:- Utils
extension MainCategoriesViewModel {
    
    func dataValidationForLoadedGroceryNeedsToUpdate(_ newGrocery: Grocery?) -> Bool {
        if newGrocery?.dbID == self.grocery?.dbID {
            return false
        }
        return true
    }
    
}
