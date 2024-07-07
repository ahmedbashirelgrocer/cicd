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
    var categoryChangeObserver: AnyObserver<CategoryDTO?> { get }
    var subCategoryChangeObserver: AnyObserver<SubCategory?> { get }
    var fetchMoreProducts: AnyObserver<Void> { get }
    var filterButtonTapObserver: AnyObserver<Void> { get }
    var filtersObserver: AnyObserver<ProductFilters?> { get }
}

protocol SubCategoryProductsViewModelOutputs {
    var categories: Observable<[CategoryDTO]> { get }
    var categoryChanged: Observable<CategoryDTO?> { get }
    var subCategories: Observable<[SubCategory]> { get }
    var error: Observable<Error?> { get }
    var title: Observable<String> { get }
    var productCellViewModels: Observable<[ReusableCollectionViewCellViewModelType]> { get }
    var loading: Observable<Bool> { get }
    var subCategoryChanged: Observable<SubCategory?> { get }
    var banners: Observable<[BannerCampaign]> { get }
    var grocery: Grocery { get }
    var refreshBasket: Observable<Void> { get }
    var shouldShowEmptyView: Observable<Bool> { get }
    var filterTap: Observable<(category: CategoryDTO?, subCategory: SubCategory?, grocery: Grocery, filters: ProductFilters?)> { get }
    var filters: Observable<ProductFilters?> { get }
}

protocol SubCategoryProductsViewModelType {
    var inputs: SubCategoryProductsViewModelInputs { get }
    var outputs: SubCategoryProductsViewModelOutputs { get }
}

class SubCategoryProductsViewModel: SubCategoryProductsViewModelType, SubCategoryProductsViewModelInputs, SubCategoryProductsViewModelOutputs {
    var inputs: SubCategoryProductsViewModelInputs { self }
    var outputs: SubCategoryProductsViewModelOutputs { self }
    
    // MARK: Inputs
    var categoryChangeObserver: AnyObserver<CategoryDTO?> { categoryChangeSubject.asObserver() }
    var subCategoryChangeObserver: AnyObserver<SubCategory?> { subCategoryChangeSubject.asObserver() }
    var fetchMoreProducts: AnyObserver<Void> { fetchMoreProductsSubject.asObserver() }
    var filterButtonTapObserver: AnyObserver<Void> { filterButtonTapSubject.asObserver() }
    var filtersObserver: AnyObserver<ProductFilters?> { filtersSubject.asObserver() }
    
    // MARK: Outputs
    var categories: Observable<[CategoryDTO]> { categoriesSubject.asObservable() }
    var categoryChanged: Observable<CategoryDTO?> { categoryChangeSubject.asObservable() }
    var subCategories: Observable<[SubCategory]> { subCategoriesSubject.asObservable() }
    var error: Observable<Error?> { errorSubject.asObservable() }
    var title: Observable<String> { titleSubject.asObservable() }
    var productCellViewModels: Observable<[ReusableCollectionViewCellViewModelType]> { productCellViewModelsSubject.asObservable() }
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var subCategoryChanged: Observable<SubCategory?> { subCategoryChangeSubject.asObservable() }
    var banners: Observable<[BannerCampaign]> { bannersSubject.asObservable() }
    var grocery: Grocery
    var refreshBasket: Observable<Void> { refreshBasketSubject.asObservable() }
    var shouldShowEmptyView: Observable<Bool> { shouldShowEmptyViewSubject.asObservable() }
    var filterTap: Observable<(category: CategoryDTO?, subCategory: SubCategory?, grocery: Grocery, filters: ProductFilters?)> {
        filterButtonTapSubject
            .withLatestFrom(Observable.combineLatest(subCategoryChangeSubject, filtersSubject))
            .compactMap { [unowned self] (sub, filters) in
                return (self.selectedCategory, sub, self.grocery, filters)
            }
    }
    var filters: Observable<ProductFilters?> { filtersSubject.asObservable() }
    
    // MARK: Subjects
    private var categoriesSubject = BehaviorSubject<[CategoryDTO]>(value: [])
    private var categoryChangeSubject = BehaviorSubject<CategoryDTO?>(value: nil)
    private var subCategoriesSubject = BehaviorSubject<[SubCategory]>(value: [])
    private var errorSubject = PublishSubject<Error?>()
    private var subCategoryChangeSubject = BehaviorSubject<SubCategory?>(value: SubCategory(id: -1, name: localizedString("title_all_subCat", comment: "")))
    private var titleSubject = BehaviorSubject<String>(value: "")
    private var productCellViewModelsSubject = BehaviorSubject<[ReusableCollectionViewCellViewModelType]>(value: [])
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private var fetchMoreProductsSubject = PublishSubject<Void>()
    private var bannersSubject = PublishSubject<[BannerCampaign]>()
    private var refreshBasketSubject = BehaviorSubject<Void>(value: ())
    private var shouldShowEmptyViewSubject: BehaviorSubject<Bool> = .init(value: false)
    private var filterButtonTapSubject: PublishSubject<Void> = .init()
    private var filtersSubject: BehaviorSubject<ProductFilters?> = .init(value: nil)
    
