//
//  CleverTapEventsLogger.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 21/10/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import Foundation
import CleverTapSDK
import FirebaseAnalytics
class CleverTapEventsLogger  {
    
    public static var shared: CleverTapEventsLogger = CleverTapEventsLogger()
    var cleverTapApp : CleverTap? = nil
    class func getCTProfileId() -> String? {
        return CleverTapEventsLogger.shared.cleverTapApp?.profileGetAttributionIdentifier()
    }
    
    func startCleverTapSharedSDK () {
        
        let config = CleverTapInstanceConfig.init(accountId: "675-6KZ-RW6Z", accountToken: "136-5a6")
        let app = CleverTap.instance(with: config)
        app.enableDeviceNetworkInfoReporting(true)
        app.setInAppNotificationDelegate(sdkManager)
        self.cleverTapApp = app
    }
    
    
    
    class func startCleverTapSDK () {
    
        #if DEBUG
        CleverTap.setDebugLevel(CleverTapLogLevel.off.rawValue)
        #endif
        
        CleverTap.autoIntegrate()
        CleverTap.sharedInstance()?.enableDeviceNetworkInfoReporting(true)
        CleverTap.sharedInstance()?.setInAppNotificationDelegate(sdkManager)
        
    }
    
    class func registerFor(_ deviceToken: Data ) {
          CleverTapEventsLogger.shared.cleverTapApp?.setPushToken(deviceToken)
    }

    class func recordEvent(_ name : String , properties : [AnyHashable : Any]?) {
        

        if let dataToSend = properties {
            CleverTapEventsLogger.shared.cleverTapApp?.recordEvent(name, withProps: dataToSend)
        }else{
            CleverTapEventsLogger.shared.cleverTapApp?.recordEvent(name)
        }
        
        
        
       // elDebugPrint("*CleverTap Logs*  *EventName *: \(name)   * properties *: \(String(describing: properties))  *****")
    }
    class func recordScreenName(_ name : String) {
        CleverTapEventsLogger.shared.cleverTapApp?.recordScreenView(name)
    }
    
}
extension CleverTapEventsLogger {
    
    class func setUserProfile (_ profile : UserProfile) {
        
        var StoreIDs = [String]()
        //var StoreNames = [String]()
        var ParentIDs = [String]()
        var ZoneIDs = [String]()
        var retailerGroup_Ids = [String]()
        for data in ElGrocerUtility.sharedInstance.groceries {
            StoreIDs.append(data.dbID)
            // StoreNames.append(data.name ?? "")
            ParentIDs.append(data.parentID.stringValue)
            ZoneIDs.append(data.deliveryZoneId ?? "0")
            retailerGroup_Ids.append(data.groupId.stringValue)
        }
        
        MixpanelManager.setIdentity(profile.email, isSmile: sdkManager.isSmileSDK)
        
        let profile: Dictionary<String, Any> = [
            "Name": profile.name ?? "" ,
            "Email": profile.email ,
            "Phone": profile.phone ?? "" ,
            "Identity": profile.dbID,
            "StoreIDs" : StoreIDs,
            "ParentIDs" : ParentIDs,
            "ZoneIDs" : ZoneIDs,
            "retailerGroupIDs" : retailerGroup_Ids,
            "language" : UserDefaults.getCurrentLanguage() ?? "" ,
            "sessionId" : ElGrocerUtility.sharedInstance.getGenericSessionID(),
            "activeStoreId" : ElGrocerUtility.sharedInstance.activeGrocery?.dbID ?? "",
            FireBaseParmName.UserFrom.rawValue : sdkManager.isSmileSDK
        ]
        CleverTapEventsLogger.shared.cleverTapApp?.onUserLogin(profile)
        if StoreIDs.count > 0{
            CleverTapEventsLogger.shared.cleverTapApp?.profileAddMultiValues(StoreIDs, forKey: "StoreIDs")
        }
        if ParentIDs.count > 0 {
            CleverTapEventsLogger.shared.cleverTapApp?.profileAddMultiValues(ParentIDs, forKey: "ParentIDs")
        }
        if ZoneIDs.count > 0 {
            CleverTapEventsLogger.shared.cleverTapApp?.profileAddMultiValues(ZoneIDs, forKey: "ZoneIDs")
        }
        if retailerGroup_Ids.count > 0 {
            CleverTapEventsLogger.shared.cleverTapApp?.profileAddMultiValues(retailerGroup_Ids, forKey: "retailerGroupIDs")
        }
        
        
        
        
       // CleverTapEventsLogger.shared.cleverTapApp?.profilePush(profile)
    }
    
