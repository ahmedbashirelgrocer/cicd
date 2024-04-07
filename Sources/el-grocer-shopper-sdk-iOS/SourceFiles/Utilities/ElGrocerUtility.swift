//
//  ElGrocerUtility.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 16/03/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import Foundation
import UIKit
//import Branch
import FirebaseAnalytics
//import FBSDKCoreKit
import FirebaseCrashlytics
import CoreLocation
import GooglePlaces
import StoreKit
import SDWebImage
import SwiftMessages
//import AppsFlyerLib
import SafariServices
import SwiftDate
//import BBBadgeBarButtonItem

private let SharedInstance = ElGrocerUtility()
let productPlaceholderPhoto = UIImage(name: "product_placeholder")!


class ElGrocerUtility {
    
    // use in network class
    var resolvedBidIdForBannerClicked: String?
    var projectScope : ScopeDetail?
    var isTokenCalling: Bool = false
    var isDeliveryMode: Bool = true 
    var currrentSelectedSlotMilis: String? = nil {

        didSet{
            elDebugPrint("currrentSelectedSlotMilis: \(ElGrocerUtility.sharedInstance.currrentSelectedSlotMilis)")
            elDebugPrint("NewSelectedSlotMilis: \(ElGrocerUtility.sharedInstance.NewSelectedSlotMilis)")
        }
    }
    var NewSelectedSlotMilis: String? = nil{
        
        didSet{
            elDebugPrint("currrentSelectedSlotMilis: \(ElGrocerUtility.sharedInstance.currrentSelectedSlotMilis)")
            elDebugPrint("NewSelectedSlotMilis: \(ElGrocerUtility.sharedInstance.NewSelectedSlotMilis)")
        }
    }
    

    /* ---- Add this dictionary here because we want to save brands and procucts data for one cycle of the app ---- */
    var brandsDict: Dictionary<String, Array<GroceryBrand>> = [:]
    var brandAvailabilityDict: Dictionary<String,Bool> = [:]
    
    var categoryAllProductsDict: Dictionary<String, Array<Product>> = [:]
    var productAvailabilityDict: Dictionary<String,Bool> = [:]
    
    var closeTimingAlertDict: Dictionary<String,Bool> = [:]
    var scheduleAlertDict: Dictionary<String,Bool> = [:]
    
    var basketFetchDict: Dictionary<String,Bool> = [:]
    
    var bannerGroups: [NSNumber : [BannerCampaign]] = [:]
    
    var isGroupedDict: Dictionary<String,Bool> = [:]
    var eventMap : [String:TimeInterval]  = [:]
    
    var completeGroceries:[Grocery] = []
    var groceries:[Grocery] = []
    var activeGrocery:Grocery?  {
        didSet {
            if let notNilGrocery = activeGrocery {
                if let name = notNilGrocery.name {
                    debugPrint("activeGrocery: \(name)")
                }
            }
        }
    }
    
    var activeAddress : DeliveryAddress? = nil
    
    var browsedCategories:[String] = []
    var browsedSubcategories:[String] = []
    var browsedGroceries:[String] = []
    
    var isStoreDetailsShowing:Bool = false
    var isHomeSelected:Bool = false
    var isUserProfileUpdated:Bool = false
    
    var isUserCloseOrderTracking:Bool = false
    
    
    var isZenDesk:Bool = true
    
    var walletTotal = String(format:"0.00 %@",CurrencyManager.getCurrentCurrency())
    var referrerAmount = String(format:"0.00 %@",CurrencyManager.getCurrentCurrency())
    
    var deepLinkURL = ""
    var deepLinkShotURL = ""
    
    var searchBarShakeHintCount:Int = 0
    var orderDeliverPopupCount:Int = 0
   
    var badgeCurrentValue = "0"
    var lastItemsCount = 0
    var deliveryRating = 0
    
    var isShoppingAfterSearchHint:Bool = false
    
    var isFromFavourite = false
    var isFromReorder = false
    
    
    var isItemInBasket = false
    
    var isFromCheckout = false
    var notAvailableItems:[Int]?
    var availableProductsPrices:NSDictionary?
    var isSummaryForGroceryBasket:Bool = false
    
    var isNavigationForSubstitution:Bool = false
    
    var isNotificationPopupShown = false
    
    var tabBarSelectedIndex = 0
    
    var appConfigData : AppConfiguration!
    var adSlots: AdSlotDTO! {         var marketType = 0 // Shopper
        if SDKManager.shared.launchOptions?.marketType == .marketPlace {
            return _adSlots[2]
        } else if SDKManager.shared.launchOptions?.marketType == .grocerySingleStore {
            return _adSlots[1]
        }
        return _adSlots[0]
    }
    var _adSlots: [Int: AdSlotDTO] = [:]
    
    var promoTagLink = "https://s3-us-west-2.amazonaws.com/elgrocerproductimagestempdata/promotag.png" + "?" + "\(Date.timeIntervalBetween1970AndReferenceDate)"
    var SessionStarttimeStamp : String =  String(format: "%.0f", Date.timeIntervalSinceReferenceDate)
    
    // following properties are only for 6.2.4 for transition build.Will be remove in next build. 
    var CurrentLoadedAddress = ""
    var isNeedToRefreshGroceryA : Bool = false
    var isNeedToRefreshBannerA : Bool = true
    var genericBannersA : [BannerCampaign] = [BannerCampaign]()
    var storeTypeA : [StoreType] = []
    var greatDealsBannersA : [BannerCampaign] = [BannerCampaign]()
    var grocerA : [Grocery] = [Grocery]()
    var chefList : [CHEF] = [CHEF]()
    var genericRecipeList : [Recipe] = [Recipe]()
    var recipeList : Dictionary<String , [Recipe] > = [:]
    
    
    var isCommingFromUniversalSearch : Bool = false
    var searchString : String? = nil
    var searchFromUniversalSearch : Home? = nil
    var clickedBannerUniversalSearch : BannerLink? = nil
    var dubaiCenterLocation : CLLocation = CLLocation.init(latitude: 25.199514 , longitude: 55.277397)
    var cAndcRetailerList : [Grocery] = [Grocery]()
    var cAndcAvailabitlyRetailerList : NSDictionary = [:]
    var currentOrderID : String = ""
    let dateFormatter = DateFormatter() // formater for slots
    var isActiveCartAvailable = false
    var isNeedToDismissGlobalSearchController: Bool = false
    private var startTime: Date = Date()
    
    
    var slotViewControllerList : Set = Set<UIViewController>()
    
    var showStorelyBanner = false

    class var sharedInstance : ElGrocerUtility {
        return SharedInstance
    }
    
    
    func CheckReloadViewsForSlotChange() {
        for vc in Array(slotViewControllerList) {
            vc.refreshSlotChange()
        }
    }

    // return format =  datestamp-appversion-latlng-userid
    func getGenericSessionID () -> String {
        
        var versionNumber = "10000"
        var latlng = "0"
        var userID = "0"
        
        if let version = PackageInfo.version { //Bundle.resource.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumber = version
        }
        if let address = ElGrocerUtility.sharedInstance.activeAddress {
           latlng = String(describing: address.latitude )  + "," + String(describing: address.longitude )
        }
        userID = UserDefaults.getLogInUserID()
        
        return self.SessionStarttimeStamp + "-" + versionNumber + "-" + latlng + "-" + userID
        return versionNumber + "-" + latlng
    }
    
    func getSesstionId() -> String {
        let appStartMilli = Int64((sdkManager.sdkStartTime?.timeIntervalSince1970 ?? self.startTime.timeIntervalSince1970) * 1000)
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
        return "\(appStartMilli)_\(uuid)"
    }
    