    // MARK: Properties
    private var disposeBag = DisposeBag()
    private var page: Int = 0
    private var selectedCategory: CategoryDTO?
    private var selectedSubcategoryId: String?
    private var isFetching = false
    private var isMoreProductsAvailable = true
    private var hitsPerPage = ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.productsSlotsSubcategories ?? 20
    private var productsVMsDictionary: [String: [Product]] = [:]
    private var selectedSlotTimeMilli: Int64
    
    // MARK: Initializations
    init(categories: [CategoryDTO], selectedCategory: CategoryDTO?, grocery: Grocery, selectedSubCategory: SubCategory? = nil, selectedSlotTimeMilli: Int64) {
        self.grocery = grocery
        self.selectedSlotTimeMilli = selectedSlotTimeMilli
        
        self.categoriesSubject.onNext(categories)
        self.categoryChangeSubject.onNext(selectedCategory)
        
        self.fetchSubCategories()
        self.fetchProducts()
        self.fetchBanners()
        
        // selecting sub-cateogry - we have to select the sub-category on sub-category fetching success
        subCategoriesSubject
            .map { _ in selectedSubCategory }
            .bind(to: subCategoryChangeSubject)
            .disposed(by: disposeBag)
        
        // Pagination
        let paginatedResult = self.fetchMoreProductsSubject
            .withLatestFrom(self.categoryChangeSubject)
            .filter { [unowned self] _ in
                !self.isFetching && self.isMoreProductsAvailable
            }
            .flatMapLatest { category in
                self.page += 1
                self.isFetching = true
                let cat = try? self.categoryChangeSubject.value()
                let subCat = try? self.subCategoryChangeSubject.value()
                let filter = try?  self.filtersSubject.value()
                return self.getProducts(category: cat?.categoryDB, subcategoryId: subCat?.subCategoryId.stringValue ?? "", searchKeyword: filter?.txtSearch ?? "", discounted: filter?.isPromotion ?? false)
            }
            .do(onNext: { [unowned self] _ in self.isFetching = false  })
            .share()
    
        self.bindProductFetchResponse(result: paginatedResult)
    }
    
    private func fetchSubCategories() {
        let categoriesFetchResult = self.categoryChangeSubject
            .distinctUntilChanged()
            .flatMapLatest {[unowned self] in
                self.getSubCategories(deliveryAddress: self.getCurrentDeliveryAddress(), category: $0?.categoryDB, grocery: grocery)
            }.share()

        categoriesFetchResult
            .compactMap{  $0.element }
            .map { [SubCategory(id: -1, name: localizedString("title_all_subCat", comment: ""))] + $0 }
            .bind(to: self.subCategoriesSubject)
            .disposed(by: disposeBag)

        categoriesFetchResult
            .compactMap{ $0.error }
            .bind(to: self.errorSubject)
            .disposed(by: disposeBag)
    }
    
    // Do the work here ...
    private func fetchProducts() {
        let categorySubCategoryChange = Observable
            .combineLatest(categoryChangeSubject.distinctUntilChanged(), subCategoryChangeSubject.distinctUntilChanged())
            .do(onNext: { [unowned self] _ in self.filtersSubject.onNext(nil) })
            .share()
        
        let productFetchResult = Observable
            .combineLatest(categorySubCategoryChange, filtersSubject.distinctUntilChanged())
            .do(onNext: { [unowned self] _ in self.loadingSubject.onNext(true) })
            .flatMapLatest { [unowned self] (arg0, filters) in
                // Fix this code for paginated calls
                let (category, subCategory) = arg0
                
                self.page = 0
                self.isMoreProductsAvailable = true
                
                self.selectedSubcategoryId = self.selectedCategory == category ? subCategory?.subCategoryId.stringValue : ""
                                
                self.selectedCategory = category
                self.productCellViewModelsSubject.onNext([])
                self.isFetching = true
                
                let searchKeyword = filters?.txtSearch ?? ""
                let discounted = filters?.isPromotion ?? false
                
                return self.getProducts(category: category?.categoryDB, subcategoryId: self.selectedSubcategoryId ?? "", searchKeyword: searchKeyword, discounted: discounted)
            }
            .do(onNext: { [unowned self] _ in
                self.isFetching = false
                self.loadingSubject.onNext(false)
            })
            .share()

        self.bindProductFetchResponse(result: productFetchResult)
    }
    
