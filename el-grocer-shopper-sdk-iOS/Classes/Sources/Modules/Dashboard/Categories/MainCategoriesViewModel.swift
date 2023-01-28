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
}

protocol MainCategoriesViewModelOutput {
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var loading: Observable<Bool> { get }
    func heightForCell(indexPath: IndexPath) -> CGFloat
    
    var viewAllCategories: Observable<Void> { get }
    var viewAllProductsOfCategory: Observable<CategoryDTO?> { get }
    var viewAllProductOfRecentPurchase: Observable<Void> { get }
    
    var refreshBasket: Observable<ProductDTO> { get }
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
    
    // MARK: outputs
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { self.cellViewModelsSubject.asObservable() }
    var loading: Observable<Bool> { self.loadingSubject.asObservable() }
    var refreshBasket: Observable<ProductDTO> { self.refreshBasketSubject.asObserver() }
    var viewAllCategories: Observable<Void> { viewAllCategoriesSubject.asObservable() }
    var viewAllProductsOfCategory: RxSwift.Observable<CategoryDTO?> { viewAllProductsOfCategorySubject.asObservable() }
    var viewAllProductOfRecentPurchase: Observable<Void> {viewAllProductOfRecentPurchaseSubject.asObservable() }
    
    // MARK: subjects
    private var cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private var scrollSubject = PublishSubject<IndexPath>()
    private var refreshBasketSubject = PublishSubject<ProductDTO>()
    private var viewAllCategoriesSubject = PublishSubject<Void>()
    private var viewAllProductsOfCategorySubject = PublishSubject<CategoryDTO?>()
    private var viewAllProductOfRecentPurchaseSubject = PublishSubject<Void>()
    
    // MARK: properties
    private var apiClient: ElGrocerApi
    private var deliveryAddress: DeliveryAddress?
    private var grocery: Grocery?
    
    private var viewModels: [SectionModel<Int, ReusableTableViewCellViewModelType>] = []
    
    private var categories = [CategoryDTO]()
    
    private var categoriesCellVMs = [ReusableTableViewCellViewModelType]()
    private var location1BannerVMs = [ReusableTableViewCellViewModelType]()
    private var location2BannerVMs = [ReusableTableViewCellViewModelType]()
    private var homeCellVMs = [ReusableTableViewCellViewModelType]()
    private var recentPurchasedVM = [ReusableTableViewCellViewModelType]()
    
    private var dispatchGroup = DispatchGroup()
    private var disposeBag = DisposeBag()
    private var apiCallingStatus: [IndexPath: Bool] = [:]

    // MARK: initlizations
    init(apiClient: ElGrocerApi = ElGrocerApi.sharedInstance, grocery: Grocery?, deliveryAddress: DeliveryAddress?) {
        self.apiClient = apiClient
        self.grocery = grocery
        self.deliveryAddress = deliveryAddress
        
        self.fetchGroceryDeliverySlots()
        self.fetchBanners(for: .sdk_store_tier_1)
        self.fetchBanners(for: .sdk_store_tier_2)
        
        self.loadingSubject.onNext(true)
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            self.viewModels = [
                SectionModel(model: 0, items: self.location1BannerVMs), // optional
                SectionModel(model: 1, items: self.categoriesCellVMs),
                SectionModel(model: 2, items: self.recentPurchasedVM), // optional
                SectionModel(model: 3, items: self.location2BannerVMs), // optional
                SectionModel(model: 4, items: self.homeCellVMs),
            ]
            self.cellViewModelsSubject.onNext(self.viewModels)
            self.loadingSubject.onNext(false)
        }
        