    func GenerateRetailerIdString(groceryA : [Grocery]?) -> String{
        
        var retailerIDString = ""
        if groceryA?.count ?? 0 > 0{
            var i = 0
            while i < groceryA!.count {
                if i == 0 {
                    retailerIDString.append((groceryA?[i].dbID)!)
                }else{
                    retailerIDString.append("," + (groceryA?[i].dbID)!)
                }
                i = i + 1
            }
        }
        return retailerIDString
    }
    
    
    func GenerateStoreTypeIdsString(groceryA : [Grocery]?) -> String{
        
        var retailerIDString = ""
        if groceryA?.count ?? 0 > 0{
            var i = 0
            while i < groceryA!.count {
                if i == 0 {
                    let grocery = groceryA?[i]
                    let storeTypes = grocery?.convertToArrayOfNumber(text: grocery?.storeType ?? "") ?? []
                    let stringOfStoreIds = storeTypes.map({$0.stringValue}).joined(separator: ",")
                    if stringOfStoreIds.count > 0 {
                        retailerIDString.append(stringOfStoreIds)
                    }
        
                }else{
                    let grocery = groceryA?[i]
                    let storeTypes = grocery?.convertToArrayOfNumber(text: grocery?.storeType ?? "") ?? []
                    let stringOfStoreIds = storeTypes.map({$0.stringValue}).joined(separator: ",")
                    if stringOfStoreIds.count > 0 {
                        retailerIDString.append(",")
                        retailerIDString.append(stringOfStoreIds )
                    }
                }
                i = i + 1
            }
        }
        return retailerIDString
    }
    
    func GenerateStoreGroupIdsString(groceryAForIds : [Grocery]?) -> [String] {
        
        var retailerIDA : [String] = []
        if let dataA = groceryAForIds {
            for grocery in dataA {
                retailerIDA.append(grocery.groupId.stringValue)
            }
        }
        return retailerIDA
    }
    
    
    func getCurrentMillis() -> Int64 {
        let slotId = UserDefaults.getCurrentSelectedDeliverySlotId()
        let grocery = ElGrocerUtility.sharedInstance.activeGrocery
        if let slot = DeliverySlot.getDeliverySlot(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: grocery?.dbID ?? "-1" , slotId: slotId.stringValue) {
            return Int64(truncating: slot.time_milli)
        }else{
            if let slots = DeliverySlot.getFirstDeliverySlots(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: grocery?.dbID ?? "-1") {
                if !slots.isInstant.boolValue {
                    return Int64(truncating: slots.time_milli)
                }
            }
        }
        return Int64(Date().getUTCDate().timeIntervalSince1970 * 1000)
        
    }
    
    func getCurrentMillisOfGrocery(id: String) -> Int64 {
    
        let slotId = UserDefaults.getCurrentSelectedDeliverySlotId()
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            if grocery.getCleanGroceryID().elementsEqual(id) {
                if let slot = DeliverySlot.getDeliverySlot(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: grocery.dbID , slotId: slotId.stringValue) {
                    return Int64(truncating: slot.time_milli)
                }
            }
        }
        
        if let grocery = Grocery.getGroceryById(id, context: DatabaseHelper.sharedInstance.mainManagedObjectContext),  let jsonSlot = grocery.initialDeliverySlotData, let dict = grocery.convertToDictionary(text: jsonSlot) {
              debugPrint(dict)
            if !grocery.isInstant() && !grocery.isInstantSchedule() {
                if let timeStamp = dict["time_milli"] as? Int64 {
                    return timeStamp
                }
            }
        } else if let slots = DeliverySlot.getFirstDeliverySlots(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: id) {
            if !slots.isInstant.boolValue {
                return Int64(truncating: slots.time_milli)
            }
        }
        
