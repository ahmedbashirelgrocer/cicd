//
//  PaymentSelectionViewModel.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 03/09/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation
import RxSwift
import Adyen
import RxDataSources

enum PaymentBottomSheetActionResult {
    case applePay(ApplePayPaymentMethod)
    case creditCartAc(CreditCard)
    case other(PaymentOption)
    case addNewCard
    case tabby(String)
}

protocol PaymentSelectionViewModelInputs {
    var fetchPaymentMethodsObserver: RxSwift.AnyObserver<Void> { get }
    var modelSelectedObserver: RxSwift.AnyObserver<ReusableTableViewCellViewModelType> { get }
}

protocol PaymentSelectionViewModelOutputs {
    var title: RxSwift.Observable<String> { get }
    var error: RxSwift.Observable<ElGrocerError> { get }
    var loading: RxSwift.Observable<Bool> { get }
    var dataSource: RxSwift.Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var height: RxSwift.Observable<CGFloat> { get }
    var result: RxSwift.Observable<PaymentBottomSheetActionResult> { get }
}

protocol PaymentSelectionViewModelType {
    var inputs: PaymentSelectionViewModelInputs { get }
    var outputs: PaymentSelectionViewModelOutputs { get }
}

class PaymentSelectionViewModel: PaymentSelectionViewModelType, PaymentSelectionViewModelInputs, PaymentSelectionViewModelOutputs {
    
    var inputs: PaymentSelectionViewModelInputs { self }
    var outputs: PaymentSelectionViewModelOutputs { self }
    
    // MARK: Inputs
    var fetchPaymentMethodsObserver: AnyObserver<Void> { fetchPaymentMethodsSubject.asObserver() }
    var modelSelectedObserver: AnyObserver<ReusableTableViewCellViewModelType> { modelSelectedSubject.asObserver() }
    
    // MARK: Output
    var title: RxSwift.Observable<String> { return titleSubject.asObservable() }
    var error: RxSwift.Observable<ElGrocerError> { errorSubject.asObservable() }
    var loading: RxSwift.Observable<Bool> { loadingSubject.asObservable() }
    var dataSource: RxSwift.Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { dataSourceSubject.asObservable() }
    var height: RxSwift.Observable<CGFloat> { heightSubject.asObservable() }
    var result: RxSwift.Observable<PaymentBottomSheetActionResult> { resultSubject.asObservable() }
    
