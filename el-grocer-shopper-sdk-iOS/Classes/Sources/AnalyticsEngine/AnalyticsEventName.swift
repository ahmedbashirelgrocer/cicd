//
//  AnalyticsEventName.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 28/11/2022.
//

import Foundation

enum AnalyticsEventName {
    
    // MARK: Cart Events
    static let cartCreated              = "Cart Created"
    static let productAdded             = "Product Added"
    static let productRemoved           = "Product Removed"
    static let cartDeleted              = "Cart Deleted"
    static let cartViewed               = "Cart Viewed"
    static let cartCheckout             = "Cart Checkout"
    static let multiCartViewed          = "MultiCarts Viewed"
    static let cartClicked              = "Cart Clicked"
    static let checkoutStarted          = "Checkout Started"
    static let multiCartsClicked        = "Multi Carts Clicked"
    
    // MARK: Order Events
    static let orderPurchased           = "Order Completed"
    static let editOrderCompleted       = "Edit Order Completed"
    static let orderEditClicked         = "Edit Order Clicked"
    static let orderDetailsClicked      = "Order Details Clicked"
    static let orderCancelled           = "Order Cancelled"
    static let orderSubstitutionCompleted    = "Substitution Completed"
    static let orderCancelClicked       = "Cancel Order Clicked"
    static let repeatOrderClicked       = "Repeat Order Clicked"
    static let chooseReplacementClicked = "Choose Replacement Clicked"
    static let itemReplaced             = "Item Replaced"
    
    
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
    static let addFundClicked           = "Add Fund Clicked"
    
    // MARK: Address
    static let addressClicked           = "Address Clicked"
    static let confirmDeliveryLocation  = "Confirm Delivery Location"
    static let confirmAddressDetails    = "Confirm Address Details"
    
    // MARK: Common
    static let helpClicked              = "Help Click"
    static let generalAPIError          = "General API Error"
    static let menuItemClicked          = "Menu Item Clicked"
    
    // MARK: Search
    static let universalSearch          = "Universal Search"
    static let storeSearch              = "Store Search"
    static let searchHistoryClicked     = "Search History Clicked"
    
    // MARK: User
    static let userRegistered           = "User Registered"
    static let userSignedIn             = "User Signed In"
    static let menuButtonClicked        = "Menu Button Clicked"
    
    // MARK: Store
    static let storeCategorySwitched    = "Store Category Switched"
    static let storeClicked             = "Store Clicked"
    static let storesInRange            = "Stores In Range"
    static let categoryViewAllClicked   = "Category View All Clicked"
    static let productCategoryViewAllClicked = "Product Category View All Clicked"
    
    // MARK: Banner
    static let bannerClicked            = "Banner Clicked"
    static let bannerViewed             = "Banner Viewed"
    
    // MARK: SDK
    static let sdkLaunched            = "SDK Launched"
        
    // MARK: Shopper App Specfic events
    static let storeCategoryClicked = "Store Category Clicked"
    static let recipeClicked        = "Recipe Clicked"
    static let recipeViewed             = "Recipe Viewed"
    static let onboardingStarted        = "Onboarding Started"
    static let phoneNumberEntered       = "Phone Number Entered"
    static let otpConfirmed             = "OTP Confirmed"
    static let signOut                  = "Sign Out"
    static let pushNotificationEnabled  = "Push Notification Enabled"
    static let deepLinkOpened           = "Deep Link Opened"
    static let pushReceived             = "Push Notification Received"
    static let pushTapped               = "Push Notification Tapped"
    static let applicationOpened        = "Application Opened"
    static let applicationBackgrounded  = "Application Backgrounded"
    static let otpAttempts              = "OTP Attempts"
    static let smilesHeaderClicked = "Smiles Header Clicked"
    static let homeTileClicked          = "Home Tile Clicked"
    
    // MARK: A/B Testing
    static let abTestExperiment         = "AB Test Experiment"
    static let genericABTestConfigError = "Generic ABTest Config Error"
}
