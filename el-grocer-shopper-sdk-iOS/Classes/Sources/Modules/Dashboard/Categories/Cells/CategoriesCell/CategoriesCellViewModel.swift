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
    var viewAllTapObserver: AnyObserver<Void> { get }
}

protocol CategoriesCellViewModelOutput {
    var title: Observable<String> { get }
    var collectionCellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
    var viewAllTap: Observable<Void> { get }
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
    var viewAllTapObserver: RxSwift.AnyObserver<Void> { viewAllTapSubject.asObserver() }
    
    // MARK: Outputs
    var title: Observable<String> { self.titleSubject.asObservable() }
    var collectionCellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { self.collectionCellViewModelsSubject }
    var viewAllTap: Observable<Void> { viewAllTapSubject.asObservable() }
    
    // MARK: Subjects
    private var titleSubject: BehaviorSubject<String>
    private var collectionCellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    private var viewAllTapSubject = PublishSubject<Void>()
    
    var reusableIdentifier: String { CategoriesCell.defaultIdentifier }
    
    private var disposeBag = DisposeBag()
    
    init(categories: [CategoryDTO]) {
        self.titleSubject = BehaviorSubject(value: "Shop by Category")
        self.collectionCellViewModelsSubject.onNext([SectionModel(model: 0, items: categories.map { StoresCategoriesCollectionViewCellViewModel(category: $0) })])
    }
}
