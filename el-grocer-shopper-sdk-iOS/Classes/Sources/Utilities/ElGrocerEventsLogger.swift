//
//  ElGrocerEventsLogger.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 18/10/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import Foundation
import FirebaseCore
import MapKit
import FBSDKCoreKit
import CleverTapSDK
//import AppsFlyerLib
import FirebaseRemoteConfig

struct EventDestination {
    var name : String? = ""
    var mode  : Int = -1
}
extension EventDestination {
    init( dict : NSDictionary?){
        name = dict?["name"] as? String ?? ""
        mode = dict?["mode"] as? Int ?? -1
    }
}

struct EventConfigEntity {
    var egName : String?
    var facebook : EventDestination?
    var firebase : EventDestination?
    var appFlyer : EventDestination?
    var cleverTap : EventDestination
    var isMobile : Bool = false
}
extension EventConfigEntity {
    
    init( dict : Dictionary<String,Any>){
       
        egName = dict["eg_name"] as? String
        facebook = EventDestination.init(dict: dict["facebook"] as? NSDictionary)
        firebase = EventDestination.init(dict: dict["firebase"] as? NSDictionary)
        appFlyer = EventDestination.init(dict: dict["app_flyer"] as? NSDictionary)
        cleverTap = EventDestination.init(dict: dict["clever_tap"] as? NSDictionary)
        isMobile = dict["isMobile"] as? Bool ?? false
    }
}


public enum ElgrocerEventConfigs: String {
    
    case NAVIGATION = "Navigation"
    case ADD_ITEM  = "AddItem"
    case REMOVE_ITEM  = "RemoveItem"
    case VIEW_ITEM  = "ViewItem"
    case SEARCH  = "Search"
    case EDIT_SEARCH = "EditSearch"
    case PAY_CASH  = "PayCash"
    case PAY_CARD_ON_DELIVERY  = "PayCardOnDelivery"
    case PAY_CREDIT_CARD  = "PayCreditCard"
    case SCHEDULE_ORDER  = "ScheduleOrder"
    case PROMO_CODE  = "PromoCode"
    case PURCHASE_ORDER  = "PurchaseOrder"
    case PURCHASE_VALUE  = "PurchaseValue"
    case CHECKOUT_TIME  = "CheckoutTime"
    case CHECKOUT_COMPLETE  = "CheckoutComplete"  // need to discuss
    case PURCHASED_ITEM  = "PurchasedItem"
    case EDIT_ORDER  = "EditOrder"
    case SIGN_IN  = "SignIn"
    case CREATE_ACCOUNT  = "CreateAccount" // Done
    case FORGOT_PASSWORD  = "ForgotPassword"
    case FORGOT_PASSWORD_SUCCESS  = "ForgotPasswordSuccess"
    case REGISTER  = "Register"
    case LOGIN  = "Login"
    case VIEW_MORE  = "ViewMore"
    case EDIT_MULTI_SEARCH  = "EditMultiSearch"
    case MULTI_SEARCH  = "MultiSearch"
    case SHARE  = "Share"
    case ADD_RECIPE  = "AddRecipe"
    case REORDER  = "ReOrder"
    case CHANGE_ORDER  = "ChangeOrder"
    case SIGN_OUT  = "SignOut"
    case AUTO_DETECT  = "AutoDetect" // done
    case MANUAL_SELECT  = "ManualSelect" //done
    case CHANGE_PASSWORD  = "ChangePassword"
    case CHANGE_LANGUAGE  = "ChangeLanguage"
    case SELECT_LOCATION_SEARCH  = "SelectLocationSearch"
    case SELECT_LOCATION_CANCEL  = "SelectLocationCancel"
    case SELECT_LOCATION_CONFIRM  = "SelectLocationConfirm"
    case SUBSTITUTION_CANCEL_ORDER  = "SubstitutionCancelOrder"
    case SUBSTITUTION_SELECTED  = "SubstitutionSelected"
    case SUBSTITUTION_CONTINUE  = "SubstitutionContinue"
    case SEND_REPLACEMENT  = "SendReplacement"
    case ADD_RATING  = "AddRating"
    case ADD_COMMENT  = "AddComment"
    case LEAVE_FEEDBACK  = "LeaveFeedback"
    case MESSAGE  = "Message"
    case POP_UP_BUTTON_CLICKED  = "PopUpButtonClick"
    case OTP_CONFIRM  = "OtpConfirm"
    case OTP_RESEND  = "OtpResend"
    case CHECKOUT  = "Checkout"
    case CLEAR_BASKET  = "ClearBasket"
    case FIRST_SET_LOCATION  = "FirstSetLocation"
    case FIRST_OPEN  = "FirstOpen"
    case FIRST_STORE_SELECTED  = "FirstStoreSelected"
    case OPEN_LOCATION  = "OpenLocation"
    case BEGIN_CHECKOUT  = "BeginCheckout"
    case STORE_LISTING_NO_STORE  = "StoreListingNoStores"
    case DEALS_CLICK  = "DealsClick"
    case DEALS_VIEW  = "DealsView"
    case NO_BANNER  = "NoBanners"
    case NO_DEALS  = "NoDeals"
    case NAV_HOME  = "NavHomeClick"
    case NAV_PROFILE  = "NavProfileClick"
    case NAV_STORE_CATEGORY  = "NavStoreCategoryClick"
    case NAV_STORE  = "NavStoreClick"
    case NAV_STORE_SEARCH  = "NavStoreSearchClick"
    case RECIPE_CLICK  = "RecipeClick"
    case RECIPE_FILTER_CLICK  = "RecipeFilterClick"
    case NO_RECIPE = "NoRecipe"
    case HOME_VIEW = "HomeView"
    case BANNER_CLICKED = "BannerClick"
    case LOCATION_CHANGE = "LocationChange"
    case STORE_LISTING_ONE_CAT_FILTER = "StoreListingOneCategoryFilter"
    case STORE_CATEGORY_FILTER = "StoreCategoryFilter"
    case STORE_LISTING_ROWS = "StoreListingRows"
    case LOCATION_SELECTED = "LocationSelected"
    case STORE_SELECTED = "StoreSelected"
    case FIRST_ORDER = "FirstOrder"
    case ADD_ITEM_PREVIOUS  = "AddItemPrevious"
    case ADD_ITEM_STORE  = "AddItemStore"
    case ADD_ITEM_PREVIOUS_VIEW_MORE  = "AddItemPreviousViewMore"
    case ADD_ITEM_MULTI_SEARCH  = "AddItemMultiSearch"
    case ADD_ITEM_BRAND  = "AddItemBrand"
    case ADD_ITEM_BASKET_CAROUSEL  = "AddItemBasketCarousel"
    case ADD_ITEM_RECIPE  = "AddItemRecipe"
    case ADD_ITEM_SEARCH  = "AddItemSearch"
    case ADD_ITEM_CATEGORY  = "AddItemCategory"
    case ADD_ITEM_LANDING_PAGE  = "AddItemHomeLanding"
    case ADD_ITEM_SEARCH_LANDING_PAGE  = "AddItemSearchLanding"
    case ADD_ITEM_SPONSORED = "AddItemSponsored"
}

