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
}

protocol HomeCellViewModelOuput {
    var productCollectionCellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
    var scroll: Observable<Void> { get }
    var title: Observable<String?> { get }
    var basketUpdated: Observable<Void> { get }
    var viewAll: Observable<CategoryDTO?> { get }
    var isArabic: Observable<Bool> { get }
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
    
    // MARK: Outputs
    var productCollectionCellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { self.productCollectionCellViewModelsSubject.asObservable() }
    var scroll: Observable<Void> { self.fetchProductsSubject.asObservable() }
    var title: Observable<String?> { self.titleSubject.asObservable() }
    var basketUpdated: Observable<Void> { basketUpdatedSubject.asObservable() }
    var viewAll: Observable<CategoryDTO?> { viewAllSubject.map { self.category }.asObservable() }
    var isArabic: Observable<Bool> { isArabicSubject.asObserver() }
    
    // MARK: Subjects
    private let productCollectionCellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    private let fetchProductsSubject = PublishSubject<Void>()
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let basketUpdatedSubject = PublishSubject<Void>()
    private let viewAllSubject = PublishSubject<Void>()
    private var isArabicSubject = BehaviorSubject<Bool>(value: false)
    
    private var apiClient: ElGrocerApi?
    private var grocery: Grocery?
    private var deliveryTime: Int?
    private var category: CategoryDTO?
    private var disposeBag = DisposeBag()
    private var limit = 20
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
        
        let productCellViewModels = products.map { productDTO in
            let viewModel = ProductCellViewModel(product: productDTO, grocery: grocery)
        
            viewModel.outputs.basketUpdated.bind(to: self.basketUpdatedSubject).disposed(by: disposeBag)
            
            return viewModel
        }
        
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
            
            print("pagination >> offset >>> \(self.offset)")
            // Shows shimmring effect only for 1st page
            if self.offset == 0 {
                self.productCollectionCellViewModelsSubject.onNext([
                    SectionModel(model: 0, items: [ProductSekeltonCellViewModel(), ProductSekeltonCellViewModel(), ProductSekeltonCellViewModel(), ProductSekeltonCellViewModel()])
                ])
            }
            
            guard let config = ElGrocerUtility.sharedInstance.appConfigData, config.fetchCatalogFromAlgolia else {
                self.apiClient?.getTopSellingProductsOfGrocery(parameters) { result in
                    switch result {
                    case .success(let response):
                        self.handleAlgoliaSuccessResponse(response: response)
                        break
                        
                    case .failure(let error):
                        print("hanlde error >> \(error)")
                        break
                    }
                }
                
                return
            }
            
            let storeId = ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)
            
            let pageNumber = self.offset / self.limit
            
            guard category.id > 1 else {
                AlgoliaApi.sharedInstance.searchOffersProductListForStoreCategory(storeID: storeId, pageNumber: 0, 10, Int64(deliveryTime)) { [weak self] content, error in
                    if let error = error {
                        print("handle error >>> \(error)")
                        return
                    }
                    guard let response = content as? NSDictionary else { return }
                    self?.handleAlgoliaSuccessResponse(response: response)
                    
                }
                return
            }
            
            AlgoliaApi.sharedInstance.searchProductListForStoreCategory(storeID: storeId, pageNumber: pageNumber, categoryId: String(category.id)) { [weak self] content, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("handle error >>> \(error)")
                    return
                }
                
                guard let response = content as? NSDictionary else { return }
                self.handleAlgoliaSuccessResponse(response: response)
            }
        }
        
        DispatchQueue.global(qos: .utility).async(execute: self.dispatchWorkItem!)
    }
    
    func handleAlgoliaSuccessResponse(response: NSDictionary) {
        let products = Product.insertOrReplaceProductsFromDictionary(response, context: DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
        
        self.moreAvailable = products.count >= self.limit
        self.offset += limit
        
        let cellVMs = products.map { product in
            let vm = ProductCellViewModel(product: ProductDTO(product: product), grocery: self.grocery)
            vm.outputs.basketUpdated.bind(to: self.basketUpdatedSubject).disposed(by: self.disposeBag)
            return vm
        }
        
        self.productCellVMs.append(contentsOf: cellVMs)
        self.isLoading = false
        self.productCollectionCellViewModelsSubject.onNext([SectionModel(model: 0, items: self.productCellVMs)])
    }
}
