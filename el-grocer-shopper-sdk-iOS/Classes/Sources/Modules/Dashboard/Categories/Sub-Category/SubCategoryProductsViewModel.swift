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
    var subCategorySwitchObserver: AnyObserver<SubCategory?> { get }
    var categoriesButtonTapObserver: AnyObserver<Void> { get }
    var fetchMoreProducts: AnyObserver<Void> { get }
}

protocol SubCategoryProductsViewModelOutputs {
    var categories: Observable<[CategoryDTO]> { get }
    var categorySwitch: Observable<CategoryDTO?> { get }
    var subCategories: Observable<[SubCategory]> { get }
    var error: Observable<Error?> { get }
    var categoriesButtonTap: Observable<[CategoryDTO]> { get }
    var title: Observable<String> { get }
    var productCellViewModels: Observable<[ReusableCollectionViewCellViewModelType]> { get }
    var loading: Observable<Bool> { get }
    var subCategorySwitch: Observable<SubCategory?> { get }
    var banners: Observable<[BannerCampaign]> { get }
    var grocery: Grocery { get }
    var refreshBasket: Observable<Void> { get }
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
    var subCategorySwitchObserver: AnyObserver<SubCategory?> { subCategorySwitchSubject.asObserver() }
    var categoriesButtonTapObserver: AnyObserver<Void> { categoriesButtonTapSubject.asObserver() }
    var fetchMoreProducts: AnyObserver<Void> { fetchMoreProductsSubject.asObserver() }
    
    // MARK: Outputs
    var categories: Observable<[CategoryDTO]> { categoriesSubject.asObservable() }
    var categorySwitch: Observable<CategoryDTO?> { categorySwitchSubject.asObservable() }
    var subCategories: Observable<[SubCategory]> { subCategoriesSubject.asObservable() }
    var error: Observable<Error?> { errorSubject.asObservable() }
    var categoriesButtonTap: Observable<[CategoryDTO]> { categoriesButtonTapSubject.withLatestFrom(categoriesSubject).asObservable() }
    var title: Observable<String> { titleSubject.asObservable() }
    var productCellViewModels: Observable<[ReusableCollectionViewCellViewModelType]> { productCellViewModelsSubject.asObservable() }
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var subCategorySwitch: Observable<SubCategory?> { subCategorySwitchSubject.asObservable() }
    var banners: Observable<[BannerCampaign]> { bannersSubject.asObservable() }
    var grocery: Grocery
    var refreshBasket: Observable<Void> { refreshBasketSubject.asObservable() }
    
    // MARK: Subjects
    private var categoriesSubject = BehaviorSubject<[CategoryDTO]>(value: [])
    private var categorySwitchSubject = BehaviorSubject<CategoryDTO?>(value: nil)
    private var subCategoriesSubject = BehaviorSubject<[SubCategory]>(value: [])
    private var errorSubject = PublishSubject<Error?>()
    private var subCategorySwitchSubject = BehaviorSubject<SubCategory?>(value: SubCategory(id: -1, name: localizedString("all_cate", comment: "")))
    private var categoriesButtonTapSubject = PublishSubject<Void>()
    private var titleSubject = BehaviorSubject<String>(value: "")
    private var productCellViewModelsSubject = BehaviorSubject<[ReusableCollectionViewCellViewModelType]>(value: [])
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private var fetchMoreProductsSubject = PublishSubject<Void>()
    private var bannersSubject = PublishSubject<[BannerCampaign]>()
    private var refreshBasketSubject = BehaviorSubject<Void>(value: ())
    
    // MARK: Properties
    private var disposeBag = DisposeBag()
    private var page: Int = 0
    private var selectedCategory: CategoryDTO?
    private var selectedSubcategoryId: String?
    private var isFetching = false
    private var isMoreProductsAvailable = true
    private var hitsPerPage = ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.productsSlotsSubcategories ?? 20
    private var productsVMsDictionary: [String: [Product]] = [:]
    
