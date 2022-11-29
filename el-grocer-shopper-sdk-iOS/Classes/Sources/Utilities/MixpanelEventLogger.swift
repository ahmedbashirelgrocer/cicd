//
//  MixpanelEventLogger.swift
//  ElGrocerShopper
//
//  Created by Salman on 01/06/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import Foundation
import Mixpanel

class MixpanelEventLoggerSync: NSObject{
    static var shared = MixpanelEventLoggerSync()
    var data : [String : TimeInterval?] = [:]
}


class MixpanelEventLogger: NSObject {

    fileprivate enum MixpanelEventsName : String {
        
        case HomeAddressClick = "SdkHome_AddressClick"
        case HomeStoreClick = "SdkHome_StoreSelected"
        case HomeHelpClick = "SdkHome_HelpClick"
        case HomeSearchClick = "SdkHome_SearchClick"
        case HomeSearchSubmit = "SdkHome_SearchSubmit"
        case HomeFeaturedStoreBannerClick = "SdkHome_FeaturedStoreBannerClick"
        case HomeShoppingCategory = "SdkHome_ShoppingCategory"
        case HomeBannerClick = "SdkHome_BannerClick"
        case HomeStoreCategory = "SdkHome_StoreCategory"
        case HomeRecipesFilter = "SdkHome_RecipesFilter"
        case HomeRecipesClick = "SdkHome_RecipesClick"
        
        case NavBarHome = "NavBar_Home"
        case NavBarStore = "NavBar_Store"
        case HomeProfile = "Home_Profile"
        case HomeCart = "Home_Cart"
        case StoreCart = "Store_Cart"
        
        case StoreListingClose = "StoreListing_Close"
        case StoreListingSearch = "StoreListing_Search"
        case StoreListingCategoryFilter = "StoreListingCategoryFilter"
        case StoreListingStoreSelected = "StoreListingStoreSelected"
        
        case DealsOffersClose = "DealsOffers_Close"
        case DealsOffersShare = "DealsOffers_Share"
        case DealsOffersButton = "DealsOffers_Button"
        //
        case ClickAndCollectClose = "ClickAndCollect_Close"
        case ClickAndCollectCategoryFilter = "ClickAndCollect_CategoryFilter"
        case ClickAndCollectSearch = "ClickAndCollect_Search"
        case ClickAndCollectStoreSelected = "ClickAndCollect_StoreSelected"
        
        case RecipesClose = "Recipes_Close"
        case RecipesSearch = "Recipes_Search"
        case RecipesCategoryFilter = "Recipes_CategoryFilter"
        case RecipesBrandClick = "Recipes_BrandClick"
        case RecipesRecipeClick = "Recipes_RecipeClick"
        
        case StoreClose = "Store_Close"
        case StoreSearch = "Store_Search"
        case StoreShoppingList = "Store_ShoppingList"
        case StoreHelp = "Store_Help"
        case StoreBannerClick = "Store_BannerClick"
        case StoreCategoryClick = "Store_CategoryClick"
        case StoreProductsViewAll = "Store_ProductsViewAll"
        case StoreAddItem = "Store_AddItem"
        case StoreRemoveItem = "Store_RemoveItem"
        
        case Cartclose = "Cart_close"
        case CartEditOOSInstruction = "Cart_EditOOSInstruction"
        case CartOOSInstructionSelected = "Cart_OOSInstructionSelected"
        case CartRemoveItem = "Cart_RemoveItem"
        case CartAddItem = "Cart_AddItem"
        case CartOOSSelected = "Cart_OOSSelected"
        case CartBeginCheckout = "Cart_BeginCheckout"
        
        case CheckoutClose = "Checkout_Close"
        case CheckoutDeliverySlotSelected = "Checkout_DeliverySlotSelected"
        case CheckoutDeliverySlotClicked = "Checkout_DeliverySlotClicked"
        case CheckoutInstructionAdded = "Checkout_InstructionAdded"
        case CheckoutPromocodeApplied = "Checkout_PromocodeApplied"
        case CheckoutPromocodeClicked = "Checkout_PromocodeClicked"
        case CheckoutShowBillDetails = "Checkout_ShowBillDetails"
        case CheckoutPromoApplied = "Checkout_PromoApplied"
        case CheckoutPromoError = "Checkout_PromoError"
        case CheckoutPaymentMethodSelected = "Checkout_PaymentMethodSelected"
        case CheckoutPaymentMethodClicked = "Checkout_PaymentMethodClicked"
        case CheckoutConfirmOrderClicked = "Checkout_ConfirmOrderClicked"
        
        case ProfileMyOrders = "Profile_MyOrders"
        case OrderDetailsclose = "OrderDetails_close"
        case OrderDetailshelp = "OrderDetails_help"
        case OrderDetailsEditOrderClicked = "OrderDetails_EditOrderClicked"
        case OrderDetailsCancelOrderClicked = "OrderDetails_CancelOrderClicked"
        
        case EditCartSearchClick = "EditCart_SearchClick"
        case EditCartEditOOSInstruction = "EditCart_EditOOSInstruction"
        case EditCartOOSInstructionSelected = "EditCart_OOSInstructionSelected"
        case EditCartRemoveItem = "EditCart_RemoveItem"
        case EditCartAddItem = "EditCart_AddItem"
        case EditCartCancelOrderClicked = "EditCart_CancelOrderClicked"
        case EditCartBeginCheckout = "EditCart_BeginCheckout"
        
        case WelcomeDetectLocationClick = "Welcome_DetectLocationClick"
        case WelcomeSigninInClicked = "Welcome_SigninInClicked"
        case WelcomeNewToElgrocer = "Welcome_NewToElgrocer"
        case WelcomeHaveAnAccount = "Welcome_HaveAnAccount"
        case WelcomeEmailEntered = "Welcome_EmailEntered"
        case WelcomePasswordEntered = "Welcome_PasswordEntered"
        case WelcomeForgotPassword = "Welcome_ForgotPassword"
        case WelcomeChooseLocation = "Welcome_ChooseLocation"
        case WelcomeClose = "Welcome_Close"
        
        case CreateLocationSearchClick = "CreateLocation_SearchClick"
        case CreateLocationCurrentLocationClick = "CreateLocation_CurrentLocationClick"
        case CreateLocationConfirmClick = "CreateLocation_ConfirmClick"
        case CreateLocationClose = "CreateLocation_Close"
        
        case CreateAccountNumberEntered = "CreateAccount_NumberEntered"
        case CreateAccountNextClick = "CreateAccount_NextClick"
        case OTPOTPEntered = "OTP_OTPEntered"
        case OTPHelp = "OTP_Help"
        case SignUpEmailEntered = "SignUp_EmailEntered"
        case SignUpPasswordEntered = "SignUp_PasswordEntered"
        case SignUpNextClick = "SignUp_NextClick"
        case SignupClose = "Signup_Close"
        case CreateAccountClose = "CreateAccount_Close"
        
        case EditAddressAddressTypeSelect = "EditAddress_AddressTypeSelect"
        case EditAddressLocationFieldClick = "EditAddress_LocationFieldClick"
        case EditAddressAddressFieldsEntered = "EditAddress_AddressFieldsEntered"
        case EditAddressAditionalInformationEntered = "EditAddress_AditionalInformationEntered"
        case EditAddressAddressFilterSelect = "EditAddress_AddressFilterSelect"
        case EditAddressInformationEntered = "EditAddress_InformationEntered"
        case EditAddressNextClick = "EditAddress_NextClick"
        case EditAddressClose = "EditAddress_Close"
        
        case SubstitutionClose = "Substitution_Close"
        case SubstitutionSubstitutionSelected = "Substitution_SubstitutionSelected"
        case SubstitutitonRemoveAllClicked = "Substitutiton_RemoveAllClicked"
        case SubstitutionConfirmClicked = "Substitution_ConfirmClicked"
        case SubstitutionCancelOrder = "Substitution_CancelOrder"
        
        case ChooseLocationClose = "ChooseLocation_Close"
        case ChooseLocationSelected = "ChooseLocation_Selected"
        case ChooseLocationAddAddressClick = "ChooseLocation_AddAddressClick"
        case ChooseLocationDeleteClick = "ChooseLocation_DeleteClick"
        case ChooseLocationEditClick = "ChooseLocation_EditClick"
        
        case AddAddressAddressTypeSelect = "AddAddress_AddressTypeSelect"
        case AddAddressLocationFieldClick = "AddAddress_LocationFieldClick"
        case AddAddressAddressFieldsEntered = "AddAddress_AddressFieldsEntered"
        case AddAddressAddressFilterSelect = "AddAddress_AddressFilterSelect"
        case AddAddressAditionalInformationEntered = "AddAddress_AditionalInformationEntered"
        case AddAddressInformationEntered = "AddAddress_InformationEntered"
        case AddAddressNextClick = "AddAddress_NextClick"
        case AddAddressClose = "AddAddress_Close"

        case ElWalletHomeClose = "_Close"
        case ElWalletAddfundsClicked = "elwallet_addfunds_clicked"
        case ElWalletVoucherViewAll = "elwallet_activeVouchers_viewAll"
        case ElWalletRedeemVoucher = "elwallet_redeemVoucher"
        case ElWalletManageCardsClicked = "elwallet_ManageCards_clicked"
        case ElwalletTransactionsViewAll = "elwallet_transactions_viewAll"
        case ElwalletAddNewCardClicked = "elwallet_AddNewCard_clicked"
        case ElwalletAddFundPaymentMethodSelection = "elwallet_addFund_paymentMethodSelection_"
        case ElwalletAddFundPaymentMethodSelectionAddNewCardClicked = "elwallet_addFund_paymentMethodSelection_addNewCard_clicked"
        case ElwalletAddFundPaymentMethodSelectionNextClicked = "elwallet_addFund_paymentMethodSelection_next_clicked"
        case ElwalletAddFundsClose = "AddFunds_Close"
        case ElwalletFundAddEnteredAddfundsClicked = "FundAddEntered_addfunds_clicked"
        case ElWalletAddFundsPaymentSuccessClose = "AddFundsPaymentSuccess_Close"
        case ElWalletAddFundsPaymentFaliureClose = "AddFundsPaymentFaliure_Close"
        case ElwalletFundsErrorTryAgainClicked = "elwalletFundsError_tryAgain_clicked"
        case ElwalletActiveVoucherManualInPutRedeemClicked = "elwallet_activeVoucher_ManualInPutRedeem_clicked"
        case ElwalletActiveVoucherVoucherRedeemError = "elwallet_activeVoucher_voucherRedeem_error"
        case ElwalletActiveVoucherInsideCardRedeemClicked = "elwallet_activeVoucher_insideCardRedeem_clicked"
        case ElwalletEditCardClicked = "elwallet_editCard_clicked"
        case ElwalletCardsAddNewCardClicked = "elwallet_addNewCard_clicked"
        case ElwalletEditCardsRemoveCardClicked = "elwallet_editCards_removeCard_clicked"
        case ElwalletEditCardsKeepUsingCardClicked = "elwallet_editCards_keepUsingCard_clicked"
        case ElwalletActiveVoucherView = "elwallet_activeVoucher_view"
        
        case CheckoutPrimaryPaymentMethodClicked = "Checkout_PrimaryPaymentMethodClicked"
        case CheckoutAddNewCardClicked = "Checkout_addNewCard_Clicked"
        case CheckoutVoucherApplied = "Checkout_voucherApplied"
        case CheckoutVoucherRemoved = "Checkout_voucherRemoved"
        case CheckoutElwalletSwitchOn = "Checkout_elwallet_switch_on"
        case CheckoutElwalletSwitchOff = "Checkout_elwallet_switch_off"
        case CheckoutSmilesSwitchOn = "Checkout_smiles_switch_on"
        case CheckoutSmilesSwitchOff = "Checkout_smiles_switch_off"
        case CheckoutElwalletSwitchError = "Checkout_elwallet_switch_error"
        case CheckoutSmilesSwitchError = "Checkout_smiles_switch_error"
        case CheckoutOrderError = "Checkout_Order_Error"
        case CheckoutAvailablePaymentMethods = "Checkout_available_payment_methods"
        case CheckoutPaymentMethodError = "Checkout_paymentMethod_Error"
        case CheckoutApplePayError = "Checkout_ApplePay_Error"
    }

