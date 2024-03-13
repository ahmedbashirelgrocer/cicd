//
//  AdyenManagerObject.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 22/12/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation

class AdyenManagerObj {
    
    var amount: NSDecimalNumber
    var orderNumber: String
    var isZeroAuth: Bool
    var isForWallet: Bool
    
    
    internal init(amount: NSDecimalNumber, orderNumber: String,isZeroAuth: Bool, isForWallet: Bool) {
        self.amount = amount
        self.orderNumber = orderNumber
        self.isZeroAuth = isZeroAuth
        self.isForWallet = isForWallet
    }
    
    internal init(amount: NSDecimalNumber,isZeroAuth: Bool, isForWallet: Bool) {
        self.amount = amount
        self.orderNumber = ""
        self.isZeroAuth = isZeroAuth
        self.isForWallet = isForWallet
    }
}
