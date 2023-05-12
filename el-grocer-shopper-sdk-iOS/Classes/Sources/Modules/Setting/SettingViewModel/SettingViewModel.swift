//
//  SettingViewModel.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 12/05/2023.
//

import Foundation
import RxSwift
import RxDataSources

protocol SettingViewModelInput {
    var setting: AnyObserver<Setting> { get }
}

protocol SettingViewModelOutPut {
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var isArbic: Observable<Bool> { get }
    func heightForCell(indexPath: IndexPath) -> CGFloat

}

protocol SettingViewModelType: SettingViewModelInput, SettingViewModelOutPut {
    var inputs: SettingViewModelInput { get }
    var outputs: SettingViewModelOutPut { get }
}

extension SettingViewModelType {
    var inputs: SettingViewModelInput { self }
    var outputs: SettingViewModelOutPut { self }
}

class SettingViewModel: SettingViewModelType, ReusableTableViewCellViewModelType {
    
    
    var reusableIdentifier: String = ""
    // input
    var setting: AnyObserver<Setting> { self.settingSubject.asObserver() }
    // output
    var cellViewModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    var isArbic: Observable<Bool> { isArbicSubject.asObservable() }
    // Subject
    private let settingSubject = PublishSubject<Setting>()
    private var cellViewModelsSubject = BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>(value: [])
    private let isArbicSubject = BehaviorSubject<Bool>(value: false)
    // properties
    private var viewModels: [SectionModel<Int, ReusableTableViewCellViewModelType>] = []
    
    init(setting: Setting) {
        self.settingSubject.onNext(setting)
        
        self.viewModels = [SectionModel(model: 0, items: [SettingCellViewModel(type: .UserLogin)]),
                           SectionModel(model: 1, items: [SettingCellViewModel(type: .LanguageChange)]),
                           SectionModel(model: 2, items: [SettingCellViewModel(type: .TermsAndConditions), SettingCellViewModel(type: .PrivacyPolicy), SettingCellViewModel(type: .Faqs)])]
        
        self.cellViewModelsSubject.onNext(self.viewModels)
    }
    
    
    func heightForCell(indexPath: IndexPath) -> CGFloat {
        switch self.viewModels[indexPath.section].items.first {
        case let model as SettingCellViewModel:
            if model.cellType == .UserLogin {
                return 200
            } else {
                return 50
            }
        default:
            return 0
        }
    }
    
    
  //  , SectionModel(model: 1, items: [SettingCellViewModel(type: .LanguageChange)]), SectionModel(model: 2, items: [SettingCellViewModel(type: .UserLogin)])]
    
    
}