    class func setUserLocationName (_ locationName : String) {
        let profile: Dictionary<String, Any> = [
            "Location": locationName ]
        CleverTapEventsLogger.shared.cleverTapApp?.profilePush(profile)
       
    }
    
    
    class func pushMoreProfileData (_ data : Dictionary<String, Any>) {
        CleverTapEventsLogger.shared.cleverTapApp?.profilePush(data)
    }
    
    class func setUserLocationCoardinatedName (_ coordinate : CLLocationCoordinate2D ) {
        CleverTap.setLocation(coordinate)
    }
    
    
 
    class func setUserlocation (_ location : CLLocationCoordinate2D) {
       CleverTapEventsLogger.shared.cleverTapApp?.setLocation(location)
    }

    class func appLaunch (_ name : String) {
        CleverTapEventsLogger.recordEvent(  name , properties: nil)
        CleverTapEventsLogger.recordScreenName( name)
    }
    
    class func trackCreateAccountClicked (_ eventName : String) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            CleverTapEventsLogger.recordEvent(  eventName , properties: [FireBaseParmName.CurrentScreen.rawValue :  topControllerName ] )
        }
    }
    class func trackDetectMyLocationClicked(_ eventName : String) {
        //"AutoDetect"
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            CleverTapEventsLogger.recordEvent(  eventName , properties: [FireBaseParmName.CurrentScreen.rawValue :  topControllerName ] )
        }
    }
    class func trackDetectManuallySelectLocationClicked(_ eventName : String) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
           CleverTapEventsLogger.recordEvent(  eventName , properties: [FireBaseParmName.CurrentScreen.rawValue :  topControllerName ] )
        }
    }
    
    // Navigation events
    class func trackMyBasketClick (_ eventName : String) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
             CleverTapEventsLogger.recordEvent(  eventName , properties:  [FireBaseParmName.CurrentScreen.rawValue : topControllerName , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.MyBasket.rawValue + (UserDefaults.isOrderInEdit() ? "Edited" : "")  ] )
        }
    }
    
    class func trackRecipeBannerClick (_ eventName : String) {
         CleverTapEventsLogger.recordEvent(  eventName , properties:  [FireBaseParmName.CurrentScreen.rawValue : FireBaseScreenName.Home.rawValue , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.Recipes.rawValue  ] )
    }
    class func trackBrandNameClicked (brandName : String , eventName : String ) {
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
              CleverTapEventsLogger.recordEvent(  eventName , properties:   [ FireBaseParmName.CurrentScreen.rawValue :  topControllerName , FireBaseParmName.NextScreen.rawValue :  "Brand_" + brandName ]  )
        }
    }
    class func trackCheckOut ( eventName : String ,  coupon : String , currency : String , value : Double , isEdit : Bool = false ) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
             CleverTapEventsLogger.recordEvent(  eventName , properties:   [ FireBaseParmName.CurrentScreen.rawValue :  topControllerName , FireBaseParmName.NextScreen.rawValue : FireBaseEventsName.CheckOut.rawValue + (UserDefaults.isOrderInEdit() ? "Edited" : "") ]  )
        }
    }
    class func trackCheckOutTime ( eventName : String  ) {
        CleverTapEventsLogger.recordEvent(eventName , properties: [FireBaseParmName.Date.rawValue : Date.dataInGST(Date())])
    }
    class func trackSettingClicked(_ eventAction : String , eventName : String) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            CleverTapEventsLogger.recordEvent(eventName, properties:  [FireBaseParmName.CurrentScreen.rawValue : (eventAction == "TermsConditions" ||  eventAction == "PrivacyPolicy") ? topControllerName :  FireBaseScreenName.Profile.rawValue , FireBaseParmName.NextScreen.rawValue : eventAction])
        }
    }
    class func trackRecipeViewAllClickedFromNewGeneric(_ eventname : String ,  source : String) {
        CleverTapEventsLogger.recordEvent(eventname, properties: [FireBaseParmName.CurrentScreen.rawValue : FireBaseScreenName.GenericHome.rawValue , FireBaseParmName.NextScreen.rawValue : FireBaseScreenName.Recipes.rawValue])
    }
    class func trackScreenNav(_ navName : String ,  _ parms :  [String : String]? = nil) {
        CleverTapEventsLogger.recordEvent(navName, properties: parms)        
    }
    class func trackCategoryClicked ( _  categoryName : String , lastScreen : String , eventName : String ) {
         CleverTapEventsLogger.recordEvent(eventName, properties: [ FireBaseParmName.CurrentScreen.rawValue : lastScreen   , FireBaseParmName.NextScreen.rawValue : categoryName ])        
    }
    class func trackRecipeDetailNav (_ chefName : String , recipeName : String , eventName : String ) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            let finalParms =  [FireBaseParmName.CurrentScreen.rawValue : topControllerName , FireBaseParmName.NextScreen.rawValue : "Chef " + chefName + " " +  recipeName ]
             CleverTapEventsLogger.recordEvent(eventName, properties: finalParms)
        }
    }
    class func trackChefFromRecipe (_ chefName : String , eventName : String ) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
             CleverTapEventsLogger.recordEvent(eventName, properties: [FireBaseParmName.CurrentScreen.rawValue :  topControllerName , FireBaseParmName.NextScreen.rawValue : "Chef " + chefName , FireBaseParmName.ChefName.rawValue :  chefName ] )
        }
    }
    class func trackRecipeCatNav (catName : String , eventName : String) {
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
             CleverTapEventsLogger.recordEvent(eventName, properties: [FireBaseParmName.CurrentScreen.rawValue :  topControllerName , FireBaseParmName.NextScreen.rawValue : "Recipe_Cat_" + catName ]  )
        }
    }
    
    
    class func trackAddToProduct ( product : Product , _ recipeName : String = "" , _ chefName : String? = "" , isCarousel : Bool = false ,  eventName : String) {
      
        let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let defaultAddressId = currentAddress?.dbID ?? ""
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
        
        let productName = product.nameEn ?? product.name ?? "No Name"
    
        //ecommernce event
        let quantity = 1
        //App event
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            CleverTapEventsLogger.recordEvent(eventName + (UserDefaults.isOrderInEdit() ? "Edited" : ""), properties: [FireBaseParmName.ProductName.rawValue :  productName , FireBaseParmName.BrandName.rawValue : brandName , FireBaseParmName.CategoryName.rawValue : categoryName , FireBaseParmName.SubCategoryName.rawValue : subCategoryName , FireBaseParmName.RecipeName.rawValue : recipeName , FireBaseParmName.ChefName.rawValue : chefName ?? ""  , FireBaseParmName.CurrentScreen.rawValue : topControllerName , AnalyticsParameterCurrency.capitalized: kProductCurrencyEngAEDName, FireBaseParmName.ItemPrice.rawValue : product.price , AnalyticsParameterQuantity.capitalized: quantity , FireBaseParmName.ItemId.rawValue : cleanProductID  , FireBaseParmName.IsSponsored.rawValue : product.isSponsored ?? NSNumber(integerLiteral: 0) , FireBaseParmName.ItemSize.rawValue : product.descr ?? ""  , FireBaseParmName.isPromotion.rawValue : product.isPromotion  , FireBaseParmName.isCarousel.rawValue : isCarousel ])
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
            //App event
            for _ in 1...quantity {
                if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
                    
                    CleverTapEventsLogger.recordEvent(eventName + (UserDefaults.isOrderInEdit() ? "Edited" : ""  ) , properties: [FireBaseParmName.ProductName.rawValue :  productName , FireBaseParmName.BrandName.rawValue : brandName , FireBaseParmName.CategoryName.rawValue : categoryName , FireBaseParmName.SubCategoryName.rawValue : subCategoryName  , FireBaseParmName.CurrentScreen.rawValue : topControllerName , AnalyticsParameterCurrency.capitalized: kProductCurrencyEngAEDName, FireBaseParmName.ItemPrice.rawValue : product.price , AnalyticsParameterQuantity.capitalized: 1 , FireBaseParmName.ItemId.rawValue : cleanProductID  , FireBaseParmName.IsSponsored.rawValue : isSponsered , FireBaseParmName.ItemSize.rawValue : product.descr ?? ""  ,  FireBaseParmName.OrderId.rawValue : orderId , FireBaseParmName.isPromotion.rawValue : product.isPromotion , FireBaseParmName.isCarousel.rawValue : isCarosal ])
              
                }
            }
            
        }
        // removing sponserd list at time of final order
        
    }
    
    class func trackPurchase ( coupon : String , coupanValue : String , currency : String , value : String , tax : NSNumber , shipping : NSNumber , transactionID : String , PurchasedItems : [[String : Any]]? , eventName : String ) {
        
        
        if let topControllerName = FireBaseEventsLogger.gettopViewControllerName() {
            let finalParms = [
                AnalyticsParameterCoupon.capitalized: coupon ,
                AnalyticsParameterCoupon.capitalized + "Value": coupanValue ,
                AnalyticsParameterCurrency.capitalized: currency ,
                AnalyticsParameterShipping.capitalized: shipping ,
                AnalyticsParameterTax.capitalized: tax ,
                AnalyticsParameterTransactionID.capitalized: transactionID ,
                AnalyticsParameterValue.capitalized: value, FireBaseParmName.CurrentScreen.rawValue : topControllerName , "PurchasedItems" : PurchasedItems ?? []
                ] as [String : Any]
            
            CleverTapEventsLogger.recordEvent(eventName + (UserDefaults.isOrderInEdit() ? "Edited" : "") , properties: finalParms)
    
        }
        
    }
    
    
    
}