    // MARK: Initializations
    init(categories: [CategoryDTO], selectedCategory: CategoryDTO, grocery: Grocery) {
        self.grocery = grocery
        
        self.categoriesSubject.onNext(categories)
        self.categorySwitchSubject.onNext(selectedCategory)
        
        self.fetchCategories()
        self.fetchProducts()
        self.fetchBanners()
        
        let paginatedResult = self.fetchMoreProductsSubject
            .filter { [unowned self] _ in
                !self.isFetching && self.isMoreProductsAvailable
            }
            .flatMapLatest { _ in
                self.page += 1
                self.isFetching = true

                return self.getProducts(category: self.selectedCategory?.categoryDB, subcategoryId: self.selectedSubcategoryId ?? "")
            }
            .do(onNext: { [unowned self] _ in self.isFetching = false  })
            .share()
    
        self.bindProductFetchResponse(result: paginatedResult)
    }
    
    private func fetchCategories() {
        let categoriesFetchResult = self.categorySwitchSubject
            .distinctUntilChanged()
            .flatMapLatest {[unowned self] in
                self.getSubCategories(deliveryAddress: self.getCurrentDeliveryAddress(), category: $0?.categoryDB, grocery: grocery)
            }.share()

        categoriesFetchResult
            .compactMap{  $0.element }
            .map { [SubCategory(id: -1, name: localizedString("all_cate", comment: ""))] + $0 }
            .bind(to: self.subCategoriesSubject)
            .disposed(by: disposeBag)

        categoriesFetchResult
            .compactMap{ $0.error }
            .bind(to: self.errorSubject)
            .disposed(by: disposeBag)
    }
    
    private func fetchProducts() {
        let subCategoryID = self.subCategorySwitchSubject
            .map { $0?.subCategoryId == -1 ? "" : $0?.subCategoryId.stringValue ?? "" }
            .distinctUntilChanged()
        
        let productFetchResult = Observable
            .combineLatest(self.categorySwitchSubject.distinctUntilChanged(), subCategoryID)
            .do(onNext: { [unowned self] _ in self.loadingSubject.onNext(true) })
            .flatMapLatest { [unowned self] in
                // Fix this code for paginated calls
                self.page = 0
                self.isMoreProductsAvailable = true
                
                if $1 == self.selectedSubcategoryId {
                    self.selectedSubcategoryId = ""
                } else {
                    self.selectedSubcategoryId = $1
                }
                self.selectedCategory = $0
                self.productCellViewModelsSubject.onNext([])
                self.isFetching = true
                
                return self.getProducts(category: $0?.categoryDB, subcategoryId: self.selectedSubcategoryId ?? "")
            }
            .do(onNext: { [unowned self] _ in
                self.isFetching = false
                self.loadingSubject.onNext(false)
            })
            .share()

        self.bindProductFetchResponse(result: productFetchResult)
    }
    
    private func fetchBanners() {
        let subCategoryID = self.subCategorySwitchSubject
            .map { $0?.subCategoryId == -1 ? "" : $0?.subCategoryId.stringValue ?? "" }
            .distinctUntilChanged()
        
        let bannersFetchResult = Observable
            .combineLatest(self.categorySwitchSubject, subCategoryID)
            .map { return ($0?.categoryDB?.dbID.intValue, Int($1)) }
            .flatMapLatest { [unowned self] (categoryID, subCategoryID) in
                return self.getBanners(categoryId: categoryID, subCategoryId: Int(self.selectedSubcategoryId ?? ""))
            }
            .share()
        
        bannersFetchResult
            .compactMap { $0.element }
            .bind(to: self.bannersSubject)
            .disposed(by: disposeBag)
    }
    
