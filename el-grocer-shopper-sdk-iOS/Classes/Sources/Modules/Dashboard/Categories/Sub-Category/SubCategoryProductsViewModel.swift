//
//  SubCategoryProductsViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 09/08/2023.
//

import Foundation
import RxSwift

protocol SubCategoryProductsViewModelInputs {
    var categorySegmentTapObserver: AnyObserver<Int> { get }
}

protocol SubCategoryProductsViewModelOutputs {
    var categories: Observable<[CategoryDTO]> { get }
    var selectedCategoryIndex: Observable<Int> { get }
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
    var categorySegmentTapObserver: AnyObserver<Int> { selectedCategoryIndexSubject.asObserver() }
    
    // MARK: Outputs
    var categories: Observable<[CategoryDTO]> { categoriesSubject.asObservable() }
    var selectedCategoryIndex: Observable<Int> { selectedCategoryIndexSubject.asObservable() }
    
    // MARK: Subjects
    private var categoriesSubject = BehaviorSubject<[CategoryDTO]>(value: [])
//    private var categorySegmentTapSubject = PublishSubject<Int>()
    private var selectedCategoryIndexSubject = BehaviorSubject<Int>(value: 0)
    
    // MARK: Properties
    private var disposeBag = DisposeBag()
    
    // MARK: Initializations
    init(categories: [CategoryDTO], selectedCategory: CategoryDTO) {
        
        self.categoriesSubject
            .onNext(categories.filter{ $0.id != -1 })
        
        self.categoriesSubject
            .compactMap { $0.firstIndex(where: { $0.id == selectedCategory.id }) }
            .bind(to: selectedCategoryIndexSubject)
        
        self.selectedCategoryIndexSubject
            .flatMapLatest { [unowned self] index in self.filterCategory(index) }
            .subscribe(onNext: {
                print("you selected the category with name >> \($0.name)")
            }).disposed(by: disposeBag)
    }
    
}

// MARK: - Helpers
fileprivate extension SubCategoryProductsViewModel {
    func filterCategory(_ index: Int) -> Observable<CategoryDTO> {
        return self.categoriesSubject
            .map({ categories in categories[index] })
    }
}
