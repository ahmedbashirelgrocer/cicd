//
//  SubCategoryProductsViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 09/08/2023.
//

import Foundation
import RxSwift

protocol SubCategoryProductsViewModelInputs {
    var categorySwitchObserver: AnyObserver<CategoryDTO> { get }
    var subCategorySwitchObserver: AnyObserver<Int> { get }
    var categoriesButtonTapObserver: AnyObserver<Void> { get }
}

protocol SubCategoryProductsViewModelOutputs {
    var categories: Observable<[CategoryDTO]> { get }
    var categorySwitch: Observable<CategoryDTO> { get }
    var subCategoriesTitle: Observable<[String]> { get }
    var error: Observable<Error?> { get }
    var categoriesButtonTap: Observable<[CategoryDTO]> { get }
    var title: Observable<String> { get }
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
    var categorySwitchObserver: AnyObserver<CategoryDTO> { categorySwitchSubject.asObserver() }
    var subCategorySwitchObserver: AnyObserver<Int> { subCategorySwitchSubject.asObserver() }
    var categoriesButtonTapObserver: AnyObserver<Void> { categoriesButtonTapSubject.asObserver() }
    
    // MARK: Outputs
    var categories: Observable<[CategoryDTO]> { categoriesSubject.asObservable() }
    var categorySwitch: Observable<CategoryDTO> { categorySwitchSubject.asObservable() }
    var subCategoriesTitle: Observable<[String]> { subCategoriesTitleSubject.asObservable() }
    var error: Observable<Error?> { errorSubject.asObservable() }
    var categoriesButtonTap: Observable<[CategoryDTO]> { categoriesButtonTapSubject.withLatestFrom(categoriesSubject).asObservable() }
    var title: Observable<String> { titleSubject.asObservable() }
    
    // MARK: Subjects
    private var categoriesSubject = BehaviorSubject<[CategoryDTO]>(value: [])
    private var categorySwitchSubject = PublishSubject<CategoryDTO>()
    private var subCategoriesTitleSubject = PublishSubject<[String]>()
    private var errorSubject = PublishSubject<Error?>()
    private var subCategorySwitchSubject = PublishSubject<Int>()
    private var categoriesButtonTapSubject = PublishSubject<Void>()
    private var titleSubject = BehaviorSubject<String>(value: "")
    
    // MARK: Properties
    private var disposeBag = DisposeBag()
    
    // MARK: Initializations
    init(categories: [CategoryDTO], selectedCategory: CategoryDTO, grocery: Grocery) {
        self.categoriesSubject
            .onNext(categories)
        
        self.titleSubject.onNext(selectedCategory.name ?? "")
        
        self.categoriesSubject
            .compactMap { $0.first(where: { $0.id == selectedCategory.id }) }
            .bind(to: categorySwitchSubject)
            .disposed(by: disposeBag)
        
        // Fetch Sub-Category
        let fetchSubCategories = self.categorySwitchSubject
            .flatMap {[unowned self] in
                self.getSubCategories(deliveryAddress: self.getCurrentDeliveryAddress(), category: $0.categoryDB, grocery: grocery)
            }.share()

        fetchSubCategories
            .compactMap{  $0.element }
            .map { [localizedString("all_cate", comment: "")] + $0.map { $0.subCategoryName } }
            .bind(to: self.subCategoriesTitleSubject)
            .disposed(by: disposeBag)

        fetchSubCategories
            .compactMap{ $0.error }
            .bind(to: self.errorSubject)
            .disposed(by: disposeBag)
        
        // Fetch Products for switching category
//        let fetchProducts = self.categorySwitchSubject
//            .flatMapLatest { [unowned self] in self.filterCategory($0) }
//            .flatMap { [unowned self] in
//                self.getProducts(category: $0.categoryDB, subcategory: "All Category")
//            }.share()
//            
    }
}

// MARK: - Helpers
fileprivate extension SubCategoryProductsViewModel {
    func filterCategory(_ index: Int) -> Observable<CategoryDTO> {
        return self.categoriesSubject
            .map({ categories in categories[index] })
    }
    
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
    
    func getProducts(category: Category, subcategory: String) -> Observable<Event<[ProductDTO]>> {
        Observable<[ProductDTO]>.create { observer in
            
            self.getProducts(category: category, subcategory: subcategory) { result in
                switch result {
                case .success(let products):
                    break
//                    let products = Product.
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            
            return Disposables.create()
        }.materialize()
    }
    
    func getProducts(category: Category?, subcategory: String, completion: @escaping (Swift.Result<[Product], Error>)->Void) {
        
    }
    
    func getCurrentDeliveryAddress() -> DeliveryAddress? {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
}