        return Int64(Date().getUTCDate().timeIntervalSince1970 * 1000)
        
    }
    
    func createAvailableStoreIdsString(grocaeryIdsArray: [NSNumber]) -> String {
        var availableStoreString = ""
        for i in 0..<grocaeryIdsArray.count {
            if i == 0 {
                availableStoreString.append(grocaeryIdsArray[i].stringValue)
            }else {
                availableStoreString.append("," +  grocaeryIdsArray[i].stringValue)
            }
        }
        return availableStoreString
    }
 
    /*
    func getCurrentMillis() -> Int64 {
        defer {
            elDebugPrint("SlotReturnDiff: \(start.timeIntervalSince(Date.getCurrentDate()))")
        }
        let start = Date.getCurrentDate()
        let slotId = UserDefaults.getCurrentSelectedDeliverySlotId()
        let grocery = ElGrocerUtility.sharedInstance.activeGrocery
        let slots = DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: grocery?.dbID ?? "-1")
        if slotId != 0 && slotId != -1 {
            let index = slots.firstIndex(where: { $0.dbID == slotId })
            if (index != nil) {
                elDebugPrint("Slot  Time is : \(slots[index!].time_milli)")
                return Int64(truncating: slots[index!].time_milli)
            }else{
                let firstObj  = slots.first
                if firstObj != nil {
                    //elDebugPrint("Slot  Time is : \(slots[index!].timeStamp)")
                    if firstObj?.dbID.intValue ?? 0 > 0 {
                        return Int64(truncating: firstObj!.time_milli)
                    }
                }
            }
            
        }else{
            let firstObj  = slots.first
            if firstObj != nil {
                elDebugPrint("Slot  Time is : \(firstObj!.time_milli)")
                if firstObj?.dbID.intValue ?? 0 > 0 {
                    return Int64(truncating: firstObj!.time_milli)
                }
            }
        }
        elDebugPrint("Slot  Time is : \(Int64(Date().getUTCDate().timeIntervalSince1970 * 1000)) Instant")
        return Int64(Date().getUTCDate().timeIntervalSince1970 * 1000)
    }*/

    

    func resetBasketPresistence() {
        
        UserDefaults.setPromoCodeValue(nil)
        UserDefaults.setLeaveUsNote(nil)
        UserDefaults.setWalletPaidAmount(nil)
        //UserDefaults.setPaymentMethod(0)
        UserDefaults.setCurrentSelectedDeliverySlotId(0)
        UserDefaults.setOver18(false,true)
        if UserDefaults.isOrderInEdit() {
            UserDefaults.setClearEditOrder(true)
        }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func delayOnBackground(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func checkForClosingHour(_ openingTime:String, withCompletionHandler completionHandler: ((_ success: Bool,_ remainingTime: String) -> Void)) {
        
        var closeHour = false
        var remainingMinutes = ""
        
        if let data = openingTime.data(using: String.Encoding.utf8) {
            do {
                
                
                let timeDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                
                let closingHours: NSArray = timeDict!["closing_hours"] as! NSArray
                
                /* 1 = Sunday,2 = Monday,3 = Tuesday,4 = Wednesday,5 = Thursday,6 = Friday, 7 = Saturday */
                
                let weekDays = ["1","2","3","4","7"]
                
                let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
                let myComponents = (myCalendar as NSCalendar).components(.weekday, from:Date())
                let weekDay = myComponents.weekday
                
                var closingTime:String = ""
                var localTime:String = ""
                
                let weekdayStr = String(format:"%d",myComponents.weekday!)
                
                if weekDays.contains(weekdayStr) {
                   elDebugPrint("Today is weekday")
                    closingTime = closingHours[0] as! String
                    
                }else if (weekDay == 5){
                   elDebugPrint("Today is Thursday")
                    closingTime = closingHours[1] as! String
                }else{
                   elDebugPrint("Today is Friday")
                    closingTime = closingHours[2] as! String
                }
                
                let formatter = DateFormatter()
                formatter.locale = Locale.current
                let phoneLanguage = UserDefaults.getCurrentLanguage()
                if phoneLanguage == "ar" {
                    formatter.locale = Locale(identifier: "ar_DZ")
                }
                
                formatter.dateFormat = "HH:mm"
                
                localTime = formatter.string(from: Date())
                
                let endTime = formatter.date(from: closingTime)
                let currentTime = formatter.date(from: localTime)
                
                if endTime != nil && currentTime != nil {
                    
                    // extract hour and minute from those `NSDate` objects
                    
                    let calendar = Calendar.current
                    
                    let endComponents = (calendar as NSCalendar).components([.hour, .minute], from: endTime!)
                    let currentComponents = (calendar as NSCalendar).components([.hour, .minute], from: currentTime!)
                    
                    let remainingMin = (endComponents.hour!*60 + endComponents.minute!) - (currentComponents.hour!*60 + currentComponents.minute!)
                    
                    if remainingMin <= 30 && remainingMin >= 0{
                        closeHour = true
                        remainingMinutes = String(format: "%d %@",remainingMin,localizedString("min_title", comment: ""))
                    }
                }
                
            } catch let error as NSError {
               // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
               elDebugPrint(error)
            }
        }
        
        completionHandler(closeHour,remainingMinutes)
    }
    
    func createBranchLinkForProduct(_ product:Product){
        
        /*let productIdentifier = String(format: "Product/%@",product.dbID)
        let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier:productIdentifier)
        branchUniversalObject.title = product.name
        branchUniversalObject.contentDescription = "el Grocer – Online Grocery Delivery"
        branchUniversalObject.imageUrl = product.imageUrl
        
        let brand = Brand.getBrandForProduct(product, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        if brand != nil && brand?.name != nil{
            branchUniversalObject.addMetadataKey("brandName", value: (brand?.name)!)
        }
        
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.feature = "sharing"
        linkProperties.channel = "facebook"
        linkProperties.addControlParam("$ios_url", withValue: "https://itunes.apple.com/ae/app/grocer-online-grocery-delivery/id1040399641?mt=8")
        
        branchUniversalObject.getShortUrl(with: linkProperties, andCallback:  { (url, error) in
            if error == nil {
               elDebugPrint("Branch link: %@", url ?? "may be url is null")
            }else{
               elDebugPrint("Error While Creating Branch link:%@",error?.localizedDescription ?? "Error")
            }
        })
        
        branchUniversalObject.automaticallyListOnSpotlight = true
        branchUniversalObject.userCompletedAction(BNCRegisterViewEvent)*/
    }
    
    func logEventToFirebaseWithEventName(_ eventName:String , _ parameter : [String : Any]? = nil ){
       // Analytics.logEvent(eventName, parameters:parameter)
    }
    

    func logAddToCartEventWithProduct(_ product: Product , _ brandName : String = "") {


        let clearProductID = "\(Product.getCleanProductId(fromId: product.dbID))"

        /* ---------- facebook Event ----------*/
        let facebookProductParams = ["id" : clearProductID , "quantity" : 1 ] as [AnyHashable: Any]
        let fbDataA : [[AnyHashable : Any]] = [facebookProductParams]
        let paramsJSON = JSON(fbDataA)
        let paramsString = paramsJSON.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions.prettyPrinted)!
      
        //AppEvents.ParameterName.contentID: clearProductID ,
       // let facebookParams = [AppEvents.ParameterName.contentType:"product",AppEvents.ParameterName.currency:kProductCurrencyEngAEDName , AppEvents.ParameterName.content : paramsString] as [AnyHashable: Any]
        
        /// FixMe Need update SDK
//        if let facebookParams = facebookParams as? [AppEvents.ParameterName : Any] {
//            AppEvents.logEvent(AppEvents.Name.addedToCart, valueToSum: Double(truncating: product.price), parameters: facebookParams)
//        }
        
   //     ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("AppEvents.Name.addedToCart", facebookParams as? [String : Any])
        
//        elDebugPrint("facebook eventName : \(AppEvents.Name.addedToCart)")
//        elDebugPrint("facebook Parm Print : \(product.price)")
//        elDebugPrint("facebook Parm Print : \(paramsString)")

        /* ---------- AppsFlyer Search Event ----------*/
        var finalBrandName = brandName
        if !finalBrandName.isNotEmtpy() {
            if let name = product.brandName {
                  finalBrandName = name
            }
        }
        
            // MARK:- TODO fixappsflyer
//        let appsFlyerParams : [String : Any] = [AFEventParamContent: paramsString ,AFEventParamContentType: "product" ,AFEventParamCurrency:kProductCurrencyEngAEDName ,AFEventParamPrice:product.price] as [String: Any]
//        AppsFlyerLib.shared().logEvent(name: AFEventAddToCart, values: appsFlyerParams) { (data, error) in
//            elDebugPrint("data");elDebugPrint(data)
//        }
        //AppsFlyerLib.shared().trackEvent(AFEventAddToCart, withValues:appsFlyerParams)
        
        /* ---------- AppsFlyer Search Event ----------*/
        let decimalPrice = NSDecimalNumber(decimal:product.price.decimalValue)
        // Answers.AddToCart(withPrice: decimalPrice,currency: product.currency,itemName:product.name,itemType:nil,itemId:product.dbID,customAttributes: nil)
    }
    
    
    
    
    func addDeliveryToServerWithBlock(_ locations:[DeliveryAddress],  completionHandler:@escaping (_ result: Bool, _ errorMessage: String) -> Void){
    
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        guard locations.count > 0 else {
            return  completionHandler(false, "")
        }
            for location in locations {
                
                ElGrocerApi.sharedInstance.addDeliveryAddress(location, completionHandler: { (result:Bool, responseObject:NSDictionary?) -> Void in
                    
                    if result {
                        
                        let addressDict = (responseObject!["data"] as! NSDictionary)["shopper_address"] as! NSDictionary
                        
                        let dbID = addressDict["id"] as! NSNumber
                        let dbIDString = "\(dbID)"
                        
                        location.dbID = dbIDString
                        let newAddress = DeliveryAddress.insertOrUpdateDeliveryAddressForUser(userProfile!, fromDictionary: addressDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        DatabaseHelper.sharedInstance.saveDatabase()
                        
                        if(location.isActive.boolValue == true){
                            
                           //  print("%@ is an Active Location",location.locationName)
                            let locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                           //  print("Locations Count:%d",locations.count)
                            
                            for tempLoc in locations {
                                
                               //  print("tempLoc.dbID:%@",tempLoc.dbID)
                               //  print("location.dbID:%@",location.dbID)
                                if tempLoc.dbID == location.dbID{
                                    tempLoc.isActive = NSNumber(value: true as Bool)
                                }else{
                                    tempLoc.isActive = NSNumber(value: false as Bool)
                                }
                            }
                            DatabaseHelper.sharedInstance.saveDatabase()
                            // We need to set the new address as the active address
                            ElGrocerApi.sharedInstance.setDefaultDeliveryAddress(newAddress, completionHandler: { (result) in
                                
                                if (result == true){
                                    completionHandler(true, "")
                                    
                                }else{
                                   //  print("Error while setting default location on Server.")
                                    completionHandler(false, "Error while setting default location on Server")
                                }
                            })
                        }else{
                           //  print("\(location.locationName) is Not an Active Location")
                            completionHandler(false, "\(location.locationName) is Not an Active Location")
                        }
                        
                    }else{
                        completionHandler(false, "Error while add location on Server.")
                    }
                })
            }
    
        
        
    }

    
    func addDeliveryToServer(_ locations:[DeliveryAddress]){
        
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        
        backgroundQueue.async(execute: {
           elDebugPrint("This is run on the background queue")
            
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
            for location in locations {
                
                ElGrocerApi.sharedInstance.addDeliveryAddress(location, completionHandler: { (result:Bool, responseObject:NSDictionary?) -> Void in
                    
                    if result {
                        
                        let addressDict = (responseObject!["data"] as! NSDictionary)["shopper_address"] as! NSDictionary
                        
                        let dbID = addressDict["id"] as! NSNumber
                        let dbIDString = "\(dbID)"
                        
                        location.dbID = dbIDString
                        let newAddress = DeliveryAddress.insertOrUpdateDeliveryAddressForUser(userProfile!, fromDictionary: addressDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        DatabaseHelper.sharedInstance.saveDatabase()
                        
                        if(location.isActive.boolValue == true){
                            
                           elDebugPrint("%@ is an Active Location",location.locationName)
                            let locations = DeliveryAddress.getAllDeliveryAddresses(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                           elDebugPrint("Locations Count:%d",locations.count)
                            
                            for tempLoc in locations {
                                
                               elDebugPrint("tempLoc.dbID:%@",tempLoc.dbID)
                               elDebugPrint("location.dbID:%@",location.dbID)
                                if tempLoc.dbID == location.dbID{
                                    tempLoc.isActive = NSNumber(value: true as Bool)
                                }else{
                                    tempLoc.isActive = NSNumber(value: false as Bool)
                                }
                            }
                            DatabaseHelper.sharedInstance.saveDatabase()
                            // We need to set the new address as the active address
                            ElGrocerApi.sharedInstance.setDefaultDeliveryAddress(newAddress, completionHandler: { (result) in
                                
                                if (result == true){
                                    
                                    
                                }else{
                                   elDebugPrint("Error while setting default location on Server.")
                                }
                            })
                        }else{
                           elDebugPrint("%@ is Not an Active Location",location.locationName)
                        }
                        
                    }else{
                       elDebugPrint("Error while add location on Server.")
                    }
                })
            }
        })
    }

    func resetRecipeView () {

        let SDKManager: SDKManagerType! = sdkManager
        //if SDKManager.rootViewController as? UITabBarController != nil {
        if let tababarController = (SDKManager.rootViewController as? UINavigationController)?.topViewController as? UITabBarController {
                let main : ElGrocerNavigationController =  tababarController.viewControllers![3] as! ElGrocerNavigationController
                if let  controller = main.viewControllers[0] as? RecipesListViewController {
                    if controller.tableView != nil {
                         controller.tableView.setContentOffset(CGPoint.zero, animated:false)
                    }
                    if let navControler = controller.navigationController {
                       navControler.popToRootViewController(animated: true)
                    }
                }
            }
        //}
    }
    
    func clearActiveBasketForReOrder(){
        
        //clear active basket
        if ElGrocerUtility.sharedInstance.isFromReorder {
            ElGrocerUtility.sharedInstance.isFromReorder = false
            ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            ElGrocerUtility.sharedInstance.resetBasketPresistence()
        }
    }
    
    func getCurrentDeliveryAddress() -> DeliveryAddress? {
        let address = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        self.activeAddress = address
        return address
    }
    
    func getPremiseFrom (_ place : GMSPlace) -> String {
        
        for addressComponent in (place.addressComponents)! {
            for type in (addressComponent.types){
                switch(type){
                case "premise":
                    return addressComponent.name
                default:
                    break
                }
            }
        }
        return ""
        
    }
    
    func dynamicHeight(text : String , font : UIFont , width : CGFloat) -> CGFloat{
        let string = text
        let textSize = string.heightOfString(withConstrainedWidth: width , font: font)
        return textSize + 14
    }
    
    func getImageWithName(_ imageName:String) -> UIImage {
        
        var flippedImage = UIImage(name: imageName)
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            let sourceImage = UIImage(name: imageName)
            flippedImage = UIImage(cgImage: sourceImage!.cgImage!, scale: (sourceImage?.scale)!, orientation: .upMirrored)
        }
        
        if flippedImage == nil {
            flippedImage = UIImage()
        }
        
        return flippedImage!
    }
    
    func distancefrom(_ fromLocation:CLLocation, toLocation:CLLocation) -> Double {
        let distance = fromLocation.distance(from: toLocation)
        return distance
    }
    func addImageatEndLableText(_ lable : UILabel , image : UIImage) {

        let imageAttachment =  NSTextAttachment()
        imageAttachment.image = image
        //Set bound to reposition
        let imageOffsetY:CGFloat = 0.0;
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        //Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        //Initialize mutable string
        let completeText = NSMutableAttributedString(string: lable.text ?? "")
        completeText.append(NSMutableAttributedString(string: " "))
        //Add image to mutable string
        completeText.append(attachmentString)

        lable.attributedText = completeText;

    }

    func isArabicSelected() -> Bool {
        return LanguageManager.sharedInstance.getSelectedLocale() == "ar"
    }
    
    func setDefaultGroceryAgain() {
        Thread.OnMainThread {
            if let currentAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext){
                if let activeGrocery = ElGrocerUtility.sharedInstance.activeGrocery {
                    UserDefaults.setGroceryId(activeGrocery.dbID , WithLocationId: (currentAddress.dbID))
                }
            }
        }
    }
    
    
    func getPaymentMethod(_ myGrocery:Grocery) -> String {
        var paymentDescription = "---"
        
        var descPayment = ""
        let paymentAvailableID = myGrocery.convertToArrayOfNumber(text: myGrocery.paymentAvailableID) ?? []
        for ids in paymentAvailableID {
            if descPayment.count > 0 {
                descPayment.append(" - ")
            }
            if ids.uint32Value == PaymentOption.cash.rawValue {
                descPayment.append("Cash")
            }else if ids.uint32Value == PaymentOption.card.rawValue {
                 descPayment.append("Card/Delivery")
            }else if ids.uint32Value == PaymentOption.creditCard.rawValue {
                descPayment.append("PayOnline")
            }
        }
        if descPayment.count == 0 {
            descPayment.append("---")
        }
         return descPayment
        
       // elDebugPrint(descPayment)
        
        
        
        if myGrocery.availablePayments.uint32Value & PaymentOption.cash.rawValue > 0 && myGrocery.availablePayments.uint32Value & PaymentOption.card.rawValue > 0 && myGrocery.availablePayments.uint32Value & PaymentOption.creditCard.rawValue > 0 {
            
            //both payments are available
            paymentDescription = localizedString("cash_card_creditCard_delivery", comment: "")
            
        }else if myGrocery.availablePayments.uint32Value & PaymentOption.cash.rawValue > 0  && myGrocery.availablePayments.uint32Value & PaymentOption.creditCard.rawValue > 0 {
            
            //both payments are available
            paymentDescription = localizedString("cash_creditCard_delivery", comment: "")
            
        }else if myGrocery.availablePayments.uint32Value & PaymentOption.card.rawValue > 0  && myGrocery.availablePayments.uint32Value & PaymentOption.creditCard.rawValue > 0 {
            
            //both payments are available
            paymentDescription = localizedString("card_creditCard_delivery", comment: "")
            
        } else if myGrocery.availablePayments.uint32Value & PaymentOption.cash.rawValue > 0 && myGrocery.availablePayments.uint32Value & PaymentOption.card.rawValue > 0 {
            
            //both payments are available
            paymentDescription = localizedString("cash_card_delivery", comment: "")
            
        } else if myGrocery.availablePayments.uint32Value & PaymentOption.cash.rawValue > 0 && myGrocery.availablePayments.uint32Value & PaymentOption.card.rawValue == 0 {
            
            //only Cash
            paymentDescription = localizedString("cash_delivery", comment: "")
            
        } else if myGrocery.availablePayments.uint32Value & PaymentOption.cash.rawValue == 0 && myGrocery.availablePayments.uint32Value & PaymentOption.card.rawValue > 0 {
            
            //only Card
            paymentDescription = localizedString("card_delivery", comment: "")
        }
        return paymentDescription
    }
    
    
    
    func getDayTitleAgainstSlot(_ dayNumber : NSNumber) -> String {
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let calendarComponents = (calendar as NSCalendar).components(.weekday, from:Date())
        let weekDay = calendarComponents.weekday
        let nextDay = weekDay! + 1 == 8 ? 1 : weekDay! + 1
        var dayTitle = localizedString("today_title", comment: "")
        if Int(truncating: (dayNumber)) == weekDay{
            dayTitle = localizedString("today_title", comment: "")
        }else if Int(truncating: (dayNumber)) == nextDay{
            dayTitle = localizedString("tomorrow_title", comment: "")
        }else{
            let formatter = DateFormatter()
            let daysA = formatter.standaloneWeekdaySymbols;
            var dayNumber = Int(truncating: (dayNumber)) - 1
            dayNumber = dayNumber < 0 ? 0 : dayNumber
            dayNumber = dayNumber > 6 ? 6 : dayNumber
            dayTitle  = daysA?[dayNumber] ?? "";
        }
        return dayTitle
    }
    
    func getCurrentActionGroceryItemCount( grocery : Grocery?) -> Int{
        
        
        let items = ShoppingBasketItem.getBasketItemsForOrder(nil , grocery: grocery , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        var itemsCount = 0
        for item in items {
            if item.isSubtituted.boolValue{
                continue
            }
            itemsCount += item.count.intValue
        }
        
        return itemsCount
        //var itemsCountStr = "\(itemsCount)"
        
        
    }
    
    
    func isComingFromPopUp(_ vc : UIViewController? = nil) -> Bool {
        
        
        if let topVc = UIApplication.topViewController() {
            if  String(describing: topVc.classForCoder) == "STPopupContainerViewController"  {
                return true
            }
            if let currentVc = vc {
                if  String(describing: currentVc.classForCoder) == "STPopupContainerViewController"  {
                    return true
                }
            }
        }
        return false
    }
    
    func getDeliverySlotString (slots : DeliverySlot?) -> String {
        
     return ""
        
    }
    
    
    func getDeliverySlotStringWithOutTodayTommrow (slots : DeliverySlot?) -> String {
        
       return ""
        
    }
    
    func setOrderStatusIcon(_ order: Order!) -> UIImage {
        
        
        // sch   =  schedule-icon
        // pen ding = status-pending-New
        // deleivery = tatus-complete-New
        // enroute = enroute-icon
        //completed = completed-icons
        //cancel = cancel-icon
        
        //        case pending = 0
        //        case accepted = 1
        //        case enRoute = 2
        //        case completed = 3
        //        case canceled = 4
        //        case delivered = 5
        //        case inSubtitution = 6
        //        case nonHandle = 7
        //        case inEdit = 8
        if order.deliverySlot != nil && order.status.intValue == 0{
            return UIImage(name: "schedule-icon")!
        }
        switch order.status.intValue {
            case 0:
                return UIImage(name: "status-pending-New")!
            case 1:
                return UIImage(name: "status-complete-New")!
            case 2:
                return UIImage(name: "enroute-icon")!
            case 3:
                return UIImage(name: "completed-icons")!
            case 4:
                return UIImage(name: "cancel-icon")!
            case 5:
                return UIImage(name: "status-complete-New")!
            default:
                return UIImage(name: "status-pending-New")!
        }
        
    }
    
    
    func checkForOtherGroceryActiveBasket(_ grocery : Grocery) -> Bool {
        
        var isAnOtherActiveBasket = false
        
        //check if other grocery basket is active
        let isOtherGroceryBasketActive = ShoppingBasketItem.checkIfBasketForOtherGroceryIsActive(grocery , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let activeBasketGrocery = ShoppingBasketItem.getGroceryForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        if isOtherGroceryBasketActive && activeBasketGrocery != nil {
            isAnOtherActiveBasket = true
        }
        
        return isAnOtherActiveBasket
    }
    
    
    
    func checkActiveGroceryNeedsToClear (_ grocery : Grocery? , completionHandler:@escaping (_ isUserAgreeOnClearOutExsisiting:Bool) -> Void) {
        
        guard grocery != nil else {
            completionHandler(true)
            return
        }
        
        let isActiceBasket = self.checkForOtherGroceryActiveBasket(grocery!)
        if isActiceBasket {
            if UserDefaults.isUserLoggedIn() {
                //clear active basket and add product
                ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                ElGrocerUtility.sharedInstance.resetBasketPresistence()
               completionHandler(true)
            }else{
                let SDKManager: SDKManagerType! = sdkManager
                let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "NoCartPopUp") , header: localizedString("products_adding_different_grocery_alert_title", comment: ""), detail: localizedString("products_adding_different_grocery_alert_message", comment: ""),localizedString("grocery_review_already_added_alert_cancel_button", comment: ""),localizedString("select_alternate_button_title_new", comment: "") , withView: SDKManager.window!) { (buttonIndex) in
                    
                    if buttonIndex == 1 {
                        //clear active basket and add product
                        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        ElGrocerUtility.sharedInstance.resetBasketPresistence()
                        completionHandler(true)
                    }else {
                        completionHandler(false)
                    }
                }
            }
        }else{
            completionHandler(true)
        }
        
    }
    
    
    
    
    func getFormattedAddress(_ locations:DeliveryAddress?) -> String {
        var formatted = "";
        if let location = locations {
            if (location.addressType ==  "0") {
                
                if location.apartment?.count ?? 0 > 0 {
                     formatted =  (location.apartment ?? "")
                     formatted = formatted.count > 0 ? (formatted + ", ") :  formatted
                }
                
                if location.floor?.count ?? 0 > 0 {
                    formatted = formatted +  (location.floor ?? "")
                    formatted = formatted.count > 0 ? (formatted + ", ") :  formatted
                }
                
                if location.building?.count ?? 0 > 0 {
                    formatted = formatted +  (location.building ?? "")
                    formatted = formatted.count > 0 ? (formatted + ", ") :  formatted
                }
                
                if location.street?.count ?? 0 > 0 {
                    formatted = formatted +  (location.street ?? "")
                    formatted = formatted.count > 0 ? (formatted + ", ") :  formatted
                }
                
                if location.city?.count ?? 0 > 0 {
                    formatted = formatted +  (location.city ?? "")
                }

            }else if (location.addressType ==  "1") {
                
                if location.houseNumber?.count ?? 0 > 0 {
                    formatted =  (location.houseNumber ?? "")
                    formatted = formatted.count > 0 ? (formatted + ", ") :  formatted
                }
                if location.street?.count ?? 0 > 0 {
                    formatted = formatted +  (location.street ?? "")
                    formatted = formatted.count > 0 ? (formatted + ", ") :  formatted
                }
//                formatted =  (location.houseNumber ?? "") + " "
//                formatted =  formatted  + (location.street ?? "")
            }else if (location.addressType ==  "2") {
                
                if location.houseNumber?.count ?? 0 > 0 {
                    formatted =  (location.houseNumber ?? "")
                    formatted = formatted.count > 0 ? (formatted + ", ") :  formatted
                }
                if location.building?.count ?? 0 > 0 {
                    formatted = formatted +  (location.building ?? "")
                    formatted = formatted.count > 0 ? (formatted + ", ") :  formatted
                }
                if location.street?.count ?? 0 > 0 {
                    formatted = formatted +  (location.street ?? "")
                    formatted = formatted.count > 0 ? (formatted + ", ") :  formatted
                }
                
//                formatted =  (location.houseNumber ?? "") + ", "
//                formatted =  formatted  + (location.building ?? "")
//                formatted =  formatted   + ", " + (location.street ?? "")
                // formatted =  formatted  + (location.houseNumber ?? "")
            } else {
                formatted = location.address
            }
        }
        
        if formatted.isEmpty {
            if let location = locations {
                formatted = location.locationName.count > 0 ? (location.locationName + "\n" + location.address): location.address
            }
        }
        
        var finalCHeck = formatted
        finalCHeck = finalCHeck.replacingOccurrences(of: " ", with: "")
        finalCHeck = finalCHeck.replacingOccurrences(of: ", ", with: "")
        finalCHeck = finalCHeck.replacingOccurrences(of: ",", with: "")
        
        if finalCHeck.isEmpty {
            formatted = locations?.city ?? ""
        }
        return formatted;
    }
    
    
     func validateUserProfile(_ userProfile: UserProfile?, andUserDefaultLocation deliveryAddress:DeliveryAddress?) -> Bool {
        
        var isValidationSuccessed = false
        
        guard let profile = userProfile, let address = deliveryAddress  else {
            return isValidationSuccessed
        }
         
     
        if address.addressType == "1" {
            
            isValidationSuccessed = profile.name != nil && !profile.name!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty && profile.phone != nil
                && !userProfile!.phone!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                // && address.street != nil && !address.street!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        }else{
            
            isValidationSuccessed = profile.name != nil && !profile.name!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty && profile.phone != nil
                && !userProfile!.phone!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                
                && address.building != nil && !address.building!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                && address.apartment != nil && !address.apartment!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
                // && address.street != nil && !address.street!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        }
        
        return isValidationSuccessed
    }
    
    
  
    
    func getCvvFromUser (controller : UIViewController , _ cardLastFour : String = "" , completion : (@escaping (_ cvv : String , _  isSuccess : Bool) -> Void)) {
        
        var  messageStr =  localizedString("cvv_alert_msg", comment: "")
        messageStr = messageStr + (cardLastFour.count > 0 ? "\n Card ends with: \(cardLastFour)" : "")
        FireBaseEventsLogger.trackMessageEvents(message: messageStr)
        let alert = UIAlertController(title: "el Grocer", message: messageStr , preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "123"
            textField.isSecureTextEntry = true
            textField.keyboardType  = .asciiCapableNumberPad
        }
        alert.addAction(UIAlertAction(title: localizedString("promo_code_alert_no", comment: "") , style: .destructive, handler: { (_) in
            completion("" , false)
            
        }))
        alert.addAction(UIAlertAction(title:  localizedString("select_alternate_button_title_new", comment: "") , style: .default , handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text?.count ?? 0 == 3 {
                completion(textField?.text! ?? "" , true)
                return
            }
            completion("" , false)
        }))
       
        controller.present(alert, animated: true, completion: nil)
        
    }
    
     func showAppStoreReviewPopUp(){
        self.delay(1) {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                // Fallback on earlier versions
                ElGrocerAlertView.createAlert(localizedString("rate_us_title", comment: ""),
                                              description: localizedString("rate_us_message", comment: ""),
                                              positiveButton: localizedString("rate_us_ok_title", comment: ""),
                                              negativeButton: localizedString("rate_us_cancel_title", comment: ""),
                                              buttonClickCallback: { (buttonIndex:Int) -> Void in
                                                if buttonIndex == 0 {
                                                    let reviewUrl = "https://itunes.apple.com/us/app/el-grocer-home-delivery-app/id1040399641?mt=8?action=write-review"
                                                    UIApplication.shared.openURL(URL(string:reviewUrl)!)
                                                }
                }).show()
            }
        }
    }
    
    
    func setPromoImage ( imageView : UIImageView?) {
        var promoUrl = promoTagLink
        if appConfigData != nil {
             promoUrl = appConfigData.promoImage
        }
        guard imageView != nil else {return}
        let url = URL(string: promoUrl);
        imageView?.sd_setImage(with: url , placeholderImage: nil , options: SDWebImageOptions.refreshCached, completed: { (image, error, cacheType, imageURL) in
             imageView?.image = image
            imageView?.contentMode = .scaleAspectFit
        })
      
    }
    
    func convertToEnglish(_ str : String) ->  String {
        let stringNumber : String  = str
        var finalString = ""
        for c in stringNumber {
            let Formatter = NumberFormatter()
            Formatter.locale = NSLocale(localeIdentifier: "EN") as Locale?
            if let final = Formatter.number(from: "\(c)") {
                finalString = finalString + final.stringValue
            }
        }
        return finalString
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch (let error) {
               // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "api-error"), object: error, userInfo: [:])
               elDebugPrint(error.localizedDescription)
            }
        }
        return nil
    }
    
    func getPriceAttributedString(priceValue: Double,isProductWhite: Bool = false, isArabic: Bool =  ElGrocerUtility.sharedInstance.isArabicSelected()) -> NSMutableAttributedString {
        
        if isArabic {
            var attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(16), NSAttributedString.Key.foregroundColor : UIColor.secondaryBlackColor()]
            var attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
            if isProductWhite {
                 attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(16), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
                 attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
            }
            
            let price = String(format: " %.2f" , priceValue)
            let stringPrice = price.changeToArabic()
            let attributedString1 = NSMutableAttributedString(string:stringPrice as String , attributes:attrs1 as [NSAttributedString.Key : Any])
            let attributedString2 = NSMutableAttributedString(string: CurrencyManager.getCurrentCurrency() , attributes:attrs2 as [NSAttributedString.Key : Any])
            attributedString1.append(attributedString2)
            return attributedString1
        }else {
            var attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.secondaryBlackColor()]
            var attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(16), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
            
            if isProductWhite {
                 attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(12), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
                 attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(16), NSAttributedString.Key.foregroundColor : UIColor.navigationBarWhiteColor()]
            }
            
            let attributedString1 = NSMutableAttributedString(string: CurrencyManager.getCurrentCurrency() , attributes:attrs1 as [NSAttributedString.Key : Any])
            let price =  NSString(format: " %.2f" , priceValue)
            let attributedString2 = NSMutableAttributedString(string:price as String , attributes:attrs2 as [NSAttributedString.Key : Any])
            attributedString1.append(attributedString2)
            return attributedString1
        }
    }
    
    func getPriceStringByLanguage(price: Double, isArabic: Bool = ElGrocerUtility.sharedInstance.isArabicSelected()) -> String {
        
        if isArabic {
            return (price.formateDisplayString()).changeToArabic() + " " + localizedString("aed", comment: "")
        }else {
           return localizedString("aed", comment: "") + " " + price.formateDisplayString()
        }
    }
    
    func setNumeralsForLanguage(numeral: String,isArabic: Bool =  ElGrocerUtility.sharedInstance.isArabicSelected()) -> String {
        if isArabic {
            let arabicString = numeral.changeToArabic()
            return arabicString
        }else {
            return numeral
        }
    }
    
    func getRefernceFrom( isAddCard : Bool  ,orderID: String , ammount : Double , randomRef : String , _ cvv : String) -> String {
        return (isAddCard ? "M" : "C") + "-" + orderID + "-" + PayFortManager.getFinalAmountToHold(ammount: ammount) + "-" + "\(randomRef)"  +  (isAddCard ? "" : ("-" + "\(cvv)")) 
    }
    func refreshURLRef(url : String) -> String {
    let refValue = String(format: "%.0f", Date.timeIntervalSinceReferenceDate)
     var array =   url.components(separatedBy: "-")
        if array.count > 6 {
            array.removeLast()
        }else{
            return url
        }
        array.append(refValue)
        return array.joined(separator: "-")
    }
    func getRefernceFromWithOutAddBackEnd( isAddCard : Bool  ,orderID: String , ammount : Double , randomRef : String) -> String {
        return (isAddCard ? "M" : "C") + "-" + orderID + "-" + "\(ammount * 100)" + "-" + "\(randomRef)"
    }
    
    func getFinalServiceFee (currentGrocery : Grocery , totalPrice : Double) -> Double {
        
        var serviceFee = currentGrocery.serviceFee + currentGrocery.riderFee
        if  currentGrocery.deliveryFee > 0.0 {
            if totalPrice < currentGrocery.minBasketValue {
                serviceFee = currentGrocery.serviceFee + currentGrocery.deliveryFee
            }
        }
        return serviceFee
        
    }
    
    func getPercentage(product : Product , _ isFromOrder : Bool = false) -> Int{
        
        guard let promoPrice = isFromOrder ? product.orderPromoPrice as? Double :product.promoPrice as? Double else {return 0}
        guard let price = product.price as? Double else{return 0}
        
        var percentage : Double = 0
        if price > 0{
            let percentageDecimal = ((price - promoPrice)/price)
            percentage = percentageDecimal * 100
            // percentage  = (promoPrice / price) * 100
        }
        
        
        return Int(percentage)
    }
    
    
    func showTopMessageView (_ msg : String ,_ title : String = "", image : UIImage? , _ index : Int = -1 , _ isNeedtoShowButton : Bool = true , backButtonClicked: @escaping (Any? , Int , Bool) -> Void, buttonIcon: UIImage? = nil) {
        let view = MessageView.viewFromNib(layout: .cardView)
        //  view.configureTheme(.warning)
        
        view.iconImageView?.isHidden = true
        if let data = image {
            view.iconImageView?.image = data
            view.iconImageView?.image = view.iconImageView?.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            view.iconImageView?.isHidden = false
            view.iconImageView?.tintColor = UIColor.navigationBarWhiteColor()
        
        }
        view.id = "\(index)"
        view.iconLabel?.text = nil
        view.iconLabel?.isHidden = true
        view.button?.setImage(buttonIcon, for: .normal)
        view.button?.tintColor = .white
        view.button?.setTitle(isNeedtoShowButton && buttonIcon == nil ? localizedString("lbl_Undo", comment: "") : "", for: .normal)
        view.button?.backgroundColor = ApplicationTheme.currentTheme.currentOrdersCollectionCellBGColor
        view.button?.setBackgroundColor(ApplicationTheme.currentTheme.themeBasePrimaryBlackColor , forState: .normal)
        view.button?.setTitleColor(.white, for: .normal)
        view.button?.titleLabel?.font = .SFProDisplaySemiBoldFont(12)
        view.titleLabel?.setBodyBoldWhiteStyle()
        view.titleLabel?.text = title
        view.bodyLabel?.font = .SFProDisplayNormalFont(14)
        view.bodyLabel?.textColor = .white
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.26
        view.bodyLabel?.attributedText =  NSMutableAttributedString(string: msg , attributes: [NSAttributedString.Key.kern: 0.25, NSAttributedString.Key.paragraphStyle: paragraphStyle , NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14)])
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            view.titleLabel?.textAlignment = .right
            view.bodyLabel?.textAlignment = .right
        } else {
            view.titleLabel?.textAlignment = .left
            view.bodyLabel?.textAlignment = .left
        }
        
        if msg.contains(localizedString("tobaco_product_msg", comment: "")) {
            let msgA = (msg as NSString).components(separatedBy: "\n")
            if msgA.count > 1 {
                let semiBold = UIFont.SFProDisplayNormalFont(14)
                let extraBold = UIFont.SFProDisplaySemiBoldFont(14)
                let dict1 = [NSAttributedString.Key.foregroundColor: UIColor.white , NSAttributedString.Key.font: extraBold]
                let dict2 = [NSAttributedString.Key.foregroundColor: UIColor.white , NSAttributedString.Key.font:semiBold]
                let attttributedText = NSMutableAttributedString()
                let prefixPart = NSMutableAttributedString(string:String(format:"%@ %@",msgA[0], "\n"), attributes:dict1)
                let descriptionPart = NSMutableAttributedString(string:msgA[1] , attributes:dict2)
                attttributedText.append(prefixPart)
                attttributedText.append(descriptionPart)
                view.bodyLabel?.attributedText =  attttributedText
            }
        }
        
        
        
        // Increase the external margin around the card. In general, the effect of this setting
        // depends on how the given layout is constrained to the layout margins.
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 16, bottom: 8, right: 16)
        
        // Reduce the corner radius (applicable to layouts featuring rounded corners).
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 8
        
        (view.backgroundView as? CornerRoundingView)?.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryBlackColor
        
        
        
        var config = SwiftMessages.Config()
                
        // Disable the default auto-hiding behavior.
        config.duration = .seconds(seconds: TimeInterval.init(5))
        // Disable the interactive pan-to-hide gesture.
        config.interactiveHide = true
        
        config.presentationContext = SwiftMessages.PresentationContext.window(windowLevel: .statusBar)
        


        // Show the message.
        SwiftMessages.show(config: config, view: view)
        
        var indexValue = -1
        indexValue = index
        
        view.buttonTapHandler = { sender in
            backButtonClicked(sender , indexValue, true )
            SwiftMessages.hide()
        }
        view.tapHandler = { sender in
               backButtonClicked(sender , indexValue, false )
            SwiftMessages.hide()
            
        }
    }
    
    
    
    
    func getTableViewCellHeightForBanner (_ isNeedToShowPageControl : Bool = true) -> CGFloat {
         
        let sideMargin : CGFloat = 52
        var rowHeight =  (ScreenSize.SCREEN_WIDTH + sideMargin) / KBannerRation
        if !isNeedToShowPageControl {
            rowHeight = rowHeight - 15
        }
        return rowHeight
        
    }
    
    
    func resetTabbarIcon(_ controller : UIViewController) {
        
        DispatchQueue.main.async {
            let barButton = controller.tabBarController?.navigationItem.rightBarButtonItem as? BBBadgeBarButtonItem
            barButton?.badgeValue = "0"
            controller.tabBarController?.tabBar.items?[4].badgeValue = nil
        }
        
    }
    
    func cleanGroceryID (_ idObj : Any?) -> String  {
        
       // elDebugPrint("groceryID Comming: \(String(describing: idObj))")
        var groceryId = "0"
        guard idObj != nil else {
            return groceryId
        }
        let data = String(describing: idObj ?? "" )
        let grocerySplittedIds = (data.split {$0 == "_"}.map { String($0) })
        if grocerySplittedIds.count > 0 {
            groceryId = grocerySplittedIds.count == 1 ? grocerySplittedIds[0] : grocerySplittedIds[1]
        }
        //elDebugPrint("groceryID: \(groceryId)")
        return  groceryId
    }
    
    func GenerateRetailerIdString(_ groceryA : [Grocery]?) -> String{
        
        var retailerIDString = ""
        if groceryA?.count ?? 0 > 0{
            var i = 0
            while i < groceryA!.count {
                if i == 0 {
                    retailerIDString.append((groceryA?[i].dbID)!)
                }else{
                    retailerIDString.append("," + (groceryA?[i].dbID)!)
                }
                i = i + 1
            }
        }
        return retailerIDString
    }
    
    
    func resetTabbar(_ tabbar : UITabBarController) {
        
        if let nav = tabbar.viewControllers?[0] as? UINavigationController {
            if nav.viewControllers.count > 0 {
                nav.popToRootViewController(animated: false)
                nav.setViewControllers([nav.viewControllers[0]], animated: false)
            }
        }
        if let nav = tabbar.viewControllers?[1] as? UINavigationController {
            if nav.viewControllers.count > 0 {
                if let main = nav.viewControllers[0] as? MainCategoriesViewController {
                    nav.popToRootViewController(animated: false)
                    main.grocery = nil
                    nav.setViewControllers([main], animated: false)
                }else if let main = nav.viewControllers[1] as? MainCategoriesViewController {
                    nav.popToRootViewController(animated: false)
                    main.grocery = nil
                    nav.setViewControllers([main], animated: false)
                }
            }
        }
        if let nav = tabbar.viewControllers?[2] as? UINavigationController {
            if nav.viewControllers.count > 0 {
                if let main = nav.viewControllers[0] as? SearchListViewController {
                    nav.popToRootViewController(animated: false)
                    main.grocery = nil
                    if nav.viewControllers.count > 1 {
                        nav.setViewControllers([main], animated: false)
                    }
                }
            }
        }
        if let nav = tabbar.viewControllers?[3] as? UINavigationController {
            if nav.viewControllers.count > 0 {
                if let main = nav.viewControllers[0] as? SettingViewController {
                    nav.popToRootViewController(animated: false)
                    if nav.viewControllers.count > 1 {
                        nav.setViewControllers([main], animated: false)
                    }
                }
            }
        }
        if let nav = tabbar.viewControllers?[4] as? UINavigationController {
            if nav.viewControllers.count > 0 {
                if let main = nav.viewControllers[0] as? MyBasketViewController {
                    nav.popToRootViewController(animated: false)
                    if nav.viewControllers.count > 1 {
                        nav.setViewControllers([main], animated: false)
                    }
                }
            }
        }
    }
    
    
    func sortGroceryArray(storeTypeA: [Grocery] ) -> [Grocery] {
        
        var filteredArray = storeTypeA
        
        filteredArray =  filteredArray.sorted(by: { (one, two) -> Bool in
            (one.distance > two.distance)
        })
        filteredArray =  filteredArray.sorted(by: { (one, two) -> Bool in
            (one.distance < two.distance)
        })
        
        var instantList = [Grocery]()
        var scheduledList = [Grocery]()
        var closedList = [Grocery]()
        filteredArray.forEach { (it) in
            if(it.isOpen.boolValue && (it.isInstantSchedule() || it.isInstant())) {
                instantList.append(it)
            } else if(it.isOpen.boolValue && it.isScheduleType()) {
                scheduledList.append(it)
            } else {
                closedList.append(it)
            }
        }
        scheduledList =  scheduledList.sorted { (one, two) -> Bool in
            if ( one.deliverySlots.count > 0 ) && ( two.deliverySlots.count > 0 ) {
                if  let slotOneDate = (one.deliverySlots.allObjects[0] as? DeliverySlot)?.start_time ,  let slotTwoDate = (two.deliverySlots.allObjects[0] as? DeliverySlot)?.start_time , (one.isOpen.boolValue && two.isOpen.boolValue) {
                    return slotOneDate < slotTwoDate
                }
            }
            return false
        }
        var list = [Grocery]()
        list.append(contentsOf: instantList)
        list.append(contentsOf: scheduledList)
        list.append(contentsOf: closedList)
        
        list = list.sorted(by:{  ($0.priority?.intValue ?? 0) < ($1.priority?.intValue ?? 0) })
        list = list.sorted(by: { groceryOne, groceryTwo in
            return (groceryOne.featured?.intValue ?? 0) > (groceryTwo.featured?.intValue ?? 0)
        })
        if list.count == 0 {
            list = storeTypeA
        }
        return list
    }
    
    
    func showWebUrl(_ url: String = "https://www.elgrocer.com" , controller : UIViewController) {
        let finalUrl = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
        if let url = URL(string: finalUrl) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let vc = SFSafariViewController(url: url, configuration: config)
            vc.modalPresentationStyle = .popover
            vc.preferredBarTintColor = .white
            vc.preferredControlTintColor = .newBlackColor()
            controller.present(vc, animated: true)
        }
    }
    
    
    func isTesting() -> Bool {
        // || ElGrocerApi.sharedInstance.baseApiPath == "https://nginx.elgrocer.com/api/"
        if ElGrocerApi.sharedInstance.baseApiPath == "https://el-grocer-staging-dev.herokuapp.com/api/" || ElGrocerApi.sharedInstance.baseApiPath == "https://stg.elgrocer.com/api/"  {
            return true
        }else{
            return false
        }
    }
    
    
    func makeFilterOneSlotBasis(storeTypeA: [Grocery] ) -> [Grocery] {
        var filteredArray = storeTypeA
        filteredArray = filteredArray.sorted(by: { (one, two) -> Bool in
          (one.distance > two.distance)
        })
        filteredArray = filteredArray.sorted(by: { (one, two) -> Bool in
          (one.distance < two.distance)
        })
        var instantList = [Grocery]()
        var scheduledList = [Grocery]()
        var closedList = [Grocery]()
        filteredArray.forEach { (it) in
          if(it.isOpen.boolValue && (it.isInstantSchedule() || it.isInstant())) {
            instantList.append(it)
          } else if(it.isOpen.boolValue && it.isScheduleType()) {
            scheduledList.append(it)
          } else {
            closedList.append(it)
          }
        }
        scheduledList = scheduledList.sorted { (one, two) -> Bool in
          if ( one.deliverySlots.count > 0 ) && ( two.deliverySlots.count > 0 ) {
            if let slotOneDate = (one.deliverySlots.allObjects[0] as? DeliverySlot)?.start_time , let slotTwoDate = (two.deliverySlots.allObjects[0] as? DeliverySlot)?.start_time , (one.isOpen.boolValue && two.isOpen.boolValue) {
              return slotOneDate < slotTwoDate
            }
          }
          return false
        }
        var list = [Grocery]()
        list.append(contentsOf: instantList)
        list.append(contentsOf: scheduledList)
        list.append(contentsOf: closedList)
        list = list.sorted(by: { groceryOne, groceryTwo in
          return (groceryOne.featured?.intValue ?? 0) > (groceryTwo.featured?.intValue ?? 0)
        })
        if list.count == 0 {
          list = storeTypeA
        }
        return list
      }
    
    func calculateAEDsForSmilesPoints(_ points: Int, smilesBurntRatio: Double?) -> Double {
        var ratio = 0.0
        
        if let smilesBurntRatio = smilesBurntRatio, smilesBurntRatio > 0 {
            ratio = smilesBurntRatio
        } else {
            ratio = ElGrocerUtility.sharedInstance.appConfigData.smilesData.burning
        }
        
        let aeds = ratio * Double(points)
        return (aeds * 100).rounded() / 100
    }
   
    func calculateSmilePointsForAEDs(_ amount: Double, smilesBurntRatio: Double?) -> Int {
        var ratio = 0.0
        
        if let smilesBurntRatio = smilesBurntRatio, smilesBurntRatio > 0 {
            ratio = smilesBurntRatio
        } else {
            ratio = ElGrocerUtility.sharedInstance.appConfigData.smilesData.burning
        }

        return Int(round(amount / ratio))
    }
}