private let ElGrocerEventsLoggerSharedInstance = ElGrocerEventsLogger()
class ElGrocerEventsLogger  {

   static var PREF = "GROCER_EVENT_CONFIGS"
   static var GENERAL  = "General"
     var MODE_CUSTOM = 1
     var MODE_DEFAULT = 2
     var MODE_SYSTEM = 3
    
    var isNeedToByPassData = true // please dont change it. To change update event logger file.

    class var sharedInstance : ElGrocerEventsLogger {
        return ElGrocerEventsLoggerSharedInstance
    }
   
    let remoteConfig = RemoteConfig.remoteConfig()
    var settings : RemoteConfigSettings = {
        let remoteSetting =  RemoteConfigSettings()
        remoteSetting.minimumFetchInterval = 1
        return remoteSetting
    }()
    
    var configKey : String = {
        if Platform.isSimulator || Platform.isDebugBuild {
            return "logger_config"
        }else{
            return "logger_config"
        }
    }()
    
    
    var configKeyForChat : String = {
        if Platform.isSimulator || Platform.isDebugBuild {
            return "ChatConfig"
        }else{
            return "ChatConfig"
        }
    }()
    
    func confgiureEventLogger( _ completionHandler:@escaping (_ isInitilized:Bool) -> Void) {

        ElGrocerUtility.sharedInstance.isZenDesk = true
        remoteConfig.configSettings = settings
        remoteConfig.fetch() { (status, error) -> Void in
            
            var data : NSDictionary =  [ "isZenDesk" : 1  ]
            
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate { (data , error)  in debugPrint("remoteConfig")}
                let configureValues =  self.remoteConfig.configValue(forKey: self.configKeyForChat)
               
                if configureValues.jsonValue is NSArray {
                    let configV = configureValues.jsonValue as! NSArray
                    if let configdata  = configV[0] as? NSDictionary {
                        data = configdata
                    }
                   // ElGrocerUtility.sharedInstance.isZenDesk = ((data["isZenDesk"] as? Int) == 1)
                    completionHandler(true)
                }else {
                    //ElGrocerUtility.sharedInstance.isZenDesk = ((data["isZenDesk"] as? Int) == 1)
                    completionHandler( self.loadDataFromLocalFile())
                }
            } else {
                ElGrocerUtility.sharedInstance.delay(2) {
                    self.confgiureEventLogger(completionHandler)
                }
            }
        }
    }
    
    
    
    
    
    
    
    private func loadDataFromLocalFile() -> Bool {
        let fileName = "events"
        let fileType = "json"
        if let path = Bundle.resource.path(forResource: fileName, ofType: fileType ) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? NSArray{
                    self.prepareMap(data: jsonResult)
                    return true
                }else{self.isNeedToByPassData = true; print("local Config not fetched"); return false}
            } catch { self.isNeedToByPassData = true; print("localConfig not fetched") ; return false }
        }
        return false
    }
    
    
    private var mapA: Dictionary<String , EventConfigEntity> = [:]
    func prepareMap (data : NSArray) {
        var configs : Array<EventConfigEntity> = []
        for eventData in data {
            let enitity = EventConfigEntity.init(dict: eventData as! Dictionary<String, Any>)
            configs.append(enitity)
        }
        configs = configs.filter({ (it) -> Bool in
            return (it.isMobile && it.egName != nil)
        })
        for obj in configs {
            mapA[obj.egName ?? ""] = obj
        }
        self.isNeedToByPassData = false
          debugPrint("Map Done")
    }
    
    
    func facebook(egName: String) -> String? {
        
        
        
        if isNeedToByPassData  {
            return egName
        }
        let facebook = mapA[egName]?.facebook
        return (facebook?.mode == MODE_CUSTOM) ? facebook?.name : nil
    }
    
    func cleverTap(egName: String)  -> String? {
        if isNeedToByPassData  {
            return nil
        }
        let cleverTap = mapA[egName]?.cleverTap
        return (cleverTap?.mode == MODE_CUSTOM) ?  cleverTap?.name : nil
    }
    
    func firebase(egName: String)  -> String? {
        if isNeedToByPassData  {
            return egName
        }
        let firebase = mapA[egName]?.firebase
        return (firebase?.mode == MODE_CUSTOM) ? firebase?.name : nil
    }

}


