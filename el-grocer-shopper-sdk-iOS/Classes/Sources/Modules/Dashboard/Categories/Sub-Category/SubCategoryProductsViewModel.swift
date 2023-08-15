//
//  SubCategoryProductsViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 09/08/2023.
//

import Foundation
import RxSwift
import RxDataSources

protocol SubCategoryProductsViewModelInputs {
    var categorySwitchObserver: AnyObserver<CategoryDTO?> { get }
    var subCategorySwitchObserver: AnyObserver<Int> { get }
    var categoriesButtonTapObserver: AnyObserver<Void> { get }
}

protocol SubCategoryProductsViewModelOutputs {
    var categories: Observable<[CategoryDTO]> { get }
    var categorySwitch: Observable<CategoryDTO?> { get }
    var subCategoriesTitle: Observable<[String]> { get }
    var error: Observable<Error?> { get }
    var categoriesButtonTap: Observable<[CategoryDTO]> { get }
    var title: Observable<String> { get }
    var productModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
    var loading: Observable<Bool> { get }
}

protocol SubCategoryProductsViewModelType: SubCategoryProductsViewModelInputs, SubCategoryProductsViewModelOutputs {
    var inputs: SubCategoryProductsViewModelInputs { get }
    var outputs: SubCategoryProductsViewModelOutputs { get }
}

extension SubCategoryProductsViewModelType {
    var inputs: SubCategoryProductsViewModelInputs { self }
    var outputs: SubCategoryProductsViewModelOutputs { self }
}

class SubCategoryProductsViewModel: SubCategoryProductsViewModelType {
    // MARK: Inputs
    var categorySwitchObserver: AnyObserver<CategoryDTO?> { categorySwitchSubject.asObserver() }
    var subCategorySwitchObserver: AnyObserver<Int> { subCategorySwitchSubject.asObserver() }
    var categoriesButtonTapObserver: AnyObserver<Void> { categoriesButtonTapSubject.asObserver() }
    
    // MARK: Outputs
    var categories: Observable<[CategoryDTO]> { categoriesSubject.asObservable() }
    var categorySwitch: Observable<CategoryDTO?> { categorySwitchSubject.asObservable() }
    var subCategoriesTitle: Observable<[String]> { subCategoriesTitleSubject.asObservable() }
    var error: Observable<Error?> { errorSubject.asObservable() }
    var categoriesButtonTap: Observable<[CategoryDTO]> { categoriesButtonTapSubject.withLatestFrom(categoriesSubject).asObservable() }
    var title: Observable<String> { titleSubject.asObservable() }
    var productModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { productModelsSubject.asObservable() }
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    
    // MARK: Subjects
    private var categoriesSubject = BehaviorSubject<[CategoryDTO]>(value: [])
    private var categorySwitchSubject = BehaviorSubject<CategoryDTO?>(value: nil)
    private var subCategoriesTitleSubject = PublishSubject<[String]>()
    private var errorSubject = PublishSubject<Error?>()
    private var subCategorySwitchSubject = PublishSubject<Int>()
    private var categoriesButtonTapSubject = PublishSubject<Void>()
    private var titleSubject = BehaviorSubject<String>(value: "")
    private var productModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    
    // MARK: Properties
    private var disposeBag = DisposeBag()
    private var grocery: Grocery
    
    // MARK: Initializations
    init(categories: [CategoryDTO], selectedCategory: CategoryDTO, grocery: Grocery) {
        self.grocery = grocery
        
        self.categoriesSubject.onNext(categories)
        self.titleSubject.onNext(selectedCategory.name ?? "")
        self.categorySwitchSubject.onNext(selectedCategory)
        
        self.fetchCategories()
        self.fetchProducts()
    }
    
    private func fetchCategories() {
        let categoriesFetchResult = self.categorySwitchSubject
            .flatMap {[unowned self] in
                self.getSubCategories(deliveryAddress: self.getCurrentDeliveryAddress(), category: $0?.categoryDB, grocery: grocery)
            }.share()

        categoriesFetchResult
            .compactMap{  $0.element }
            .map { [localizedString("all_cate", comment: "")] + $0.map { $0.subCategoryName } }
            .bind(to: self.subCategoriesTitleSubject)
            .disposed(by: disposeBag)

        categoriesFetchResult
            .compactMap{ $0.error }
            .bind(to: self.errorSubject)
            .disposed(by: disposeBag)
    }
    
