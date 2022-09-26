//
//  FireBaseEventsLogger.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 07/01/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
// update

import Foundation
import FirebaseAnalytics
import FirebaseCrashlytics
import STPopup
import UIKit


public let FireBaseElgrocerPrefix : String = "EG_"
public let CleverTapElgrocerPrefix : String = Platform.isDebugBuild ?  "EG1_" : "CT_"

enum FireBaseScreenName: String {
    
    case Splash = "Splash"
    case DefaultForNav = "DefaultNavigationController"
    case GenericHome = "Home"
    case Home = "HomeStore"
    case Category = "Categories"
    case MyBasket = "MyBasket"
    case CheckOut = "CheckOut"
    case PurchaseOrder = "PurchaseOrder"
    case Search = "Search"
    case LogIn = "LogIn"
    case CreateAccount = "CreateAccount"
    case Recipes = "Recipes"
    case MultiSearch = "MultiSearch"
    case MyOrders = "MyOrders"
    case ViewOrder = "ViewOrder"
    case Profile = "Profile"
    case DashBoard = "ChangeLocation"
    case ViewItem = "ViewItem"
    case DetectLocation = "DetectLocation"
    case Map = "SelectLocation"
    case ChangeStore = "ChangeStore"
    case ChangePassword = "ChangePassword"
    case ChangeLanguage = "ChangeLanguage"
    case Substitutions  =  "Substitutions"
    case SubstitutionConfirmation  =  "SubstitutionConfirmation"
    case SubCategory  =  "SubCategory"
    case Brand  =  "Brand"
    case Replacement = "Replacement"
    case OtpRequest = "OtpRequest"
    case ShoppingList = "ShoppingList"
    case PaymentConfirmationn = "PaymentConfirmation"
    case CardConfirmation = "CardConfirmation"
    case TermsConditions = "TermsConditions"
    case FAQ = "FAQ"
    case PrivacyPolicy = "PrivacyPolicy"
    case GlobalSearchResults = "GlobalSearchResults"
    
    case RecipeDetail = "recipePage"
    case SavedRecipes = "savedRecipes"
    
    case CancelReason = "CancelReason"
    case ProductDetailView = "ProductDetailView"
    case ApplyPromoVC = "PromoList"
    
}


enum FireBaseParmName : String {
    
    case DeliveryType = "DeliveryType"
    case Source = "Source"
  
    case statusId = "order_statusId"
    case SearchTerm = "SearchTerm"
    case OrderId = "OrderId"
    case ItemSize = "ItemSize"
    case ItemId = "ItemId"
    case ItemPrice = "ItemPrice"
    case IsSponsored = "IsSponsored"
    case isPromotion = "Item_ispromotional"
    case isCarousel = "IsCarousel"
    case ProductName = "ProductName"
    case ProductId = "ProductId"
    case CategoryName = "CategoryName"
    case SubCategoryName = "SubCategoryName"
    case BrandName = "BrandName"
    case RecipeName = "RecipeName"
    case ChefName = "ChefName"
    
    case NextScreen = "NextScreen"
    case PreviousScreen = "PreviousScreen"
    case StoreCategoryFilter =  "StoreCategoryFilter"
    case LocationName = "LocationName"
    case LocationId = "LocationId"
    case LocationLatLng = "LocationLatLng"
    case LocationChange = "LocationChange"
    case OldLocationId = "OldLocationId"
    case OldLocationName = "OldLocationName"
    case Date = "Date"
    case StoreCategoryID = "StoreCategoryID"
    case StoreCategoryName = "StoreCategoryName"
    
    case LastStoreCategoryID = "LastStoreCategoryID"
    case LastStoreCategoryName = "LastStoreCategoryName"
    
    case Position = "Position"
    case NumberOfRow = "NumberOfRow"
    case NumberOfRetailers = "NumberOfRetailers"
    case StoreName = "StoreName"
    case NumberOfItemsOldStore = "NumberOfItemsOldStore"
    case OldStoreID = "OldStoreID"
    case OldStoreName = "OldStoreName"
    case RowView = "RowView"
    
    case CheifId = "CheifId"
    case CheifName = "CheifName"
    case CampaignId = "CampaignId"
    case CampaignName = "CampaignName"
    case DealsClick   =  "DealsClick"
    case Storyly = "isStoryly"
    case StorylyDeepLink = "storylyDeepLink"
    
    case Category = "Category"
    case SubCategory = "SubCategory"
    case ViewType = "ViewType"
    case HasPromotion = "Item_hasPromotion"
    case OrderDiscount = "Order_discount"
    case ItemDiscount = "Item_discount"
    
    //  new events parm names
    
    case recipeId = "Recipe_id"
    case RecipeIngredientid = "Recipe_ingredientid"
    case RecipeChefid = "Recipe_chefid"
    case RecipeChefname = "Recipe_chefname"
    case CurrentScreen = "Action_currentscreen"
    case ActionParentid = "Action_parentid"
    case ActionStoreid = "Action_storeid"
    case ActionStorename = "Action_storename"
    case SessionID = "User_sessionid"
    case UserId = "User_id"
    case Userlatlon = "User_latlon"
    case UserPlatform = "User_platform"
    case UserFrom = "User_SmileSDK"
    case PickerID = "PickerId"
    case OrderStatusID = "OrderStausId"
    
    case CurrentLat = "CurrentLat"
    case CurrentLng = "CurrentLng"
    case CurrentSavedLat = "CurrentSavedLat"
    case CurrentSavedLng = "CurrentSavedLng"

    case HomeTileId = "HomeTile_id"
    case HomeTileType = "HomeTile_type"
    case HomeTileName = "HomeTile_name"
    
    case NoPriorityStore = "NoPriorityStore"
    case BannerType = "Banner_type"
    
    case AvailableQuantity = "AvailableQuantity"
    case Reason = "Reason"

    case DeepLink = "DeepLink"
    case AvailableStoreIds = "AvailableStoreIds"
    case StoreId = "StoreId"
    case BrandId = "BrandId"
    case SelectedStoreId = "SelectedStoreId"

    case PromoCode = "Promo"
    case PromoIndex = "Index"
    case StoreSearch = "StoreSearch"

}


enum FireBaseEventsName : String {
   
    case Navigation =  "Navigation"
    case AddItem =  "AddItem"
    case RemoveItem = "RemoveItem"
    case Search = "Search"
    case RecipeSearch = "RecipeSearch"
    case CheckOut = "CheckOut"
    case MultiSearch = "MultiSearch"
    case PurchaseItem = "PurchasedItem"
    case PopUp = "Message"
    case AbandonBasket = "AbandonBasket"
    case OtpConfirm = "OtpConfirm"
    case OtpResend = "OtpResend"
    case BannerView = "BannerView"
   
    case DealsView = "DealsView"
    case CustomEvent = "CustomLogEvent"
    case StoreListingRows = "StoreListingRows"
    case StoreListingStoreClick  = "StoreListingStoreClick"
    case StoreListingOneCategoryFilter = "StoreListingOneCategoryFilter"
    case StoreListingNoStores = "StoreListingNoStores"
    case StoreListingStores = "AvailableStores"
    
    case NoBanners = "NoBanners"
    case NoDeals = "NoDeals"
    case NoRecipe = "NoRecipe"

    case ViewRecipe = "ViewRecipe"
    case RecipeClick = "RecipeClick"
    case RecipeFilterClick = "RecipeFilterClick"
    
    
    case RecipeIngredientPurchase = "IngredientPurchase"
    case RecipePurchase = "RecipePurchase"
    case CarousalIngredientPurchase = "CarouselProductPurchase"
    
    case OrderStatusCardView = "OrderStatusCardView"
    case OrderStatusCardClick = "OrderStatusCardClick"
    case OrderTrackingClick = "OrderTrackingClick"
    
    case pickerChat = "PickerChat"
    
    case ChangeLocationClick = "ChangeToCurrentLocation"
    case DontChangeLocationClick = "DontChangeLocation"
  
    case supportChat = "SupportChat"
    
    case HomeTileClicked = "HomeTileClicked"
    case HomeTileView = "HomeTileView"
    
    case InventoryReach =  "InventoryReach"
    case LimitedStockItems = "LimitedStockItems"
    case AddItemFailure = "AddItemFailure"

    case ProductViewed = "ProductViewed"
    case ProductClicked = "ProductClicked"
    case ProductStoreListViewed = "ProductStoreListViewed"
    case ProductStoreSelection = "ProductStoreSelection"
    case PromoApplyClicked = "PromoApplyClicked"

}



class FireBaseEventsLogger  {

    
//    static let KFireBaseName = "elGrocerSandBox"
//    class func configureSecondInstanceFireBase () {
//
//            // Configure with manual options.
//            let secondaryOptions = FirebaseOptions(googleAppID: "1:434254382905:ios:7a943896997dc9dff24ae8", gcmSenderID: "434254382905")
//            secondaryOptions.bundleID = "elgrocer.com.ElGrocerShopper"
//            secondaryOptions.apiKey = "AIzaSyA3vd2E1bBLezwvAapDaFuoFIw2VnXjjlQ"
//            secondaryOptions.clientID = "434254382905-lrab4l21j5a8641p6llct8ib151ncq11.apps.googleusercontent.com"
//            secondaryOptions.databaseURL = "https://elgrocer.firebaseio.com"
//            secondaryOptions.storageBucket = "myproject.appspot.com"
//            FirebaseApp.configure(name:  KFireBaseName, options: secondaryOptions)
//
//    }
//
//    class func getFirebaseApp () -> FirebaseApp {
//        return FirebaseApp.app(name: KFireBaseName) ?? <#default value#>
//    }
//
    
    class func logEventToFirebaseWithEventName( _ screenName : String = "" ,  eventName : String ,  parameter : [String : Any]? = nil ){
        
        var eventNameToSend = ""
        
        if screenName.count > 0 {
           eventNameToSend =  FireBaseEventsLogger.concateName(screenName,eventName)
        }else{
            eventNameToSend =  eventName
        }
        
        eventNameToSend = eventNameToSend.replacingOccurrences(of: " ", with: "")
        
        if eventNameToSend.count > 40 {
            let eventA = eventNameToSend.split(separator: "_")
            var trimEventName = ""
            for (index , data) in eventA.enumerated() {
                if data.count > 10 {
                    let dataCap = String(data.prefix(8)).capitalized
                    trimEventName.append(dataCap)
                    trimEventName.append("..")
                }else{
                    trimEventName.append(String(data).capitalized)
                }
                if index == eventA.count - 1 {  } else {
                     trimEventName.append("_")
                }
            }
            if trimEventName.count > 0 {
                eventNameToSend = trimEventName
            }
            let trimToCharacter = 40
            eventNameToSend = String(eventNameToSend.prefix(trimToCharacter))
        }
        
        eventNameToSend = eventNameToSend.replacingOccurrences(of: "-", with: "")
        eventNameToSend = eventNameToSend.replacingOccurrences(of: ">", with: "To_")
        if screenName.count > 0 {
            eventNameToSend = FireBaseElgrocerPrefix + eventNameToSend
        }
    
        var newParms =  parameter == nil ? [:] : parameter
        
        if let dbID = ElGrocerUtility.sharedInstance.activeGrocery?.dbID  {
            newParms?[FireBaseParmName.ActionStoreid.rawValue] = dbID
            newParms?[FireBaseParmName.StoreName.rawValue] = ElGrocerUtility.sharedInstance.activeGrocery?.name ?? ""
            newParms?["StoreTypes"] = ElGrocerUtility.sharedInstance.activeGrocery?.storeType.count ?? 0 > 0 ? ElGrocerUtility.sharedInstance.activeGrocery?.storeType.map { String(describing: $0) }.joined(separator: ",") : "0"
            newParms?[FireBaseParmName.ActionParentid.rawValue] = ElGrocerUtility.sharedInstance.activeGrocery?.parentID.stringValue ?? "0"
            newParms?["ZoneID"] = ElGrocerUtility.sharedInstance.activeGrocery?.deliveryZoneId ?? "0"
        }
        
        newParms?[FireBaseParmName.UserFrom.rawValue] = sdkManager.isSmileSDK
        newParms?[FireBaseParmName.UserPlatform.rawValue] = "ios"
        
        if let newLocation = ElGrocerUtility.sharedInstance.activeAddress {
            newParms?[FireBaseParmName.LocationId.rawValue] = newLocation.dbID.count > 0 ? newLocation.dbID : "1"
            newParms?[FireBaseParmName.Userlatlon.rawValue] = String(describing: newLocation.latitude )  + "," + String(describing: newLocation.longitude )
        }
        newParms?[FireBaseParmName.SessionID.rawValue] = ElGrocerUtility.sharedInstance.getGenericSessionID()
        if newParms?[FireBaseParmName.Source.rawValue] == nil {
            newParms?[FireBaseParmName.Source.rawValue] =  DispatchQueue.isRunningOnMainQueue ? FireBaseEventsLogger.getSourceName() : "UnKnown"
        }
        newParms?[FireBaseParmName.DeliveryType.rawValue] = ElGrocerUtility.sharedInstance.isDeliveryMode ? OrderType.delivery.rawValue : OrderType.CandC.rawValue
        
