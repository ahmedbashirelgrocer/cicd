//
//  CategoriesCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 13/01/2023.
//

import Foundation
import RxSwift
import RxDataSources

protocol CategoriesCellViewModelInput {
    
}

protocol CategoriesCellViewModelOutput {
    var title: Observable<String> { get }
    var collectionCellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
}

protocol CategoriesCellViewModelType: CategoriesCellViewModelInput, CategoriesCellViewModelOutput {
    var inputs: CategoriesCellViewModelInput { get }
    var outputs: CategoriesCellViewModelOutput { get }
}

extension CategoriesCellViewModelType {
    var inputs: CategoriesCellViewModelInput { self }
    var outputs: CategoriesCellViewModelOutput { self }
}

class CategoriesCellViewModel: CategoriesCellViewModelType, ReusableTableViewCellViewModelType {
    // MARK: Inputs
    
    // MARK: Outputs
    var title: Observable<String> { self.titleSubject.asObservable() }
    var collectionCellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { self.collectionCellViewModelsSubject }
    
    // MARK: Subjects
    private var titleSubject: BehaviorSubject<String>
    private var collectionCellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    
    var reusableIdentifier: String { CategoriesCell.defaultIdentifier }
    
    private var disposeBag = DisposeBag()
    
    init(categories: [CategoryDTO]) {
        self.titleSubject = BehaviorSubject(value: "Shop by Category")
        self.collectionCellViewModelsSubject.onNext([SectionModel(model: 0, items: categories.map { StoresCategoriesCollectionViewCellViewModel(category: $0) })])
    }
}
