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

class ActiveCartListingViewModel: ActiveCartListingViewModelType, ReusableTableViewCellViewModelType {
    // MARK: Inputs
    
    // MARK: Outputs
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    
    // MARK: Subjects
    var cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    
    
    // MARK: Properties
    var reusableIdentifier: String { ActiveCartTableViewCell.defaultIdentifier }
    private var apiClinet: ElGrocerApi
    private var disposeBag = DisposeBag()
    
    // MARK: Initlizations
    init(apiClinet: ElGrocerApi, latitude: Double, longitude: Double) {
        self.apiClinet = apiClinet
        
        self.fetchActiveCarts(latitude: latitude, longitude: longitude)
    }
}

// MARK: Helpers
private extension ActiveCartListingViewModel {
    func fetchActiveCarts(latitude: Double, longitude: Double) {
        let activeCarts: [ActiveCartDTO] = [
            ActiveCartDTO(companyName: "Riyan Test Store", isOpened: true, products: [ActiveCartProductDTO(), ActiveCartProductDTO(), ActiveCartProductDTO()], deliveryType: .instant),
            ActiveCartDTO(companyName: "Store Name", isOpened: true, products: [ActiveCartProductDTO(), ActiveCartProductDTO()], deliveryType: .scheduled),
            ActiveCartDTO(companyName: "Test Store Name", products: [ActiveCartProductDTO(), ActiveCartProductDTO(), ActiveCartProductDTO(), ActiveCartProductDTO()], deliveryType: .scheduled),
        ]
        
        let activeCartVMs = activeCarts.map { ActiveCartCellViewModel(activeCart: $0)}
        self.cellViewModelsSubject.onNext([SectionModel(model: 0, items: activeCartVMs)])
    }
}