        let id = UserDefaults.getLogInUserID()
            if id != "0" {
                newParms?[FireBaseParmName.UserId.rawValue] = id
            }
        
    
        
        if let removeNull = newParms {
             newParms = removeNull.compactMapValues { $0 }
        }
     
        let finalParm = newParms
        for (key, value) in finalParm ?? [:] {
            
           // elDebugPrint("check logger for type  type : \(String(describing: value.self)) : \(key) : valure : \(value) ")
            
             if value is [NSNumber] {
                newParms?[key] = (value as AnyObject).description
            }
            
            if value is String {
                var finalString : String = value as! String
                if finalString.count > 100 {
                    finalString = String(finalString.prefix(100))
                    newParms?[key] = finalString
                   // elDebugPrint("value change here : \(finalString)")
                }
            }
        }
        
        let currentTime = Date().timeIntervalSince1970
        if let eventInMap = ElGrocerUtility.sharedInstance.eventMap[eventNameToSend], currentTime - eventInMap < 2000 {
            if eventNameToSend == "EG_PromoCode"
                || eventNameToSend == "EG_SmilesError"
                || eventNameToSend == "EG_PayCreditCard"
                || eventNameToSend == "EG_CheckoutTime"
                || eventNameToSend == "EG_CarouselProductPurchase"
                || eventNameToSend == "EG_AvailableStores"
                || eventNameToSend == "EG_PayCardOnDelivery"
                || eventNameToSend == "EG_PayCash"
                || eventNameToSend == "EG_PayCreditCard"
                || eventNameToSend == "EG_NoPriorityStore" {
                return
            }
        }
        ElGrocerUtility.sharedInstance.eventMap[eventNameToSend] = Date().timeIntervalSince1970
        
        
        DispatchQueue.global(qos: .background).async {
          
            usleep(1)
            
            var nameForCleverTap = eventNameToSend
            if nameForCleverTap.contains(FireBaseElgrocerPrefix) {
                nameForCleverTap = nameForCleverTap.replacingOccurrences(of: FireBaseElgrocerPrefix , with: CleverTapElgrocerPrefix )
                CleverTapEventsLogger.recordEvent( nameForCleverTap  , properties: newParms != nil ? newParms : [:] )
            }
            Analytics.logEvent( eventNameToSend  , parameters:newParms != nil ? newParms : [:]) //40 char limit
            
            if Platform.isDebugBuild {
                elDebugPrint("*Firebase Logs*  *EventName Only*: \(eventNameToSend)  *****")
                elDebugPrint("*Firebase Logs*  *EventName*: \(eventNameToSend)  *Parms*: \(newParms as Any)  *****")
                elDebugPrint("=====================*Firebase Logs event Name*=========================")
            }
        }
    }
    
    class func setScreenName (_ screenName : String?  , screenClass : String? ) {
       
        var finalScreenName = screenName
        finalScreenName = finalScreenName?.replacingOccurrences(of: " ", with: "_")
        finalScreenName = finalScreenName?.replacingOccurrences(of: "-", with: "_")
        finalScreenName = finalScreenName?.replacingOccurrences(of: ">", with: "To_")
        if let _ = screenName {
            Analytics.logEvent(AnalyticsEventScreenView , parameters: ["screenName" : finalScreenName ?? "" , "screenClass" : screenClass ?? ""])
           // Analytics.setScreenName(finalScreenName, screenClass: screenClass ?? "") //100 char limit
        }
    
    }
  
    
    class func setUserID (_ userID : String?) {
        if let _ = userID {
            Analytics.setUserID(userID)
            Crashlytics.crashlytics().setUserID(userID ?? "")
            
//            elDebugPrint("=====================*Firebase Logs Property*=========================")
//            elDebugPrint("*Firebase Logs* *SetUserID*:  \(userID ?? "" )   ******")
//            elDebugPrint("=====================*Firebase Logs Property*=========================")
//
        }
      
    }
    class func setUserProperty (_ value :  String? , key : String) {
        if let _ = value {
            Crashlytics.crashlytics().setCustomValue(value ?? "" , forKey: key )
            Analytics.setUserProperty(value, forName: key)
//            elDebugPrint("=====================*Firebase Logs Property*=========================")
//            elDebugPrint("*Firebase Logs* *setUserProperty*  value: \(value ?? "" )   key: \(key)  ***** ")
//            elDebugPrint("=====================*Firebase Logs Property*=========================")
        }
      
    }
    class func setUserName (name : String?) -> Void {
        Crashlytics.crashlytics().setCustomValue(name ?? "UnKnown", forKey: "user_name")
    }
    class func setUserEmail (email : String?) -> Void {
        Crashlytics.crashlytics().setCustomValue(email ?? "UnKnown", forKey: "user_email")
      //  Crashlytics.crashlytics().setUserEmail(email)
    }
    
    //MARK:-  Home screen Events
    
    class func appLaunch (_ name : String) {
        FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: FireBaseElgrocerPrefix + name , parameter:[:])
        
    }
    @discardableResult
    class func trackAddToProduct ( product : Product , _ recipeName : String = "" , _ chefName : String? = "" , isCarousel : Bool = false ,  eventName : String, isNeedToLogEvent: Bool = true) -> [String: Any] {
        
        let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let defaultAddressId = currentAddress?.dbID ?? ""
        let cleanProductID = Product.getCleanProductId(fromId: product.dbID)
        var brandName : String = product.brandNameEn ?? product.brandName ?? ""
        var categoryName : String =  product.categoryNameEn ?? product.categoryName ?? ""
        var subCategoryName : String =  product.subcategoryNameEn ?? product.subcategoryName ?? ""
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        
        if currentLang == "ar" {
            brandName =  product.brandNameEn ?? ""
            categoryName =   product.categoryNameEn ?? ""
            subCategoryName = product.subcategoryNameEn ?? ""
        }
        
        let productName = product.nameEn ?? product.name ?? "No Name"
        
        
        //ecommernce event
        let quantity = 1
        var paramsToSend: [String : Any] = [:]
        //App event
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            
            var deepLink = ""
            if let topVc = UIApplication.topViewController() {
                if let vc = topVc as? BrandDeepLinksVC {
                    deepLink = vc.deepLink
                    BrandUserDefaults.setProductAddFromDeepLink(product.dbID, deepLink: deepLink)
                } else if let vc = topVc as? DeepLinkBottomGroceryVC {
                    deepLink = vc.deepLink
                    BrandUserDefaults.setProductAddFromDeepLink(product.dbID, deepLink: deepLink)
                }
            }
            
             paramsToSend = [FireBaseParmName.ProductName.rawValue :  productName , FireBaseParmName.BrandName.rawValue : brandName , FireBaseParmName.CategoryName.rawValue : categoryName , FireBaseParmName.SubCategoryName.rawValue : subCategoryName , FireBaseParmName.recipeId.rawValue : Int(recipeName) ?? -1 , FireBaseParmName.ChefName.rawValue : Int(chefName ?? "-1") ?? ""   , FireBaseParmName.CurrentScreen.rawValue : topControllerName , AnalyticsParameterCurrency.capitalized: kProductCurrencyEngAEDName, FireBaseParmName.ItemPrice.rawValue : product.price , AnalyticsParameterQuantity.capitalized: quantity , FireBaseParmName.ItemId.rawValue : cleanProductID  , FireBaseParmName.IsSponsored.rawValue : product.isSponsored ?? NSNumber(integerLiteral: 0) , FireBaseParmName.ItemSize.rawValue : product.descr ?? "" , FireBaseParmName.isPromotion.rawValue : product.promotion?.boolValue ?? false  , FireBaseParmName.isCarousel.rawValue : isCarousel , FireBaseParmName.AvailableQuantity.rawValue : product.availableQuantity.intValue, FireBaseParmName.DeepLink.rawValue : deepLink   ]
            guard isNeedToLogEvent else {
                return paramsToSend
            }
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.AddItem.rawValue + (UserDefaults.isOrderInEdit() ? "Edited" : "")  , parameter: paramsToSend)
            
        }
        
    
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "", eventName: AnalyticsEventAddToCart , parameter: [
            AnalyticsParameterCurrency: kProductCurrencyEngAEDName,
            AnalyticsParameterPrice: product.price ,
            AnalyticsParameterQuantity: quantity,
            AnalyticsParameterItemCategory: categoryName,
            AnalyticsParameterItemID:  cleanProductID ,
            AnalyticsParameterLocationID: defaultAddressId,
            AnalyticsParameterItemName: productName ,
            AnalyticsParameterValue: product.price
        ])
        
        if UIApplication.topViewController() is SearchViewController {
            if let isSpons = product.isSponsored {
                if isSpons.intValue == 1 {
                    UserDefaults.setSponsoredItems(product, WithGrocerID: product.groceryId)
                }
            }
        }
     return paramsToSend
    }
    @discardableResult
    class func trackDecrementAddToProduct ( product : Product , _ recipeName : String = "",isNeedToLogEvent: Bool = true)-> [String: Any] {
        
        let cleanProductID = Product.getCleanProductId(fromId: product.dbID)
        var brandName : String = product.brandNameEn ?? product.brandName ?? ""
        var categoryName : String =  product.categoryNameEn ?? product.categoryName ?? ""
        var subCategoryName : String =  product.subcategoryNameEn  ?? product.subcategoryName ?? ""
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            brandName =  product.brandNameEn ?? ""
            categoryName =   product.categoryNameEn ?? ""
            subCategoryName = product.subcategoryNameEn ?? ""
        }
        
        let quantity = 1