extension  ElGrocerEventsLogger   {
    
 /*return order will be : (facebook , cleverTap , firebase)**/
    func WhichEventNeedToLog(egName : String ) -> (String? , String? , String?) {
        var facebook  , cleverTap  , firebase : String?
        facebook = ElGrocerEventsLogger.sharedInstance.facebook(egName: egName)
        cleverTap = ElGrocerEventsLogger.sharedInstance.cleverTap(egName: egName)
        firebase = ElGrocerEventsLogger.sharedInstance.firebase(egName: egName)
        return (facebook , cleverTap , firebase)
    }
    /*
     
     general rule maker
     
     let result = WhichEventNeedToLog(egName: ElgrocerEventConfigs.FIRST_OPEN.rawValue)
     let isfacebook = result.0
     var iscleverTap = result.1
            iscleverTap = nil
         iscleverTap = nil
     let isfirebase = result.2
     if isfacebook != nil { }
     if iscleverTap != nil {
    
     }
     if isfirebase != nil {
    
     }
     
     */
    
    func setUserProfile (_ userProfile : UserProfile , _ locationName : String? = nil) {
        CleverTapEventsLogger.setUserProfile(userProfile)
            // MARK:- TODO fixappsflyer
        //AppsFlyerLib.shared().customerUserID = CleverTap.sharedInstance()?.profileGetID()
        //ZohoChat.loginZohoWith(userProfile.dbID.stringValue)
        // PushWooshTracking.setUserID(userID: userProfile.dbID.stringValue)
        FireBaseEventsLogger.setUserID(userProfile.dbID.stringValue)
        if locationName != nil , locationName?.count ?? 0 > 0 {
            CleverTapEventsLogger.setUserLocationName(locationName ?? "")
        }
    }
    
    func updateUserLocation (currentAddress : DeliveryAddress , delAddress: DeliveryAddress ) {
    
        // PushWooshTracking.updateAreaWithCoordinates(currentAddress.latitude, longitude: currentAddress.longitude , delAddress: currentAddress)
        CleverTapEventsLogger.setUserlocation(CLLocationCoordinate2D(latitude: currentAddress.latitude , longitude: currentAddress.longitude))
    }
    
