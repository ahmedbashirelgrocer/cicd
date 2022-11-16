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
    var title: Observable<String> { get }
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var nextButtonTap: Observable<ActiveCartDTO> { get }
    var bannerTap: Observable<String> { get }
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
    var title: Observable<String> { titleSubject.asObservable() }
    var nextButtonTap: Observable<ActiveCartDTO> { nextButtonTapSubject.asObservable() }
    var bannerTap: Observable<String> { bannerTapSubject.asObservable() }
    
    
    // MARK: Subjects
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private var cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let titleSubject = BehaviorSubject<String>(value: NSLocalizedString("screen_active_cart_listing_title", bundle: .resource, comment: ""))
    private let nextButtonTapSubject = PublishSubject<ActiveCartDTO>()
    private let bannerTapSubject = PublishSubject<String>()
    
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

        self.fetchActiveCarts()
    }
}
        
// MARK: Helpers
private extension ActiveCartListingViewModel {
    func fetchActiveCarts() {
        self.loadingSubject.onNext(true)
        
        self.apiClinet.getActiveCarts(latitude: self.latitude, longitude: self.longitude) { [weak self] result in
            guard let self = self else { return }
            
            self.loadingSubject.onNext(false)

            switch result {
            case .success(let activeCarts):
                if activeCarts.isEmpty {
                    let emptyMsg = NSLocalizedString("screen_active_cart_listing_empty_message", bundle: .resource, comment: "")
                    self.cellViewModelsSubject.onNext([SectionModel(model: 0, items: [EmptyCellViewModel(errorMsg: emptyMsg)])])
                    return
                }
                
                // convert the cert DTOs to cell view model 
                let activeCartVMs = activeCarts.map { cart in
                    let cartCellViewModel = ActiveCartCellViewModel(activeCart: cart)
                    
                    cartCellViewModel.outputs.nextButtonTap.bind(to: self.nextButtonTapSubject).disposed(by: self.disposeBag)
                    cartCellViewModel.outputs.bannerTap.bind(to: self.bannerTapSubject).disposed(by: self.disposeBag)
                    
                    return cartCellViewModel
                }
                
                self.cellViewModelsSubject.onNext([SectionModel(model: 0, items: activeCartVMs)])
                break

            case .failure(let error):
                self.cellViewModelsSubject.onNext([SectionModel(model: 0, items: [EmptyCellViewModel(errorMsg: error.localizedMessage)])])
                break
            }
        }
    }
}
