//
//  AnalyticsEventName.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 28/11/2022.
//

import Foundation

enum AnalyticsEventName {
    
    // MARK: Cart Events
    static let cartCreated   = "Cart Created"
    static let productAdded   = "Product Added"
    static let productRemoved = "Product Removed"
    static let cartDeleted   = "Cart Deleted"
    static let cartViewed    = "Cart Viewed"
    static let cartCheckout  = "Cart Checkout"
    
    // MARK: Order Events
    static let orderPurchased = "Order Purchased"
    
    // MARK: Payment Methods
    static let paymentMethodChanged     = "Payment Method Changed"
    static let smilesPointsEnabled      = "Smiles Points Enabled"
    static let elWalletToggleEnabled    = "elWallet Toggle Enabled"
    static let promoCodeApplied         = "Promo Code Applied"
    static let promoCodeViewed          = "Promo Code Viewed"
    static let fundMethodSelected       = "Fund Method Selected"
    static let cardAdded                = "Card Added"
    static let cardRemoved              = "Card Removed"
    static let fundAdded                = "Funds Added"
    static let voucherRedeemed          = "Voucher Redeemed"
    
    // MARK: Address
    static let addressClicked           = "Address Clicked"
    static let confirmDeliveryLocation  = "Confirm Delivery Location"
    static let confirmAddressDetails     = "Confirm Address Details"
    
    // MARK: Common
    static let helpClicked              = "Help Click"
    static let generalAPIError          = "General API Error"
    
    // MARK: Search
    static let universalSearch          = "Universal Search"
    static let storeSearch              = "Store Search"
}