    private func fetchProducts() {
        let productFetchResult = self.categorySwitchSubject
            .do(onNext: { [unowned self] _ in self.loadingSubject.onNext(true) })
            .flatMap { [unowned self] in
                self.getProducts(category: $0?.categoryDB, subcategory: "")
            }
            .do(onNext: { [unowned self] _ in self.loadingSubject.onNext(false) })
            .share()
        
        productFetchResult
            .compactMap { $0.element }
            .map { [SectionModel(model: 0, items: $0.map { ProductCellViewModel(product: $0, grocery: self.grocery) })] }
            .bind(to: self.productModelsSubject)
            .disposed(by: disposeBag)
        
        productFetchResult
            .compactMap { $0.error }
            .bind(to: self.errorSubject)
            .disposed(by: disposeBag)
    }
}

// MARK: - Helpers
fileprivate extension SubCategoryProductsViewModel {
    func getSubCategories(deliveryAddress: DeliveryAddress?, category: Category?, grocery: Grocery) -> Observable<Event<[SubCategory]>> {
        Observable<[SubCategory]>.create { observer in
            
            ElGrocerApi.sharedInstance.getAllCategories(deliveryAddress, parentCategory: category , forGrocery: grocery) { (result) -> Void in
                switch result {
                    case .success(let response):
                        let subcategories = SubCategory.getAllSubCategoriesFromResponse(response)
                        observer.onNext(subcategories)
                        observer.onCompleted()
                    
                    case .failure(let error):
                        observer.onError(error)
                }
            }
            
            return Disposables.create()
        }.materialize()
    }
    
    func getProducts(category: Category?, subcategory: String) -> Observable<Event<[ProductDTO]>> {
        Observable<[ProductDTO]>.create { observer in
            
            self.getProducts(category: category, subcategory: subcategory) { result in
                switch result {
                case .success(let products):
                    let products = products.map { ProductDTO(product: $0) }
                    observer.onNext(products)
                    observer.onCompleted()

                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            
            return Disposables.create()
        }.materialize()
    }
    
    func getProducts(category: Category?, subcategory: String, completion: @escaping (Swift.Result<[Product], Error>)->Void) {
        if self.isFetchFromAlgolia() == false {
            // Fetch Product from elGrocer server
            ProductBrowser.shared.getAllProductsOfCategory(category, forGrocery: self.grocery, limit: 20, offset: 0){ (result) -> Void in
                switch result {
                case .success(let response):
                    completion(.success(response.products))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            return
        }
    
        let pageNumber = 0
        
        if self.isFetchOffersProducts(category: category) {
            // Fetch Offers Product from Algolia
            ProductBrowser.shared.searchOffersProductListForStoreCategory(
                storeID: ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery.dbID),
                pageNumber: pageNumber,
                hitsPerPage: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.productsSlotsSubcategories ?? 20,
                ElGrocerUtility.sharedInstance.getCurrentMillis(),
                slots: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.sponsoredSlotsSubcategories ?? 3, completion: { [weak self] (content, error) in
                    
                    if let responseObject = content {
                        completion(.success(responseObject.products))
                    } else {
                        completion(.failure(error ?? ElGrocerError.genericError()))
                    }
            })
            return
        }

        // Fetch All Product of category from Algolia
        ProductBrowser.shared.searchProductListForStoreCategory(
            storeID: ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery.dbID),
            pageNumber: pageNumber,
            categoryId: category?.dbID.stringValue ?? "",
            hitsPerPage: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.productsSlotsSubcategories ?? 20,
            slots: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.sponsoredSlotsSubcategories ?? 3, completion: { [weak self] (content, error) in

                if  let responseObject = content {
                    completion(.success(responseObject.products))
                } else {
                    completion(.failure(error ?? ElGrocerError.genericError()))
                }
            })
    }
    
    func getCurrentDeliveryAddress() -> DeliveryAddress? {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    func isFetchFromAlgolia() -> Bool {
        let config = ElGrocerUtility.sharedInstance.appConfigData
        return config == nil || config?.fetchCatalogFromAlgolia == true
    }
    
    func isFetchOffersProducts(category: Category?) -> Bool {
        return (category?.dbID.intValue ?? 0) <= 1
    }
}