    private func bindProductFetchResponse(result: Observable<Event<[ProductDTO]>>) {
        result
            .compactMap { $0.element}
            .map({ products in
                products.map { product in
                    let border = ABTestManager.shared.storeConfigs.variant != .vertical
                    let productCellViewModel = ProductCellViewModel(product: product, grocery: self.grocery, border: border)
                    productCellViewModel.outputs.basketUpdated
                        .bind(to: self.refreshBasketSubject)
                        .disposed(by: self.disposeBag)
                    
                    return productCellViewModel
                }
            })
            .subscribe(onNext: { [weak self] productsViewModel in
                let currentItems = (try? self?.productCellViewModelsSubject.value()) ?? []
                let updated = (currentItems ?? []) + productsViewModel
                self?.productCellViewModelsSubject.onNext(updated)
            })
            .disposed(by: disposeBag)
        
        result
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
    
    func getProducts(category: Category?, subcategoryId: String) -> Observable<Event<[ProductDTO]>> {
        Observable<[ProductDTO]>.create { observer in
            
            self.getProducts(category: category, subcategoryId: subcategoryId) { result in
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
    
    func getProducts(category: Category?, subcategoryId: String, completion: @escaping (Swift.Result<[Product], Error>)->Void) {
        // check products locally and return
        if let localProducts = self.getLocalProducts(category?.dbID.stringValue ?? "", subcategoryId), localProducts.count > 0 {
            completion(.success(localProducts))
            return
        }
            
        if self.isFetchFromAlgolia() == false {
            // Fetch Products from elGrocer server
            ProductBrowser.shared.getAllProductsOfCategory(category, forGrocery: self.grocery, limit: 20, offset: 0){ (result) -> Void in
                switch result {
                case .success(let response):
                    // save products locally in dictionary
                    self.saveProducts(category?.dbID.stringValue ?? "", subcategoryId, products: response.products)
                    
                    self.isMoreProductsAvailable = (response.algoliaCount ?? response.products.count) >= self.hitsPerPage
                    completion(.success(response.products))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            return
        }
        
        if self.isFetchOffersProducts(category: category) {
            // Fetch Offers Product from Algolia
            ProductBrowser.shared.searchOffersProductListForStoreCategory(
                storeID: ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery.dbID),
                pageNumber: self.page,
                hitsPerPage: self.hitsPerPage,
                ElGrocerUtility.sharedInstance.getCurrentMillis(),
                slots: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.sponsoredSlotsSubcategories ?? 3, completion: { [weak self] (content, error) in
                    guard let self = self else { return }
                    
                    if let responseObject = content {
                        // save products locally in dictionary
                        self.saveProducts(category?.dbID.stringValue ?? "", subcategoryId, products: responseObject.products)
                        
                        self.isMoreProductsAvailable = (responseObject.algoliaCount ?? responseObject.products.count) >= self.hitsPerPage
                        completion(.success(responseObject.products))
                    } else {
                        completion(.failure(error ?? ElGrocerError.genericError()))
                    }
            })
            return
        }

        // Fetch all Products by category and sub-category from Algolia
        ProductBrowser.shared.searchProductListForStoreCategory(
            storeID: ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery.dbID),
            pageNumber: self.page,
            categoryId: category?.dbID.stringValue ?? "",
            hitsPerPage: self.hitsPerPage,
            subcategoryId,
            slots: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.sponsoredSlotsSubcategories ?? 3, completion: { [weak self] (content, error) in
                guard let self = self else { return }
                
                if  let responseObject = content {
                    // save products locally in dictionary
                    self.saveProducts(category?.dbID.stringValue ?? "", subcategoryId, products: responseObject.products)
                    
                    self.isMoreProductsAvailable = (responseObject.algoliaCount ?? responseObject.products.count) >= self.hitsPerPage
                    completion(.success(responseObject.products))
                } else {
                    completion(.failure(error ?? ElGrocerError.genericError()))
                }
            })
    }

    func getBanners(categoryId: Int?, subCategoryId: Int?) -> Observable<Event<[BannerCampaign]>> {
        Observable<[BannerCampaign]>.create { observer in
            
            let location = BannerLocation.subCategory_tier_1.getType()
            let storeTypes = ElGrocerUtility.sharedInstance.activeGrocery?.getStoreTypes()?.map{ "\($0)" } ?? []
            
            ElGrocerApi.sharedInstance.getBanners(for: location, retailer_ids: [self.grocery.dbID], store_type_ids: storeTypes, retailer_group_ids: nil, category_id: categoryId, subcategory_id: subCategoryId, brand_id: nil, search_input: nil) { result in
                    
                switch result {
                case .success(let banners):
                    observer.onNext(banners)
                    observer.onCompleted()
                        
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }.materialize()
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
    
    func saveProducts(_ categoryID: String, _ subCategoryID: String, products: [Product]) {
        let id = categoryID + "_" + subCategoryID
        
        if self.page == 0 {
            self.productsVMsDictionary[id] = products
        } else {
            self.productsVMsDictionary[id]?.append(contentsOf: products)
        }
    }
    
    func getLocalProducts(_ categoryID: String, _ subCategoryID: String) -> [Product]? {
        let id = categoryID + "_" + subCategoryID
        let startIndex = page * hitsPerPage
        
        guard let products = self.productsVMsDictionary[id], products.isNotEmpty, startIndex < products.count else {
            return nil
        }

        let endIndex = min(startIndex + hitsPerPage, products.count)
        return Array(products[startIndex..<endIndex])
    }
}
