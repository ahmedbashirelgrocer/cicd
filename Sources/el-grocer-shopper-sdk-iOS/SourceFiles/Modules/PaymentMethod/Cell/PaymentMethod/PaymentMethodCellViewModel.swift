//
//  OnlinePaymentCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 07/12/2023.
//

import UIKit
import RxSwift
import Adyen

protocol PaymentMethodCellViewModelInput {
}

protocol PaymentMethodCellViewModelOutput {
    var icon: RxSwift.Observable<UIImage?> { get }
    var title: RxSwift.Observable<String?> { get }
    var arabic: RxSwift.Observable<Bool> { get }
    var subTitle: RxSwift.Observable<String?> { get }
    var selected: RxSwift.Observable<Bool> { get }
    
    var applePay: RxSwift.Observable<ApplePayPaymentMethod>? { get }
    var creditCard: RxSwift.Observable<CreditCard>? { get }
    var option: RxSwift.Observable<PaymentOption>? { get }
    var tabbyAuthUrl: RxSwift.Observable<String>? { get }
}

protocol PaymentMethodCellViewModelType {
    var inputs: PaymentMethodCellViewModelInput { get }
    var outputs: PaymentMethodCellViewModelOutput { get }
}

class PaymentMethodCellViewModel: PaymentMethodCellViewModelType, PaymentMethodCellViewModelInput, PaymentMethodCellViewModelOutput, ReusableTableViewCellViewModelType {
    var reusableIdentifier: String { PaymentMethodCell.defaultIdentifier }
    
    var inputs: PaymentMethodCellViewModelInput { self }
    var outputs: PaymentMethodCellViewModelOutput { self }
    
    /// Outputs
    var icon: RxSwift.Observable<UIImage?> { iconSubject.asObservable() }
    var title: RxSwift.Observable<String?> { titleSubject.asObservable() }
    var arabic: RxSwift.Observable<Bool> { arabicSubject.asObservable() }
    var subTitle: RxSwift.Observable<String?> { subTitleSubject.asObservable() }
    var selected: RxSwift.Observable<Bool> { selectedSubjet.asObservable() }
    
    var applePay: RxSwift.Observable<ApplePayPaymentMethod>? { applePaySubject?.asObservable() }
    var creditCard: RxSwift.Observable<CreditCard>? { creditCardSubject?.asObservable() }
    var option: RxSwift.Observable<PaymentOption>? { optionSubject?.asObservable() }
    var tabbyAuthUrl: RxSwift.Observable<String>? { tabbyAuthUrlSubject?.asObservable() }
    
    /// Subjects
    private var iconSubject: BehaviorSubject<UIImage?> = .init(value: nil)
    private var titleSubject: BehaviorSubject<String?> = .init(value: nil)
    private var arabicSubject: BehaviorSubject<Bool> = .init(value: ElGrocerUtility.sharedInstance.isArabicSelected())
    private var subTitleSubject: BehaviorSubject<String?> = .init(value: nil)
    private var selectedSubjet: BehaviorSubject<Bool> = .init(value: false)
    
    private var applePaySubject: BehaviorSubject<ApplePayPaymentMethod>?
    private var creditCardSubject: BehaviorSubject<CreditCard>?
    private var optionSubject: BehaviorSubject<PaymentOption>?
    private var tabbyAuthUrlSubject: BehaviorSubject<String>?
    
    // For ApplePay Cell
    init(applePay: ApplePayPaymentMethod, _ isSelected: Bool = false) {
        iconSubject.onNext(UIImage(name: "payWithApple"))
        titleSubject.onNext(localizedString("checkout_paymentlist_applepay_title", comment: ""))
        applePaySubject = .init(value: applePay)
        selectedSubjet.onNext(isSelected)
    }
    
    // For Online Payment Cell
    init(creditCard: CreditCard, _ isSelected: Bool = false) {
        iconSubject.onNext(creditCard.cardType.getCardColorImageFromType())
        titleSubject.onNext(localizedString("lbl_Card_ending_in", comment: "") + creditCard.last4)
        creditCardSubject = .init(value: creditCard)
        selectedSubjet.onNext(isSelected)
    }
    
    // For Cash & Card on Delivery Cell
    init(paymentOption: PaymentOption, _ isSelected: Bool = false) {
        let title = paymentOption == .cash
            ? localizedString("cash_On_Delivery_string", comment: "")
            : localizedString("pay_via_card", comment: "")

        let icon =  paymentOption == .card
            ? UIImage(name: "cash-List")
            : UIImage(name: "CardOnDelivery")

        iconSubject.onNext(icon)
        titleSubject.onNext(title)
        optionSubject = .init(value: paymentOption)
        selectedSubjet.onNext(isSelected)
    }
    
    // For Tabby Cell
    init(authenticationUrl: String, _ isSelected: Bool = false) {
        iconSubject.onNext(UIImage(name: "pay_via_tabby"))
        titleSubject.onNext(localizedString("tabby_view_title_text", comment: ""))
        subTitleSubject.onNext(localizedString("tabby_payment_warning_msg", comment: ""))
        tabbyAuthUrlSubject = .init(value: authenticationUrl)
        selectedSubjet.onNext(isSelected)
    }
}
