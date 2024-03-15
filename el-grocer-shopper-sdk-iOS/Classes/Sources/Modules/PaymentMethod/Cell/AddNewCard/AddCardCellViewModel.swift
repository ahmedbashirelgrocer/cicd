//
//  AddCardCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 09/12/2023.
//

import Foundation
import RxSwift

protocol AddCardCellViewModelInput { }

protocol AddCardCellViewModelOutput {
    var title: Observable<String> { get }
    var leadingIconName: Observable<String> { get }
    var trailingIconName: Observable<String> { get }
}

protocol AddCardCellViewModelType {
    var inputs: AddCardCellViewModelInput { get }
    var outputs: AddCardCellViewModelOutput { get }
}

class AddCardCellViewModel: AddCardCellViewModelType, AddCardCellViewModelInput, AddCardCellViewModelOutput, ReusableTableViewCellViewModelType {
    var inputs: AddCardCellViewModelInput { self }
    var outputs: AddCardCellViewModelOutput { self }
    
    /// Outputs
    var title: Observable<String> { titleSubject.asObservable() }
    var leadingIconName: Observable<String> { leadingIconNameSubject.asObservable() }
    var trailingIconName: Observable<String> { trailingIconNameSubject.asObservable() }
    
    /// Subjects
    private var titleSubject: BehaviorSubject<String> = .init(value: localizedString("Add_New_Card_Title", comment: ""))
    private var leadingIconNameSubject: BehaviorSubject<String> = .init(value: sdkManager.isShopperApp ? "plusGreen" : "plus")
    private var trailingIconNameSubject: BehaviorSubject<String> = .init(value: sdkManager.isShopperApp ? "arrowRight"  : "arrowForward")
}

extension AddCardCellViewModel {
    var reusableIdentifier: String { AddCardCell.defaultIdentifier }
}
