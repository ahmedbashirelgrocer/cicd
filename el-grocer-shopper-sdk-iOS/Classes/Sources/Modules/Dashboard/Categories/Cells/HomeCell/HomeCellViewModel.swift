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
    var fetchProductsObserver: AnyObserver<CategoryDTO?> { get }
    var quickAddButtonTapObserver: AnyObserver<Product> { get }
    
    var viewAllTapObserver: AnyObserver<Void> { get }
}

protocol HomeCellViewModelOuput {
    var productCollectionCellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
    var scroll: Observable<CategoryDTO?> { get }
    var title: Observable<String?> { get }
    var quickAddButtonTap: Observable<Product> { get }
    var viewAll: Observable<CategoryDTO?> { get }
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
    var fetchProductsObserver: AnyObserver<CategoryDTO?> { self.fetchProductsSubject.asObserver() }
    var quickAddButtonTapObserver: AnyObserver<Product> { self.quickAddButtonTapSubject.asObserver() }
    var viewAllTapObserver: AnyObserver<Void> { viewAllSubject.asObserver() }
    
    // MARK: Outputs
    var productCollectionCellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { self.productCollectionCellViewModelsSubject.asObservable() }
    var scroll: Observable<CategoryDTO?> { self.fetchProductsSubject.asObservable() }
    var title: Observable<String?> { self.titleSubject.asObservable() }
    var quickAddButtonTap: Observable<Product> { quickAddButtonTapSubject.asObservable() }
    var viewAll: Observable<CategoryDTO?> { viewAllSubject.map { self.category }.asObservable() }
    
    // MARK: Subjects
    private let productCollectionCellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    private let fetchProductsSubject = BehaviorSubject<CategoryDTO?>(value: nil)
    private let titleSubject = BehaviorSubject<String?>(value: nil)
    private let quickAddButtonTapSubject = PublishSubject<Product>()
    private let viewAllSubject = PublishSubject<Void>()
    
    private var apiClient: ElGrocerApi?
    private var grocery: Grocery?
    private var deliveryTime: Int?
    private var category: CategoryDTO?
    private var disposeBag = DisposeBag()
    
    init(apiClient: ElGrocerApi = ElGrocerApi.sharedInstance, algoliaAPI: AlgoliaApi = AlgoliaApi.sharedInstance, deliveryTime: Int, category: CategoryDTO?, grocery: Grocery?) {
        self.apiClient = apiClient
        self.grocery = grocery
        self.deliveryTime = deliveryTime
        self.category = category
        
        self.titleSubject.onNext(category?.name)
        self.fetchProductsSubject.asObserver().subscribe(onNext: { category in
            if let category = category {
                self.fetchProduct(category: category)
            }
        }).disposed(by: disposeBag)
    }
    
    init(title: String, products: [ProductDTO]) {
        self.titleSubject.onNext(title)
        
        self.productCollectionCellViewModelsSubject.onNext([
            SectionModel(model: 0, items: products.map { ProductCellViewModel(product: $0, grocery: self.grocery) })
        ])
    }
}

private extension HomeCellViewModel {
    func fetchProduct(category: CategoryDTO) {
        guard let deliveryTime = deliveryTime else { return }
        
        let parameters = NSMutableDictionary()
        parameters["limit"] = 10
        parameters["offset"] = 0
        parameters["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)
        parameters["category_id"] = category.id
        parameters["delivery_time"] =  deliveryTime
        
        // show shimmring efffect by adding
        self.productCollectionCellViewModelsSubject.onNext([
            SectionModel(model: 0, items: [ProductSekeltonCellViewModel(), ProductSekeltonCellViewModel(), ProductSekeltonCellViewModel(), ProductSekeltonCellViewModel()])
        ])
        
        guard let config = ElGrocerUtility.sharedInstance.appConfigData, config.fetchCatalogFromAlgolia else {
            self.apiClient?.getTopSellingProductsOfGrocery(parameters) { result in
                switch result {
                case .success(let response):
                    break
                    
                case .failure(let error):
                    break
                }
            }
            
            return
        }
        
        let storeId = ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery?.dbID)
        
        guard category.id > 1 else {
            AlgoliaApi.sharedInstance.searchOffersProductListForStoreCategory(storeID: storeId, pageNumber: 0, 10, Int64(deliveryTime)) { [weak self] content, error in
                if let error = error {
                    print("handle error >>> \(error)")
                    return
                }
                guard let response = content else { return }
                self?.handleAlgoliaSuccessResponse(response: response)
                
            }
            return
        }
        
        AlgoliaApi.sharedInstance.searchProductListForStoreCategory(storeID: storeId, pageNumber: 0, categoryId: String(category.id)) { [weak self] content, error in
            if let error = error {
                print("handle error >>> \(error)")
                return
            }
            
            guard let response = content else { return }
            
            let products = Product.insertOrReplaceProductsFromDictionary(response as NSDictionary, context: DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
            
            let productCellVMs = products.map { ProductCellViewModel(product: ProductDTO(product: $0), grocery: self?.grocery)}
            self?.productCollectionCellViewModelsSubject.onNext([SectionModel(model: 0, items: productCellVMs)])
//            self?.handleAlgoliaSuccessResponse(response: response)
        }
    }
    
    func handleAlgoliaSuccessResponse(response: [String: Any]) {
        guard let hits = response["hits"] as? NSDictionary else { return }
        
        let products = Product.insertOrReplaceProductsFromDictionary(hits as NSDictionary, context: DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
        
        let productCellVMs = products.map { ProductCellViewModel(product: ProductDTO(product: $0), grocery: grocery)}
        
        
//        let productCellVMs = hits.map { hit in
//
//            let product = Product.createProductFromDictionary(hit as NSDictionary, context: DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
//            var productDTO = ProductDTO(dic: hit)
//            productDTO.productDB = product
//
//            return ProductCellViewModel(product: productDTO, grocery: self.grocery)
//        }
//
////        let productCellVMs = hits.map { ProductCellViewModel(product: ProductDTO(dic: $0), grocery: self.grocery) }
        self.productCollectionCellViewModelsSubject.onNext([SectionModel(model: 0, items: productCellVMs)])
    }
}
