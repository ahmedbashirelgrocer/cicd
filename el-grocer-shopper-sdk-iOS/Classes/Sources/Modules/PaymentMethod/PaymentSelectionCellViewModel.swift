//
//  PaymentSelectionCellViewModel.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 06/09/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import Adyen

protocol PaymentSelectionCellViewModelInputs {
    var selectedObserver: AnyObserver<Bool> { get }
}

protocol PaymentSelectionCellViewModelOutputs {
    var icon: RxSwift.Observable<UIImage?> { get }
    var title: RxSwift.Observable<String> { get }
    var selected: RxSwift.Observable<Bool> { get }
    var isForAddNewCard: RxSwift.Observable<Bool> { get }
    var isArbicSelected: RxSwift.Observable<Bool> { get }
}

protocol PaymentSelectionCellViewModelType {
    var inputs: PaymentSelectionCellViewModelInputs { get }
    var outputs: PaymentSelectionCellViewModelOutputs { get }
}

class PaymentSelectionCellViewModel: PaymentSelectionCellViewModelType, PaymentSelectionCellViewModelInputs, PaymentSelectionCellViewModelOutputs  {
    
    private let iconSubject = BehaviorSubject<UIImage?>(value: nil)
    private let titleSubject = BehaviorSubject<String>(value: "")
    private let selectedSubject = BehaviorSubject<Bool>(value: false)
    private let radioButtonSubject = BehaviorSubject<UIImage?>(value: nil)
    private let isForAddNewCardSubject: BehaviorSubject<Bool>
    private let isArbicSelectedSubject =  BehaviorSubject<Bool>(value: false)
    
    // fix me
    var option: PaymentOption?
    var creditCard: CreditCard?
    var applePay: ApplePayPaymentMethod?
    
    
    var inputs: PaymentSelectionCellViewModelInputs { self }
    var outputs: PaymentSelectionCellViewModelOutputs { self }
    
    var selectedObserver: AnyObserver<Bool> { selectedSubject.asObserver() }

    // MARK: Outputs
    var icon: RxSwift.Observable<UIImage?> { iconSubject.asObservable() }
    var title: RxSwift.Observable<String> { titleSubject.asObservable() }
    var selected: RxSwift.Observable<Bool> { selectedSubject.asObservable() }
    var radioButtonIcon: RxSwift.Observable<UIImage?> { radioButtonSubject.asObservable() }
    var isForAddNewCard: RxSwift.Observable<Bool> { isForAddNewCardSubject.asObservable() }
    var isArbicSelected: RxSwift.Observable<Bool> { isArbicSelectedSubject.asObservable() }
    
    init(option: PaymentOption, applePay: ApplePayPaymentMethod? = nil, isSelected: Bool = false) {
        
        isForAddNewCardSubject = BehaviorSubject<Bool>(value: false)
        self.selectedSubject.onNext(isSelected)
        
        self.option = option
        
        switch option {
            case .none, .creditCard, .smilePoints, .voucher, .PromoCode:
                break

            case .cash:
                self.titleSubject.onNext(localizedString("cash_On_Delivery_string", comment: ""))
                self.iconSubject.onNext(UIImage(named: "cash-List"))
                break
            
            case .applePay:
                self.applePay = applePay
                self.titleSubject.onNext(localizedString("checkout_paymentlist_applepay_title", comment: ""))
                self.iconSubject.onNext(UIImage(named: "payWithApple"))
                break

            case .card:
                self.titleSubject.onNext(localizedString("pay_via_card", comment: ""))
                self.iconSubject.onNext(UIImage(named: "CardOnDelivery"))
                break
        }
    }
    
    init(card: CreditCard, isSelected: Bool = false) {
        isForAddNewCardSubject = BehaviorSubject<Bool>(value: false)
        self.selectedSubject.onNext(isSelected)
        
        self.creditCard = card
        
        self.titleSubject.onNext(localizedString("lbl_Card_ending_in", comment: "") + card.last4)
        self.iconSubject.onNext(card.cardType.getCardColorImageFromType())
    }
    
    init(string: String, isSelected: Bool = false) {
        isForAddNewCardSubject = BehaviorSubject<Bool>(value: true)
        self.selectedSubject.onNext(isSelected)
        
        self.titleSubject.onNext(string)
        self.iconSubject.onNext(UIImage(name: "plus")!)
        self.radioButtonSubject.onNext(UIImage(name: "arrowForward"))
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.isArbicSelectedSubject.onNext(true)
        }
    }
}