class GenericClass {
    class func print(_ items: Any..., function: String = #function) -> Void {
        #if DEBUG
        var idx = items.startIndex
        let endIdx = items.endIndex
        Swift.print("=> FuncationName:\(function as Any) <=")
        repeat {
            Swift.print(items[idx], separator: " ", terminator: idx == (endIdx - 1) ? "\n" : " ")
            idx += 1
        } while idx < endIdx
        #endif
    }
}
struct Platform {
    static let isSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
    static let isDebugBuild: Bool = {
        
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    static let isTestFlight: Bool = {
        guard let path = Bundle.resource.appStoreReceiptURL?.path else {
            return false
        }
        return path.contains("sandboxReceipt")
    }()
    
}

extension DispatchQueue {
    
    private struct QueueReference { weak var queue: DispatchQueue? }
    
    private static let key: DispatchSpecificKey<QueueReference> = {
        let key = DispatchSpecificKey<QueueReference>()
        let queue = DispatchQueue.main
        queue.setSpecific(key: key, value: QueueReference(queue: queue))
        return key
    }()
    
    static var isRunningOnMainQueue: Bool { getSpecific(key: key)?.queue == .main }
}

extension UIViewController {
    
    func hideTabBar() {
        self.tabBarController?.tabBar.isHidden = true
        self.presentingViewController?.tabBarController?.tabBar.isHidden = true
        self.extendedLayoutIncludesOpaqueBars = true
        self.edgesForExtendedLayout = UIRectEdge.bottom
    }
    
    
    
    
    
    func setupClearNavBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func setupGradient(height: CGFloat, topColor: CGColor, bottomColor: CGColor) ->  CAGradientLayer {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.colors = [topColor,bottomColor]
            gradient.locations = [0.0 , 1.0]
            gradient.startPoint = CGPoint(x: 0.25, y: 0.5)
            gradient.endPoint = CGPoint(x: 0.75, y: 0.5)
            gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: height)
            return gradient
        }
}


extension UIView {
    
        func setupGradient(height: CGFloat, topColor: CGColor, bottomColor: CGColor) ->  CAGradientLayer {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.colors = [topColor,bottomColor]
            gradient.locations = [0.0 , 1.0]
            gradient.startPoint = CGPoint(x: 0.25, y: 0.5)
            gradient.endPoint = CGPoint(x: 0.75, y: 0.5)
            gradient.frame = CGRect(x: 0.0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: height + 10)
            return gradient
        }
}