    fileprivate enum MixpanelParmName : String {
        
        case UserId = "User_id"
        case UserEmail = "User_email"
        case UserPhoneNum = "User_phonenumber"
        case UserOTP = "User_otp"
        
        case SelectedAddress = "Address_selectedaddress"
        case SelectedAddressId = "Address_selectedaddressid"
        case SelectedStoreId = "Store_selectedid"
        case SelectedStoreName = "Store_selectedstorename"
        
        case SearchTerm = "Search_term"
        
        case StoreId = "Store_id"
        case StoreName = "Store_name"
        case StoreCategoryCategoryId = "StoreCategory_categoryid"
        case StoreCategoryCategoryName = "StoreCategory_categoryname"
        case StoreViewAllCategoryId = "StoreViewAll_categoryid"
        case StoreViewAllCategoryName = "StoreViewAll_categoryname"
        
        case HomeCategoryName = "Home_categoryname"
        case HomeCategoryId = "Home_categoryid"
        
        case BannerTier = "Banner_tier"
        case BannerId = "Banner_id"
        case BannerTitle = "Banner_title"
        
        case HomeStoreCategoryName = "Home_storecategoryname"
        case HomeStoreCategoryId = "Home_storecategoryid"
        
        case RecipeId = "Recipe_id"
        case RecipeName = "Recipe_name"
        case RecipeSelectedCategoryId = "Recipe_selectedcategoryid"
        case RecipeSelectedCategoryName = "Recipe_selectedcategoryname"
        case RecipeChefId = "Recipe_checfid"
        case RecipeChefName = "Recipe_chefname"
        
        case StoreListCategoryId = "StoreList_categoryid"
        case StoreListCategoryName = "StoreList_categoryname"
        case StoreListSelectedCategoryId = " StoreList_selectedcategoryid"
        case StoreListSelectedCategoryName = "StoreList_selectedcategoryname"
        
        case DealsId = "Deals_id"
        
        case ClickAndCollectSelectedCategoryId = "ClickAndCollect_selectedcategoryid"
        case ClickAndCollectSelectedCategoryName = "ClickAndCollect_selectedcategoryname"
        
        case CartOOSInstruction = "CartOOS_instruction"
        case CartInstructionsInstruction = "CartInstruction_instruction"
        
        case SlotId = "Slot_id"
        case SlotStartTime = "Slot_starttime"
        case SlotEndTime = "Slot_endtime"
        case SlotTimeStamp = "Slot_timestamp"
        
        case PromoCode = "PromoCode_code"
        case PromoDiscount = "PromoCode_discount"
        case promoId = "PromoCode_id"
        case PromoError = "PromoCode_error"
        
        case OrderId = "Order_id"
        case OrderValue = "Order_value"
        case OrderPriceShow = "OrderPrices_show"
        
        case PaymentMethodId = "PaymentMethod_id"
        case PaymentCreditCardId = "PaymentMethod_cardid"
        
        case LocationAddress = "Location_address"
        case LocationId = "Location_id"
        
        case AddressType = "Address_type"
        case AddressField = "Address_field"
        case AddressAditionalInformation = "Address_aditionalinformation"
        case AddressFilterId = "Address_filerid"
        case AddressFilter = "Address_filter"
        case AddressUserName = "Address_username"
        case AddressUserPhoneNum = "Address_userphonenumber"
        
        case ItemOOSId = "ItemOOS_id"
        case ItemOOSName = "ItemOOS_name"
        
        case CurrentScreen = "CurrentScreen"
        
        case ElWalletVoucherCode = "PromoCode_voucherCode"
        case ElwalletVoucherID = "PromoCode_voucherId"
        
        case VoucherCode = "voucherCode"
        case VoucherId = "voucherId"
        
        case RetailerID = "retailerId"
        
        case AvailableBalance = "availableBalance"
        
        case ErrorMessage = "errorMessage"
        
        case TotalOrderAmount = "totalOrderAmount"
        
        case IsCashAvailable = "isCashAvailable"
        case IsCODAvailable = "isCODAvailable"
        case IsOnlineAvailable = "isOnlineAvailable"
        
    
    }
    