//        let shoppingBasketItem = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: ElGrocerUtility.sharedInstance.activeGrocery , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
//        if let item = shoppingBasketItem {
//            quantity = item.count.intValue
//        }
        var paramsToSend: [String: Any] = [:]
        
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            
            paramsToSend = [ FireBaseParmName.ProductName.rawValue  :  product.nameEn ?? product.name ?? "" , FireBaseParmName.BrandName.rawValue : brandName , FireBaseParmName.CategoryName.rawValue : categoryName , FireBaseParmName.SubCategoryName.rawValue : subCategoryName , FireBaseParmName.RecipeName.rawValue : recipeName ,  FireBaseParmName.CurrentScreen.rawValue : topControllerName  , AnalyticsParameterCurrency.capitalized: kProductCurrencyEngAEDName, FireBaseParmName.ItemPrice.rawValue : product.price , AnalyticsParameterQuantity.capitalized: quantity , FireBaseParmName.ItemId.rawValue : cleanProductID  , FireBaseParmName.IsSponsored.rawValue : product.isSponsored ?? NSNumber(integerLiteral: 0) , FireBaseParmName.ItemSize.rawValue : product.descr ?? "" , FireBaseParmName.isPromotion.rawValue : product.isPromotion , FireBaseParmName.AvailableQuantity.rawValue : product.availableQuantity.intValue  ]
            
            guard isNeedToLogEvent else {
                return paramsToSend
            }
            
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.RemoveItem.rawValue + (UserDefaults.isOrderInEdit() ? "Edited" : "") , parameter: paramsToSend )
            elDebugPrint(topControllerName)
        }
        return paramsToSend
    }
    
    
    class func trackMultiSearch (_ searchList : String ) {
        
        
        var array = searchList.components(separatedBy: CharacterSet.newlines)
        array = array.filter({ $0 != ""})
        array = array.map { $0.trimmingCharacters(in: .whitespaces) }
        let itemList =  array.joined(separator: ",")
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.MultiSearch.rawValue  , parameter: [FireBaseParmName.CurrentScreen.rawValue : topControllerName , FireBaseParmName.SearchTerm.rawValue : itemList] )
            elDebugPrint(topControllerName)
        }
         let parms = [AnalyticsParameterItemCategory : itemList ]
        FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: AnalyticsEventViewItemList, parameter: parms )
        
    }
    
    
    class func trackMyBasketClick (_ eventName : String) {
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            let finalEventName = FireBaseElgrocerPrefix + eventName
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: finalEventName , parameter: [FireBaseParmName.CurrentScreen.rawValue : topControllerName , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.MyBasket.rawValue + (UserDefaults.isOrderInEdit() ? "Edited" : "")  ] )
            elDebugPrint(topControllerName)
        }
        
    }
    
    class func trackRecipeBannerClick (_ eventName : String) {
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            let finalEventName = FireBaseElgrocerPrefix + eventName
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: finalEventName , parameter: [FireBaseParmName.CurrentScreen.rawValue : FireBaseScreenName.Home.rawValue , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.Recipes.rawValue  ] )
            elDebugPrint(topControllerName)
        }

    }
    
    
    
    class func trackChangeStore () {
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "ChangeStore" , parameter: [FireBaseParmName.CurrentScreen.rawValue : topControllerName ] )
            elDebugPrint(topControllerName)
        }
        
    }
    
    class func trackChangeLocation () {
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName:FireBaseElgrocerPrefix +  "ChangeLocation" , parameter: [FireBaseParmName.CurrentScreen.rawValue : topControllerName ] )
            elDebugPrint(topControllerName)
        }
     
    }
    
    class func trackChangeToCurrentLocationClicked(_ currentLocationLat: Double, _ currentLocationLng: Double, _ currentSavedLocationLat: Double, _ currentSavedLocationLng: Double ) {

        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.CurrentLat.rawValue] = currentLocationLat
        finalParms[FireBaseParmName.CurrentLng.rawValue] = currentLocationLng
        finalParms[FireBaseParmName.CurrentSavedLat.rawValue] = currentSavedLocationLat
        finalParms[FireBaseParmName.CurrentSavedLng.rawValue] = currentSavedLocationLng
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            finalParms[FireBaseParmName.CurrentScreen.rawValue] = topControllerName
            elDebugPrint(topControllerName)
        }
        
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "", eventName: FireBaseElgrocerPrefix + FireBaseEventsName.ChangeLocationClick.rawValue, parameter: finalParms )
    }
    
    class func trackDontChangeLocationClicked(_ currentLocationLat: Double, _ currentLocationLng: Double, _ currentSavedLocationLat: Double, _ currentSavedLocationLng: Double ) {

        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.CurrentLat.rawValue] = currentLocationLat
        finalParms[FireBaseParmName.CurrentLng.rawValue] = currentLocationLng
        finalParms[FireBaseParmName.CurrentSavedLat.rawValue] = currentSavedLocationLat
        finalParms[FireBaseParmName.CurrentSavedLng.rawValue] = currentSavedLocationLng
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            finalParms[FireBaseParmName.CurrentScreen.rawValue] = topControllerName
            elDebugPrint(topControllerName)
        }
        
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.DontChangeLocationClick.rawValue, parameter: finalParms )
    }
    
    class func trackViewMoreClick ( topControllerName : String = FireBaseEventsLogger.gettopViewControllerName() ?? UIApplication.gettopViewControllerName() ?? String(describing: UIApplication.topViewController())  , _ parms : [String : Any]) {
        var finalParm = parms
        finalParm[FireBaseParmName.CurrentScreen.rawValue] = topControllerName
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "ViewMore" , parameter: finalParm )
        elDebugPrint(topControllerName)
        
    }
    
    class func trackViewItemClick ( topControllerName : String = FireBaseEventsLogger.gettopViewControllerName() ?? String(describing: UIApplication.topViewController())  , _ parms : [String : Any]) {
        
        FireBaseEventsLogger.logEventToFirebaseWithEventName( topControllerName , eventName: "ViewItem" , parameter: parms )
        elDebugPrint(topControllerName)
        
    }
    
    class func trackBannerClicked ( brandName : String = "" , _ cateName : String = "" , _  subcateName : String = "" , link : BannerCampaign , possition : String ) {
  
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            var nextscreenName = ""
            if brandName.count > 0 {
                nextscreenName =   "Brand_" + brandName
            }else if cateName.count > 0 && subcateName.count > 0  {
                nextscreenName =   "Cat_" + cateName +  "/" + subcateName
            }else if cateName.count > 0   {
                nextscreenName =   "Cat_" + cateName
            }
            var parms =  [FireBaseParmName.CurrentScreen.rawValue :   topControllerName , FireBaseParmName.NextScreen.rawValue : nextscreenName , FireBaseParmName.BrandName.rawValue : brandName , FireBaseParmName.CategoryName.rawValue : cateName , FireBaseParmName.SubCategoryName.rawValue : subcateName]
            let eventName =  FireBaseElgrocerPrefix + "BannerClick"
            parms[FireBaseParmName.CampaignId.rawValue] = link.dbId.stringValue
            parms[FireBaseParmName.CampaignName.rawValue] = link.title
            parms[FireBaseParmName.Position.rawValue] = possition
            if link.campaignType.intValue == BannerCampaignType.priority.rawValue {
                parms[FireBaseParmName.BannerType.rawValue] = "PriorityStore"
            }
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: eventName , parameter: parms )
            elDebugPrint(topControllerName)
        }
        
    }
    
    
    
    class func trackBrandBanner (isSingle : Bool ,   brandName : String = "" , _ cateName : String = "" , _  subcateName : String = "" , link : BannerLink , possition : String ) {
        
//        guard brandName.count > 0 || cateName.count > 0 || subcateName.count > 0 else {
//            return
//        }
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            
            var nextscreenName = ""
            if brandName.count > 0 {
              nextscreenName =   "Brand_" + brandName
            }else if cateName.count > 0 && subcateName.count > 0  {
                nextscreenName =   "Cat_" + cateName +  "/" + subcateName
            }else if cateName.count > 0   {
                nextscreenName =   "Cat_" + cateName
            }
            
             var parms =  [FireBaseParmName.CurrentScreen.rawValue :   topControllerName , FireBaseParmName.NextScreen.rawValue : nextscreenName , FireBaseParmName.BrandName.rawValue : brandName , FireBaseParmName.CategoryName.rawValue : cateName , FireBaseParmName.SubCategoryName.rawValue : subcateName]
            
            
            var eventName =  FireBaseElgrocerPrefix +  (isSingle ? "BannerSingle" : "BannerMulti")
            if link.isDeals {
                eventName =  FireBaseElgrocerPrefix +  FireBaseParmName.DealsClick.rawValue
            }
            
            parms[FireBaseParmName.CampaignId.rawValue] = link.bannerLinkId.stringValue
            parms[FireBaseParmName.CampaignName.rawValue] = link.bannerLinkTitle
            parms[FireBaseParmName.Position.rawValue] = possition
            
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: eventName , parameter: parms )
            elDebugPrint(topControllerName)
        }
        
    }
    
    class func trackBannerView (isSingle : Bool ,   brandName : String , _ cateName : String = "" , _  subcateName : String = "" , link : BannerLink? , _ bannerCampaign : BannerCampaign? = nil , _ isStoryly : Bool = false , _ deepLink : String = "") {
        
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            
            var parms =  [FireBaseParmName.CurrentScreen.rawValue :  topControllerName  , FireBaseParmName.BrandName.rawValue : brandName , FireBaseParmName.CategoryName.rawValue : cateName , FireBaseParmName.SubCategoryName.rawValue : subcateName , "Type" : (isSingle ? "Single" : "Multi") ]
            var eventName = FireBaseEventsName.BannerView.rawValue
            if link != nil {
                if link!.isDeals {
                    eventName = FireBaseEventsName.DealsView.rawValue
                }
                parms[FireBaseParmName.CampaignId.rawValue] = link!.bannerLinkId.stringValue
                parms[FireBaseParmName.CampaignName.rawValue] = link!.bannerLinkTitle
            }else{
                parms[FireBaseParmName.CampaignId.rawValue] = bannerCampaign?.dbId.stringValue ?? ""
                parms[FireBaseParmName.CampaignName.rawValue] = bannerCampaign?.title ?? ""
            }
            
            if bannerCampaign?.campaignType.intValue == BannerCampaignType.priority.rawValue {
                parms[FireBaseParmName.BannerType.rawValue] = "PriorityStore"
                
            }
            
            parms [FireBaseParmName.Storyly.rawValue] = isStoryly ? "1" : "0"
            parms [FireBaseParmName.StorylyDeepLink.rawValue] = deepLink
            
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix +  eventName , parameter: parms )
                //  elDebugPrint(topControllerName)
                //  elDebugPrint("EventName = \(FireBaseElgrocerPrefix +  eventName)")
        }
        
    }
    
    /*
    class func trackBannerView (isSingle : Bool ,   brandName : String , _ cateName : String = "" , _  subcateName : String = "" , link : BannerLink? , _ bannerCampaign : BannerCampaign? = nil) {
        
//        guard brandName.count > 0 || cateName.count > 0 || subcateName.count > 0 else {
//            return
//        }
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            
//            var nextscreenName = ""
//            if brandName.count > 0 {
//                nextscreenName =   "Brand_" + brandName
//            }else if cateName.count > 0 && subcateName.count > 0  {
//                nextscreenName =   "Cat_" + cateName +  "/" + subcateName
//            }else if cateName.count > 0   {
//                nextscreenName =   "Cat_" + cateName
//            }
            //FireBaseParmName.NextScreen.rawValue : nextscreenName
            
              var parms =  [FireBaseParmName.CurrentScreen.rawValue :  topControllerName  , FireBaseParmName.BrandName.rawValue : brandName , FireBaseParmName.CategoryName.rawValue : cateName , FireBaseParmName.SubCategoryName.rawValue : subcateName , "Type" : (isSingle ? "Single" : "Multi") ]
            var eventName = FireBaseEventsName.BannerView.rawValue
            if link != nil {
                if link!.isDeals {
                    eventName = FireBaseEventsName.DealsView.rawValue
                }
                parms[FireBaseParmName.CampaignId.rawValue] = link!.bannerLinkId.stringValue
                parms[FireBaseParmName.CampaignName.rawValue] = link!.bannerLinkTitle
            }else{
                parms[FireBaseParmName.CampaignId.rawValue] = bannerCampaign?.dbId.stringValue ?? ""
                parms[FireBaseParmName.CampaignName.rawValue] = bannerCampaign?.title ?? ""
            }
           
            
     
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix +  eventName , parameter: parms )
          //  elDebugPrint(topControllerName)
          //  elDebugPrint("EventName = \(FireBaseElgrocerPrefix +  eventName)")
        }
        
    }
    */
    
    
    class func trackCustomEvent (eventType : String ,   action : String , _ parms : [String : Any] = [:] , _ isNeedToGetTop : Bool = true) {
        
        var finalParms = parms
        if isNeedToGetTop {
            if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
                let parmsScreen =  [FireBaseParmName.CurrentScreen.rawValue :  topControllerName  , "eventType" : eventType , "action" : action ]
                parmsScreen.forEach { finalParms[$0] = $1 }
                FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix +  FireBaseEventsName.CustomEvent.rawValue , parameter: finalParms )
                elDebugPrint(topControllerName)
            }
            
        }else{
            let parmsScreen =  ["eventType" : eventType , "action" : action ]
            parmsScreen.forEach { finalParms[$0] = $1 }
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix +  FireBaseEventsName.CustomEvent.rawValue , parameter: finalParms )
        }
        
    }
    
    
   

    
    //MARK:-  Category screen Events
    
    
    class func trackCategoryClicked ( _  nextscreenName : String , lastScreen : String  , categoryName : String , subcategoryName : String , ViewType : String ) {
        
        
        FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: FireBaseElgrocerPrefix + FireBaseEventsName.Navigation.rawValue , parameter: [FireBaseParmName.CurrentScreen.rawValue : lastScreen  , FireBaseParmName.NextScreen.rawValue : nextscreenName , FireBaseParmName.Category.rawValue : categoryName  , FireBaseParmName.SubCategory.rawValue : subcategoryName , FireBaseParmName.ViewType.rawValue : ViewType  ])
        
        
    //    FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + eventName , parameter: [ FireBaseParmName.CurrentScreen.rawValue : lastScreen   , FireBaseParmName.NextScreen.rawValue : categoryName ] )
        
    }
    
    
    
    //MARK:-  Sub- Category screen Events
    
    
    class func trackSubCategoryClicked ( _  categoryName : String , subCateGoryName : String) {
        
        FireBaseEventsLogger.logEventToFirebaseWithEventName( categoryName  , eventName: subCateGoryName , parameter: nil )
        
    }
    
    // expect to have #SubcategoryName# - #BrandName#
    class func trackSubCategoryBrandClicked ( _  categoryName : String , brandName : String , subCateName : String) {
        
        FireBaseEventsLogger.logEventToFirebaseWithEventName( ""  , eventName: FireBaseElgrocerPrefix + brandName , parameter: [FireBaseParmName.CategoryName.rawValue : categoryName , FireBaseParmName.SubCategoryName.rawValue : subCateName] )
        
    }
    
    class func trackSearchClicked (_ screenName : String? =  FireBaseEventsLogger.gettopViewControllerName() ) {
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.Search.rawValue  , parameter: [ FireBaseParmName.CurrentScreen.rawValue :  (screenName != nil ? screenName! :  topControllerName)] )
            elDebugPrint(topControllerName)
            
        }
        
    }
    
    class func trackListView (isListView : Bool , categoryName : String , subcateName :  String ,  lastScreen: String ) {
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            ElGrocerEventsLogger.sharedInstance.trackCategoryClicked(topControllerName, lastScreen: lastScreen , categoryName: categoryName, subcategoryName: subcateName, ViewType: isListView ? "ListView" : "BrandView")
        }
    }
    
    class func trackBrandNameClicked (brandName : String , eventName : String ) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
             FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + eventName  , parameter: [ FireBaseParmName.CurrentScreen.rawValue :  topControllerName , FireBaseParmName.NextScreen.rawValue :  "Brand_" + brandName ] )
        }
    }

    // MARK:-  MyBasket
    
    class func trackClearBasket () {
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "ClearBasket" , parameter: [ FireBaseParmName.CurrentScreen.rawValue :  topControllerName ]  )
            elDebugPrint(topControllerName)
        }
        
    }
    
    class func trackCheckOut ( eventName : String ,  coupon : String , currency : String , value : Double , isEdit : Bool = false ) {
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + eventName , parameter:  [ FireBaseParmName.CurrentScreen.rawValue :  topControllerName , FireBaseParmName.NextScreen.rawValue : FireBaseEventsName.CheckOut.rawValue + (UserDefaults.isOrderInEdit() ? "Edited" : "") ] )
            elDebugPrint(topControllerName)
        }
        
        FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: AnalyticsEventBeginCheckout, parameter: [AnalyticsParameterCoupon: ""  , AnalyticsParameterCurrency: currency , AnalyticsParameterValue : value ] )
        
    }
    
    class func trackCheckOutTime ( eventName : String  ) {
        FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: FireBaseElgrocerPrefix + eventName , parameter: [FireBaseParmName.Date.rawValue : Date.dataInGST(Date())])
        
         FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: FireBaseElgrocerPrefix + "CheckoutComplete" , parameter: [ "Success" : true])
        
        
         FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: FireBaseElgrocerPrefix + "CheckoutTime" , parameter: [FireBaseParmName.Date.rawValue : Date.dataInGST(Date())])
        
        
    }
    
    
    // MARK:-  MultiSearch edit
    
    class func trackMultiSearchEditClick (_ parms : [String : Any]) {
        
        var finalParms = parms
        finalParms  [ FireBaseParmName.CurrentScreen.rawValue ] = FireBaseScreenName.MultiSearch.rawValue
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "EditMultiSearch" , parameter: finalParms )
    
    }
    
     // MARK:-  Placeorder screen
    
    class func trackPaymentMethod (_ isCash  : Bool , _ isCreditCard : Bool = false) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            
            var name = ( isCash ? "PayCash" : "PayCardOnDelivery")
            if isCreditCard {
                name = "PayCreditCard"
            }
            
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + name , parameter:  [ FireBaseParmName.CurrentScreen.rawValue :  topControllerName ] )
            elDebugPrint(topControllerName)
        }
    }
    
    
    
    
    class func trackPromoCode (_ code  : String) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "PromoCode" , parameter: ["Name" : code , FireBaseParmName.CurrentScreen.rawValue :  topControllerName  ] )
            elDebugPrint(topControllerName)
        }
    }
    
    
    class func trackScheduleOrder () {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "ScheduleOrder" , parameter: [ FireBaseParmName.CurrentScreen.rawValue :  topControllerName  ] )
            elDebugPrint(topControllerName)
        }
    }
    
    
    class func addPaymentInfo (_ info : String) {
         FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: AnalyticsEventAddPaymentInfo , parameter: [ AnalyticsParameterItemName : info ] )
    }
    
    
    
    //Mark:- OrderConfirmationViewController
    class func trackEditOrder (_ orderID : String) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "EditOrder" , parameter: ["orderID" : orderID , FireBaseParmName.CurrentScreen.rawValue :  topControllerName ] )
            elDebugPrint(topControllerName)
        }
    }
    
    class func chatWithPickerClicked(orderId: String, pickerID: String, orderStatusId: String, eventName: String) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: eventName , parameter: [FireBaseParmName.OrderId.rawValue : orderId , FireBaseParmName.PickerID.rawValue :  pickerID , FireBaseParmName.OrderStatusID.rawValue : orderStatusId ] )
            elDebugPrint(topControllerName)
        }
    }
    
    class func chatWithSupportClicked(orderId: String, eventName: String) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: eventName , parameter: [FireBaseParmName.OrderId.rawValue : orderId ] )
            elDebugPrint(topControllerName)
        }
    }
    
    
    //Mark:- login
    
    class func trackSignOut (_ isSuccess : Bool) {
        
        
        
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName:FireBaseElgrocerPrefix +  "SignOut" , parameter: [FireBaseParmName.CurrentScreen.rawValue :  topControllerName , "IsSuccess" : isSuccess ? "Success" : "Cancel" ] )
            elDebugPrint(topControllerName)
        }
    }
    
    
    class func trackAbove18 (_ isAbove : Bool) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName:FireBaseElgrocerPrefix +  "AgeConfirmation" , parameter: [FireBaseParmName.CurrentScreen.rawValue :  topControllerName  , "Above18" : isAbove ] )
            elDebugPrint(topControllerName)
        }
    }
  
    class func trackSignIn () {
        
         UserDefaults.setOver18(UserDefaults.isUserOver18())
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName:FireBaseElgrocerPrefix +  "SignIn" , parameter: [FireBaseParmName.CurrentScreen.rawValue :  topControllerName ] )
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: AnalyticsEventLogin , parameter: nil )
            elDebugPrint(topControllerName)
        }
        
        
    }
    
    
    
    
    
    class func trackCreateAccountClicked (_ eventName : String) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix +  eventName , parameter: [FireBaseParmName.CurrentScreen.rawValue :  topControllerName ] )
            elDebugPrint(topControllerName)
        }
    }
    
    class func trackForgotPasswordClicked () {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "ForgotPassword" , parameter: [FireBaseParmName.CurrentScreen.rawValue :  topControllerName ] )
            elDebugPrint(topControllerName)
        }
    }
    //Mark:- Search
    
    class func trackSearch (_ searchTerm : String , topControllerName : String = FireBaseEventsName.Search.rawValue , isFromUniversalSearch : Bool = false ) {
        
        let parms =  [AnalyticsParameterSearchTerm :  searchTerm , AnalyticsParameterStartDate : "\(Date())"]
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: AnalyticsEventSearch , parameter: parms)
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: AnalyticsEventViewSearchResults , parameter: parms)
        var currentScreenName =  FireBaseEventsName.Search.rawValue + "_" +  topControllerName
        if topControllerName == FireBaseEventsName.Search.rawValue {
            currentScreenName = FireBaseEventsName.Search.rawValue  + "_" + "Main"
        }
        let finalParms =  [FireBaseParmName.CurrentScreen.rawValue : currentScreenName  ,  FireBaseParmName.SearchTerm.rawValue :  searchTerm , "SearchDate" : "\(Date())" , "isUniversal" : isFromUniversalSearch ? "1" : "0" ]
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.Search.rawValue , parameter: finalParms )// EG_Search_Go
            elDebugPrint(topControllerName)
        
    }
    
    
    class func trackRetailerSearch (_ searchTerm : String , topControllerName : String = FireBaseEventsName.Search.rawValue , isFromUniversalSearch : Bool = false, retailId : String? ) {
        
        let parms =  [AnalyticsParameterSearchTerm :  searchTerm , AnalyticsParameterStartDate : "\(Date())"]
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: AnalyticsEventSearch , parameter: parms)
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: AnalyticsEventViewSearchResults , parameter: parms)
        var currentScreenName =  FireBaseEventsName.Search.rawValue + "_" +  topControllerName
        if topControllerName == FireBaseEventsName.Search.rawValue {
            currentScreenName = FireBaseEventsName.Search.rawValue  + "_" + "Main"
        }
        
        let finalParms =  [FireBaseParmName.CurrentScreen.rawValue : currentScreenName  ,  FireBaseParmName.SearchTerm.rawValue :  searchTerm , "SearchDate" : "\(Date())" , "isUniversal" : isFromUniversalSearch ? "1" : "0" , FireBaseParmName.StoreSearch.rawValue : (retailId != nil) ] as [String : Any]
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.Search.rawValue , parameter: finalParms )// EG_Search_Go
        elDebugPrint(topControllerName)
        
    }
    
    
    class func trackRecipeSearch (_ searchTerm : String) {
        
        
        
        let parms =  [AnalyticsParameterSearchTerm :  searchTerm , AnalyticsParameterStartDate : "\(Date())"]
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: AnalyticsEventSearch , parameter: parms)
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            var finalParms =  [FireBaseParmName.SearchTerm.rawValue :  searchTerm , "SearchDate" : "\(Date())"]
            finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseEventsName.Search.rawValue + "_" + topControllerName
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.Search.rawValue , parameter: finalParms )// EG_Search_Go
            elDebugPrint(topControllerName)
        }
        
        
    }
    
    
    
    class func trackRecipeDetailNav (_ chefName : String , recipeName : String , eventName : String ) {
    
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            let finalParms =  [FireBaseParmName.CurrentScreen.rawValue : topControllerName , FireBaseParmName.NextScreen.rawValue : "Chef " + chefName + " " +  recipeName  , FireBaseParmName.ChefName.rawValue :  chefName , FireBaseParmName.RecipeName.rawValue :  recipeName ]
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + eventName  , parameter: finalParms )// EG_Search_Go
            elDebugPrint(topControllerName)
        }
        
    }
    
    
    
     //Mark:- CreateAccount
    
    
    class func trackRegisteration () {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "Register" , parameter: [FireBaseParmName.CurrentScreen.rawValue :  topControllerName ] )
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: AnalyticsEventSignUp , parameter: nil )
            elDebugPrint(topControllerName)
        }
    }
    
    class func trackLoginClickedOnCreateAccountController () {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( topControllerName , eventName:FireBaseElgrocerPrefix + "Login" , parameter: [FireBaseParmName.CurrentScreen.rawValue :  topControllerName ] )
            elDebugPrint(topControllerName)
        }
    }
    
    
    class func trackViewItem (_ product : Product ) {
        
        let productID = Product.getCleanProductId(fromId: product.dbID)
        
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: AnalyticsEventViewItem , parameter: [AnalyticsParameterItemID : productID ,  AnalyticsParameterCoupon: "" , AnalyticsParameterCurrency: kProductCurrencyEngAEDName , AnalyticsParameterShipping: product.price ] )
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            
            let cleanProductID = Product.getCleanProductId(fromId: product.dbID)
            var brandName : String = product.brandName ?? ""
            var categoryName : String =  product.categoryName ?? ""
            var subCategoryName : String =  product.subcategoryName ?? ""
            let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
            if currentLang == "ar" {
                brandName =  product.brandNameEn ?? ""
                categoryName =   product.categoryNameEn ?? ""
                subCategoryName = product.subcategoryNameEn ?? ""
            }
            var quantity = 1
            let shoppingBasketItem = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: ElGrocerUtility.sharedInstance.activeGrocery , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if let item = shoppingBasketItem {
                quantity = item.count.intValue
            }
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "ViewItem" + (UserDefaults.isOrderInEdit() ? "Edited" : "") , parameter: ["ProductId" : cleanProductID, FireBaseParmName.ProductName.rawValue :  product.nameEn ?? product.name ?? "" , FireBaseParmName.BrandName.rawValue : brandName , FireBaseParmName.CategoryName.rawValue : categoryName , FireBaseParmName.SubCategoryName.rawValue : subCategoryName , FireBaseParmName.CurrentScreen.rawValue :  topControllerName , AnalyticsParameterCurrency.capitalized: kProductCurrencyEngAEDName, FireBaseParmName.ItemPrice.rawValue : product.price , AnalyticsParameterQuantity.capitalized: quantity , FireBaseParmName.ItemId.rawValue : cleanProductID  , FireBaseParmName.IsSponsored.rawValue : product.isSponsored ?? NSNumber(integerLiteral: 0) , FireBaseParmName.ItemSize.rawValue : product.descr ?? "" , FireBaseParmName.isPromotion.rawValue : product.isPromotion] )
        }
        
    }
  
    class func trackPurchase ( coupon : String , coupanValue : String , currency : String , value : String , tax : NSNumber , shipping : NSNumber , transactionID : String , PurchasedItems : [[String : Any]]? , discount : Double, IsSmiles: Bool, smilePoints: Int, pointsEarned: Int, pointsBurned: Int ) {
        
        
        func json(from object:Any) -> String {
            guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
                return "[]"
            }
            return String(data: data, encoding: String.Encoding.utf8) ?? "[]"
        }
        

        let parms = [
            AnalyticsParameterDiscount : discount ,
            AnalyticsParameterCoupon: coupon ,
            AnalyticsParameterCurrency: currency ,
            AnalyticsParameterShipping: shipping ,
            AnalyticsParameterTax: tax ,
            AnalyticsParameterTransactionID: transactionID ,
            AnalyticsParameterValue: Double(value) ?? 0,
            ] as [String : Any]
        
        FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: AnalyticsEventPurchase, parameter:parms)
        
            if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
                let finalParms = [
                    FireBaseParmName.OrderDiscount.rawValue : discount ,
                    AnalyticsParameterDiscount.capitalized : discount ,
                    AnalyticsParameterCoupon.capitalized: coupon ,
                    AnalyticsParameterCoupon.capitalized + "Value": coupanValue ,
                    AnalyticsParameterCurrency.capitalized: currency ,
                    AnalyticsParameterShipping.capitalized: shipping ,
                    AnalyticsParameterTax.capitalized: tax ,
                    AnalyticsParameterTransactionID.capitalized: transactionID ,
                    AnalyticsParameterValue.capitalized: value, FireBaseParmName.CurrentScreen.rawValue : topControllerName , "PurchasedItems" : json(from: PurchasedItems ?? "[]"),
                    SmilesEventsParmName.IsSmile.rawValue: IsSmiles,
                    SmilesEventsParmName.Points.rawValue: smilePoints,
                    SmilesEventsParmName.SmilesPointsEarned.rawValue: pointsEarned,
                    SmilesEventsParmName.SmilesPointsSpent.rawValue: pointsBurned
                    ] as [String : Any]
                FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "PurchaseOrder" + (UserDefaults.isOrderInEdit() ? "Edited" : "")  , parameter: finalParms)
            }

        
    }
    
    
    class func trackFirstOrder (_ order : Order) {
   
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            let finalParms = [
                AnalyticsParameterCoupon.capitalized: order.promoCode?.code ?? "" ,
                AnalyticsParameterCoupon.capitalized + "Value": order.promoCode?.valueCents ?? "" ,
                AnalyticsParameterCurrency.capitalized: kProductCurrencyEngAEDName ,
                AnalyticsParameterShipping.capitalized: order.grocery.vat ,
                AnalyticsParameterTax.capitalized: order.grocery.vat ,
                AnalyticsParameterTransactionID.capitalized: order.dbID.stringValue ,
                AnalyticsParameterValue.capitalized : order.totalValue , FireBaseParmName.CurrentScreen.rawValue : topControllerName
            ] as [String : Any]
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "FirstOrder" , parameter: finalParms)
        }
    }
    
    class func trackPurchaseItems (  productList : [Product] , orderId : String , carosalA : [Product] = []  , grocerID : String , eventName : String) {
        
        
            let getSponseredList = UserDefaults.getSponsoredItemArray(grocerID: grocerID) ?? []
            
            for product in productList {
                let cleanProductID = Product.getCleanProductId(fromId: product.dbID)
                let filterA = carosalA.filter {
                    product.dbID == $0.dbID
                }
                let isCarosal = filterA.count > 0
                let isSponsered = getSponseredList.filter { (dbid) -> Bool in "\(cleanProductID)"  == dbid }.count > 0
                var brandName : String = product.brandName ?? ""
                var categoryName : String =  product.categoryName ?? ""
                var subCategoryName : String =  product.subcategoryName ?? ""
                let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
                if currentLang == "ar" {
                    brandName =  product.brandNameEn ?? ""
                    categoryName =   product.categoryNameEn ?? ""
                    subCategoryName = product.subcategoryNameEn ?? ""
                }
                let productName = product.nameEn ?? product.name ?? "No Name"
                //ecommernce event
                var quantity = 1
                let shoppingBasketItem = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: ElGrocerUtility.sharedInstance.activeGrocery , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                if let item = shoppingBasketItem {
                    quantity = item.count.intValue
                }
                
                let deepLinkProducts = BrandUserDefaults.getAddItemProduct()
                //App event
                for _ in 1...quantity {
                    if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
                        var discountValue = 0.0
                        if let productPromo = product.promoPrice {
                            if productPromo.intValue > 0 {
                                discountValue = product.price.doubleValue - productPromo.doubleValue
                            }
                        }
                        
                        var deepLink = ""
                        if let dataDict = deepLinkProducts as? [String : String] {
                            deepLink = dataDict[product.dbID] ?? ""
                        }
                        
                        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix  + eventName + (UserDefaults.isOrderInEdit() ? "Edited" : ""  )  , parameter: [FireBaseParmName.ProductName.rawValue :  productName , FireBaseParmName.BrandName.rawValue : brandName , FireBaseParmName.CategoryName.rawValue : categoryName , FireBaseParmName.SubCategoryName.rawValue : subCategoryName  , FireBaseParmName.CurrentScreen.rawValue : topControllerName , AnalyticsParameterCurrency.capitalized: kProductCurrencyEngAEDName, FireBaseParmName.ItemPrice.rawValue : product.price , AnalyticsParameterQuantity.capitalized: 1 , FireBaseParmName.ItemId.rawValue : cleanProductID  , FireBaseParmName.IsSponsored.rawValue : isSponsered , FireBaseParmName.ItemSize.rawValue : product.descr ?? "" ,  FireBaseParmName.OrderId.rawValue : orderId  , FireBaseParmName.isCarousel.rawValue : isCarosal , FireBaseParmName.ItemDiscount.rawValue : discountValue , FireBaseParmName.isPromotion.rawValue : discountValue > 0 ? true : false , FireBaseParmName.DeepLink.rawValue : deepLink ])
                    }
                }
                
            }
        
              BrandUserDefaults.removedProductsAddItemFromDeepLink()
           // UserDefaults.removeSponseredItemArray(grocerID: grocerID) // removing sponserd list at time of final order

    }
    
    //MARK:- Extra Recipe
    class func trackChefFromRecipe (_ chefName : String , eventName : String ) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + eventName , parameter: [FireBaseParmName.CurrentScreen.rawValue :  topControllerName , FireBaseParmName.NextScreen.rawValue : "Chef " + chefName ]  )
            elDebugPrint(topControllerName)
        }
        
    }
    class func trackRecipeCatNav (catName : String , eventName : String) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + eventName  , parameter: [FireBaseParmName.CurrentScreen.rawValue :  topControllerName , FireBaseParmName.NextScreen.rawValue : "Recipe_Cat_" + catName , FireBaseParmName.CategoryName.rawValue : catName]  )
            elDebugPrint(topControllerName)
        }
    }
    
    class func trackAddRecipe () {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "AddRecipe"  , parameter: [FireBaseParmName.CurrentScreen.rawValue :  topControllerName ]  )
            
            elDebugPrint(topControllerName)
        }
    }
    
    
    
    class func trackRecipeShare ( recipeName : String , recipeID : String) {
        
        let parms = [AnalyticsParameterContentType : recipeName , AnalyticsParameterItemID : recipeID]
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: AnalyticsEventShare  , parameter: parms )

        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            let finalParms = [AnalyticsParameterContentType.capitalized : recipeName , AnalyticsParameterItemID.capitalized : recipeID , FireBaseParmName.CurrentScreen.rawValue :  topControllerName]
            
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "Share"  , parameter: finalParms )
            elDebugPrint(topControllerName)
        }
    }
    
    class func trackViewOrder(_ parm : [String : Any]? = nil) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            var finalParms = parm
            finalParms?[FireBaseParmName.CurrentScreen.rawValue] = topControllerName
            finalParms?[FireBaseParmName.NextScreen.rawValue] = FireBaseScreenName.ViewOrder.rawValue
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix +  FireBaseEventsName.Navigation.rawValue  , parameter: finalParms  )
            elDebugPrint(topControllerName)
        }
    }
    
    class func trackEditOrder(_ parm : [String : Any]? = nil) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            var finalParms = parm
            finalParms?[FireBaseParmName.CurrentScreen.rawValue] = topControllerName
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName:FireBaseElgrocerPrefix +  "EditOrder"  , parameter: finalParms )
            elDebugPrint(topControllerName)
        }
    }
    
    class func trackReOrder(_ parm : [String : Any]? = nil) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            var finalParms = parm
            finalParms?[FireBaseParmName.CurrentScreen.rawValue] = topControllerName
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix +  "ReOrder"  , parameter: finalParms )
            elDebugPrint(topControllerName)
        }
    }
    
    class func trackChangeOrderSlot(_ parm : [String : Any]? = nil) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            var finalParms = parm
            finalParms?[FireBaseParmName.CurrentScreen.rawValue] = topControllerName
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "ChangeOrderSlot"  , parameter: finalParms )
            elDebugPrint(topControllerName)
        }
    }
    
    //MARK:- Setting screen
    
    class func trackSettingClicked(_ eventAction : String , eventName : String) {
   
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + eventName  , parameter: [FireBaseParmName.CurrentScreen.rawValue : (eventAction == "TermsConditions" ||  eventAction == "PrivacyPolicy") ? topControllerName :  FireBaseScreenName.Profile.rawValue , FireBaseParmName.NextScreen.rawValue : eventAction] )
            elDebugPrint(topControllerName)
        }
    }
    
    class func trackRecipeViewAllClickedFromNewGeneric(_ eventname : String , source : String) {
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + eventname , parameter: [FireBaseParmName.CurrentScreen.rawValue : FireBaseEventsLogger.gettopViewControllerName() ??  "UnKnown" , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.Recipes.rawValue , FireBaseParmName.Source.rawValue : source] )
    }
    
    
    class func trackScreenNav(_ navName : String ,  _ parms :  [String : String]? = nil) {
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: navName  , parameter: parms )
        
    }
    
    
    //MARK:- DetectLocation screen
    
    class func trackDetectMyLocationClicked(_ name : String) {
        //"AutoDetect"
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName:  name   , parameter: [FireBaseParmName.CurrentScreen.rawValue : topControllerName]  )
            elDebugPrint(topControllerName) // eg_detectlocation_detect_my_location
        }
    }
    
    /*
    class func trackDetectMyLocationClicked() {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName:   "AutoDetect"  , parameter: [FireBaseParmName.CurrentScreen.rawValue : topControllerName]  )
            elDebugPrint(topControllerName) // eg_detectlocation_detect_my_location
        }
    }
    */
    
    class func trackDetectManuallySelectLocationClicked(_ name : String) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName:  name  , parameter: [FireBaseParmName.CurrentScreen.rawValue : topControllerName]  )
            elDebugPrint(topControllerName)
        }
    }
    
    
    
