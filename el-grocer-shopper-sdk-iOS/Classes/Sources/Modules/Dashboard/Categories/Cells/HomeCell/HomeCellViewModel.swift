//
//  HomeCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 17/01/2023.
//

import Foundation
import RxSwift
import RxDataSources

protocol HomeCellViewModelInput {
    var fetchProductsObserver: AnyObserver<Void> { get }
    var viewAllTapObserver: AnyObserver<Void> { get }
    var refreshProductCellObserver: AnyObserver<Void> { get }
}

protocol HomeCellViewModelOuput {
    var productCollectionCellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
    var scroll: Observable<Void> { get }
    var title: Observable<String?> { get }
    var basketUpdated: Observable<Void> { get }
    var viewAll: Observable<CategoryDTO?> { get }
    var isArabic: Observable<Bool> { get }
    var viewAllText: Observable<String> { get }
    var productCount: Observable<Int> { get }
}

protocol HomeCellViewModelType: HomeCellViewModelInput, HomeCellViewModelOuput {
    var inputs: HomeCellViewModelInput { get }
    var outputs: HomeCellViewModelOuput { get }
}

extension HomeCellViewModelType {
    var inputs: HomeCellViewModelInput { self }
    var outputs: HomeCellViewModelOuput { self }
}

class HomeCellViewModel: ReusableTableViewCellViewModelType, HomeCellViewModelType {
    var reusableIdentifier: String { HomeCell.defaultIdentifier }
    
    // MARK: Inputs
    var fetchProductsObserver: AnyObserver<Void> { self.fetchProductsSubject.asObserver() }
    var viewAllTapObserver: AnyObserver<Void> { viewAllSubject.asObserver() }
    var refreshProductCellObserver: AnyObserver<Void> { refreshProductCellSubject.asObserver() }
    
    // MARK: Outputs
    var productCollectionCellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { self.productCollectionCellViewModelsSubject.asObservable() }
    var scroll: Observable<Void> { self.fetchProductsSubject.asObservable() }
    var title: Observable<String?> { self.titleSubject.asObservable() }
    var basketUpdated: Observable<Void> { basketUpdatedSubject.asObservable() }
    var viewAll: Observable<CategoryDTO?> { viewAllSubject.map { self.category }.asObservable() }
    var isArabic: Observable<Bool> { isArabicSubject.asObserver() }
    var viewAllText: Observable<String> { viewAllTextSubject.asObservable() }
    var productCount: Observable<Int> { productCountSubject.asObservable() }
    
    // MARK: Subjects
    private let productCollectionCellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    private let fetchProductsSubject = PublishSubject<Void>()
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let basketUpdatedSubject = PublishSubject<Void>()
    private let viewAllSubject = PublishSubject<Void>()
    private var isArabicSubject = BehaviorSubject<Bool>(value: ElGrocerUtility.sharedInstance.isArabicSelected())
    private var viewAllTextSubject = BehaviorSubject<String>(value: localizedString("view_more_title", bundle: .resource, comment: ""))
    private var refreshProductCellSubject = PublishSubject<Void>()
    private var productCountSubject = BehaviorSubject<Int>(value: 1) // passing non-zero value to make the the height for shimmer
    
    private var apiClient: ElGrocerApi?
    private var grocery: Grocery?
    private var deliveryTime: Int?
    private var category: CategoryDTO?
    private var disposeBag = DisposeBag()
    private var limit = ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.productsSlotsStorePage ?? 20
    private var offset = 0
    private var moreAvailable = true
    private var isLoading = false
    private var productCellVMs: [ProductCellViewModel] = []
    private var dispatchWorkItem: DispatchWorkItem?
    
    init(apiClient: ElGrocerApi = ElGrocerApi.sharedInstance, algoliaAPI: AlgoliaApi = AlgoliaApi.sharedInstance, deliveryTime: Int, category: CategoryDTO?, grocery: Grocery?) {
        self.apiClient = apiClient
        self.grocery = grocery
        self.deliveryTime = deliveryTime
        self.category = category
        
        self.titleSubject.onNext(category?.name)
        self.fetchProductsSubject.asObserver().subscribe(onNext: { [weak self] category in
            guard let self = self, let category = self.category else { return }
            
            if !self.isLoading && self.moreAvailable {
                self.fetchProduct(category: category)
                self.isLoading = true
            }
        }).disposed(by: disposeBag)
    }
    