    //MARK:- Basic  events
    
    func firstOpen() {
        let result = WhichEventNeedToLog(egName: ElgrocerEventConfigs.FIRST_OPEN.rawValue)
        let isfacebook = result.0
//        var iscleverTap = result.1
//            iscleverTap = nil
        let isfirebase = result.2
        if isfacebook != nil { }
//        if iscleverTap != nil {
//            CleverTapEventsLogger.appLaunch(iscleverTap!)
//        }
        if isfirebase != nil {
            FireBaseEventsLogger.appLaunch(isfirebase!)
        }
    }
    
    
    //MARK:- Clicked Button events
    
    func trackCreateAccountClicked() {
        
        let result = WhichEventNeedToLog(egName: ElgrocerEventConfigs.CREATE_ACCOUNT.rawValue)
//        var iscleverTap = result.1
//            iscleverTap = nil
//         iscleverTap = nil
        let isfirebase = result.2
//        if iscleverTap != nil {
//            CleverTapEventsLogger.trackCreateAccountClicked(iscleverTap!)
//        }
        if isfirebase != nil {
            FireBaseEventsLogger.trackCreateAccountClicked(isfirebase!)
        }
    }
    
    func trackDetectMyLocationClicked() {
        let result = WhichEventNeedToLog(egName: ElgrocerEventConfigs.AUTO_DETECT.rawValue)
//        var iscleverTap = result.1
//            iscleverTap = nil
//         iscleverTap = nil
        let isfirebase = result.2
//        if iscleverTap != nil {
//            CleverTapEventsLogger.trackDetectMyLocationClicked(iscleverTap!)
//        }
        if isfirebase != nil {
            FireBaseEventsLogger.trackDetectMyLocationClicked(isfirebase!)
        }
    }
    
    func trackDetectManuallySelectLocationClicked() {
        let result = WhichEventNeedToLog(egName: ElgrocerEventConfigs.MANUAL_SELECT.rawValue)
        var iscleverTap = result.1
            iscleverTap = nil
//         iscleverTap = nil
        let isfirebase = result.2
        if iscleverTap != nil {
            CleverTapEventsLogger.trackDetectManuallySelectLocationClicked(iscleverTap!)
        }
        if isfirebase != nil {
            FireBaseEventsLogger.trackDetectManuallySelectLocationClicked(isfirebase!)
        }
    }
    
    
    //MARK:- Navigation events
    
     func trackMyBasketClick () {
        
        let eventName  =  FireBaseElgrocerPrefix +  FireBaseEventsName.Navigation.rawValue
        FireBaseEventsLogger.trackMyBasketClick(eventName)
    }
    
    
    
    func trackRecipeBannerClick () {
        
    
        let eventName  =  FireBaseElgrocerPrefix +  FireBaseEventsName.Navigation.rawValue
        FireBaseEventsLogger.trackRecipeBannerClick(eventName)
        GoogleAnalyticsHelper.trackRecipeBanerClickClick()
        
    }
    
    func trackBrandNameClicked (brandName : String  ) {
        FireBaseEventsLogger.trackBrandNameClicked(brandName: brandName , eventName: FireBaseElgrocerPrefix +  FireBaseEventsName.Navigation.rawValue)
    }
    
    
    func trackSettingClicked(_ eventAction : String) {
  
        let eventName  =  FireBaseElgrocerPrefix +  FireBaseEventsName.Navigation.rawValue
        FireBaseEventsLogger.trackSettingClicked(eventAction, eventName: eventName)
    }
    
    func chatWithPickerClicked(orderId: String , pickerID : String , orderStatusID : String){
        let event = FireBaseElgrocerPrefix + FireBaseEventsName.pickerChat.rawValue
        FireBaseEventsLogger.chatWithPickerClicked(orderId: orderId, pickerID: pickerID, orderStatusId: orderStatusID, eventName: event)
    }

    func chatWithSupportClicked(orderId: String){
        let event = FireBaseElgrocerPrefix + FireBaseEventsName.supportChat.rawValue
        FireBaseEventsLogger.chatWithSupportClicked(orderId: orderId, eventName: event)
    }

    
    func trackRecipeViewAllClickedFromNewGeneric( source : String) {
        let eventName  =   FireBaseEventsName.Navigation.rawValue
        FireBaseEventsLogger.trackRecipeViewAllClickedFromNewGeneric(eventName, source: source)
        //FireBaseEventsLogger.trackRecipeViewAllClickedFromNewGeneric(eventName , source)

    }
    
