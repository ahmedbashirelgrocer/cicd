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
    var continueShoppingTapObserver: AnyObserver<Void> { get }
    var cellSelectedObserver: AnyObserver<ActiveCartDTO> { get }
}

protocol ActiveCartListingViewModelOutput {
    var loading: Observable<Bool> { get }
    var title: Observable<String> { get }
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var bannerTap: Observable<String> { get }
    var showEmptyView: Observable<Void> { get }
    var continueShoppingTap: Observable<Void> { get }
    var cellSelected: Observable<ActiveCartDTO> { get }
    var error: Observable<ElGrocerError> { get }
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
    var continueShoppingTapObserver: AnyObserver<Void> { continueShoppingTapSubject.asObserver() }
    var cellSelectedObserver: AnyObserver<ActiveCartDTO> { cellSelectedSubject.asObserver() }
    
    // MARK: Outputs
    var loading: Observable<Bool> { loadingSubject.asObservable() }
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    var title: Observable<String> { titleSubject.asObservable() }
    var bannerTap: Observable<String> { bannerTapSubject.asObservable() }
    var showEmptyView: Observable<Void> { showEmptyViewSubject.asObservable() }
    var continueShoppingTap: Observable<Void> { continueShoppingTapSubject.asObservable() }
    var cellSelected: Observable<ActiveCartDTO> { cellSelectedSubject.asObservable() }
    var error: Observable<ElGrocerError> { errorSubject.asObservable() }
    
    // MARK: Subjects
    private var loadingSubject = BehaviorSubject<Bool>(value: false)
    private var cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let titleSubject = BehaviorSubject<String>(value: NSLocalizedString("screen_active_cart_listing_title", bundle: .resource, comment: ""))
    private let bannerTapSubject = PublishSubject<String>()
    private let showEmptyViewSubject = PublishSubject<Void>()
    private let continueShoppingTapSubject = PublishSubject<Void>()
    private let cellSelectedSubject = PublishSubject<ActiveCartDTO>()
    private let errorSubject = PublishSubject<ElGrocerError>()
    
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
                guard activeCarts.isNotEmpty else {
                    self.showEmptyViewSubject.onNext(())
                    return
                }
                
                let activeCartVMs = activeCarts.map { cart in
                    let cartCellViewModel = ActiveCartCellViewModel(activeCart: cart)
                    cartCellViewModel.outputs.bannerTap.bind(to: self.bannerTapSubject).disposed(by: self.disposeBag)             
                    return cartCellViewModel
                }
                
                self.cellViewModelsSubject.onNext([SectionModel(model: 0, items: activeCartVMs)])
                break

            case .failure(let error):
                self.errorSubject.onNext(error)
                break
            }
        }
    }
}
