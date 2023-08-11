//
//  SubCategoryProductsViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 09/08/2023.
//

import Foundation
import RxSwift

protocol SubCategoryProductsViewModelInputs {
    var categorySwitchObserver: AnyObserver<Int> { get }
}

protocol SubCategoryProductsViewModelOutputs {
    var categories: Observable<[CategoryDTO]> { get }
    var categorySwitch: Observable<Int> { get }
    var subCategoriesTitle: Observable<[String]> { get }
    var error: Observable<Error?> { get }
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
    var categorySwitchObserver: AnyObserver<Int> { categorySwitchSubject.asObserver() }
    
    // MARK: Outputs
    var categories: Observable<[CategoryDTO]> { categoriesSubject.asObservable() }
    var categorySwitch: Observable<Int> { categorySwitchSubject.asObservable() }
    var subCategoriesTitle: Observable<[String]> { subCategoriesTitleSubject.asObservable() }
    var error: Observable<Error?> { errorSubject.asObservable() }
    
    // MARK: Subjects
    private var categoriesSubject = BehaviorSubject<[CategoryDTO]>(value: [])
    private var categorySwitchSubject = BehaviorSubject<Int>(value: 0)
    private var subCategoriesTitleSubject = PublishSubject<[String]>()
    private var errorSubject = PublishSubject<Error?>()
    
    // MARK: Properties
    private var disposeBag = DisposeBag()
    
    // MARK: Initializations
    init(categories: [CategoryDTO], selectedCategory: CategoryDTO, grocery: Grocery) {
        self.categoriesSubject
            .onNext(categories)
        
        self.categoriesSubject
            .compactMap { $0.firstIndex(where: { $0.id == selectedCategory.id }) }
            .bind(to: categorySwitchSubject)
            .disposed(by: disposeBag)
        
        // fetching sub-categories
        let fetchSubCategories = self.categorySwitchSubject
            .flatMapLatest { [unowned self] in self.filterCategory($0) }
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
    
    func getCurrentDeliveryAddress() -> DeliveryAddress? {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
}