     func trackScreenNav(  _ parms :  [String : String]? = nil) {
        
        FireBaseEventsLogger.trackScreenNav(FireBaseElgrocerPrefix +  FireBaseEventsName.Navigation.rawValue , parms)
        
    }
    
    func trackCategoryClicked ( _  nextscreenName : String , lastScreen : String  , categoryName : String , subcategoryName : String , ViewType : String ) {
        
        
        FireBaseEventsLogger.trackCategoryClicked(nextscreenName, lastScreen: lastScreen , categoryName: categoryName, subcategoryName: subcategoryName, ViewType: ViewType)
        
    }
    
    func trackRecipeDetailNav (_ chefName : String , recipeName : String ) {
        
        
        FireBaseEventsLogger.trackRecipeDetailNav(chefName, recipeName: recipeName, eventName:   FireBaseEventsName.Navigation.rawValue)
    
    }
    
    func trackChefFromRecipe (_ chefName : String ) {
        
        
        FireBaseEventsLogger.trackChefFromRecipe(chefName , eventName : FireBaseElgrocerPrefix +  FireBaseEventsName.Navigation.rawValue)
        
    }
     func trackRecipeCatNav (catName : String) {
        
        FireBaseEventsLogger.trackRecipeCatNav(catName: catName , eventName :   FireBaseEventsName.Navigation.rawValue)

    }
    
    
    
    
    //MARK:- Ecommerence events
    
    func trackCheckOut ( coupon : String , currency : String , value : Double , isEdit : Bool = false , itemsCount : String , productIds : String , availablePayments : Bool = false , appFlayerJsonString : String  ) {
        
        let result = WhichEventNeedToLog(egName: ElgrocerEventConfigs.CHECKOUT.rawValue)
        let isfacebook = result.0
        var iscleverTap = result.1
            iscleverTap = nil
        let isfirebase = result.2
        if isfacebook != nil {
            AppEvents.logEvent(AppEvents.Name.initiatedCheckout, valueToSum: value)
        }
        if iscleverTap != nil {
            CleverTapEventsLogger.trackCheckOut( eventName : iscleverTap! , coupon: coupon, currency: currency, value: value, isEdit: isEdit)
        }
        if isfirebase != nil {
            FireBaseEventsLogger.trackCheckOut( eventName : isfirebase! , coupon: coupon, currency: currency, value: value, isEdit: isEdit)
        }
            // MARK:- TODO fixappsflyer
        
//        let param = [AFEventParamPrice: value , AFEventParamCurrency : kProductCurrencyEngAEDName , AFEventParamQuantity : itemsCount  , AFEventParamContentType : "product" , AFEventParamContentId : productIds , AFEventParamPaymentInfoAvailable : availablePayments  , AppEvents.ParameterName.content : appFlayerJsonString ] as! [String : Any]
//        AppsFlyerLib.shared().logEvent(name: AFEventInitiatedCheckout, values: param) { (data, error) in
//            debugPrint(data)
//        }
       // AppsFlyerLib.shared().trackEvent(AFEventInitiatedCheckout, withValues:param)
        
        
        let resultCheckOutTime = WhichEventNeedToLog(egName: ElgrocerEventConfigs.CHECKOUT_TIME.rawValue)
        let isfacebookC = resultCheckOutTime.0
        let iscleverTapC = resultCheckOutTime.1
        let isfirebaseC = resultCheckOutTime.2
        if isfacebookC != nil {
                //MARK:- Fix fix it later with sdk version
            //AppEvents.logEvent(AppEvents.Name(rawValue: isfacebookC!), parameters: ["Date" : Date.dataInGST(Date())])
        }
        if iscleverTapC != nil {
            CleverTapEventsLogger.trackCheckOutTime(eventName: iscleverTapC!)
        }
        if isfirebaseC != nil {
            FireBaseEventsLogger.trackCheckOutTime(eventName: isfirebaseC!)
        }
    
    }
    
    
    func addToCart (product : Product , _ recipeName : String = "" , _ chefName : String? = "" , _ isCarousel : Bool = false , _ cellIndex : IndexPath? = nil , _ brandName : String = "" , _ recipeIngredientsName: String = "" ) {
        
        
        let result = WhichEventNeedToLog(egName: ElgrocerEventConfigs.ADD_ITEM.rawValue)
        let isfacebookC = result.0
        var iscleverTap = result.1
            iscleverTap = nil
        let isfirebase = result.2
        if iscleverTap != nil {
            CleverTapEventsLogger.trackAddToProduct(product: product, recipeName, chefName, isCarousel: isCarousel, eventName: iscleverTap!)
        }
        if isfirebase != nil {
            FireBaseEventsLogger.trackAddToProduct(product: product, recipeName, chefName, isCarousel: isCarousel, eventName: isfirebase!)
        }
        if recipeName.count > 0 {
            GoogleAnalyticsHelper.trackRecipeIngredientsAddToCartClick(recipeName  , recipeIngredientsName)
            GoogleAnalyticsHelper.trackAddToProduct(product: product , recipeName)
        }
        
 
        let clearProductID = "\(Product.getCleanProductId(fromId: product.dbID))"
        /* ---------- facebook Event ----------*/
        let facebookProductParams = ["id" : clearProductID , "quantity" : 1 ] as [AnyHashable: Any]
        let fbDataA : [[AnyHashable : Any]] = [facebookProductParams]
        let paramsJSON = JSON(fbDataA)
        let paramsString = paramsJSON.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions.prettyPrinted)!

