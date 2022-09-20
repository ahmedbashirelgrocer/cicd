//
//  PaymentSelectionViewModel.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 03/09/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation
import RxSwift

protocol PaymentSelectionViewModelInputs {
    var selectedItemObserver: AnyObserver<PaymentSelectionCellViewModel> { get }
}

protocol PaymentSelectionViewModelOutputs {
    var cellViewModels: Observable<[PaymentSelectionCellViewModel]> { get }
    var title: Observable<String> { get }
    var error: Observable<ElGrocerError> { get }
    var selectedItem: Observable<PaymentSelectionCellViewModel> { get }
}

protocol PaymentSelectionViewModelType {
    var inputs: PaymentSelectionViewModelInputs { get }
    var outputs: PaymentSelectionViewModelOutputs { get }
}

class PaymentSelectionViewModel: PaymentSelectionViewModelType, PaymentSelectionViewModelInputs, PaymentSelectionViewModelOutputs {
    var inputs: PaymentSelectionViewModelInputs { self }
    var outputs: PaymentSelectionViewModelOutputs { self }
    
    
    private var elGrocerAPI: ElGrocerApi
    private var adyenAPIManager: AdyenApiManager
    private var grocery: Grocery?
    private var paymentOption: PaymentOption?
    private var selectedCardId: String?
    private var viewModels = [PaymentSelectionCellViewModel]()
    
    private var disposeBag = DisposeBag()
    
    // MARK: Subjects
    private var cellViewModelsSubject = BehaviorSubject<[PaymentSelectionCellViewModel]>(value: [])
    private var errorSubject = PublishSubject<ElGrocerError>()
    private var selectedItemSubject = PublishSubject<PaymentSelectionCellViewModel>()
    private var titleSubject = BehaviorSubject<String>(value: "")
    
    // MARK: Inputs
    var selectedItemObserver: AnyObserver<PaymentSelectionCellViewModel> { selectedItemSubject.asObserver() }
    
    // MARK: Output
    var cellViewModels: Observable<[PaymentSelectionCellViewModel]> { return cellViewModelsSubject.asObservable() }
    var title: Observable<String> { return titleSubject.asObservable() }
    var error: Observable<ElGrocerError> { errorSubject.asObservable() }
    var selectedItem: Observable<PaymentSelectionCellViewModel> { selectedItemSubject.asObservable() }
    
    init(elGrocerAPI: ElGrocerApi, adyenApiManager: AdyenApiManager, grocery: Grocery?,selectedPaymentOption: PaymentOption?, cardId: String?) {
        self.elGrocerAPI = elGrocerAPI
        self.adyenAPIManager = adyenApiManager
        self.grocery = grocery
        self.paymentOption = selectedPaymentOption
        self.selectedCardId = cardId
        self.titleSubject.onNext(localizedString("payment_method_title", comment: ""))
    }
}

extension PaymentSelectionViewModel {
    func fetchPaymentMethods(completion: @escaping ((Bool) -> Void)) {
        guard let groceryID = grocery?.dbID else { return }
        

        PaymentMethodFetcher.getPaymentOptions(groceryID: groceryID) { paymentOptions, error in
            if let error = error {
                self.errorSubject.onNext(error)
                completion(true)
                return
            }
            
            guard var paymentOptions = paymentOptions else { return }
            
            
            if paymentOptions.contains(where: { $0 == .cash}) {
                self.viewModels.append(PaymentSelectionCellViewModel(option: .cash, isSelected: self.paymentOption == .cash))
            }
            if paymentOptions.contains(where: { $0 == .card}) {
                self.viewModels.append(PaymentSelectionCellViewModel(option: .card, isSelected: self.paymentOption == .card))
//                self.viewModels.append(PaymentSelectionCellViewModel(option: .card, isSelected: true))
            }
            
            
            if paymentOptions.contains(where: { $0 == .creditCard }) {
                // TODO: Ask why passing hard coded value of amount
                let amount = AdyenManager.createAmount(amount: 100.0)
                
                PaymentMethodFetcher.getPaymentMethods(amount: amount, addApplePay: true) { creditCards, applePay, error in
                    if let error = error {
                        self.errorSubject.onNext(error)
                        return
                    }
                    
                    paymentOptions.removeAll(where: { $0 == .creditCard })
                    
//                    paymentOptions.forEach { option in
//                        self.viewModels.append(PaymentSelectionCellViewModel(option: option))
//                    }
                    
                    if applePay != nil {
                        self.viewModels.append(PaymentSelectionCellViewModel(option: .applePay, applePay: applePay, isSelected: self.paymentOption == .applePay))
                    }
                    
                    creditCards?.forEach({ creditCard in
                        if (self.selectedCardId ?? "").elementsEqual(creditCard.cardID) && self.paymentOption == .creditCard {
                            self.viewModels.append(PaymentSelectionCellViewModel(card: creditCard, isSelected: true))
                        }else {
                            self.viewModels.append(PaymentSelectionCellViewModel(card: creditCard))
                        }
                    })
                    
                    self.viewModels.append(PaymentSelectionCellViewModel(string: localizedString("btn_add_new_card", comment: "")))
                    self.cellViewModelsSubject.onNext(self.viewModels)
                }
            } else {
                self.cellViewModelsSubject.onNext(self.viewModels)
            }
            completion(true)
        }
    }
}


