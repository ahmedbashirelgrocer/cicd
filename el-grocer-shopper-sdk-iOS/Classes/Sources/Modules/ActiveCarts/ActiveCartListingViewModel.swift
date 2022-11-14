//
//  ActiveCartListingViewModel.swift
//  Adyen
//
//  Created by Rashid Khan on 14/11/2022.
//

import Foundation
import RxSwift
import RxDataSources

protocol ActiveCartListingViewModelInput {
    
}

protocol ActiveCartListingViewModelOutput {
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
}

protocol ActiveCartListingViewModelType: ActiveCartListingViewModelInput, ActiveCartListingViewModelOutput {
    var inputs: ActiveCartListingViewModelInput { get }
    var outputs: ActiveCartListingViewModelOutput { get }
}

extension ActiveCartListingViewModelType {
    var inputs: ActiveCartListingViewModelInput { self }
    var outputs: ActiveCartListingViewModelOutput { self }
}

class ActiveCartListingViewModel: ActiveCartListingViewModelType {
    // MARK: Inputs
    
    // MARK: Outputs
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    
    // MARK: Subjects
    var cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    
    
    // MARK: Properties
    private var apiClinet: ElGrocerApi
    private var disposeBag = DisposeBag()
    
    // MARK: Initlizations
    init(apiClinet: ElGrocerApi, latitude: Double, longitude: Double) {
        self.apiClinet = apiClinet
        
    }
}

// MARK: Helpers
private extension ActiveCartListingViewModel { }
