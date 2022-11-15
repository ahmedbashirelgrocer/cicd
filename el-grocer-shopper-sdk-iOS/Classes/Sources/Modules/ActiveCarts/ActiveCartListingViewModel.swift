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
    var loading: Observable<Bool> { get }
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

class ActiveCartListingViewModel: ActiveCartListingViewModelType, ReusableTableViewCellViewModelType {
    // MARK: Inputs
    
    // MARK: Outputs
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    
    // MARK: Subjects
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private var cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    
    
    // MARK: Properties
    var reusableIdentifier: String { ActiveCartTableViewCell.defaultIdentifier }
    private var apiClinet: ElGrocerApi
    private var latitude: Double
    private var longitude: Double
    private var disposeBag = DisposeBag()
    
    // MARK: Initlizations
    init(apiClinet: ElGrocerApi, latitude: Double, longitude: Double) {
        self.apiClinet = apiClinet
        self.latitude = latitude
        self.longitude = longitude
        
        self.fetchActiveCarts(latitude: latitude, longitude: longitude)
    }
}

// MARK: Helpers
private extension ActiveCartListingViewModel {
    func fetchActiveCarts(latitude: Double, longitude: Double) {
        let activeCarts: [ActiveCartDTO] = [
            ActiveCartDTO(companyName: "Test Company", products: [ActiveCartProductDTO()], deliveryType: .scheduled)
        ]
        
        let activeCartVMs = activeCarts.map { ActiveCartCellViewModel(activeCart: $0)}
        self.cellViewModelsSubject.onNext([SectionModel(model: 0, items: activeCartVMs)])
    }
}
