//
//  ElwalletViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 05/12/2023.
//

import Foundation
import RxSwift

protocol ElWalletViewModelInput {
    var confirButtonTapObserver: AnyObserver<Void> { get }
    var sliderObserver: AnyObserver<Float> { get }
    var textFieldObserver: AnyObserver<String?> { get }
}

protocol ElWalletViewModelOutput {
    typealias LocalizedText = (title: String, description: String, amountDue: String, amountRemaining: String, confirmButtonTitle: String)
    
    var localizedText: Observable<LocalizedText> { get }
    var redeemedAmount: Observable<String> { get }
    var availableBalance: Observable<String> { get }
    var amountDue: Observable<String?> { get }
    var amountRemaining: Observable<String?> { get }
    var sliderLimit: Observable<(Float, Float)> { get }
    var sliderCurrentValue: Observable<Float> { get }
    var result: Observable<Double> { get }
    var error: Observable<String?> { get }
}

protocol ElWalletViewModelType {
    var inputs: ElWalletViewModelInput { get }
    var outputs: ElWalletViewModelOutput { get }
}

class ElWalletViewModel: ElWalletViewModelType, ElWalletViewModelOutput, ElWalletViewModelInput {
    
    /// I/O Ports
    var inputs: ElWalletViewModelInput { self }
    var outputs: ElWalletViewModelOutput { self }
    
    /// Inputs
    var confirButtonTapObserver: AnyObserver<Void> { confirButtonTapSubject.asObserver() }
    var sliderObserver: AnyObserver<Float> { sliderSubject.asObserver() }
    var textFieldObserver: AnyObserver<String?> { textFieldSubject.asObserver() }
    
    /// Outputs
    var localizedText: Observable<LocalizedText> { localizedTextSubject.asObservable() }
    var redeemedAmount: Observable<String> { redeemedAmountSubject.asObservable() }
    var availableBalance: Observable<String> { availableBalanceSubject.map { ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: $0)} }
    var amountDue: Observable<String?> { amountDueSubject.map { ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: $0 ?? 0)} }
    var amountRemaining: Observable<String?> { amountRemaningSubject.asObservable() }
    var sliderLimit: Observable<(Float, Float)> { availableBalanceSubject.map { (0.0, Float($0)) }}
    var sliderCurrentValue: Observable<Float> { sliderCurrentValueSubject }
    var result: Observable<Double> { resultSubject.asObservable() }
    var error: Observable<String?> { errorSubject.asObservable() }
    
    /// Subjects
    private let localizedTextSubject: BehaviorSubject<LocalizedText>
    private var confirButtonTapSubject: PublishSubject<Void> = .init()
    private var sliderSubject: BehaviorSubject<Float> = .init(value: 0.0)
    
    private var redeemedAmountSubject: BehaviorSubject<String> = .init(value: "0")
    private var availableBalanceSubject: BehaviorSubject<Double> = .init(value: 0.0)
    private let amountDueSubject: BehaviorSubject<Double?> = .init(value: nil)
    private let amountRemaningSubject: BehaviorSubject<String?> = .init(value: nil)
    private var resultSubject: PublishSubject<Double> = .init()
    private var sliderCurrentValueSubject: BehaviorSubject<Float> = .init(value: 0.0)
    
    private var initialRedeemSubject: BehaviorSubject<Float> = .init(value: 0.0)
    private var textFieldSubject: BehaviorSubject<String?> = .init(value: nil)
    private var errorSubject: BehaviorSubject<String?> = .init(value: nil)
    
    /// Properities
    private var disposeBag = DisposeBag()
    
    init(availableAmount: Double, redeemedAmount: Double = 0.0, amountToPay: Double) {
        availableBalanceSubject.onNext(availableAmount.round(to: 2))
        initialRedeemSubject.onNext(Float(redeemedAmount.round(to: 2)))
        amountDueSubject.onNext((amountToPay + redeemedAmount).round(to: 2))
        
        self.localizedTextSubject = BehaviorSubject(value: (
            title: localizedString("el_wallet_redeemed_bottom_sheet_title", comment: ""),
            description: localizedString("el_wallet_redeemed_bottom_sheet_description", comment: ""),
            amountDue: localizedString("amount_due_text", comment: ""),
            amountRemaining: localizedString("remaining_amount_text", comment: ""),
            confirmButtonTitle: localizedString("confirm_button_title", comment: "")
        ))
        
        let sliderValue = Observable
            .combineLatest(Observable.merge(sliderSubject, initialRedeemSubject), amountDueSubject)
            .map { min(Double($0), $1 ?? 0.0) }
        
        sliderValue
            .map { Float($0) }
            .bind(to: self.sliderCurrentValueSubject)
            .disposed(by: disposeBag)
        
        sliderValue
            .map { $0.formateDisplayString() }
            .bind(to: self.redeemedAmountSubject)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(amountDueSubject, sliderValue)
            .map { ($0 ?? 0.0) - $1 }
            .map { ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: $0) }
            .bind(to: self.amountRemaningSubject)
            .disposed(by: disposeBag)
        
        redeemedAmountSubject
            .bind(to: self.textFieldSubject)
            .disposed(by: disposeBag)
        
        let confirmButtonTap = confirButtonTapSubject
            .withLatestFrom(textFieldSubject)
            .map { $0?.removingWhitespaceAndNewlines() }
            .map { Double($0 ?? "0") ?? 0.0 }
            .share()
        
        Observable
            .combineLatest(confirmButtonTap, amountDueSubject, availableBalanceSubject)
            .filter { $0 > ($1 ?? 0.0) || $0 > $2 }
            .map { self.errorMsg(redeemAmount: $0, availableAmount: $2) }
            .bind(to: self.errorSubject)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(confirmButtonTap, amountDueSubject, availableBalanceSubject)
            .filter { $0 <= $2 && $0 <= $1 ?? 0 }
            .map { $0.0 }
            .bind(to: resultSubject)
            .disposed(by: disposeBag)
    }
    
    private func errorMsg(redeemAmount: Double, availableAmount: Double) -> String {
        if redeemAmount > availableAmount {
            return localizedString("el_wallet_entered_amount_more_than_available_error", comment: "")
        }
        
        return localizedString("el_wallet_entered_amount_more_than_bill_error", comment: "")
    }
}