        if isfacebookC != nil {
           
            //AppEvents.ParameterName.contentID: clearProductID ,
            let facebookParams = [AppEvents.ParameterName.contentType:"product",AppEvents.ParameterName.currency:kProductCurrencyEngAEDName , AppEvents.ParameterName.content : paramsString] as [AnyHashable: Any]
                //MARK:- Fix fix it later with sdk version
           // AppEvents.logEvent(AppEvents.Name(rawValue: isfacebookC!), valueToSum: Double(truncating: product.price), parameters: facebookParams as! [String : Any])
        }
        GoogleAnalyticsHelper.trackAddToProduct(product: product)
        AlgoliaApi.sharedInstance.addItemToAlgolia(product: product, possitionIndex: (cellIndex?.row ?? nil) )
        
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            // PushWooshTracking.addEventForProductAdd(product, storeId: grocery.dbID)
            if isCarousel {
                // PushWooshTracking.addEventForCarouselProductAdd( product , storeId: grocery.dbID)
                GoogleAnalyticsHelper.trackCarouselAddToCartWithName(productName: product.name ?? "")
            }
        }
        
        /* ---------- AppsFlyer Search Event ----------*/
        var finalBrandName = brandName
        if !finalBrandName.isNotEmtpy() {
            if let name = product.brandName {
                finalBrandName = name
            }
        }
        
            // MARK:- TODO fixappsflyer
//        let appsFlyerParams = [AFEventParamContent: paramsString ,AFEventParamContentType: "product" ,AFEventParamCurrency:kProductCurrencyEngAEDName ,AFEventParamPrice:product.price] as [String: Any]
//        AppsFlyerLib.shared().logEvent(name: AFEventAddToCart, values: appsFlyerParams, completionHandler: nil)
       // AppsFlyerLib.shared().trackEvent(AFEventAddToCart, withValues:appsFlyerParams)
        
       
    //    let decimalPrice = NSDecimalNumber(decimal:product.price.decimalValue)
    //    Answers.logAddToCart(withPrice: decimalPrice,currency: product.currency,itemName:product.name,itemType:nil,itemId:product.dbID,customAttributes: nil)
     
    }
    
    
    func recordPurchaseAnalytics (finalOrderItems:[ShoppingBasketItem] , finalProducts:[Product]! , finalOrder:Order! ,  availableProductsPrices:NSDictionary?  , priceSum : Double , discountedPrice : Double  , grocery : Grocery , deliveryAddress : DeliveryAddress , carouselproductsArray : [Product] , promoCode : String , serviceFee : Double , payment : PaymentOption , discount : Double , IsSmiles : Bool, smilePoints: Int, pointsEarned: Int, pointsBurned: Int ){
       
        //google Analytics ecommerce
        let fbDataA =   GoogleAnalyticsHelper.trackPlacedOrderForEcommerce(finalOrder , orderItems: finalOrderItems, products: finalProducts, productsPrices: availableProductsPrices, IsSmiles : IsSmiles)
        
        /* ---------- Facebook Purchase Event ----------*/
        let paramsJSON = JSON(fbDataA)
        let paramsString = paramsJSON.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions.prettyPrinted)!
        let facebookParams = [ AppEvents.ParameterName.contentType:"product", AppEvents.ParameterName.content : paramsString ] as [AnyHashable: Any]
       
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("AppEvents.Name.logPurchase", facebookParams as? [String : Any])
        debugPrint("facebook eventName : logPurchase")
        debugPrint("facebook Parm price : \(priceSum)")
        debugPrint("facebook Parm Print : \(facebookParams)")
        
        
        /* ---------- AppsFlyer Purchase Event ----------*/
        var queryIDs : [String] = []
        var content : [String] = []
        var idData : [String] = []
        var fireBaseList  : [[String : Any]] = []
        for product in finalProducts {
            let idString = "\(Product.getCleanProductId(fromId: product.dbID))"
            idData.append(idString)
            if product.queryID?.count ?? 0 > 0 {
                if !queryIDs.contains(product.queryID!){
                    queryIDs.append(product.queryID!)
                }
            }
            if let name = product.nameEn {
                content.append(name)
            }
            fireBaseList.append([FireBaseParmName.ProductName.rawValue : product.nameEn ?? product.name ?? "" , FireBaseParmName.BrandName.rawValue : product.brandNameEn ?? product.brandName ?? "" , FireBaseParmName.CategoryName.rawValue :  product.categoryNameEn ?? product.categoryName ?? ""  , FireBaseParmName.SubCategoryName.rawValue : product.subcategoryNameEn ?? product.subcategoryName ?? "" ])
        }
        // let contentStr = (content.map{String($0)}).joined(separator: ",")
        let idStr = (idData.map{String($0)}).joined(separator: ",")
        // AFEventParamReceiptId : self.order.dbID.stringValue
        
        
            // MARK:- TODO fixappsflyer