    private func fetchBanners() {
        let subCategoryID = self.subCategoryChangeSubject
            .map { $0?.subCategoryId == -1 ? "" : $0?.subCategoryId.stringValue ?? "" }
            .distinctUntilChanged()
        
        let bannersFetchResult = Observable
            .combineLatest(self.categoryChangeSubject, subCategoryID)
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
                    let productCellViewModel = ProductCellViewModel(product: product, grocery: self.grocery, border: true)
                    productCellViewModel.outputs.basketUpdated
                        .bind(to: self.refreshBasketSubject)
                        .disposed(by: self.disposeBag)
                    
                    return productCellViewModel
                }
            })
            .subscribe(onNext: { [weak self] productsViewModel in
                let currentItems = (try? self?.productCellViewModelsSubject.value()) ?? []
                let result = currentItems + productsViewModel
                self?.productCellViewModelsSubject.onNext(result)
                self?.shouldShowEmptyViewSubject.onNext(result.isEmpty)
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
    
    func getProducts(category: Category?, subcategoryId: String, searchKeyword: String = "", discounted: Bool = false) -> Observable<Event<[ProductDTO]>> {
        Observable<[ProductDTO]>.create { observer in
            
            self.getProducts(category: category, subcategoryId: subcategoryId, searchKeyword: searchKeyword, discounted: discounted) { result in
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
    
    func getProducts(category: Category?, subcategoryId: String, searchKeyword: String = "", discounted: Bool = false, completion: @escaping (Swift.Result<[Product], Error>)->Void) {
        // check products locally and return
        if searchKeyword == "" && discounted == false {
            if let localProducts = self.getLocalProducts(category?.dbID.stringValue ?? "", subcategoryId), localProducts.count > 0 {
                completion(.success(localProducts))
                return
            }
        }
            
        if self.isFetchFromAlgolia() == false {
            // Fetch Products from elGrocer server
            ProductBrowser.shared.getAllProductsOfCategory(category, forGrocery: self.grocery, limit: 20, offset: 0){ (result) -> Void in
                switch result {
                case .success(let response):
                    // save products locally in dictionary
                    if searchKeyword == "" && discounted == false {
                        self.saveProducts(category?.dbID.stringValue ?? "", subcategoryId, products: response.products)
                    }
                    
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
                        if searchKeyword == "" && discounted == false {
                            self.saveProducts(category?.dbID.stringValue ?? "", subcategoryId, products: responseObject.products)
                        }
                        
                        self.isMoreProductsAvailable = (responseObject.algoliaCount ?? responseObject.products.count) >= self.hitsPerPage
                        completion(.success(responseObject.products))
                    } else {
                        completion(.failure(error ?? ElGrocerError.genericError()))
                    }
            })
            return
        }

        // Fetch all Products by category and sub-category from Algolia
        ProductBrowser.shared
            .searchProductListForStoreCategoryWithFilters(storeID: ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery.dbID),
                                                          pageNumber: self.page,
                                                          categoryId: category?.dbID.stringValue ?? "",
                                                          discountedProducts: discounted,
                                                          deliveryTime: self.selectedSlotTimeMilli,
                                                          searchKeyword: searchKeyword,
                                                          hitsPerPage,
                                                          subcategoryId,
                                                          [],
                                                          slots: ElGrocerUtility.sharedInstance.adSlots?.productSlots.first?.sponsoredSlotsSubcategories ?? 3) { [weak self] content, error in
                guard let self = self else { return }
            
                if  let responseObject = content {
                    // save products locally in dictionary
                    if searchKeyword == "" && discounted == false {
                        self.saveProducts(category?.dbID.stringValue ?? "", subcategoryId, products: responseObject.products)
                    }
                
                    self.isMoreProductsAvailable = (responseObject.algoliaCount ?? responseObject.products.count) >= self.hitsPerPage
                    completion(.success(responseObject.products))
                } else {
                    completion(.failure(error ?? ElGrocerError.genericError()))
                }
        }
    }

    func getBanners(categoryId: Int?, subCategoryId: Int?) -> Observable<Event<[BannerCampaign]>> {
    
        Observable<[BannerCampaign]>.create { observer in
            var subCatId =  subCategoryId
            if subCatId == nil {
                observer.onNext([])
                observer.onCompleted()
                return Disposables.create()
            }
            let locations: [BannerLocation] = [BannerLocation.subCategory_tier_1.getType()]
            // let retailerIDs = [ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery.dbID)]
            let storeTypes = ElGrocerUtility.sharedInstance.activeGrocery?.getStoreTypes()?.map{ "\($0)" } ?? []
            
            ElGrocerApi.sharedInstance.getCombinedBanners(for: locations,retailer_ids: [ElGrocerUtility.sharedInstance.cleanGroceryID(self.grocery.dbID)],
                                              store_type_ids: storeTypes, retailer_group_ids: nil, category_id: categoryId, subcategory_id: subCatId) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    let customCampaignBanners = response.filter { bannerCampaign in
                        let locations = bannerCampaign.locations ?? []
                        return locations.contains(where: { value in
                            return value == BannerLocation.subCategory_tier_1.getType().rawValue
                        })
                    }
                    observer.onNext(customCampaignBanners)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                    break
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
}

fileprivate extension SubCategoryProductsViewModel {
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
