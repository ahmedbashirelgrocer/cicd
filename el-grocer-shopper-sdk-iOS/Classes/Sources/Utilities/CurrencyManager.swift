//
//  CurrencyManager.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 22/09/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
class CurrencyManager {
    
    
    public static func getCurrentCurrency() -> String {
        return localizedString("aed", comment: "")
    }
}