//        let param = [AFEventParamRevenue:priceSum, AFEventParamCurrency:kProductCurrencyEngAEDName  , AFEventParamContentType : "product"  , AFEventParamContentId : idStr , AFEventParamContent: paramsString, "IsSmiles": IsSmiles ] as [String: Any]
//        AppsFlyerLib.shared().logEvent(name: AFEventPurchase, values: param, completionHandler: nil)
       // AppsFlyerLib.shared().trackEvent(AFEventPurchase, withValues:param)
        
        FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: "PurchaseValue", parameter: ["PurchaseValue" : priceSum ])
        
        // algolia calls
        let cleanGroceryID =  Grocery.getGroceryIdForGrocery(grocery)
        AlgoliaApi.sharedInstance.purchase(productQueryIDsList: queryIDs , productIDsList: idData , cleanGroceryID: cleanGroceryID)
        
        // PushWooshTracking.addInAppPurchaseProducts(finalProducts, orderItems: finalOrderItems, deliveryAddress  : deliveryAddress)
        let decimalPrice = NSDecimalNumber(value: priceSum as Double)
        let pricePush = "\(CurrencyManager.getCurrentCurrency()) \(decimalPrice)"
        // PushWooshTracking.addInAppPurchasePrice(pricePush)
        // PushWooshTracking.addCreateOrderEvent()
        // PushWooshTracking.addLastInAppPurchasedate()
        
        
        let result = WhichEventNeedToLog(egName: ElgrocerEventConfigs.PURCHASED_ITEM.rawValue)
       // let isfacebookC = result.0
        var iscleverTap = result.1
         iscleverTap = nil
        let isfirebase = result.2
        
        if isfirebase != nil {
            FireBaseEventsLogger.trackPurchaseItems(productList: finalProducts, orderId: finalOrder.dbID.stringValue , carosalA: carouselproductsArray , grocerID: grocery.dbID, eventName: isfirebase!)
        }
        if iscleverTap != nil {
            CleverTapEventsLogger.trackPurchaseItems(productList: finalProducts, orderId: finalOrder.dbID.stringValue , carosalA: carouselproductsArray , grocerID: grocery.dbID, eventName: iscleverTap!)
        }
      
        var priceToSend = priceSum
        var promoCodeNumberValue = 0.0
        if let promoCodeValue = UserDefaults.getPromoCodeValue() {
            promoCodeNumberValue = promoCodeValue.valueCents  as Double
        }
        if promoCodeNumberValue > 0 {
            priceToSend = discountedPrice
        }
        
        let result1 = WhichEventNeedToLog(egName: ElgrocerEventConfigs.PURCHASE_ORDER.rawValue)
        let isfacebookC1 = result1.0
        let iscleverTap1 = result1.1
        let isfirebase1 = result1.2
        
        if isfirebase1 != nil {
            FireBaseEventsLogger.trackPurchase(coupon: promoCode, coupanValue: "\(promoCodeNumberValue)" , currency: kProductCurrencyEngAEDName , value: String(format: "%.2f", priceToSend) , tax: grocery.vat , shipping: NSNumber(value: serviceFee)  , transactionID: finalOrder.dbID.stringValue, PurchasedItems: fireBaseList, discount: discount, IsSmiles: IsSmiles, smilePoints: smilePoints, pointsEarned: pointsEarned, pointsBurned: pointsBurned  )
        }