    class fileprivate func mixpanelTrackTappedEvent(_ eventName : String , params :  [String : Any]? = nil) {
        
        var finalParms:Properties = [:]
        
        if let dataDict = params {
            for (key, value) in dataDict {
                finalParms[key] = value as? MixpanelType
            }
        }
        
        Mixpanel.mainInstance().track(event: eventName, properties: finalParms)
        
    }
    //MARK: current screen name
    
    class func trackCurrentScreenName( ) {
        
        
        if let vc = UIApplication.gettopViewControllerName() {
            let eventName: String = vc
            let params: [String : Any]? = [
                "clickedEvent": eventName
                
                ]
            MixpanelManager.trackEvent(eventName, params: params)
        }
    }
    
    //MARK: Home Screen Events
    
    class func trackHomeStoreClick(_ storeId : String ) {
        
        let eventName: String = MixpanelEventsName.HomeStoreClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            "storeId" : storeId
            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackHomeAddressClick( ) {
        
        let eventName: String = MixpanelEventsName.HomeAddressClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackHomeHelpClick( ) {
        
        let eventName: String = MixpanelEventsName.HomeHelpClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,

            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackHomeSearchClick( ) {
        
        let eventName: String = MixpanelEventsName.HomeSearchClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,

            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackHomeSearchSubmit(keyWord: String ) {
        
        let eventName: String = MixpanelEventsName.HomeSearchSubmit.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.SearchTerm.rawValue : keyWord
            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackHomeFeaturedStoreBannerClick(storeId: String, storeName: String ) {
        
        let eventName: String = MixpanelEventsName.HomeFeaturedStoreBannerClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.StoreId.rawValue: storeId,
            MixpanelParmName.StoreName.rawValue: storeName

            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackHomeShoppingCategory(categoryName: String, categoryId: String ) {
        
        let eventName: String = MixpanelEventsName.HomeShoppingCategory.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.HomeCategoryName.rawValue: categoryName,
            MixpanelParmName.HomeCategoryId.rawValue: categoryId
            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackHomeBannerClick(id: String, title: String, tier: String ) {
        
        let eventName: String = MixpanelEventsName.HomeBannerClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.BannerId.rawValue: id,
            MixpanelParmName.BannerTitle.rawValue: title,
            MixpanelParmName.BannerTier.rawValue: tier

            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackHomeStoreCategory(categoryName: String, categoryId: String ) {
        
        let eventName: String = MixpanelEventsName.HomeStoreCategory.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.HomeStoreCategoryName.rawValue : categoryName,
            MixpanelParmName.HomeStoreCategoryId.rawValue: categoryId
            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    
    class func trackHomeRecipesFilter( ) {
        
        let eventName: String = MixpanelEventsName.HomeRecipesFilter.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,

            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackHomeRecipesClick(recipeName: String, recipeId: String, chefId: String, chefName: String ) {
        
        let eventName: String = MixpanelEventsName.HomeRecipesClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.RecipeId.rawValue: recipeId,
            MixpanelParmName.RecipeName.rawValue: recipeName,
            MixpanelParmName.RecipeChefId.rawValue: chefId,
            MixpanelParmName.RecipeChefName.rawValue: chefName
            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    
    //MARK: Nav bar Events
    
    
    class func trackNavBarHome( ) {
        
        let eventName: String = MixpanelEventsName.NavBarHome.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,

            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackNavBarStore( ) {
        
        let eventName: String = MixpanelEventsName.NavBarStore.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,

            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackNavBarProfile( ) {
        
        let eventName: String = MixpanelEventsName.HomeProfile.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.CurrentScreen.rawValue : FireBaseEventsLogger.gettopViewControllerName()
            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackNavBarCart( ) {
        
        let eventName: String = MixpanelEventsName.HomeCart.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.CurrentScreen.rawValue: FireBaseEventsLogger.gettopViewControllerName()
            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackStoreCart( ) {
        
        let eventName: String = MixpanelEventsName.StoreCart.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.CurrentScreen.rawValue: FireBaseEventsLogger.gettopViewControllerName()
            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    //MARK: hypermarket shopping page Events
    
//case StoreListingClose = "StoreListing_Close"
//case StoreListingSearch = "StoreListing_Search"
//case StoreListingCategoryFilter = "StoreListingCategoryFilter"
//case StoreListingStoreSelected = "StoreListingStoreSelected"
    
    class func trackStoreListingClose(storeListCategoryId: String, storeListCategoryName: String ) {
        
        let eventName: String = MixpanelEventsName.StoreListingClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.StoreListCategoryId.rawValue: "",
            MixpanelParmName.StoreListCategoryName.rawValue: ""

            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackStoreListingSearch(storeListCategoryId: String, storeListCategoryName: String) {
        
        let eventName: String = MixpanelEventsName.StoreListingSearch.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.StoreListCategoryId.rawValue: "",
            MixpanelParmName.StoreListCategoryName.rawValue: ""
            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackStoreListingCategoryFilter(storeListCategoryId: String, storeListCategoryName: String, selectedCatId: String, selectedCatName: String ) {
        
        let eventName: String = MixpanelEventsName.StoreListingCategoryFilter.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.StoreListCategoryId.rawValue: storeListCategoryId,
            MixpanelParmName.StoreListCategoryName.rawValue: storeListCategoryName,
            MixpanelParmName.StoreListSelectedCategoryId.rawValue: selectedCatId,
            MixpanelParmName.StoreListSelectedCategoryName.rawValue: selectedCatName
            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackStoreListingStoreSelected(storeListCategoryId: String, storeListCategoryName: String, storeId: String, storeName: String ) {
        
        let eventName: String = MixpanelEventsName.StoreListingStoreSelected.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.StoreListCategoryId.rawValue: storeListCategoryId,
            MixpanelParmName.StoreListCategoryName.rawValue: storeListCategoryName,
            MixpanelParmName.StoreId.rawValue: storeId,
            MixpanelParmName.StoreName.rawValue: storeName
            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    //MARK: deals and offers page Events
    
    
    class func trackDealsOffersClose( ) {
        
        let eventName: String = MixpanelEventsName.DealsOffersClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackDealsOffersShare( ) {
        
        let eventName: String = MixpanelEventsName.DealsOffersShare.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackDealsOffersButton(dealId: String ) {
        
        let eventName: String = MixpanelEventsName.DealsOffersButton.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.DealsId.rawValue: dealId
            ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    //MARK: click & collect page Events
    
    
    class func trackClickAndCollectClose( ) {
        
        let eventName: String = MixpanelEventsName.ClickAndCollectClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackClickAndCollectCategoryFilter(filterId: String, filterName: String ) {
        
        let eventName: String = MixpanelEventsName.ClickAndCollectCategoryFilter.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.ClickAndCollectSelectedCategoryId.rawValue: filterId,
            MixpanelParmName.ClickAndCollectSelectedCategoryName.rawValue: filterName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackClickAndCollectSearch( ) {
        
        let eventName: String = MixpanelEventsName.ClickAndCollectSearch.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackClickAndCollectStoreSelected(storeId: String, storeName: String ) {
        
        let eventName: String = MixpanelEventsName.ClickAndCollectStoreSelected.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.StoreId.rawValue: storeId,
            MixpanelParmName.StoreName.rawValue: storeName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    //MARK: recipe page Events
    
    class func trackRecipesClose( ) {
        
        let eventName: String = MixpanelEventsName.RecipesClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackRecipesSearch( ) {
        
        let eventName: String = MixpanelEventsName.RecipesSearch.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackRecipesCategoryFilter(categoryId: String, categoryName: String ) {
        
        let eventName: String = MixpanelEventsName.RecipesCategoryFilter.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.RecipeSelectedCategoryId.rawValue: categoryId,
            MixpanelParmName.RecipeSelectedCategoryName.rawValue: categoryName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackRecipesBrandClick(chefId: String, chefName: String ) {
        
        let eventName: String = MixpanelEventsName.RecipesBrandClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.RecipeChefId.rawValue: chefId,
            MixpanelParmName.RecipeChefName.rawValue: chefName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackRecipesRecipeClick(recipeId: String, recipeName: String, chefId: String, chefName: String ) {
        
        let eventName: String = MixpanelEventsName.RecipesRecipeClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.RecipeId.rawValue: recipeId,
            MixpanelParmName.RecipeName.rawValue: recipeName,
            MixpanelParmName.RecipeChefId.rawValue: chefId,
            MixpanelParmName.RecipeChefName.rawValue: chefName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    //MARK: store page Events

    class func trackStoreClose( ) {
        
        let eventName: String = MixpanelEventsName.StoreClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackStoreSearch( ) {
        
        let eventName: String = MixpanelEventsName.StoreSearch.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackStoreShoppingList( ) {
        
        let eventName: String = MixpanelEventsName.StoreShoppingList.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackStoreHelp( ) {
        
        let eventName: String = MixpanelEventsName.StoreHelp.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackStoreBannerClick(id: String, title: String, tier: String ) {
        
        let eventName: String = MixpanelEventsName.StoreBannerClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.BannerId.rawValue: id,
            MixpanelParmName.BannerTitle.rawValue: title,
            MixpanelParmName.BannerTier.rawValue: tier
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackStoreCategoryClick(categoryId: String, categoryName: String ) {
        
        let eventName: String = MixpanelEventsName.StoreCategoryClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.StoreCategoryCategoryId.rawValue: categoryId,
            MixpanelParmName.StoreCategoryCategoryName.rawValue: categoryName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackStoreProductsViewAll(categoryId: String, categoryName: String ) {
        
        let eventName: String = MixpanelEventsName.StoreProductsViewAll.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.StoreViewAllCategoryId.rawValue: categoryId,
            MixpanelParmName.StoreViewAllCategoryName.rawValue: categoryName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackStoreAddItem(product: Product ) {
        
        let eventName: String = MixpanelEventsName.StoreAddItem.rawValue
        let parameters = FireBaseEventsLogger.trackAddToProduct(product: product, eventName: eventName,isNeedToLogEvent: false)
//        let params: [String : Any]? = [
//            "clickedEvent": eventName
//        ]

        MixpanelManager.trackEvent(eventName, params: parameters)
    }
    
    class func trackStoreRemoveItem(product: Product ) {
        
        let eventName: String = MixpanelEventsName.StoreRemoveItem.rawValue
        let parameters = FireBaseEventsLogger.trackDecrementAddToProduct(product: product, "", isNeedToLogEvent: false)
//        let params: [String : Any]? = [
//            "clickedEvent": eventName
//        ]

        MixpanelManager.trackEvent(eventName, params: parameters)
    }
    
    
    //MARK: cart page Events

    class func trackCartclose( ) {
        
        let eventName: String = MixpanelEventsName.Cartclose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCartEditOOSInstruction( ) {
        
        let eventName: String = MixpanelEventsName.CartEditOOSInstruction.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCartOOSInstructionSelected(instruction: String ) {
        
        let eventName: String = MixpanelEventsName.CartOOSInstructionSelected.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.CartOOSInstruction.rawValue: instruction
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCartRemoveItem(product: Product ) {
        
        let eventName: String = MixpanelEventsName.CartRemoveItem.rawValue
        
        let parameters = FireBaseEventsLogger.trackDecrementAddToProduct(product: product, "", isNeedToLogEvent: false)
//        let params: [String : Any]? = [
//            "clickedEvent": eventName
//        ]

        MixpanelManager.trackEvent(eventName, params: parameters)
    }
    
    class func trackCartAddItem(product: Product ) {
        
        let eventName: String = MixpanelEventsName.CartAddItem.rawValue
        
        let parameters = FireBaseEventsLogger.trackAddToProduct(product: product, eventName: eventName,isNeedToLogEvent: false)
//        let params: [String : Any]? = [
//            "clickedEvent": eventName
//        ]

        MixpanelManager.trackEvent(eventName, params: parameters)
    }
    
    class func trackCartOOSSelected(product: Product, OOSProduct: Product ) {
        
        let eventName: String = MixpanelEventsName.CartOOSSelected.rawValue
        let paramsProduct = FireBaseEventsLogger.trackAddToProduct(product: product, eventName: eventName,isNeedToLogEvent: false)
        var params: [String : Any] = [
            "clickedEvent": eventName,
            MixpanelParmName.ItemOOSId.rawValue: "\(OOSProduct.getCleanProductId())",
            MixpanelParmName.ItemOOSName.rawValue: OOSProduct.nameEn ?? ""
        ]
        for (key, Value) in paramsProduct {
            params[key] = Value
        }
        

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCartBeginCheckout(value: String ) {
        
        let eventName: String = MixpanelEventsName.CartBeginCheckout.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.OrderValue.rawValue: value
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    

    //MARK: checkout page Events

    class func trackCheckoutClose( ) {
        
        let eventName: String = MixpanelEventsName.CheckoutClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCheckoutDeliverySlotSelected(slot: DeliverySlot, retailerID: String ) {
        
        let eventName: String = MixpanelEventsName.CheckoutDeliverySlotSelected.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.SlotId.rawValue: slot.dbID.stringValue,
            MixpanelParmName.SlotTimeStamp.rawValue: slot.time_milli.stringValue,
            MixpanelParmName.SlotStartTime.rawValue: "\(slot.start_time)",
            MixpanelParmName.SlotEndTime.rawValue: "\(slot.end_time)",
            MixpanelParmName.RetailerID.rawValue: retailerID
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCheckoutDeliverySlotClicked( ) {
        
        let eventName: String = MixpanelEventsName.CheckoutDeliverySlotClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    
    class func trackCheckoutInstructionAdded(instruction: String ) {
        
        let eventName: String = MixpanelEventsName.CheckoutInstructionAdded.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.CartInstructionsInstruction.rawValue : instruction
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    
    class func trackCheckoutPromocodeApplied(code: String ) {
        
        let eventName: String = MixpanelEventsName.CheckoutPromocodeApplied.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.PromoCode.rawValue: code
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    
    class func trackCheckoutPromocodeClicked( ) {
        
        let eventName: String = MixpanelEventsName.CheckoutPromocodeClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    
    class func trackCheckoutShowBillDetails(isVisible: Bool ) {
        
        let eventName: String = MixpanelEventsName.CheckoutShowBillDetails.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.OrderPriceShow.rawValue: isVisible
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    
    class func trackCheckoutPromoApplied(promoCode: PromotionCode ) {
        
        let eventName: String = MixpanelEventsName.CheckoutPromoApplied.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.promoId.rawValue: promoCode.promotionCodeRealizationId,
            MixpanelParmName.PromoDiscount.rawValue: "\(promoCode.valueCents)",
            MixpanelParmName.PromoCode.rawValue: promoCode.code
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    
    class func trackCheckoutPromoError(promoCode: String, error: String ) {
        
        let eventName: String = MixpanelEventsName.CheckoutPromoError.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.PromoCode.rawValue: promoCode,
            MixpanelParmName.PromoError.rawValue: error
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    
    class func trackCheckoutPaymentMethodSelected(paymentMethodId: String, cardId: String = "-1", retaiilerId: String ) {
        
        let eventName: String = MixpanelEventsName.CheckoutPaymentMethodSelected.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.PaymentMethodId.rawValue: paymentMethodId,
            MixpanelParmName.PaymentCreditCardId.rawValue: cardId,
            MixpanelParmName.RetailerID.rawValue: retaiilerId
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    
    class func trackCheckoutPaymentMethodClicked( ) {
        
        let eventName: String = MixpanelEventsName.CheckoutPaymentMethodClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    
    class func trackCheckoutConfirmOrderClicked(value: String ) {
        
        let eventName: String = MixpanelEventsName.CheckoutConfirmOrderClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.OrderValue.rawValue: value
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
//
    
    //MARK: order details page Events

    class func trackProfileMyOrders( ) {
        
        let eventName: String = MixpanelEventsName.ProfileMyOrders.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackOrderDetailsclose( ) {
        
        let eventName: String = MixpanelEventsName.OrderDetailsclose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackOrderDetailshelp( ) {
        
        let eventName: String = MixpanelEventsName.OrderDetailshelp.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackOrderDetailsEditOrderClicked(oId: String ) {
        
        let eventName: String = MixpanelEventsName.OrderDetailsEditOrderClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.OrderId.rawValue: oId
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackOrderDetailsCancelOrderClicked(oId: String ) {
        
        let eventName: String = MixpanelEventsName.OrderDetailsCancelOrderClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.OrderId.rawValue: oId
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
//
    
    //MARK: edit order page Events

    class func trackEditCartSearchClick( ) {
        
        let eventName: String = MixpanelEventsName.EditCartSearchClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackEditCartEditOOSInstruction( ) {
        
        let eventName: String = MixpanelEventsName.EditCartEditOOSInstruction.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackEditCartOOSInstructionSelected(reason: String ) {
        
        let eventName: String = MixpanelEventsName.EditCartOOSInstructionSelected.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.CartOOSInstruction.rawValue: reason
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackEditCartRemoveItem(product: Product ) {
        
        let eventName: String = MixpanelEventsName.EditCartRemoveItem.rawValue
        
        let parameters = FireBaseEventsLogger.trackDecrementAddToProduct(product: product, "", isNeedToLogEvent: false)
//        let params: [String : Any]? = [
//            "clickedEvent": eventName
//        ]

        MixpanelManager.trackEvent(eventName, params: parameters)
    }
    
    class func trackEditCartAddItem(product: Product ) {
        
        let eventName: String = MixpanelEventsName.EditCartAddItem.rawValue
        
        let parameters = FireBaseEventsLogger.trackAddToProduct(product: product, eventName: eventName,isNeedToLogEvent: false)
//        let params: [String : Any]? = [
//            "clickedEvent": eventName
//        ]

        MixpanelManager.trackEvent(eventName, params: parameters)
    }
    
    class func trackEditCartCancelOrderClicked(oId: String ) {
        
        let eventName: String = MixpanelEventsName.EditCartCancelOrderClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.OrderId.rawValue: oId
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackEditCartBeginCheckout(value: String ) {
        
        let eventName: String = MixpanelEventsName.EditCartBeginCheckout.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.OrderValue.rawValue: value
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
//
    
    //MARK: signin page Events

    class func trackWelcomeDetectLocationClick( ) {
        
        let eventName: String = MixpanelEventsName.WelcomeDetectLocationClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackWelcomeSigninInClicked( ) {
        
        let eventName: String = MixpanelEventsName.WelcomeSigninInClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackWelcomeNewToElgrocer( ) {
        
        let eventName: String = MixpanelEventsName.WelcomeNewToElgrocer.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackWelcomeHaveAnAccount( ) {
        
        let eventName: String = MixpanelEventsName.WelcomeHaveAnAccount.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackWelcomeEmailEntered(email: String ) {
        
        let eventName: String = MixpanelEventsName.WelcomeEmailEntered.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.UserEmail.rawValue: email
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackWelcomePasswordEntered( ) {
        
        let eventName: String = MixpanelEventsName.WelcomePasswordEntered.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackWelcomeForgotPassword( ) {
        
        let eventName: String = MixpanelEventsName.WelcomeForgotPassword.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackWelcomeChooseLocation( ) {
        
        let eventName: String = MixpanelEventsName.WelcomeChooseLocation.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackWelcomeClose( ) {
        
        let eventName: String = MixpanelEventsName.WelcomeClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
//
    
    //MARK: choose your location page Events

    class func trackCreateLocationSearchClick( ) {
        
        let eventName: String = MixpanelEventsName.CreateLocationSearchClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCreateLocationCurrentLocationClick( ) {
        
        let eventName: String = MixpanelEventsName.CreateLocationCurrentLocationClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCreateLocationConfirmClick( addressText:String ) {
        
        let eventName: String = MixpanelEventsName.CreateLocationConfirmClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.LocationAddress.rawValue: addressText
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCreateLocationClose( ) {
        
        let eventName: String = MixpanelEventsName.CreateLocationClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
//
    
    //MARK: sign up page Events

    class func trackCreateAccountNumberEntered( number:String ) {
        
        let eventName: String = MixpanelEventsName.CreateAccountNumberEntered.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.UserPhoneNum.rawValue: number
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCreateAccountNextClick( ) {
        
        let eventName: String = MixpanelEventsName.CreateAccountNextClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackOTPOTPEntered( otp:String ) {
        
        let eventName: String = MixpanelEventsName.OTPOTPEntered.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.UserOTP.rawValue: otp
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackOTPHelp( ) {
        
        let eventName: String = MixpanelEventsName.OTPHelp.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackSignUpEmailEntered( ) {
        
        let eventName: String = MixpanelEventsName.SignUpEmailEntered.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackSignUpPasswordEntered( ) {
        
        let eventName: String = MixpanelEventsName.SignUpPasswordEntered.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackSignUpNextClick( ) {
        
        let eventName: String = MixpanelEventsName.SignUpNextClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackSignupClose( ) {
        
        let eventName: String = MixpanelEventsName.SignupClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCreateAccountClose( ) {
        
        let eventName: String = MixpanelEventsName.CreateAccountClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
//
    
    //MARK: edit address details page Events

    class func trackEditAddressAddressTypeSelect( addressType:String ) {
        
        let eventName: String = MixpanelEventsName.EditAddressAddressTypeSelect.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.AddressType.rawValue: addressType
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackEditAddressLocationFieldClick( ) {
        
        let eventName: String = MixpanelEventsName.EditAddressLocationFieldClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackEditAddressAddressFieldsEntered( addressText:String ) {
        
        let eventName: String = MixpanelEventsName.EditAddressAddressFieldsEntered.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.AddressField.rawValue: addressText
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackEditAddressAditionalInformationEntered( info:String ) {
        
        let eventName: String = MixpanelEventsName.EditAddressAditionalInformationEntered.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.AddressAditionalInformation.rawValue: info
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackEditAddressAddressFilterSelect( filterName: String, filterId: String ) {
        
        let eventName: String = MixpanelEventsName.EditAddressAddressFilterSelect.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.AddressFilter.rawValue: filterName,
            MixpanelParmName.AddressFilterId.rawValue: filterId
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackEditAddressInformationEntered( name:String, number:String ) {
        
        let eventName: String = MixpanelEventsName.EditAddressInformationEntered.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.AddressUserName.rawValue: name,
            MixpanelParmName.AddressUserPhoneNum.rawValue: number
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackEditAddressNextClick( ) {
        
        let eventName: String = MixpanelEventsName.EditAddressNextClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackEditAddressClose( ) {
        
        let eventName: String = MixpanelEventsName.EditAddressClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
//
    
    //MARK: OOS page Events

    class func trackSubstitutionClose( ) {
        
        let eventName: String = MixpanelEventsName.SubstitutionClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackSubstitutionSubstitutionSelected(product: Product, OOSProduct: Product ) {
        
        let eventName: String = MixpanelEventsName.SubstitutionSubstitutionSelected.rawValue
        
        let paramsProduct = FireBaseEventsLogger.trackAddToProduct(product: product, eventName: eventName,isNeedToLogEvent: false)
        var params: [String : Any] = [
            "clickedEvent": eventName,
            MixpanelParmName.ItemOOSId.rawValue: "\(OOSProduct.getCleanProductId())",
            MixpanelParmName.ItemOOSName.rawValue: OOSProduct.nameEn ?? ""
        ]
        for (key, Value) in paramsProduct {
            params[key] = Value
        }
        
        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackSubstitutitonRemoveAllClicked( ) {
        
        let eventName: String = MixpanelEventsName.SubstitutitonRemoveAllClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackSubstitutionConfirmClicked( ) {
        
        let eventName: String = MixpanelEventsName.SubstitutionConfirmClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackSubstitutionCancelOrder( orderId: String ) {
        
        let eventName: String = MixpanelEventsName.SubstitutionCancelOrder.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.OrderId.rawValue: orderId
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
//
    
    //MARK: Choose your location Events

    class func trackChooseLocationClose( ) {
        
        let eventName: String = MixpanelEventsName.ChooseLocationClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackChooseLocationSelected(locAddress: String, locId: String ) {
        
        let eventName: String = MixpanelEventsName.ChooseLocationSelected.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.LocationAddress.rawValue: locAddress,
            MixpanelParmName.LocationId.rawValue: locId
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackChooseLocationAddAddressClick( ) {
        
        let eventName: String = MixpanelEventsName.ChooseLocationAddAddressClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackChooseLocationDeleteClick( ) {
        
        let eventName: String = MixpanelEventsName.ChooseLocationDeleteClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackChooseLocationEditClick( ) {
        
        let eventName: String = MixpanelEventsName.ChooseLocationEditClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
//
    
    //MARK: Add address details page Events

    class func trackAddAddressAddressTypeSelect( addressType:String ) {
        
        let eventName: String = MixpanelEventsName.AddAddressAddressTypeSelect.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.AddressType.rawValue: addressType
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackAddAddressLocationFieldClick( ) {
        
        let eventName: String = MixpanelEventsName.AddAddressLocationFieldClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackAddAddressAddressFieldsEntered( addressText:String ) {
        
        let eventName: String = MixpanelEventsName.AddAddressAddressFieldsEntered.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.AddressField.rawValue: addressText
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackAddAddressAditionalInformationEntered( info:String ) {
        
        let eventName: String = MixpanelEventsName.AddAddressAditionalInformationEntered.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.AddressAditionalInformation.rawValue: info
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackAddAddressAddressFilterSelect( filterName: String, filterId: String ) {
        
        let eventName: String = MixpanelEventsName.AddAddressAddressFilterSelect.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.AddressFilter.rawValue: filterName,
            MixpanelParmName.AddressFilterId.rawValue: filterId
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackAddAddressInformationEntered( name:String, number:String ) {
        
        let eventName: String = MixpanelEventsName.AddAddressInformationEntered.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.AddressUserName.rawValue: name,
            MixpanelParmName.AddressUserPhoneNum.rawValue: number
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackAddAddressNextClick( ) {
        
        let eventName: String = MixpanelEventsName.AddAddressNextClick.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackAddAddressClose( ) {
        
        let eventName: String = MixpanelEventsName.AddAddressClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    //MARK: El Wallet
    class func trackElWalletClose( ) {
        
        let eventName: String = (UIApplication.gettopViewControllerName() ?? "elWallet") +  MixpanelEventsName.ElWalletHomeClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElWalletAddFundsClicked( ) {
        
        let eventName: String =  MixpanelEventsName.ElWalletAddfundsClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElWalletVoucherViewAllClicked( ) {
        
        let eventName: String =  MixpanelEventsName.ElWalletVoucherViewAll.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElWalletRedeemVoucherClicked(voucherId: String, voucherCode: String ) {
        
        let eventName: String =  MixpanelEventsName.ElWalletRedeemVoucher.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.ElWalletVoucherCode.rawValue : voucherCode,
            MixpanelParmName.ElwalletVoucherID.rawValue : voucherId
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElWalletManageCardsClicked() {
        
        let eventName: String =  MixpanelEventsName.ElWalletManageCardsClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletTransactionsViewAllClicked() {
        
        let eventName: String =  MixpanelEventsName.ElwalletTransactionsViewAll.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletAddNewCardClicked() {
        
        let eventName: String =  MixpanelEventsName.ElwalletAddNewCardClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletAddFundPaymentMethodSelection(methodName: String) {
        
        let eventName: String =  MixpanelEventsName.ElwalletAddFundPaymentMethodSelection.rawValue + methodName
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletAddFundPaymentMethodSelectionAddNewCardClicked() {
        
        let eventName: String =  MixpanelEventsName.ElwalletAddFundPaymentMethodSelectionAddNewCardClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletAddFundPaymentMethodSelectionNextClicked() {
        
        let eventName: String =  MixpanelEventsName.ElwalletAddFundPaymentMethodSelectionNextClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletAddFundsClose() {
        
        let eventName: String =  MixpanelEventsName.ElwalletAddFundsClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletFundAddEnteredAddfundsClicked() {
        
        let eventName: String =  MixpanelEventsName.ElwalletFundAddEnteredAddfundsClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElWalletAddFundsPaymentSuccessClose() {
        
        let eventName: String =  MixpanelEventsName.ElWalletAddFundsPaymentSuccessClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElWalletAddFundsPaymentFaliureClose() {
        
        let eventName: String =  MixpanelEventsName.ElWalletAddFundsPaymentFaliureClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletFundsErrorTryAgainClicked() {
        
        let eventName: String =  MixpanelEventsName.ElwalletFundsErrorTryAgainClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElWalletUnifiedClose( ) {
        
        let eventName: String = (UIApplication.gettopViewControllerName() ?? "") +  MixpanelEventsName.ElWalletHomeClose.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletActiveVoucherManualInPutRedeemClicked(code: String ) {
        
        let eventName: String = MixpanelEventsName.ElwalletActiveVoucherManualInPutRedeemClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.VoucherCode.rawValue : code
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletActiveVoucherVoucherRedeemError( ) {
        
        let eventName: String = MixpanelEventsName.ElwalletActiveVoucherVoucherRedeemError.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletActiveVoucherInsideCardRedeemClicked(voucherId: String, voucherCode: String ) {
        
        let eventName: String =  MixpanelEventsName.ElwalletActiveVoucherInsideCardRedeemClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.VoucherCode.rawValue : voucherCode,
            MixpanelParmName.VoucherId.rawValue : voucherId
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletEditCardClicked() {
        
        let eventName: String =  MixpanelEventsName.ElwalletEditCardClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletCardsAddNewCardClicked() {
        
        let eventName: String =  MixpanelEventsName.ElwalletCardsAddNewCardClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletEditCardsRemoveCardClicked() {
        
        let eventName: String =  MixpanelEventsName.ElwalletEditCardsRemoveCardClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletEditCardsKeepUsingCardClicked() {
        
        let eventName: String =  MixpanelEventsName.ElwalletEditCardsKeepUsingCardClicked.rawValue
        
        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackElwalletActiveVoucherView(id: String, code: String) {

        let eventName: String =  MixpanelEventsName.ElwalletActiveVoucherView.rawValue

        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.ElwalletVoucherID.rawValue: id,
            MixpanelParmName.ElWalletVoucherCode.rawValue: code,
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    //MARK: Second Checkout
    
    class func trackCheckoutPrimaryPaymentMethodClicked() {

        let eventName: String =  MixpanelEventsName.CheckoutPrimaryPaymentMethodClicked.rawValue

        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCheckoutAddNewCardClicked() {

        let eventName: String =  MixpanelEventsName.CheckoutAddNewCardClicked.rawValue

        let params: [String : Any]? = [
            "clickedEvent": eventName
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCheckoutVoucherApplied(code: String, id: String) {

        let eventName: String =  MixpanelEventsName.CheckoutVoucherApplied.rawValue

        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.VoucherCode.rawValue: code,
            MixpanelParmName.VoucherId.rawValue: id
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCheckoutVoucherRemoved(code: String, id: String) {

        let eventName: String =  MixpanelEventsName.CheckoutVoucherRemoved.rawValue

        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.ElWalletVoucherCode.rawValue: code,
            MixpanelParmName.ElwalletVoucherID.rawValue: id
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCheckoutElwalletSwitchOn(balance: String) {

        let eventName: String =  MixpanelEventsName.CheckoutElwalletSwitchOn.rawValue

        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.AvailableBalance.rawValue: balance
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCheckoutElwalletSwitchOff(balance: String) {

        let eventName: String =  MixpanelEventsName.CheckoutElwalletSwitchOff.rawValue

        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.AvailableBalance.rawValue: balance
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCheckoutSmilesSwitchOn(balance: String) {

        let eventName: String =  MixpanelEventsName.CheckoutSmilesSwitchOn.rawValue

        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.AvailableBalance.rawValue: balance
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCheckoutSmilesSwitchOff(balance: String) {

        let eventName: String =  MixpanelEventsName.CheckoutSmilesSwitchOff.rawValue

        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.AvailableBalance.rawValue: balance
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCheckoutElwalletSwitchError(error: String) {

        let eventName: String =  MixpanelEventsName.CheckoutElwalletSwitchError.rawValue

        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.ErrorMessage.rawValue: error
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCheckoutSmilesSwitchError(error: String) {

        let eventName: String =  MixpanelEventsName.CheckoutSmilesSwitchError.rawValue

        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.ErrorMessage.rawValue: error
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCheckoutOrderError(error: String, value: String) {

        let eventName: String =  MixpanelEventsName.CheckoutOrderError.rawValue

        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.ErrorMessage.rawValue: error,
            MixpanelParmName.TotalOrderAmount.rawValue: value
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCheckoutAvailablePaymentMethods(retailerId: String,cash: Bool, card: Bool, online: Bool) {

        let eventName: String =  MixpanelEventsName.CheckoutAvailablePaymentMethods.rawValue

        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.IsCashAvailable.rawValue: cash,
            MixpanelParmName.IsCODAvailable.rawValue: card,
            MixpanelParmName.IsOnlineAvailable.rawValue: online,
            MixpanelParmName.RetailerID.rawValue: retailerId
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCheckoutPaymentMethodError(error: String) {

        let eventName: String =  MixpanelEventsName.CheckoutPaymentMethodError.rawValue

        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.ErrorMessage.rawValue: error
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
    class func trackCheckoutApplePayError(error: String) {

        let eventName: String =  MixpanelEventsName.CheckoutApplePayError.rawValue

        let params: [String : Any]? = [
            "clickedEvent": eventName,
            MixpanelParmName.ErrorMessage.rawValue: error
        ]

        MixpanelManager.trackEvent(eventName, params: params)
    }
    
}