//    class func trackDetectManuallySelectLocationClicked() {
//        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
//            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName:  "ManualSelect"  , parameter: [FireBaseParmName.CurrentScreen.rawValue : topControllerName]  )
//            elDebugPrint(topControllerName)
//        }
//    }
    
    
    //  NotificationEnable and NotificationLater
    //MARK:- Notifcation screen
    
    
    class func trackNotificationEnableClicked() {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "NotificationEnable"  , parameter: [FireBaseParmName.CurrentScreen.rawValue : topControllerName] )
            elDebugPrint(topControllerName) // eg_detectlocation_detect_my_location
        }
    }
    class func trackNotificationLaterClicked() {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + "NotificationLater"  , parameter: [ FireBaseParmName.CurrentScreen.rawValue : topControllerName ] )
            elDebugPrint(topControllerName) // eg_detectlocation_detect_my_location
        }
    }
    
    
    //MARK:- select location screen
    class func trackSelectLocationEvents(_ eventName : String , params :  [String : Any]? = nil) {
        var finalParms = params
        finalParms?[FireBaseParmName.CurrentScreen.rawValue] = FireBaseScreenName.Map.rawValue
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseScreenName.Map.rawValue + FireBaseScreenName.Search.rawValue   , parameter: finalParms )
    }
    
    
    //MARK:- ChangePassword screen
    class func trackChangePasswordEvents(_ eventName : String , params :  [String : Any]? = nil) {
        var finalParms = params
        finalParms?[FireBaseParmName.CurrentScreen.rawValue] = FireBaseScreenName.ChangePassword.rawValue
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + eventName  , parameter: finalParms )
    }
    
    //MARK:- Changelangauge screen
    class func trackChangeLanguageEvents(_ eventName : String , params :  [String : Any]? = nil) {
        var finalParms = params
        finalParms?[FireBaseParmName.CurrentScreen.rawValue] = FireBaseScreenName.ChangeLanguage.rawValue
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseScreenName.ChangeLanguage.rawValue + "_" + eventName.capitalized  , parameter: finalParms )
    }
    
    //MARK:- Cancel screen
    class func trackCancelEvents( eventName : String , screenName : String , params :  [String : Any]? = nil) {
        var finalParms = params
        finalParms?[FireBaseParmName.CurrentScreen.rawValue] = screenName
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + eventName  , parameter: finalParms )
    }
    
    
    //MARK:- Substitutions screen
    class func trackSubstitutionsEvents(_ eventName : String , params :  [String : Any]? = nil) {
        var finalParms = params
        finalParms?[FireBaseParmName.CurrentScreen.rawValue] = FireBaseScreenName.Substitutions.rawValue
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix  + FireBaseScreenName.Substitutions.rawValue  + eventName  , parameter: finalParms )
    }
    //MARK:- Subsitution confirmation screen
    class func trackSubstitutionConfirmationEvents(_ eventName : String , params :  [String : Any]? = nil) {
        var finalParms = params
        finalParms?[FireBaseParmName.CurrentScreen.rawValue] = FireBaseScreenName.SubstitutionConfirmation.rawValue
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix  +  eventName  , parameter:  finalParms  )
    }
    
    //MARK:- review screen
    class func trackReviewEvents(screenName : String ,  eventName : String , params :  [String : Any]? = nil) {
        let finalScreenName = "Feedback" + "_" + screenName.capitalized
        var finalParms = params
        finalParms?[FireBaseParmName.CurrentScreen.rawValue] = finalScreenName
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: eventName  , parameter: finalParms )
    }
    
    
    //MARK:- PopUp screen
    
    class func trackMessageEvents( message : String , params :  [String : Any]? = nil) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            let finalParms = [FireBaseParmName.CurrentScreen.rawValue : topControllerName ,  FireBaseEventsName.PopUp.rawValue :  message]
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.PopUp.rawValue  , parameter: finalParms )
        }
    }
    
    
    class func trackOTPEvents( event : String ) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            let finalParms = [FireBaseParmName.CurrentScreen.rawValue : topControllerName]
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + event  , parameter: finalParms )
        }
    }
     //MARK:- New Home Generic Events
    
    class func trackGenricHomeView( params :  [String : Any]? = nil ) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            var finalParms = params
            finalParms?[FireBaseParmName.CurrentScreen.rawValue] = topControllerName
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseScreenName.GenericHome.rawValue + "View"  , parameter: finalParms )
        }
    }

    class func trackChangeLocationFromHome( oldLocationID : String , oldLocationName : String , oldlocationLat : Double ,  oldlocationLng : Double , newLocation : DeliveryAddress? ) {
        guard  newLocation != nil else {return}
        guard (oldlocationLat != newLocation?.latitude) , (oldlocationLng != newLocation?.longitude) else {return}
        guard (oldlocationLat != 0) , (oldlocationLng != 0)  , (newLocation?.latitude != 0) , (newLocation?.longitude != 0) else {return}
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.LocationId.rawValue] = newLocation?.dbID.count ?? 0 > 0 ? newLocation?.dbID : "1"
        finalParms[FireBaseParmName.LocationName.rawValue] = newLocation?.locationName
        finalParms[FireBaseParmName.OldLocationId.rawValue] = oldLocationID.count > 0 ? oldLocationID : "1"
        finalParms[FireBaseParmName.OldLocationName.rawValue] = oldLocationName
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseScreenName.GenericHome.rawValue
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseParmName.LocationChange.rawValue  , parameter: finalParms )
    }

    class func trackHomeTileClicked(tileId : String , tileName : String , tileType : String , nextScreen : UIViewController?) {
    
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.HomeTileId.rawValue] = tileId
        finalParms[FireBaseParmName.HomeTileType.rawValue] = tileType
        finalParms[FireBaseParmName.HomeTileName.rawValue] = tileName
        finalParms[FireBaseParmName.CurrentScreen.rawValue] =  UIApplication.gettopViewControllerName()
        
        if let nextScreen = nextScreen {
            finalParms[FireBaseParmName.NextScreen.rawValue] = UIApplication.gettopViewControllerName(nextScreen)
        }

        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.HomeTileClicked.rawValue  , parameter: finalParms )
    }
    
    class func trackHomeTileView(tileId : String , tileName : String , tileType : String) {
        
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.HomeTileId.rawValue] = tileId
        finalParms[FireBaseParmName.HomeTileType.rawValue] = tileType
        finalParms[FireBaseParmName.HomeTileName.rawValue] = tileName
        finalParms[FireBaseParmName.CurrentScreen.rawValue] =  UIApplication.gettopViewControllerName()
        
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.HomeTileView.rawValue  , parameter: finalParms )
    }
    
    
    class func trackNoPriorityStore() {

        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseParmName.NoPriorityStore.rawValue, parameter: [:] )
    }
    
    class func trackStoreCategoryFilter(  catID : String , catName : String , possition : String   ,   newLocation : DeliveryAddress  ) {
    
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.StoreCategoryID.rawValue] = catID
        finalParms[FireBaseParmName.StoreCategoryName.rawValue] = catName
        finalParms[FireBaseParmName.Position.rawValue] = possition
        finalParms[FireBaseParmName.LocationId.rawValue] = newLocation.dbID.count > 0 ? newLocation.dbID : "1"
        finalParms[FireBaseParmName.LocationName.rawValue] = newLocation.locationName
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseScreenName.GenericHome.rawValue
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseParmName.StoreCategoryFilter.rawValue  , parameter: finalParms )
    }
    
    class func trackStoreListingRows(  NumberOfRow : String , NumberOfRetailers : String , StoreCategoryID : String  , StoreCategoryName : String  ,   newLocation : DeliveryAddress  ) {
        
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.NumberOfRow.rawValue] = NumberOfRow
        finalParms[FireBaseParmName.NumberOfRetailers.rawValue] = NumberOfRetailers
        finalParms[FireBaseParmName.StoreCategoryID.rawValue] = StoreCategoryID
        finalParms[FireBaseParmName.StoreCategoryName.rawValue] = StoreCategoryName.count > 0 ? StoreCategoryName : "All Stores"
        finalParms[FireBaseParmName.LocationId.rawValue] = newLocation.dbID.count > 0 ? newLocation.dbID : "1"
        finalParms[FireBaseParmName.LocationName.rawValue] = newLocation.locationName
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseScreenName.GenericHome.rawValue
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.StoreListingRows.rawValue  , parameter: finalParms )
    }
    
    class func trackStoreListingStoreClick(  OldStoreID : String ,  OldStoreName : String , NumberOfItemsOldStore : String , Position : String ,  RowView : String  , NumberOfRetailers : String , StoreCategoryID : String  , StoreCategoryName : String  ) {
        
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.OldStoreID.rawValue] = OldStoreID
        finalParms[FireBaseParmName.OldStoreName.rawValue] = OldStoreName
        finalParms[FireBaseParmName.NumberOfItemsOldStore.rawValue] = NumberOfItemsOldStore
        finalParms[FireBaseParmName.Position.rawValue] = Position
        finalParms[FireBaseParmName.RowView.rawValue] = RowView
        finalParms[FireBaseParmName.NumberOfRetailers.rawValue] = NumberOfRetailers
        finalParms[FireBaseParmName.StoreCategoryID.rawValue] = StoreCategoryID
        finalParms[FireBaseParmName.StoreCategoryName.rawValue] = StoreCategoryName.count > 0 ? StoreCategoryName : "All Stores"

        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseScreenName.GenericHome.rawValue

        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.StoreListingStoreClick.rawValue  , parameter: finalParms )
    }
    
    
    class func trackStoreListingOneCategoryFilter(   StoreCategoryID : String  , StoreCategoryName : String ,  lastStoreCategoryID : String  , lastStoreCategoryName : String ) {
        
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.StoreCategoryID.rawValue] = StoreCategoryID
        finalParms[FireBaseParmName.StoreCategoryName.rawValue] = StoreCategoryName.count > 0 ? StoreCategoryName : "All Stores"
        
        finalParms[FireBaseParmName.LastStoreCategoryID.rawValue] = lastStoreCategoryID
        finalParms[FireBaseParmName.LastStoreCategoryName.rawValue] = lastStoreCategoryName.count > 0 ? lastStoreCategoryName : "All Stores"
        
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = UIApplication.gettopViewControllerName()
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.StoreListingOneCategoryFilter.rawValue  , parameter: finalParms )
    }
    
    
    class func trackStoreListing(_ listA : [Grocery]) {
        
        
        var StoreIDs = [String]()
        //var StoreNames = [String]()
        var ParentIDs = [String]()
        var ZoneIDs = [String]()
        for data in listA {
            StoreIDs.append(data.dbID)
           // StoreNames.append(data.name ?? "")
            ParentIDs.append(data.parentID.stringValue)
            ZoneIDs.append(data.deliveryZoneId ?? "0")
        }
        
        var finalParms = [String:Any]()
        
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseScreenName.GenericHome.rawValue
        finalParms["StoreIDs"] = StoreIDs.map { String(describing: $0) }.joined(separator: ",")
       // finalParms["StoreNames"] = StoreNames
        finalParms["ParentIDs"] = ParentIDs.map { String(describing: $0) }.joined(separator: ",")
        finalParms["ZoneIDs"] = ZoneIDs.map { String(describing: $0) }.joined(separator: ",")
        
        
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.StoreListingStores.rawValue  , parameter: finalParms )
    }
    
    
    class func trackStoreListingNoStores() {
        
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseScreenName.GenericHome.rawValue
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.StoreListingNoStores.rawValue  , parameter: finalParms )
    }
    
    class func trackNoBanners() {
        
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseScreenName.GenericHome.rawValue
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.NoBanners.rawValue  , parameter: finalParms )
    }
    
    //EG_NoDeals
    class func trackNoDeals() {
        
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseScreenName.GenericHome.rawValue
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.NoDeals.rawValue  , parameter: finalParms )
    }
    
    class func trackNavHomeClick (oldScreen : String , newScreen : String ) {
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseScreenName.GenericHome.rawValue
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.NoDeals.rawValue  , parameter: finalParms )
    
    }
    
    class func trackNavStoreClick ( ) {
        let eventName = "EG_" + "NavStoreClick"
        if let topVC = UIApplication.topViewController() {
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: eventName , parameter: ["clickedEvent" : "fromTabBar" ,  FireBaseParmName.CurrentScreen.rawValue : (FireBaseEventsLogger.gettopViewControllerName(topVC) ?? ""), FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.MyBasket.rawValue ])
        }
    }
    
    class func trackNoRecipe() {
        
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseScreenName.GenericHome.rawValue
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.NoRecipe.rawValue  , parameter: finalParms )
    }
    
    
    
    class func trackRecipeView(recipe : Recipe , source : String) {
        
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.Source.rawValue] = source
        finalParms[FireBaseParmName.recipeId.rawValue] = recipe.recipeID
        finalParms[FireBaseParmName.RecipeName.rawValue] = recipe.recipeName
        finalParms[FireBaseParmName.RecipeChefid.rawValue] = recipe.recipeChef?.chefID
        finalParms[FireBaseParmName.RecipeChefname.rawValue] = recipe.recipeChef?.chefName
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseEventsLogger.gettopViewControllerName()
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.ViewRecipe.rawValue  , parameter: finalParms )
    }
    
    class func trackRecipeClick(recipe : Recipe) {
        
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.recipeId.rawValue] = recipe.recipeID
        finalParms[FireBaseParmName.RecipeIngredientid.rawValue] = recipe.recipeName
        finalParms[FireBaseParmName.RecipeChefid.rawValue] = recipe.recipeChef?.chefID
        finalParms[FireBaseParmName.RecipeChefname.rawValue] = recipe.recipeChef?.chefName
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseEventsLogger.gettopViewControllerName()
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.RecipeClick.rawValue  , parameter: finalParms )
    }
    
    
    class func trackRecipeFilterClick(chef : CHEF ,  source : String) {
        
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.Source.rawValue] = source
        finalParms[FireBaseParmName.RecipeChefid.rawValue] = chef.chefID
        finalParms[FireBaseParmName.RecipeChefname.rawValue] = chef.chefName
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseEventsLogger.gettopViewControllerName()
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.RecipeFilterClick.rawValue  , parameter: finalParms )
    }
    
    class func trackOrderStatusCardView (orderId : String ,  statusID : String) {
        
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.statusId.rawValue] = statusID
        finalParms[FireBaseParmName.OrderId.rawValue] = orderId
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseEventsLogger.gettopViewControllerName()
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.OrderStatusCardView.rawValue  , parameter: finalParms )
        
    }
    
    
    class func OrderStatusCardClick (orderId : String ,  statusID : String) {
        
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.statusId.rawValue] = statusID
        finalParms[FireBaseParmName.OrderId.rawValue] = orderId
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseEventsLogger.gettopViewControllerName()
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.OrderStatusCardClick.rawValue  , parameter: finalParms )
        
    }
    
    class func trackOrderTrackingClick (orderId : String ,  statusID : String) {
        
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.statusId.rawValue] = statusID
        finalParms[FireBaseParmName.OrderId.rawValue] = orderId
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseEventsLogger.gettopViewControllerName()
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.OrderTrackingClick.rawValue  , parameter: finalParms )
        
    }
    
    
    class func trackInventoryReach ( product : Product, isCarousel : Bool = false) {
        
        let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let defaultAddressId = currentAddress?.dbID ?? ""
        let cleanProductID = Product.getCleanProductId(fromId: product.dbID)
        var brandName : String = product.brandNameEn ?? product.brandName ?? ""
        var categoryName : String =  product.categoryNameEn ?? product.categoryName ?? ""
        var subCategoryName : String =  product.subcategoryNameEn ?? product.subcategoryName ?? ""
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        
        if currentLang == "ar" {
            brandName =  product.brandNameEn ?? ""
            categoryName =   product.categoryNameEn ?? ""
            subCategoryName = product.subcategoryNameEn ?? ""
        }
        
        let productName = product.nameEn ?? product.name ?? "No Name"

        let quantity = 1
        
            //App event
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.InventoryReach.rawValue + (UserDefaults.isOrderInEdit() ? "Edited" : "")  , parameter: [FireBaseParmName.ProductName.rawValue :  productName , FireBaseParmName.BrandName.rawValue : brandName , FireBaseParmName.CategoryName.rawValue : categoryName , FireBaseParmName.SubCategoryName.rawValue : subCategoryName  , FireBaseParmName.CurrentScreen.rawValue : topControllerName , AnalyticsParameterCurrency.capitalized: kProductCurrencyEngAEDName, FireBaseParmName.ItemPrice.rawValue : product.price , AnalyticsParameterQuantity.capitalized: quantity , FireBaseParmName.ItemId.rawValue : cleanProductID  , FireBaseParmName.IsSponsored.rawValue : product.isSponsored ?? NSNumber(integerLiteral: 0) , FireBaseParmName.ItemSize.rawValue : product.descr ?? "" , FireBaseParmName.isPromotion.rawValue : product.promotion?.boolValue ?? false  , FireBaseParmName.isCarousel.rawValue : isCarousel , FireBaseParmName.AvailableQuantity.rawValue : product.availableQuantity.intValue   ])
            
        }
        
        
    }
    
    //
    
    
    class func trackLimitedStockItems ( product : Product) {
        
        let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let defaultAddressId = currentAddress?.dbID ?? ""
        let cleanProductID = Product.getCleanProductId(fromId: product.dbID)
        var brandName : String = product.brandNameEn ?? product.brandName ?? ""
        var categoryName : String =  product.categoryNameEn ?? product.categoryName ?? ""
        var subCategoryName : String =  product.subcategoryNameEn ?? product.subcategoryName ?? ""
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        
        if currentLang == "ar" {
            brandName =  product.brandNameEn ?? ""
            categoryName =   product.categoryNameEn ?? ""
            subCategoryName = product.subcategoryNameEn ?? ""
        }
        
        let productName = product.nameEn ?? product.name ?? "No Name"
        
        
            //ecommernce event
        let quantity = 1
        
            //App event
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.LimitedStockItems.rawValue + (UserDefaults.isOrderInEdit() ? "Edited" : "")  , parameter: [FireBaseParmName.ProductName.rawValue :  productName , FireBaseParmName.BrandName.rawValue : brandName , FireBaseParmName.CategoryName.rawValue : categoryName , FireBaseParmName.SubCategoryName.rawValue : subCategoryName  , FireBaseParmName.CurrentScreen.rawValue : topControllerName , AnalyticsParameterCurrency.capitalized: kProductCurrencyEngAEDName, FireBaseParmName.ItemPrice.rawValue : product.price , AnalyticsParameterQuantity.capitalized: quantity , FireBaseParmName.ItemId.rawValue : cleanProductID  , FireBaseParmName.IsSponsored.rawValue : product.isSponsored ?? NSNumber(integerLiteral: 0) , FireBaseParmName.ItemSize.rawValue : product.descr ?? "" , FireBaseParmName.isPromotion.rawValue : product.promotion?.boolValue ?? false , FireBaseParmName.AvailableQuantity.rawValue : product.availableQuantity.intValue  ])
            
        }
        
        
    }
    
    //
    
    
    class func trackAddItemFailure ( product : Product, reason : String) {
        
        let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let cleanProductID = Product.getCleanProductId(fromId: product.dbID)
        var brandName : String = product.brandNameEn ?? product.brandName ?? ""
        var categoryName : String =  product.categoryNameEn ?? product.categoryName ?? ""
        var subCategoryName : String =  product.subcategoryNameEn ?? product.subcategoryName ?? ""
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        
        if currentLang == "ar" {
            brandName =  product.brandNameEn ?? ""
            categoryName =   product.categoryNameEn ?? ""
            subCategoryName = product.subcategoryNameEn ?? ""
        }
        
        let productName = product.nameEn ?? product.name ?? "No Name"
        
        
            //ecommernce event
        let quantity = 1
        
            //App event
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.AddItemFailure.rawValue + (UserDefaults.isOrderInEdit() ? "Edited" : "")  , parameter: [FireBaseParmName.ProductName.rawValue :  productName , FireBaseParmName.BrandName.rawValue : brandName , FireBaseParmName.CategoryName.rawValue : categoryName , FireBaseParmName.SubCategoryName.rawValue : subCategoryName  , FireBaseParmName.CurrentScreen.rawValue : topControllerName , AnalyticsParameterCurrency.capitalized: kProductCurrencyEngAEDName, FireBaseParmName.ItemPrice.rawValue : product.price , AnalyticsParameterQuantity.capitalized: quantity , FireBaseParmName.ItemId.rawValue : cleanProductID  , FireBaseParmName.IsSponsored.rawValue : product.isSponsored ?? NSNumber(integerLiteral: 0) , FireBaseParmName.ItemSize.rawValue : product.descr ?? "" , FireBaseParmName.isPromotion.rawValue : product.promotion?.boolValue ?? false , FireBaseParmName.AvailableQuantity.rawValue : product.availableQuantity.intValue , FireBaseParmName.Reason.rawValue : reason  ])
            
        }
        
        
    }
    

        // //DeepLink2. BrnadID3. ProductID4. Type (Brand/ProductDeepLink)5. Index6. Source (Global / Store )7. AvailableStoreIds
    
    class func trackProductView ( product : Product, deepLink : String, position : Int , source : String , type : String) {
        
      //  let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let cleanProductID = Product.getCleanProductId(fromId: product.dbID)
        var brandName : String = product.brandNameEn ?? product.brandName ?? ""
        var categoryName : String =  product.categoryNameEn ?? product.categoryName ?? ""
        var subCategoryName : String =  product.subcategoryNameEn ?? product.subcategoryName ?? ""
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        let storeIds = product.shopIds?.filter({ storeId in
            return ElGrocerUtility.sharedInstance.groceries.contains { grocery in
                return grocery.getCleanGroceryID() == storeId.stringValue
            }
        })
        let storeIdString = ElGrocerUtility.sharedInstance.createAvailableStoreIdsString(grocaeryIdsArray: storeIds ?? [])
        if currentLang == "ar" {
            brandName =  product.brandNameEn ?? ""
            categoryName =   product.categoryNameEn ?? ""
            subCategoryName = product.subcategoryNameEn ?? ""
        }
        
        let productName = product.nameEn ?? product.name ?? "No Name"
        let brandId = product.brandId?.stringValue ?? ""
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            
            
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.ProductViewed.rawValue , parameter: [FireBaseParmName.ProductName.rawValue :  productName , FireBaseParmName.BrandName.rawValue : brandName, FireBaseParmName.CurrentScreen.rawValue : topControllerName , FireBaseParmName.ItemPrice.rawValue : product.price, FireBaseParmName.ItemId.rawValue : cleanProductID,  FireBaseParmName.ItemSize.rawValue : product.descr ?? "" , FireBaseParmName.isPromotion.rawValue : product.promotion?.boolValue ?? false , FireBaseParmName.AvailableQuantity.rawValue : product.availableQuantity.intValue , FireBaseParmName.DeepLink.rawValue : deepLink , FireBaseParmName.AvailableStoreIds.rawValue :  storeIdString, FireBaseParmName.Position.rawValue : position, FireBaseParmName.Source.rawValue : source, FireBaseParmName.ViewType.rawValue : type,FireBaseParmName.BrandId.rawValue: brandId])
            
        }
        
    }
    
    class func trackProductClicked ( product : Product, deepLink : String, position : Int , source : String , type : String) {
        
            //  let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let cleanProductID = Product.getCleanProductId(fromId: product.dbID)
        var brandName : String = product.brandNameEn ?? product.brandName ?? ""
        var categoryName : String =  product.categoryNameEn ?? product.categoryName ?? ""
        var subCategoryName : String =  product.subcategoryNameEn ?? product.subcategoryName ?? ""
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        let storeIds = product.shopIds?.filter({ storeId in
            return ElGrocerUtility.sharedInstance.groceries.contains { grocery in
                return grocery.getCleanGroceryID() == storeId.stringValue
            }
        })
        let storeIdString = ElGrocerUtility.sharedInstance.createAvailableStoreIdsString(grocaeryIdsArray: storeIds ?? [])
        if currentLang == "ar" {
            brandName =  product.brandNameEn ?? ""
            categoryName =   product.categoryNameEn ?? ""
            subCategoryName = product.subcategoryNameEn ?? ""
        }
        
        let productName = product.nameEn ?? product.name ?? "No Name"
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            
            
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.ProductClicked.rawValue , parameter: [FireBaseParmName.ProductName.rawValue :  productName , FireBaseParmName.BrandName.rawValue : brandName, FireBaseParmName.CurrentScreen.rawValue : topControllerName , FireBaseParmName.ItemPrice.rawValue : product.price, FireBaseParmName.ItemId.rawValue : cleanProductID,  FireBaseParmName.ItemSize.rawValue : product.descr ?? "" , FireBaseParmName.isPromotion.rawValue : product.promotion?.boolValue ?? false , FireBaseParmName.AvailableQuantity.rawValue : product.availableQuantity.intValue , FireBaseParmName.DeepLink.rawValue : deepLink , FireBaseParmName.AvailableStoreIds.rawValue :  storeIdString, FireBaseParmName.Position.rawValue : position, FireBaseParmName.Source.rawValue : source, FireBaseParmName.ViewType.rawValue : type ])
            
        }
        
    }
    
    
   // ProductStoreListViewed
    
    class func trackProductStoreListViewed (store: Grocery, product : Product, deepLink : String, position : Int , source : String , type : String) {
        
        let cleanProductID = Product.getCleanProductId(fromId: product.dbID)
        let productName = product.nameEn ?? product.name ?? "No Name"
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            
            
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.ProductStoreListViewed.rawValue , parameter:
                                                                    [FireBaseParmName.ProductName.rawValue :  productName , FireBaseParmName.CurrentScreen.rawValue : topControllerName, FireBaseParmName.ItemPrice.rawValue : product.price, FireBaseParmName.ItemId.rawValue : cleanProductID,  FireBaseParmName.ItemSize.rawValue : product.descr ?? "" , FireBaseParmName.DeepLink.rawValue : deepLink , FireBaseParmName.StoreId.rawValue :  store.getCleanGroceryID(), FireBaseParmName.Position.rawValue : position, FireBaseParmName.Source.rawValue : source, FireBaseParmName.ViewType.rawValue : type ])
            
        }
        
    }
    
    //promo vc
    class func ApplyPromoClick (index : Int ,  code : String) {
        
        var finalParms = [String:Any]()
        finalParms[FireBaseParmName.PromoIndex.rawValue] = index
        finalParms[FireBaseParmName.PromoCode.rawValue] = code
        finalParms[FireBaseParmName.CurrentScreen.rawValue] = FireBaseEventsLogger.gettopViewControllerName()
        FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.PromoApplyClicked.rawValue  , parameter: finalParms )
        
    }

    //ProductStoreSelection
    
    class func trackProductStoreSelection (store: Grocery, product : Product, deepLink : String, position : Int , source : String , type : String) {
        
        let cleanProductID = Product.getCleanProductId(fromId: product.dbID)
        let productName = product.nameEn ?? product.name ?? "No Name"

        let storeIds = product.shopIds?.filter({ storeId in
            return ElGrocerUtility.sharedInstance.groceries.contains { grocery in
                return grocery.getCleanGroceryID() == storeId.stringValue
            }
        })
        let storeIdString = ElGrocerUtility.sharedInstance.createAvailableStoreIdsString(grocaeryIdsArray: storeIds ?? [])
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            
            
            FireBaseEventsLogger.logEventToFirebaseWithEventName( "" , eventName: FireBaseElgrocerPrefix + FireBaseEventsName.ProductStoreSelection.rawValue , parameter:
                                                                    [FireBaseParmName.ProductName.rawValue :  productName , FireBaseParmName.CurrentScreen.rawValue : topControllerName, FireBaseParmName.ItemPrice.rawValue : product.price, FireBaseParmName.ItemId.rawValue : cleanProductID,  FireBaseParmName.ItemSize.rawValue : product.descr ?? "" , FireBaseParmName.DeepLink.rawValue : deepLink , FireBaseParmName.StoreId.rawValue :  store.getCleanGroceryID(), FireBaseParmName.Position.rawValue : position, FireBaseParmName.Source.rawValue : source, FireBaseParmName.ViewType.rawValue : type, FireBaseParmName.SelectedStoreId.rawValue: store.getCleanGroceryID(),FireBaseParmName.AvailableStoreIds.rawValue: storeIdString ])
        }
        
    }

    //MARK:- Extra funcation
    class func concateName ( _ screenName : String , _ eventName : String) -> String{
        return screenName + "_" + eventName
    }
    
    class func gettopViewControllerName(_ controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> String? {
        
        if let navigationController = controller as? UINavigationController {
            return gettopViewControllerName(navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return gettopViewControllerName(selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return gettopViewControllerName(presented)
        }
        
        return FireBaseEventsLogger.getGivenControllerName(controller)
        
        
    }
    
    class func getGivenControllerName(_ controller : UIViewController?) -> String {
        
        //controller
        var title = ""
        
//        if controller is SpecialtyStoresGroceryViewController {
//            let vc = controller as! SpecialtyStoresGroceryViewController
//            //vc.title =
//            title = FireBaseScreenName.CheckOut.rawValue
//
//        }
//
        if controller is  ShopByCategoriesViewController {
            title = "CategoryListing_"
        }else if controller is SpecialtyStoresGroceryViewController {
            let vc = controller as! SpecialtyStoresGroceryViewController
             title = "StoreListing_" + vc.controllerTitle
        } else if controller is MyBasketPlaceOrderVC {
            title = FireBaseScreenName.CheckOut.rawValue
        } else if controller is OrderCancelationVC {
            title = FireBaseScreenName.CancelReason.rawValue
            
        } else if controller is RecipeDetailVC {
            title = FireBaseScreenName.RecipeDetail.rawValue
        } else if controller is GlobalSearchResultsViewController {
            title = FireBaseScreenName.GlobalSearchResults.rawValue
        } else if controller is GenericProfileViewController {
            title = FireBaseScreenName.Profile.rawValue
        }  else if controller is SplashAnimationViewController {
            title = FireBaseScreenName.GenericHome.rawValue
        }else if controller is GenericStoresViewController {
            title = FireBaseScreenName.GenericHome.rawValue
        } else if controller is GroceryLoaderViewController {
            title = FireBaseScreenName.Home.rawValue
        } else if controller is MainCategoriesViewController {
            title = FireBaseScreenName.Home.rawValue
        } else if controller is SearchViewController {
            let contr : SearchViewController = controller as! SearchViewController
            title = FireBaseScreenName.Search.rawValue + "_" +  contr.navigationFromControllerName
        } else if controller is SubCategoriesViewController {
            title = kGoogleAnalyticsSubcategoriesScreen
            let currentVC : SubCategoriesViewController = controller as! SubCategoriesViewController
            title = "Cat_" + (currentVC.viewHandler.getParentCategory()?.nameEn ?? "")
            title = title + "/" + (currentVC.viewHandler.getParentSubCategory()?.subCategoryNameEn ?? "All")
        } else if controller is BrandDetailsViewController {
            title = kGoogleAnalyticsBrandsScreen
            let currentVC : BrandDetailsViewController = controller as! BrandDetailsViewController
            title = "Brand_" + currentVC.brand.nameEn
        } else if controller is MyBasketViewController {
            title = FireBaseScreenName.MyBasket.rawValue + (UserDefaults.isOrderInEdit() ? "Edited" : "")
        } else if controller is ReplacementViewController {
            title = FireBaseScreenName.Replacement.rawValue
        } else if controller is GrocerySelectionViewController {
            title = FireBaseScreenName.ChangeStore.rawValue + FireBaseScreenName.Recipes.rawValue
        } else if controller is ShoppingListViewController {
            title = FireBaseScreenName.MultiSearch.rawValue
        } else if controller is BrowseViewController {
            title = FireBaseScreenName.Category.rawValue
        } else if controller is OrderConfirmationViewController {
            title = FireBaseScreenName.PurchaseOrder.rawValue
        } else if controller is SignInViewController {
            title = FireBaseScreenName.LogIn.rawValue
        } else if controller is RegistrationViewController {
            title = FireBaseScreenName.CreateAccount.rawValue
        } else if controller is RecipesListViewController {
            title = FireBaseScreenName.Recipes.rawValue
        } else if controller is OrdersViewController {
            title = FireBaseScreenName.MyOrders.rawValue
        } else if controller is OrderDetailsViewController {
            title = FireBaseScreenName.ViewOrder.rawValue
        } else if controller is DashboardLocationViewController {
            title = FireBaseScreenName.DashBoard.rawValue
        } else if controller is SettingViewController {
            title = FireBaseScreenName.Profile.rawValue
        } else if controller is EntryViewController {
            title = FireBaseScreenName.DetectLocation.rawValue
        } else if controller is ChangePasswordViewController {
            title = FireBaseScreenName.ChangePassword.rawValue
        } else if controller is LanguageViewController {
            title = FireBaseScreenName.ChangeLanguage.rawValue
        } else if controller is SubstitutionsProductViewController {
            title = FireBaseScreenName.Substitutions.rawValue
        } else if controller is SubtitutionBasketViewController {
            title = FireBaseScreenName.SubstitutionConfirmation.rawValue
        } else if controller is ReplacementViewController {
            title = FireBaseScreenName.Replacement.rawValue
        } else if controller is CodeVerificationViewController {
            title = FireBaseScreenName.OtpRequest.rawValue
        } else if controller is FilteredRecipeViewController {
            let currentVC : FilteredRecipeViewController = controller as! FilteredRecipeViewController
            if let chefName = currentVC.dataHandler.selectChef?.chefName {
                title = "Chef" + "_"  + chefName;
            }else{
                title =  controller?.title ?? String(describing: controller.self)
            }
        } else if controller is RecipeDetailViewController {
            let currentVC : RecipeDetailViewController = controller as! RecipeDetailViewController
            if let recipeName = currentVC.recipe?.recipeName, let chefName = currentVC.recipe?.recipeChef?.chefName  {
                title =  "Chef" + "_" + chefName + "_" +  recipeName
            }else{
                title =  controller?.title ?? String(describing: controller.self)
            }
            title = title.replacingOccurrences(of: " ", with: "_")
        } else if String(describing: controller?.classForCoder) == "STPopupContainerViewController"  {
            title = FireBaseScreenName.ProductDetailView.rawValue
        } else {
            if let contr = controller {
                title =  controller?.title ?? String(describing: contr.classForCoder)
            }else{
                title =   String(describing: controller.self)
            }
        }
        return title
        
        
    }
    
    
    class func getSourceName(_ controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> String? {
        
        if let navigationController = controller as? UINavigationController {
            return gettopViewControllerName(navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return gettopViewControllerName(selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return gettopViewControllerName(presented)
        }
        
        //controller
        var title = ""
        
         if controller is GenericProfileViewController {
            title = FireBaseScreenName.Profile.rawValue
        }  else if controller is GenericStoresViewController {
            title = FireBaseScreenName.GenericHome.rawValue
        }else if controller is GroceryLoaderViewController {
            title = FireBaseScreenName.Home.rawValue
        }else if controller is MainCategoriesViewController {
            title = FireBaseScreenName.Home.rawValue
        }else if controller is SearchViewController {
            let contr : SearchViewController = controller as! SearchViewController
            title = FireBaseScreenName.Search.rawValue + "_" +  contr.navigationFromControllerName
        }else if controller is UniversalSearchViewController {
            title = FireBaseScreenName.Search.rawValue
        }else if controller is SubCategoriesViewController {
            title = kGoogleAnalyticsSubcategoriesScreen
            let currentVC : SubCategoriesViewController = controller as! SubCategoriesViewController
            title = "Cat_" + (currentVC.viewHandler.getParentCategory()?.nameEn ?? "")
            title = title + "/" + (currentVC.viewHandler.getParentSubCategory()?.subCategoryNameEn ?? "")
        }else if controller is BrandDetailsViewController {
            title = kGoogleAnalyticsBrandsScreen
            let currentVC : BrandDetailsViewController = controller as! BrandDetailsViewController
            title = "Brand_" + currentVC.brand.nameEn
        }else if controller is MyBasketViewController {
            title = FireBaseScreenName.MyBasket.rawValue + (UserDefaults.isOrderInEdit() ? "Edited" : "")
        }else if controller is ReplacementViewController {
            title = FireBaseScreenName.Replacement.rawValue
        }else if controller is GrocerySelectionViewController {
            title = FireBaseScreenName.ChangeStore.rawValue + FireBaseScreenName.Recipes.rawValue
        }else if controller is ShoppingListViewController {
            title = FireBaseScreenName.MultiSearch.rawValue
        }else if controller is BrowseViewController {
            title = FireBaseScreenName.Category.rawValue
        } else if controller is OrderConfirmationViewController {
            title = FireBaseScreenName.PurchaseOrder.rawValue
        }else if controller is SignInViewController {
            title = FireBaseScreenName.LogIn.rawValue
        }else if controller is RegistrationViewController {
            title = FireBaseScreenName.CreateAccount.rawValue
        }else if controller is RecipesListViewController {
            title = FireBaseScreenName.Recipes.rawValue
        }else if controller is OrdersViewController {
            title = FireBaseScreenName.MyOrders.rawValue
        }else if controller is OrderDetailsViewController {
            title = FireBaseScreenName.ViewOrder.rawValue
        }else if controller is DashboardLocationViewController {
            title = FireBaseScreenName.DashBoard.rawValue
        }else if controller is SettingViewController {
            title = FireBaseScreenName.Profile.rawValue
        }else if controller is EntryViewController {
            title = FireBaseScreenName.DetectLocation.rawValue
        }else if controller is ChangePasswordViewController {
            title = FireBaseScreenName.ChangePassword.rawValue
        }else if controller is LanguageViewController {
            title = FireBaseScreenName.ChangeLanguage.rawValue
        }else if controller is SubstitutionsProductViewController {
            title = FireBaseScreenName.Substitutions.rawValue
        }else if controller is SubtitutionBasketViewController {
            title = FireBaseScreenName.SubstitutionConfirmation.rawValue
        }else if controller is ReplacementViewController {
            title = FireBaseScreenName.Replacement.rawValue
        }else if controller is CodeVerificationViewController {
            title = FireBaseScreenName.OtpRequest.rawValue
        }else if controller is FilteredRecipeViewController {
            let currentVC : FilteredRecipeViewController = controller as! FilteredRecipeViewController
            if let chefName = currentVC.dataHandler.selectChef?.chefName {
                title = "Chef" + "_"  + chefName;
            }else{
                title =  controller?.title ?? String(describing: controller.self)
            }
        }else if controller is RecipeDetailViewController {
            let currentVC : RecipeDetailViewController = controller as! RecipeDetailViewController
            if let recipeName = currentVC.recipe?.recipeName, let chefName = currentVC.recipe?.recipeChef?.chefName  {
                title =  "Chef" + "_" + chefName + "_" +  recipeName
            }else{
                title =  controller?.title ?? String(describing: controller.self)
            }
            title = title.replacingOccurrences(of: " ", with: "_")
        }else {
            if let contr = controller {
                title =  controller?.title ?? String(describing: contr.classForCoder)
            }else{
                title =   String(describing: controller.self)
            }
        }
        //  elDebugPrint("Controller is: \(title)")
        
        return title
        
        
    }
    
    public func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .main, closure: @escaping () -> Void) {
        let dispatchTime = DispatchTime.now() + seconds
        dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
    }
    
    public enum DispatchLevel {
        case main, userInteractive, userInitiated, utility, background
        var dispatchQueue: DispatchQueue {
            switch self {
                case .main:                 return DispatchQueue.main
                case .userInteractive:      return DispatchQueue.global(qos: .userInteractive)
                case .userInitiated:        return DispatchQueue.global(qos: .userInitiated)
                case .utility:              return DispatchQueue.global(qos: .utility)
                case .background:           return DispatchQueue.global(qos: .background)
            }
        }
    }
    
     
}

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
    
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}

extension NSError {
    
    func addItemsToUserInfo(newUserInfo: Dictionary<String, Any>) -> NSError {
        
        var currentUserInfo = userInfo
        newUserInfo.forEach { (key, value) in
            currentUserInfo[key] = value
        }
        return NSError(domain: domain, code: code, userInfo: currentUserInfo)
    }
}