        self.scrollSubject.asObservable().subscribe(onNext: { [weak self] indexPath in
            guard let self = self else { return }
            
            if self.apiCallingStatus[indexPath] == nil {
                guard let vm = self.homeCellVMs[indexPath.row] as? HomeCellViewModel else { return }
                
                vm.inputs.fetchProductsObserver.onNext(self.categories[indexPath.row])
                vm.outputs.productAddedToCart.bind(to: self.refreshBasketSubject).disposed(by: self.disposeBag)
                
                self.apiCallingStatus[indexPath] = true
            }
        }).disposed(by: self.disposeBag)
    }
    
    func heightForCell(indexPath: IndexPath) -> CGFloat {
        switch self.viewModels[indexPath.section].items.first {
            
            case is GenericBannersCellViewModel : return (ScreenSize.SCREEN_WIDTH / CGFloat(2)) + 20
            case is CategoriesCellViewModel     : return categories.count > 5 ? 290 : 180
            case is HomeCellViewModel           : return 309
            
            default: return 0
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
                        }
                        return
                    }

                    // handle parsing error
                } catch {
                    // handle parsing error
                    print("parsing error >> \(error)")
                }
                
                break
                
            case .failure(_):
                break
            }
        }
    }
    
    func fetchCategories(deliveryTime: Int) {
        self.apiClient.getAllCategories(self.deliveryAddress, parentCategory: nil, forGrocery: self.grocery, deliveryTime: deliveryTime) { [weak self] result in
            guard let self = self else { return }
            
            self.dispatchGroup.leave()
            switch result {
                
            case .success(let response):
                do {
                    if let rootJson = response as? [String: Any] {
                        let data = try JSONSerialization.data(withJSONObject: rootJson)
                        let categories = try JSONDecoder().decode(CategoriesResponse.self, from: data).categories
                        
                        self.categories = categories
                        
                        // creating home cell view models
                        let categoriesCellVM = CategoriesCellViewModel(categories: self.categories)
                        categoriesCellVM.viewAll.bind(to: self.viewAllCategoriesSubject).disposed(by: self.disposeBag)
                        self.categoriesCellVMs = [categoriesCellVM]
                        
                        // creating home cell view models
                        self.homeCellVMs = self.categories.map({
                            let viewModel = HomeCellViewModel(deliveryTime: deliveryTime, category: $0, grocery: self.grocery)
                            viewModel.outputs.viewAll.bind(to: self.viewAllProductsOfCategorySubject).disposed(by: self.disposeBag)
                            return viewModel
                        })
                        return
                    }
                    
                    // handle parsing error
                } catch {
                    // handle parsing error
                    print("parsing error >> \(error)")
                }
                break
                
            case .failure(let error):
                // handle error
                break
            }
        }
    }
    
    func fetchBanners(for location: BannerLocation) {
        self.dispatchGroup.enter()
        self.apiClient.getBannersFor(location: location.getType(), retailer_ids: [ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)]) { [weak self] result in
            guard let self = self else { return }
            
            self.dispatchGroup.leave()
            
            switch result {
            case .success(let response):
                do {
                    if let rootJson = response as? [String: Any] {
                        let data = try JSONSerialization.data(withJSONObject: rootJson)
                        let banners = try JSONDecoder().decode(CampaignsResponse.self, from: data).data
                        
                        if banners.isNotEmpty {
                            if location == .sdk_store_tier_1 {
                                self.location1BannerVMs.append(GenericBannersCellViewModel(banners: banners))
                            } else if location == .sdk_store_tier_2 {
                                self.location1BannerVMs.append(GenericBannersCellViewModel(banners: banners))
                            }
                        }
                        return
                    }
                    
                    // handle parsing error
                } catch {
                    // handle parsing error
                    print("parsing error >> \(error)")
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
                
                let productDTOs = products.map { ProductDTO(product: $0) }
                
                if productDTOs.isNotEmpty {
                    let homeCellViewModel = HomeCellViewModel(title: "Recent Purchases", products: productDTOs, grocery: self.grocery)
                    
                    homeCellViewModel.outputs.viewAll.map { _ in }
                        .bind(to: self.viewAllProductOfRecentPurchaseSubject)
                        .disposed(by: self.disposeBag)
                    
                    homeCellViewModel.outputs.productAddedToCart
                        .bind(to: self.refreshBasketSubject)
                        .disposed(by: self.disposeBag)
                    
                    self.recentPurchasedVM.append(homeCellViewModel)
                }
                
                break
            case .failure(let error):
                print("handle error >> \(error)")
                break
            }
        }
    }
}
