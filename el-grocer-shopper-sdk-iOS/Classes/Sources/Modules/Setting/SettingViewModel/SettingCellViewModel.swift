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
    
    case UserNotLogin
    case UserLogin
    case liveChat
    case Recipes
    case SaveCars
    case Address
    case Orders
    case PaymentMethods
    case ElWallet
    case Password
    case DeleteAccount
    case LanguageChange
    case TermsAndConditions
    case PrivacyPolicy
    case Faqs
    case SignOut
    case `default`
    
}

protocol SettingCellViewModelInput {
    var type: AnyObserver<SettingCellType> { get }
}

protocol SettingCellViewModelOutput {
    var title: String { get }
    var image: UIImage { get }
    var cellType : SettingCellType { get }
    var buttonAction: Observable<Any> { get}
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
    var title: String = ""
    var image: UIImage = UIImage(name: "product_placeholder")!
    var cellType : SettingCellType
    var buttonAction: Observable<Any> { buttonActionSubject.asObservable()}
    // MARK: Subjects
    private let typeSubject = PublishSubject<SettingCellType>()
    private let buttonActionSubject = PublishSubject<Any>()
    // MARK: Properties
    var reusableIdentifier: String
    
    // MARK: Initlizations
    init(type: SettingCellType) {
      
        self.cellType = type
        
        switch type {
        case .UserNotLogin:
            self.reusableIdentifier = KloginCellIdentifier
            self.title = ""
        case .UserLogin:
            self.reusableIdentifier = "UserInfoTableCell"
            self.title = ""
        case .LanguageChange:
            self.reusableIdentifier = "SettingTableCell"
            self.title = localizedString("language_settings", comment: "")
            self.image = UIImage(name: "languageSettings") ?? self.image
        case .TermsAndConditions:
            self.reusableIdentifier = "SettingTableCell"
            self.title = localizedString("terms_settings", comment: "")
            self.image = UIImage(name: "termsSettings") ?? self.image
        case .PrivacyPolicy:
            self.reusableIdentifier = "SettingTableCell"
            self.title = localizedString("privacy_policy", comment: "")
            self.image = UIImage(name: "privacyPolicySettings") ?? self.image
        case .Faqs:
            self.reusableIdentifier = "SettingTableCell"
            self.title = localizedString("FAQ_settings", comment: "")
            self.image = UIImage(name: "faqSettings") ?? self.image
        case .Orders:
            self.reusableIdentifier = "SettingTableCell"
            self.title = localizedString("orders_Settings", comment: "")
            self.image = UIImage(name: "ordersSettings") ?? self.image
        case .PaymentMethods:
            self.reusableIdentifier = "SettingTableCell"
            self.title = localizedString("payment_methods", comment: "")
            self.image = UIImage(name: "paymentMethodSettings") ?? self.image
        case .liveChat:
            self.reusableIdentifier = "SettingTableCell"
            self.title = localizedString("live_chat", comment: "")
            self.image = UIImage(name: "liveChatSettings") ?? self.image
        case .Recipes:
            self.reusableIdentifier = "SettingTableCell"
            self.title = localizedString("saved_recipies", comment: "")
            self.image = UIImage(name: "savedRecipesSettings") ?? self.image
        case .SaveCars:
            self.reusableIdentifier = "SettingTableCell"
            self.title = localizedString("saved_Cars", comment: "")
            self.image = UIImage(name: "savedCarsSettings") ?? self.image
        case .Address:
            self.reusableIdentifier = "SettingTableCell"
            self.title = localizedString("address_settings", comment: "")
            self.image = UIImage(name: "addressSettings") ?? self.image
        case .ElWallet:
            self.reusableIdentifier = "SettingTableCell"
            self.title = localizedString("txt_title_elWallet", comment: "")
            self.image = UIImage(name: "paymentMethodSettings") ?? self.image
        case .Password:
            self.reusableIdentifier = "SettingTableCell"
            self.title = localizedString("password_settings", comment: "")
            self.image = UIImage(name: "passwordSettings") ?? self.image
        case .DeleteAccount:
            self.reusableIdentifier = "SettingTableCell"
            self.title = localizedString("delete_account", comment: "")
            self.image = UIImage(name: "DeleteAccountSettings") ?? self.image
        case .SignOut:
            self.reusableIdentifier = kSignOutCellIdentifier
        case .default:
            self.reusableIdentifier = "SettingTableCell"
            self.title = ""
        }
        self.typeSubject.onNext(type)
        
    }
    
    func handleButtonAction(_ type: Any) {
           buttonActionSubject.onNext((type))
       }
    
    
}
