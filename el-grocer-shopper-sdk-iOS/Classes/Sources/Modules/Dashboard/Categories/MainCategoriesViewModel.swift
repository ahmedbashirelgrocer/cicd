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
    
    // MARK: subjects
    private var cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private var scrollSubject = PublishSubject<IndexPath>()
    
    // MARK: properties
    private var apiClient: ElGrocerApi
    private var deliveryAddress: DeliveryAddress?
    private var grocery: Grocery?
    
    private var viewModels: [SectionModel<Int, ReusableTableViewCellViewModelType>] = []
    
    private var categories = [CategoryDTO]()
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
                SectionModel(model: 1, items: [CategoriesCellViewModel(categories: self.categories)]),
                SectionModel(model: 2, items: self.recentPurchasedVM), // optional
                SectionModel(model: 3, items: self.location2BannerVMs), // optional
                SectionModel(model: 4, items: self.homeCellVMs),
            ]
            self.cellViewModelsSubject.onNext(self.viewModels)
            self.loadingSubject.onNext(false)
        }
        
        self.scrollSubject.asObservable().subscribe(onNext: { indexPath in
            if self.apiCallingStatus[indexPath] == nil {
                guard let vm = self.homeCellVMs[indexPath.row] as? HomeCellViewModel else { return }
                
                vm.inputs.fetchProductsObserver.onNext(self.categories[indexPath.row])
                self.apiCallingStatus[indexPath] = true
            }
        }).disposed(by: self.disposeBag)
    }
    
    func heightForCell(indexPath: IndexPath) -> CGFloat {
        if self.viewModels[indexPath.section].items.first is GenericBannersCellViewModel {
            return (ScreenSize.SCREEN_WIDTH / CGFloat(2)) + 20
        } else if self.viewModels[indexPath.section].items.first is CategoriesCellViewModel {
            return self.categories.count > 5 ? 290 : 180
        } else if self.viewModels[indexPath.section].items.first is HomeCellViewModel {
            return 309
        }
        
        return 0.0
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
                        self.homeCellVMs = self.categories.map { HomeCellViewModel(deliveryTime: deliveryTime, category: $0, grocery: self.grocery) }
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
                do {
                    if let rootJson = response as? [String: Any] {
                        let data = try JSONSerialization.data(withJSONObject: rootJson)
                        let products = try JSONDecoder().decode(ProductResponse.self, from: data).data
                        if products.isNotEmpty {
                            self.recentPurchasedVM.append(HomeCellViewModel(title: "Recent Purchases", products: products))
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
}
