//
//  SettingCellViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 12/05/2023.
//

import Foundation
import RxSwift
import RxDataSources

enum SettingCellType {
    
    case UserLogin
    case LanguageChange
    case TermsAndConditions
    case PrivacyPolicy
    case Faqs
    case Orders
    case PaymentMethods
    case `default`
    
}

protocol SettingCellViewModelInput {
    var type: AnyObserver<SettingCellType> { get }
}

protocol SettingCellViewModelOutput {
    var title: Observable<String> { get }
   // var productQuantity: Observable<String> { get }
}

protocol SettingCellViewModelType: SettingCellViewModelInput, SettingCellViewModelOutput {
    var inputs: SettingCellViewModelInput { get }
    var outputs: SettingCellViewModelOutput { get }
}

extension SettingCellViewModelType {
    var inputs: SettingCellViewModelInput { self }
    var outputs: SettingCellViewModelOutput { self }
}

class SettingCellViewModel: SettingCellViewModelType, ReusableTableViewCellViewModelType {
    
    // MARK: Inputs
    var type: AnyObserver<SettingCellType> { self.typeSubject.asObserver() }
    // MARK: Outputs
    var title: Observable<String> { self.titleSubject.asObservable() }
    // MARK: Subjects
    private let typeSubject = PublishSubject<SettingCellType>()
    private let titleSubject = BehaviorSubject<String>(value: "")
    
    // MARK: Properties
    var reusableIdentifier: String
    var cellType : SettingCellType
    
    // MARK: Initlizations
    init(type: SettingCellType) {
        
        switch type {
        case .UserLogin:
            self.reusableIdentifier = "UserInfoTableCell"
        case .LanguageChange:
            self.reusableIdentifier = "SettingTableCell"
            self.titleSubject.onNext(localizedString("language_settings", comment: ""))
        case .TermsAndConditions:
            self.reusableIdentifier = "SettingTableCell"
            self.titleSubject.onNext(localizedString("language_settings", comment: ""))
        case .PrivacyPolicy:
            self.reusableIdentifier = "SettingTableCell"
            self.titleSubject.onNext(localizedString("language_settings", comment: ""))
        case .Faqs:
            self.reusableIdentifier = "SettingTableCell"
            self.titleSubject.onNext(localizedString("language_settings", comment: ""))
        case .Orders:
            self.reusableIdentifier = "SettingTableCell"
            self.titleSubject.onNext(localizedString("language_settings", comment: ""))
        case .PaymentMethods:
            self.reusableIdentifier = "SettingTableCell"
            self.titleSubject.onNext(localizedString("language_settings", comment: ""))
        case .default:
            self.reusableIdentifier = "SettingTableCell"
            self.titleSubject.onNext(localizedString("language_settings", comment: ""))
        }
        self.typeSubject.onNext(type)
        self.cellType = type
    }
    
    
    
}