    init(title: String, products: [ProductDTO], grocery: Grocery?) {
        self.titleSubject.onNext(title)
        self.grocery = grocery
        
        let productCellViewModels = products.map { productDTO -> ProductCellViewModel in
            let viewModel = ProductCellViewModel(product: productDTO, grocery: grocery)
        
            viewModel.outputs.basketUpdated.bind(to: self.basketUpdatedSubject).disposed(by: disposeBag)
            refreshProductCellSubject.asObservable().bind(to: viewModel.inputs.refreshDataObserver).disposed(by: disposeBag)
            return viewModel
        }
        
        self.productCountSubject.onNext(products.count)
        self.productCollectionCellViewModelsSubject.onNext([SectionModel(model: 0, items: productCellViewModels)])
    }
}

private extension HomeCellViewModel {
    func fetchProduct(category: CategoryDTO) {
        guard let deliveryTime = deliveryTime else { return }
        
        self.dispatchWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            let parameters = NSMutableDictionary()
            parameters["limit"] = self.limit
            parameters["offset"] = self.offset
            parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)
            parameters["category_id"] = category.id
            parameters["delivery_time"] =  deliveryTime
            parameters["shopper_id"] = UserDefaults.getLogInUserID()
            
            // Shows shimmring effect only for 1st page
            if self.offset == 0 {
                self.productCollectionCellViewModelsSubject.onNext([
                    SectionModel(model: 0, items: [ProductSekeltonCellViewModel(), ProductSekeltonCellViewModel(), ProductSekeltonCellViewModel(), ProductSekeltonCellViewModel()])
                ])
            }
            
            if let config = ElGrocerUtility.sharedInstance.appConfigData, config.fetchCatalogFromAlgolia == false {
                ProductBrowser.shared.getTopSellingProductsOfGrocery(parameters, true) { result in
                    switch result {
                    case .success(let response):
                        self.handleAlgoliaSuccessResponse(response: response)
                        break
                    case .failure(_):
                        //    print("hanlde error >> \(error)")
                        break
                    }
                }
                return
            }
            
            let storeId = ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)
            
            let pageNumber = self.offset / self.limit
            
            guard category.id > 1 else {
                ProductBrowser.shared.searchOffersProductListForStoreCategory(storeID: storeId, pageNumber: pageNumber, hitsPerPage: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.productsSlotsStorePage ?? 20, Int64(deliveryTime), slots: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.sponsoredSlotsStorePage ?? 3) { [weak self] content, error in
                    if let _ = error {
                        //  print("handle error >>> \(error)")
                        return
                    }
                    guard let response = content else { return }
                    self?.handleAlgoliaSuccessResponse(response: response)
                    
                }
                return
            }
            
            ProductBrowser.shared.searchProductListForStoreCategory(storeID: storeId, pageNumber: pageNumber, categoryId: String(category.id), hitsPerPage: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.productsSlotsStorePage ?? 20, slots: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.sponsoredSlotsStorePage ?? 3) { [weak self] content, error in
                guard let self = self else { return }
                
                if let _ = error {
                    //  print("handle error >>> \(error)")
                    return
                }
                
                guard let response = content else { return }
                self.handleAlgoliaSuccessResponse(response: response)
            }
        }
        
        DispatchQueue.global(qos: .utility).async(execute: self.dispatchWorkItem!)
    }
    
    func handleAlgoliaSuccessResponse(response products: (products: [Product], algoliaCount: Int?)) {
        // let products = Product.insertOrReplaceProductsFromDictionary(response, context: DatabaseHelper.sharedInstance.backgroundManagedObjectContext)

        self.moreAvailable = (products.algoliaCount ?? products.products.count) >= self.limit
        let cellVMs = products.products.map { product -> ProductCellViewModel in
            let vm = ProductCellViewModel(product: ProductDTO(product: product), grocery: self.grocery)
            vm.outputs.basketUpdated.bind(to: self.basketUpdatedSubject).disposed(by: self.disposeBag)
            refreshProductCellSubject.asObservable().bind(to: vm.inputs.refreshDataObserver).disposed(by: disposeBag)
            return vm
        }
        
        if products.algoliaCount == 0{
            debugPrint("")
        }
        
        // this check ensure that the first call products is zero
        if offset == 0 {
            self.productCountSubject.onNext(products.algoliaCount ?? products.products.count)
        }
        
        self.productCellVMs.append(contentsOf: cellVMs)
        self.isLoading = false
        self.productCollectionCellViewModelsSubject.onNext([SectionModel(model: 0, items: self.productCellVMs)])
        self.offset += limit
    }
}
