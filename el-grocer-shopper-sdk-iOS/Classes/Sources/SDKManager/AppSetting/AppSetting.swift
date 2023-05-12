//
//  AppSetting.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 12/05/2023.
//

import Foundation



class AppSetting  {
    static var currentSetting: Setting  {
        switch sdkManager.launchOptions?.marketType {
        case .shopper:
            return ElgrocerShopperSetting()
        case .marketPlace:
            return SmileMarketPlaceSetting()
        case .grocerySingleStore:
            return SmileMarketSetting()
        case .none:
            return SmileMarketSetting()
        }
    }
    
    static var theme : Theme { ApplicationTheme.currentTheme }
}



protocol Setting {
    func isElgrocerApp() -> Bool
    func isSmileApp() -> Bool
    func getSettingCellViewModel() -> SettingViewModel
}

extension Setting {
    func isElgrocerApp() -> Bool {
        return sdkManager.launchOptions?.marketType == .shopper
    }
    func isSmileApp() -> Bool {
        return sdkManager.launchOptions?.marketType != .shopper
    }
}

class ElgrocerShopperSetting : Setting {
    func getSettingCellViewModel() -> SettingViewModel {
        return SettingViewModel.init(setting: self, user: UserProfile.getOptionalUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext))
    }
    
}
class SmileMarketPlaceSetting: Setting {
    func getSettingCellViewModel() -> SettingViewModel {
        return SettingViewModel.init(setting: self, user: UserProfile.getOptionalUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext))
    }
}
class SmileMarketSetting: Setting {
    func getSettingCellViewModel() -> SettingViewModel {
        return SettingViewModel.init(setting: self, user: UserProfile.getOptionalUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext))
    }
}
