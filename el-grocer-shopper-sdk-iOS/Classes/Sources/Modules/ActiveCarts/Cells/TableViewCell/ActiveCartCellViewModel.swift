//
//  ActiveCartCellViewModel.swift
//  Adyen
//
//  Created by Rashid Khan on 14/11/2022.
//

import Foundation
import RxSwift
import RxDataSources

protocol ActiveCartCellViewModelInput { }

protocol ActiveCartCellViewModelOutput {
    var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { get }
}

protocol ActiveCartCellViewModelType: ActiveCartCellViewModelInput, ActiveCartCellViewModelOutput {
    var inputs: ActiveCartCellViewModelInput { get }
    var outputs: ActiveCartCellViewModelOutput { get }
}

extension ActiveCartCellViewModelType {
    var inputs: ActiveCartCellViewModelInput { self }
    var outputs: ActiveCartCellViewModelOutput { self }
}

class ActiveCartCellViewModel: ActiveCartCellViewModelType, ReusableTableViewCellViewModelType {
    
    // MARK: Outputs
    var cellViewModels: Observable<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    
    // MARK: Subjects
    private var cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableCollectionViewCellViewModelType>]>(value: [])
    
    // MARK: Properties
    var reusableIdentifier: String { ActiveCartTableViewCell.defaultIdentifier }
    
    init(activeCart: ActiveCartDTO) {
        let productVMs = activeCart.products.map { ActiveCartProductCellViewModel(product: $0)}
        self.cellViewModelsSubject.onNext([SectionModel(model: 0, items: productVMs)])
    }
}
