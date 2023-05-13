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
    var user: AnyObserver<UserProfile?> { get }
}

protocol SettingViewModelOutPut {
    var cellViewModels: Observable<[SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>]> { get }
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
    var user: AnyObserver<UserProfile?> { self.userSubject.asObserver() }
    // output
    var cellViewModels: Observable<[SectionHeaderModel<Int, String , ReusableTableViewCellViewModelType>]> { cellViewModelsSubject.asObservable() }
    var isArbic: Observable<Bool> { isArbicSubject.asObservable() }
    // Subject
    private let settingSubject = PublishSubject<Setting>()
    private let userSubject = PublishSubject<UserProfile?>()
    private var cellViewModelsSubject = BehaviorSubject<[SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>]>(value: [])
    private let isArbicSubject = BehaviorSubject<Bool>(value: false)
    // properties
    private var viewModels: [SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>] = []
    
    init(setting: Setting, user: UserProfile?) {
        self.settingSubject.onNext(setting)
        self.userSubject.onNext(user)
        self.viewModels = self.setViewModels(setting: setting, user: user)
        self.cellViewModelsSubject.onNext(self.viewModels)
    }
    
    private func setViewModels(setting: Setting, user: UserProfile?) -> [SectionHeaderModel<Int, String, ReusableTableViewCellViewModelType>] {
        
        if setting.isSmileApp() {
            
        return [SectionHeaderModel(model: 0, header: "" , items: [SettingCellViewModel(type: .UserLogin)]),
                SectionHeaderModel(model: 1, header: localizedString("account_hedding", comment: ""), items: [SettingCellViewModel(type: .liveChat), SettingCellViewModel(type: .Orders),SettingCellViewModel(type: .Address),SettingCellViewModel(type: .PaymentMethods)]),
        SectionHeaderModel(model: 2, header: localizedString("Information_heading", comment: ""), items: [SettingCellViewModel(type: .TermsAndConditions), SettingCellViewModel(type: .PrivacyPolicy), SettingCellViewModel(type: .Faqs)])]
            
        }else if  user == nil {
            // not login case
                  return [SectionHeaderModel(model: 0, header: "" , items: [SettingCellViewModel(type: .UserNotLogin)]),
                                     SectionHeaderModel(model: 1, header: localizedString("settings_heading", comment: ""), items: [SettingCellViewModel(type: .LanguageChange)]),
                                     SectionHeaderModel(model: 2, header: localizedString("Information_heading", comment: ""), items: [SettingCellViewModel(type: .TermsAndConditions), SettingCellViewModel(type: .PrivacyPolicy), SettingCellViewModel(type: .Faqs)])]
            
        } else if user != nil && setting.isElgrocerApp() {
            // elgrocer login view
            return [SectionHeaderModel(model: 0, header: "" , items: [SettingCellViewModel(type: .UserLogin)]),
                            SectionHeaderModel(model: 1, header: localizedString("account_hedding", comment: ""), items: [SettingCellViewModel(type: .liveChat), SettingCellViewModel(type: .Orders),SettingCellViewModel(type: .Recipes),SettingCellViewModel(type: .SaveCars),SettingCellViewModel(type: .Address),SettingCellViewModel(type: .PaymentMethods),SettingCellViewModel(type: .Password)]),
                            SectionHeaderModel(model: 2, header: localizedString("settings_heading", comment: ""), items: [SettingCellViewModel(type: .LanguageChange), SettingCellViewModel(type: .DeleteAccount)]),
                    SectionHeaderModel(model: 3, header: localizedString("Information_heading", comment: ""), items: [SettingCellViewModel(type: .TermsAndConditions), SettingCellViewModel(type: .PrivacyPolicy), SettingCellViewModel(type: .Faqs), SettingCellViewModel(type: .SignOut)])]
        } else {
            // fatel error // this case never happens
            elDebugPrint("fatel error: Setting screen destroy")
            return []
        }
    }
    
    
    func heightForCell(indexPath: IndexPath) -> CGFloat {
        switch self.viewModels[indexPath.section].items.first {
        case let model as SettingCellViewModel:
            if model.cellType == .UserLogin {
                return kUserInfoCellHeight
            } else if model.cellType == .UserNotLogin {
                return KloginCellHeight
            } else {
                return kSettingCellHeight
            }
        default:
            return 0
        }
    }
  
}
