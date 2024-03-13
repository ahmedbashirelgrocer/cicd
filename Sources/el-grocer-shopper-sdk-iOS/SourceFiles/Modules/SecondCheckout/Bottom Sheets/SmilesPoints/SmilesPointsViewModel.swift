//
//  SmilesPointSliderViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 04/12/2023.
//

import Foundation
import RxSwift

protocol SmilesPointsViewModelInput {
    var sliderValueObserver: AnyObserver<Float> { get }
    var confirmButtonTapObserver: AnyObserver<Void> { get }
}

protocol SmilesPointsViewModelOutput {
    typealias LocalizedText = (title: String, description: String, amountDue: String, amountRemaining: String, points: String, redeemPoints: String, confirmButtonTitle: String)
    
    var localizedText: Observable<LocalizedText> { get }
    var smilesPointsRedeemed: Observable<String> { get }
    var sliderLimit: Observable<(Int, Int)> { get }
    var availableSmilesPoints: Observable<String> { get }
    var availablePointsConvertedToAED: Observable<String> { get }
    var sliderCurrentValue: Observable<Float> { get }
    var result: Observable<Int> { get }
    var amountDueInAED: Observable<String?> { get }
    var amountRemaningInAED: Observable<String?> { get }
}

protocol SmilesPointsViewModelType {
    var inputs: SmilesPointsViewModelInput { get }
    var outputs: SmilesPointsViewModelOutput { get }
}

class SmilesPointsViewModel: SmilesPointsViewModelType, SmilesPointsViewModelInput, SmilesPointsViewModelOutput {
    
    /// I/O Ports
    var inputs: SmilesPointsViewModelInput { self }
    var outputs: SmilesPointsViewModelOutput { self }
    
    /// Inputs
    var sliderValueObserver: RxSwift.AnyObserver<Float> { sliderValueSubject.asObserver() }
    var confirmButtonTapObserver: RxSwift.AnyObserver<Void> { confirmButtonTapSubject.asObserver() }
    
    /// Outputs
    var localizedText: RxSwift.Observable<LocalizedText> { localizedTextSubject.asObservable() }
    var smilesPointsRedeemed: RxSwift.Observable<String> { smilesPointsRedeemedSubject.asObservable() }
    var sliderLimit: Observable<(Int, Int)> { availableSmilesPointsSubject.map { (0, $0) } }
    var availableSmilesPoints: RxSwift.Observable<String> { availableSmilesPointsSubject.map { "(\($0) pts)" } }
    var availablePointsConvertedToAED: RxSwift.Observable<String> { availablePointsConvertedToAEDSubject.asObservable() }
    var sliderCurrentValue: Observable<Float> { sliderCurrentValueSubject.asObservable() }
    var amountDueInAED: Observable<String?> { amountDueInAEDSubject.asObservable() }
    var amountRemaningInAED: RxSwift.Observable<String?> { amountRemaningInAEDSubject.asObservable() }
    var result: Observable<Int> { resultSubject.asObservable() }
    
    /// Subjects
    private let localizedTextSubject: BehaviorSubject<LocalizedText>
    
    private let sliderValueSubject: BehaviorSubject<Float> = .init(value: 0.0)
    private let smilesPointsRedeemedSubject: BehaviorSubject<String> = .init(value: "0")
    private let availableSmilesPointsSubject: BehaviorSubject<Int> = .init(value: 0)
    private let availablePointsConvertedToAEDSubject: BehaviorSubject<String> = .init(value: "0")
    private let confirmButtonTapSubject: PublishSubject<Void> = .init()
    
    private let amountDueInAEDSubject: BehaviorSubject<String?> = .init(value: nil)
    private let amountRemaningInAEDSubject: BehaviorSubject<String?> = .init(value: nil)
    private let resultSubject: PublishSubject<Int> = .init()
    private var sliderCurrentValueSubject: BehaviorSubject<Float> = .init(value: 0.0)
    private let sliderInitialValueSubject: BehaviorSubject<Float> = .init(value: 0.0)
    
    /// Properties
    private var disponseBag = DisposeBag()
    private var smilesBurntRatio: Double?
    
    init(availablePoints: Int, smilesRedeem: Double = 0.0, amountToPay: Double, smilesBurntRatio: Double?) {
        self.smilesBurntRatio = smilesBurntRatio
        let amountToPay = amountToPay + smilesRedeem
        
        availableSmilesPointsSubject.onNext(availablePoints)
        
        let smilesPointsRedeem = ElGrocerUtility.sharedInstance.calculateSmilePointsForAEDs(smilesRedeem, smilesBurntRatio: smilesBurntRatio)
        sliderInitialValueSubject.onNext(Float(smilesPointsRedeem))
        amountDueInAEDSubject.onNext(ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: amountToPay))
        
        localizedTextSubject = BehaviorSubject(value: (
            title: localizedString("smiles_points_redemmed_bottom_sheet_title", comment: ""),
            description: localizedString("smiles_points_redemmed_bottom_sheet_description", comment: ""),
            amountDue: localizedString("amount_due_text", comment: ""),
            amountRemaining: localizedString("remaining_amount_text", comment: ""),
            points: localizedString("text_pts", comment: ""),
            redeemPoints: localizedString("text_redeem_points", comment: ""),
            confirmButtonTitle: localizedString("confirm_button_title", comment: "")
        ))
        
        let sliderValue = Observable
            .merge(sliderValueSubject, sliderInitialValueSubject)
            .map { Int($0) }
            .map { min($0, ElGrocerUtility.sharedInstance.calculateSmilePointsForAEDs(amountToPay, smilesBurntRatio: smilesBurntRatio)) }
        
        sliderValue
            .map { Float($0) }
            .bind(to: sliderCurrentValueSubject)
            .disposed(by: disponseBag)
        
        sliderValue
            .map { "\($0)" }
            .bind(to: smilesPointsRedeemedSubject)
            .disposed(by: disponseBag)
        
        sliderValue
            .map { amountToPay - ElGrocerUtility.sharedInstance.calculateAEDsForSmilesPoints($0, smilesBurntRatio: smilesBurntRatio) }
            .map { ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: $0) }
            .bind(to: amountRemaningInAEDSubject)
            .disposed(by: disponseBag)
        
        availableSmilesPointsSubject
            .map { ElGrocerUtility.sharedInstance.calculateAEDsForSmilesPoints($0, smilesBurntRatio: smilesBurntRatio) }
            .map { ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: $0) }
            .bind(to: availablePointsConvertedToAEDSubject)
            .disposed(by: disponseBag)
        
        confirmButtonTapSubject
            .withLatestFrom(sliderValue)
            .map { $0 }
            .bind(to: resultSubject)
            .disposed(by: disponseBag)
    }
}
