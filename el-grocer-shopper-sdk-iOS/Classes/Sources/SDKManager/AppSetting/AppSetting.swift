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
}



protocol Setting {
    func getSettingCellViewModel() -> SettingViewModel
}

class ElgrocerShopperSetting : Setting {
    func getSettingCellViewModel() -> SettingViewModel {
        return SettingViewModel.init(setting: self)
    }
}
class SmileMarketPlaceSetting: Setting {
    func getSettingCellViewModel() -> SettingViewModel {
        return SettingViewModel.init(setting: self)
    }
}
class SmileMarketSetting: Setting {
    func getSettingCellViewModel() -> SettingViewModel {
        return SettingViewModel.init(setting: self)
    }
}
