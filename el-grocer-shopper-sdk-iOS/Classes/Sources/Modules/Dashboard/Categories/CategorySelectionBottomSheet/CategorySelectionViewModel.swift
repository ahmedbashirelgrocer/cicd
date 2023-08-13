//
//  CategorySelectionViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 13/08/2023.
//

import Foundation
import RxSwift
import RxDataSources

protocol CategorySelectionViewModelInput { }

protocol CategorySelectionViewModelOutput {
    var categoriesDataSource: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
}

protocol CategorySelectionViewModelType: CategorySelectionViewModelInput, CategorySelectionViewModelOutput {
    var inputs: CategorySelectionViewModelInput { get }
    var outputs: CategorySelectionViewModelOutput { get }
}

extension CategorySelectionViewModelType {
    var inputs: CategorySelectionViewModelInput { self }
    var outputs: CategorySelectionViewModelOutput { self }
}

class CategorySelectionViewModel: CategorySelectionViewModelType {
    
    // Ouputs
    var categoriesDataSource: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { self.categoriesDataSourceSubject.asObservable() }
    
    // Subjects
    private var categoriesDataSourceSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    
    init(categories: [CategoryDTO]) {
        let categoriesVMs = categories.map { StoresCategoriesCollectionViewCellViewModel(category: $0) }
        self.categoriesDataSourceSubject.onNext([SectionModel(model: 0, items: categoriesVMs)])
    }
}
