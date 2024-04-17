//
//  WarningBottomSheetViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 28/02/2024.
//

import Foundation
import RxSwift

protocol WarningBottomSheetViewModelInput { }

protocol WarningBottomSheetViewModelOutput {
    typealias LocalizedText = (message: String, positiveButtonTitle: String, negativeButtonTitle: String)
    
    var icon: Observable<String?> { get }
    var localizedStrings: Observable<LocalizedText> { get }
}

protocol WarningBottomSheetViewModelType {
    var inputs: WarningBottomSheetViewModelInput { get }
    var outputs: WarningBottomSheetViewModelOutput { get }
}

class WarningBottomSheetViewModel: WarningBottomSheetViewModelType, WarningBottomSheetViewModelInput, WarningBottomSheetViewModelOutput {
    /// I/0 Ports
    var inputs: WarningBottomSheetViewModelInput { self }
    var outputs: WarningBottomSheetViewModelOutput { self }
    
    /// Outputs
    var icon: Observable<String?> { iconSubject.asObservable() }
    var localizedStrings: Observable<LocalizedText> { localizedStringsSubject.asObservable() }
    
    /// Subject
    var iconSubject: BehaviorSubject<String?> = .init(value: nil)
    var localizedStringsSubject: BehaviorSubject<LocalizedText>
    
    /// Initializations
    init(icon: String, message: String, positiveTitle: String, negativeTitle: String) {
        iconSubject.onNext(icon)
        
        localizedStringsSubject = BehaviorSubject(value: (
            message: message,
            positiveButtonTitle: positiveTitle,
            negativeButtonTitle: negativeTitle
        ))
    }
}
