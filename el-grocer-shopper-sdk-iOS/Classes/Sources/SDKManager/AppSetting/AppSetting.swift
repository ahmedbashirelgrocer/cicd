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
    func settingViewModel() -> Bool
}

class ElgrocerShopperSetting : Setting {
    func settingViewModel() -> Bool {
        return false
    }
}
class SmileMarketPlaceSetting: Setting {
    func settingViewModel() -> Bool {
        return false
    }
}
class SmileMarketSetting: Setting {
    func settingViewModel() -> Bool {
        return false
    }
}