//        if iscleverTap1 != nil {
//            CleverTapEventsLogger.trackPurchase(coupon: promoCode, coupanValue: "\(promoCodeNumberValue)" , currency: kProductCurrencyEngAEDName , value: String(format: "%.2f", priceToSend) , tax: grocery.vat , shipping: NSNumber(value: serviceFee)  , transactionID: finalOrder.dbID.stringValue, PurchasedItems: fireBaseList , eventName : iscleverTap1! )
//        }
       // if isfacebookC1 != nil {
            AppEvents.logPurchase(priceSum, currency: kProductCurrencyEngAEDName , parameters: facebookParams as! [String : Any])
        //}
     
        FireBaseEventsLogger.setUserProperty(nil, key: "shopping_cart_amount")
        UserDefaults.removeSponsoredItemArray(grocerID: grocery.dbID)
        
        
        
        var cleverTap : [ Any ] = []
        
        var orderItemsMap = [String : ShoppingBasketItem]()
        for item in finalOrderItems {
            orderItemsMap[item.productId] = item
        }
        
        for product in finalProducts {
            
            
            let idString = "\(Product.getCleanProductId(fromId: product.dbID))"
            
            let item = orderItemsMap[product.dbID]
            if item != nil {
                cleverTap.append(["ProductId" : idString  , "ProductName" : product.nameEn ?? ""  , "Quantity" : item?.count.intValue ?? 1  , "Category" : product.categoryNameEn ?? "" , "Subcategory" : product.subcategoryNameEn ?? "" , "Brand" : product.brandNameEn ?? ""])
            }
         
        }
       
        var paymentstr = "PayCreditCard"
        if payment == PaymentOption.cash {
            paymentstr = "PayCash"
        }else  if payment == PaymentOption.card {
            paymentstr = "PayCardOnDelivery"
        }
        CleverTap.sharedInstance()?.recordChargedEvent(withDetails: ["Amount" : priceSum , "PaymentMode" : paymentstr , "ChargedID" : finalOrder.dbID.stringValue, "IsSmiles": IsSmiles ], andItems: cleverTap)

    }
    
    //
    
    class func trackOrderStatusCardView (orderId : String ,  statusID : String) {
        
        if let topVCName = FireBaseEventsLogger.gettopViewControllerName() {
            if !UserDefaults.isOrderDisplayed(orderId , topControllerName: topVCName ) {
                UserDefaults.addOrderID(orderId, topControllerName: topVCName)
                FireBaseEventsLogger.trackOrderStatusCardView(orderId: orderId, statusID: statusID)
            }
        }
    }
    
    
    class func OrderStatusCardClick (orderId : String ,  statusID : String) {
        
        FireBaseEventsLogger.OrderStatusCardClick(orderId: orderId, statusID: statusID)
    
    }
    
    class func trackOrderTrackingClick (orderId : String,  statusID : String) {

        FireBaseEventsLogger.trackOrderTrackingClick(orderId: orderId, statusID: statusID)

    }
    
    
    
    
    

    
    
    
//    func loginClickFromRegister() {
//        FirebaseEvents.getInstance().loginClick()
//        CleverTapEvents.getInstance().loginClick()
//    }
//
//    func login(userId: String) {
//        FirebaseEvents.getInstance().login(userId)
//        CleverTapEvents.getInstance().login(userId)
//    }
//
//    func register(userId: String) {
//        FirebaseEvents.getInstance().register(userId)
//        CleverTapEvents.getInstance().register(userId)
//    }
//
//    func detectLocationClicked() {
//        FirebaseEvents.getInstance().detectLocation()
//        CleverTapEvents.getInstance().detectLocation()
//    }
//
//    func chooseLocationClicked() {
//        FirebaseEvents.getInstance().chooseLocation()
//        CleverTapEvents.getInstance().chooseLocation()
//    }
//
//    func addNewAddressClick() {
//        FirebaseEvents.getInstance().addNewAddressClick()
//        CleverTapEvents.getInstance().addNewAddressClick()
//    }
//
//    func selectRetailer(retailer: Retailer) {
//        EventsData.retailer = retailer
//        FirebaseEvents.getInstance().selectRetailer()
//        CleverTapEvents.getInstance().selectRetailer()
//    }
//
//    func openLocations() {
//        FirebaseEvents.getInstance().openLocations()
//        CleverTapEvents.getInstance().openLocations()
//    }
    
    
}