    // MARK: Subjects
    private var errorSubject = RxSwift.PublishSubject<ElGrocerError>()
    private var titleSubject = RxSwift.BehaviorSubject<String>(value: localizedString("payment_method_title", comment: ""))
    private var loadingSubject = RxSwift.BehaviorSubject<Bool>(value: false)
    private var fetchPaymentMethodsSubject = RxSwift.PublishSubject<Void>()
    private var dataSourceSubject: RxSwift.BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]> = .init(value: [])
    private var heightSubject: RxSwift.BehaviorSubject<CGFloat> = .init(value: 150)
    private var resultSubject: RxSwift.PublishSubject<PaymentBottomSheetActionResult> = .init()
    private var modelSelectedSubject: RxSwift.PublishSubject<ReusableTableViewCellViewModelType> = .init()
    
    private var disposeBag = DisposeBag()
    private var selectedPaymentOption: PaymentOption?
    private var selectedCreditCardId: String?
    private var tabbyAuthUrl: String = ""
    
    init(grocery: Grocery?, selectedPaymentOption: PaymentOption?, cardId: String?, paymentTypes: [PaymentType], tabbyAuthURL: String?) {
        self.selectedPaymentOption = selectedPaymentOption
        self.selectedCreditCardId = cardId
        self.tabbyAuthUrl = tabbyAuthURL ?? ""
        
        // Fetch Payment Methods
        let paymentOptionsFetch = fetchPaymentMethodsSubject
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(true)})
            .flatMapLatest { [unowned self] _ in self.getPrimaryPaymentType(retailerPaymentTypes: paymentTypes) }
            .do(onNext: { [weak self] _ in self?.loadingSubject.onNext(false)})
            .share()
        
        //
        let paymentOptions = paymentOptionsFetch
            .compactMap { $0.element }
            .share()
        
        let viewModelsSubject = paymentOptions
            .flatMapLatest{ [unowned self] pMethods in
                Observable.just(self.makeCellViewModels(options: pMethods.0, creditCards: pMethods.1, applePay: pMethods.2))
            }
            .share()
        
        viewModelsSubject
            .map { [SectionModel(model: 0, items: $0)]}
            .bind(to: self.dataSourceSubject)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(paymentOptions, viewModelsSubject)
            .map { ($0.0, $1) }
            .map { options, viewModels in
                if let tabbyOption = options.first(where: { $0 == .tabby }) {
                    return CGFloat((viewModels.count * 48) + 50 + 24)
                }
                
                return CGFloat((viewModels.count * 48) + 50)
            }
            .bind(to: self.heightSubject)
            .disposed(by: disposeBag)
        
        let paymentMethodModelSelected = modelSelectedSubject
            .compactMap { $0 as? PaymentMethodCellViewModelType }
            .filter { $0 != nil }
            .share()
        
        Observable
            .merge(
                paymentMethodModelSelected
                    .flatMap{$0.outputs.applePay ?? .empty()}
                    .compactMap{ PaymentBottomSheetActionResult.applePay($0) },
                
                paymentMethodModelSelected
                    .flatMap{$0.outputs.creditCard ?? .empty()}
                    .compactMap{PaymentBottomSheetActionResult.creditCartAc($0)},
                
                paymentMethodModelSelected
                    .flatMap{$0.outputs.option ?? .empty()}
                    .compactMap{PaymentBottomSheetActionResult.other($0)},
                
                paymentMethodModelSelected
                    .flatMap{$0.outputs.tabbyAuthUrl ?? .empty()}
                    .compactMap{PaymentBottomSheetActionResult.tabby($0)}
            )
            .bind(to: self.resultSubject)
            .disposed(by: disposeBag)
        
        modelSelectedSubject
            .compactMap { $0 as? AddCardCellViewModel }
            .map { _ in PaymentBottomSheetActionResult.addNewCard }
            .bind(to: self.resultSubject)
            .disposed(by: disposeBag)
    }
    
    private func makeCellViewModels(options: [PaymentOption], creditCards: [CreditCard], applePay: ApplePayPaymentMethod?) -> [ReusableTableViewCellViewModelType] {
        var cellViewModels: [ReusableTableViewCellViewModelType] = []
        
        if let applePay = applePay {
            cellViewModels.append(PaymentMethodCellViewModel(applePay: applePay, self.selectedPaymentOption == .applePay))
        }
        
        cellViewModels.append(contentsOf: creditCards
                .map { PaymentMethodCellViewModel(creditCard: $0, (self.selectedCreditCardId ?? "").elementsEqual($0.cardID) && self.selectedPaymentOption == .creditCard)}
        )
        
        cellViewModels.append(
            contentsOf: options.filter {$0 != .tabby }.map { PaymentMethodCellViewModel(paymentOption: $0, self.selectedPaymentOption == $0) }
        )
        
        cellViewModels.append(
            contentsOf: options
                .filter {$0 == .tabby}
                .map { _ in PaymentMethodCellViewModel(authenticationUrl: tabbyAuthUrl, self.selectedPaymentOption == .tabby) }
        )
        
        cellViewModels.append(AddCardCellViewModel())
        
        return cellViewModels
    }
}

fileprivate extension PaymentSelectionViewModel {
    func getPrimaryPaymentType(retailerPaymentTypes: [PaymentType]) -> RxSwift.Observable<Event<([PaymentOption], [CreditCard], ApplePayPaymentMethod?)>> {
        Observable.create { observer in
            
            let filteredOptions = retailerPaymentTypes
                .filter { ($0.accountType == .primary && $0.getLocalPaymentOption() != .applePay && $0.getLocalPaymentOption() != .creditCard)}
                .map { $0.getLocalPaymentOption() }
            
            if let online = retailerPaymentTypes.first(where: { $0.getLocalPaymentOption() == .creditCard }) {
                
                let amount = AdyenManager.createAmount(amount: 100.0)
                PaymentMethodFetcher.getPaymentMethods(amount: amount, addApplePay: true) { creditCards, applePayMethod, error in
                    if error == nil {
                        observer.onNext((filteredOptions, creditCards ?? [], applePayMethod))
                        observer.onCompleted()
                        return
                    }
                    
                    observer.onNext((filteredOptions, [], nil))
                }
            } else {
                observer.onNext((filteredOptions, [], nil))
                observer.onCompleted()
            }
            
            return Disposables.create()
        }.materialize()
    }
}
