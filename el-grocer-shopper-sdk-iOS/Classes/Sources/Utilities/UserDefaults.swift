//
//  UserDefaults.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 06.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

public class UserDefaults {
    
    static var notificationAskDate: Date? {
        set {
            let date = newValue!
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "dd/MM/yyyy HH:mm:ss"
            Foundation.UserDefaults.standard.set(dateFormater.string(from: date), forKey: "NotificationAskDateKey")
        }
        get {
            let dateString = Foundation.UserDefaults.standard.string(forKey: "NotificationAskDateKey") ?? ""
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "dd/MM/yyyy HH:mm:ss"
            return dateFormater.date(from: dateString)
        }
    }
    
    // MARK: Login state
    
    class func setLogInUserID(_ userID : String)  {
        Foundation.UserDefaults.standard.set(userID, forKey: "loggedINuserID")
        Foundation.UserDefaults.standard.synchronize()
    }
    
    class func getLogInUserID() -> String  {
        var user_id = Foundation.UserDefaults.standard.string(forKey: "loggedINuserID") ?? "0"
        if user_id == "0" {
            let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            user_id = userProfile?.dbID.stringValue ?? "0"
        }
        return user_id
    }
    
    
    class func isUserLoggedIn() -> Bool {
        
        return Foundation.UserDefaults.standard.bool(forKey: "userLoggedIn")
    
    }
    
    class func isAnalyticsIdentificationCompleted() -> Bool {
        return Foundation.UserDefaults.standard.bool(forKey: "getAnalyticsIdentificationCompleted")
    }
    
    class func setIsAnalyticsIdentificationCompleted(new value: Bool) {
        Foundation.UserDefaults.standard.set(value, forKey: "getAnalyticsIdentificationCompleted")
    }
    
    class func setUserLoggedIn(_ logged:Bool) {
       // SendBirdManager().setPushNotification(enable: logged, completionHandler: nil)
       // SendBirdDeskManager(type: .agentSupport).setPushNotification(enable: logged)
        Foundation.UserDefaults.standard.set(logged, forKey: "userLoggedIn")
        Foundation.UserDefaults.standard.synchronize()
    }
    
    // Keep track of shopper is logged in with smiles or not
    // On the base of this on Checkout screen we are showing error message when user try to apply smiles point
    class func setSmilesUserLoggedIn(status: Bool) {
        Foundation.UserDefaults.standard.set(status, forKey: "SmilesUserLoggedIn")
        Foundation.UserDefaults.standard.synchronize()
    }
    
    class func isSmilesUserLoggedIn() -> Bool {
        return Foundation.UserDefaults.standard.bool(forKey: "SmilesUserLoggedIn")
    }
    
    // MARK: Promo code value
    
    class func getPromoCodeValue() -> PromotionCode? {
        var loadedPromotionCode : PromotionCode? = nil
        if let loadedData = Foundation.UserDefaults().data(forKey: "promoCodeValue") {
            do {
//                let promotionCode = try NSKeyedUnarchiver.unarchivedObject(ofClass: PromotionCode.self, from: loadedData)
                let promotionCode = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [PromotionCode.self,NSArray.self,NSDictionary.self], from: loadedData) as? PromotionCode
                loadedPromotionCode = promotionCode
            } catch (let error) {
                elDebugPrint("error: \(error.localizedDescription)")
            }
        }
        return loadedPromotionCode
    }
    
   
    
    
    class func setPromoCodeValue(_ value:Data?) {
        Foundation.UserDefaults.standard.set(value, forKey: "promoCodeValue")
        Foundation.UserDefaults.standard.synchronize()
    }

    class func setPromoCodeIsFromText(_ value: Bool?) {
        Foundation.UserDefaults.standard.set(value, forKey: "promoCodeIsFromText")
        Foundation.UserDefaults.standard.synchronize()
    }
    class func getPromoCodeIsFromText() -> Bool? {
        if let isFromText = Foundation.UserDefaults.standard.bool(forKey: "promoCodeIsFromText") as? Bool {
            return isFromText
        }
        return false
    }

    

    // MARK: Did user set address
    
    class func didUserSetAddress() -> Bool {
        
        return Foundation.UserDefaults.standard.bool(forKey: "didUserSetAddress")
    }
    
    class func setDidUserSetAddress(_ logged:Bool) {
        
        Foundation.UserDefaults.standard.set(logged, forKey: "didUserSetAddress")
        Foundation.UserDefaults.standard.synchronize()
    }
        
    // MARK: Access Token
    
    class func getAccessToken() -> String? {
        return Foundation.UserDefaults.standard.string(forKey: "accessToken")
    }


    
    class func setAccessToken(_ accessToken:String?) {
        Foundation.UserDefaults.standard.set(accessToken, forKey: "accessToken")
        Foundation.UserDefaults.standard.synchronize()
        FireBaseEventsLogger.setUserProperty(accessToken , key: "Authentication-Token")
    }

    // MARK: Push device token
    
    class func getDevicePushToken() -> String? {
        
        return Foundation.UserDefaults.standard.string(forKey: "DevicePushToken")
    }
    
    class func setDevicePushToken(_ value:String) {
        
        Foundation.UserDefaults.standard.set(value, forKey: "DevicePushToken")
        Foundation.UserDefaults.standard.synchronize()
    }
    class func getDevicePushTokenData() -> Data? {
        
        return Foundation.UserDefaults.standard.data(forKey: "DevicePushTokenData")
    }
    
    class func setDevicePushTokenData(_ value:Data) {
        
        Foundation.UserDefaults.standard.set(value, forKey: "DevicePushTokenData")
        Foundation.UserDefaults.standard.synchronize()
    }
    class func isDevicePushTokenRegistered() -> Bool? {
        
        return Foundation.UserDefaults.standard.bool(forKey: "isDevicePushTokenRegistered")
    }
    
    class func setIsDevicePushTokenRegistered(_ value:Bool) {
        
        Foundation.UserDefaults.standard.set(value, forKey: "isDevicePushTokenRegistered")
        Foundation.UserDefaults.standard.synchronize()
    }
    
    // MARK: Tutorial screen
    
    class func getExclusiveDealsPromo() -> (code: String, retailerId: String){
        

        let data =  Foundation.UserDefaults.standard.value(forKey: "exclusiveDealsPromo") as? [String : Any] ?? [:]
        
        let code = data["code"] as? String ?? ""
        let retailerId = data["retailer_id"] as? String ?? ""
        
        return (code,retailerId)
    }
    
    class func setExclusiveDealsPromo(promo: ExclusiveDealsPromoCode) {
        
        var data: [String: Any] = ["code": promo.code ?? "", "retailer_id": String(promo.retailer_id ?? 0) ]
        Foundation.UserDefaults.standard.set(data, forKey: "exclusiveDealsPromo")
        Foundation.UserDefaults.standard.synchronize()
    }
    
    class func deleteExclusiveDealsPromo(promo: ExclusiveDealsPromoCode) {
        
        Foundation.UserDefaults.standard.removeObject(forKey: "exclusiveDealsPromo")
        Foundation.UserDefaults.standard.synchronize()
    }
    
    // MARK: Tutorial screen
    
    class func wasTutorialImageShown(_ tutorialImage:TutorialView.TutorialImage) -> Bool {
        
        let imageName = "\(tutorialImage)"
        return Foundation.UserDefaults.standard.bool(forKey: imageName)
    }
    
    class func setTutorialImageAsShown(_ tutorialImage:TutorialView.TutorialImage) {
        
        let imageName = "\(tutorialImage)"
        Foundation.UserDefaults.standard.set(true, forKey: imageName)
    }
    
    // MARK: Helpshift reply
    
    class func isHelpShiftChatResponseUnread() -> Bool {
        
        return Foundation.UserDefaults.standard.bool(forKey: "HelpshiftChatResponse")
    }
    
    class func setHelpShiftChatResponseUnread(_ value:Bool) {
        
        Foundation.UserDefaults.standard.set(value, forKey: "HelpshiftChatResponse")
        Foundation.UserDefaults.standard.synchronize()
    }
    
    // MARK: App version
    
    /** Stores the app version from last run */
    static var appLastVersion: String {
        get {
            return Foundation.UserDefaults.standard.string(forKey: "lastVersionNumberKey") ?? ""
        } set {
            Foundation.UserDefaults.standard.set(newValue, forKey: "lastVersionNumberKey")
        }
    }
    
    // MARK: LocationView Tutorial
    
    class func wasLocationTutorialShown() -> Bool {
        
        return Foundation.UserDefaults.standard.bool(forKey: "LocationTutorial")
    }
    
    class func setLectionTutorialAsShown(_ value:Bool) {
        
        Foundation.UserDefaults.standard.set(value, forKey: "LocationTutorial")
        Foundation.UserDefaults.standard.synchronize()
    }
        
    // MARK: Leave Us Note
    
    class func getLeaveUsNote() -> String? {
        return Foundation.UserDefaults.standard.string(forKey: "LeaveUsNote")
    }
    
    class func setLeaveUsNote(_ leaveUsNote:String?) {
        Foundation.UserDefaults.standard.set(leaveUsNote, forKey: "LeaveUsNote")
        Foundation.UserDefaults.standard.synchronize()
    }
    
    
    // MARK: Payment Method
    
    class func getPaymentMethod(forStoreId storeID : String) -> UInt32 {
        let key = "Payment" + storeID
        elDebugPrint("get key Obj : \(key) : value : \(UInt32(Foundation.UserDefaults.standard.integer(forKey: key)))")
        return UInt32(Foundation.UserDefaults.standard.integer(forKey: key))
    }
    
    class func setPaymentMethod(_ payment:UInt32 , forStoreId storeID : String) {
        let key = "Payment" + storeID
        elDebugPrint("set key Obj : \(key) : value : \(Int(payment))")
        Foundation.UserDefaults.standard.set(Int(payment), forKey: key)
        Foundation.UserDefaults.standard.synchronize()
    }
    
    // MARK: Location Fetching
    class func wasLocationFetched() -> Bool {
        return Foundation.UserDefaults.standard.bool(forKey: "LocationFetched")
    }
    class func setLocationFetched(_ value:Bool) {
        Foundation.UserDefaults.standard.set(value, forKey: "LocationFetched")
        Foundation.UserDefaults.standard.synchronize()
    }
    // MARK: Wallet Paid Amount
    class func getWalletPaidAmount() -> String? {
        return Foundation.UserDefaults.standard.string(forKey: "WalletPaidAmount")
    }
    class func setWalletPaidAmount(_ amount:String?) {
        Foundation.UserDefaults.standard.set(amount, forKey: "WalletPaidAmount")
        Foundation.UserDefaults.standard.synchronize()
    }
    // MARK: Shake Search Hint
    class func getShakeSearchHintCount() -> Int {
        return Foundation.UserDefaults.standard.integer(forKey: "ShakeSearchHintCount")
    }
    class func setShakeSearchHintCount(_ shakeCount:Int) {
        Foundation.UserDefaults.standard.set(shakeCount, forKey: "ShakeSearchHintCount")
        Foundation.UserDefaults.standard.synchronize()
    }
    // MARK: Location Fetching
    class func wasNavigateToHomeAfterInstall() -> Bool {
        return Foundation.UserDefaults.standard.bool(forKey: "NavigateToHomeAfterInstall")
    }
    class func setNavigateToHomeAfterInstall(_ value:Bool) {
        Foundation.UserDefaults.standard.set(value, forKey: "NavigateToHomeAfterInstall")
        Foundation.UserDefaults.standard.synchronize()
    }
    // MARK: Delivery Slot
    class func getCurrentSelectedDeliverySlotId() -> NSNumber {
        let slotId = Foundation.UserDefaults.standard.integer(forKey: "DeliverySlotId")
        return NSNumber(value: slotId as Int)
    }
    class func setCurrentSelectedDeliverySlotId(_ slotId:NSNumber) {
        Foundation.UserDefaults.standard.set(Int(truncating: slotId), forKey: "DeliverySlotId")
        Foundation.UserDefaults.standard.synchronize()
    }
    
    // MARK: Delivery Slot for Edit order
    class func setEditOrderSelectedDelivery(_ value:Any?) {
        Foundation.UserDefaults.standard.set(value , forKey: "DeliverySlotObj")
        Foundation.UserDefaults.standard.synchronize()
    }
    class func getEditOrderSelectedDeliverySlot() -> Any? {
        if let loadedData = Foundation.UserDefaults().object(forKey: "DeliverySlotObj") {
             return loadedData
        }
        return nil
    }
    // MARK: Order Deliver Popup
    class func getOrderDeliverPopupCount() -> Int {
        return Foundation.UserDefaults.standard.integer(forKey: "OrderDeliverPopupCount")
    }
    class func setOrderDeliverPopupCount(_ shakeCount:Int) {
        Foundation.UserDefaults.standard.set(shakeCount, forKey: "OrderDeliverPopupCount")
        Foundation.UserDefaults.standard.synchronize()
    }
    // MARK: Language Selection
    class func isLanguageSelectionShown() -> Bool {
        return Foundation.UserDefaults.standard.bool(forKey: "LanguageSelection")
    }
    class func setLanguageSelectionShown(_ logged:Bool) {
        Foundation.UserDefaults.standard.set(logged, forKey: "LanguageSelection")
        Foundation.UserDefaults.standard.synchronize()
    }
    class func getCurrentLanguage() -> String? {
        return Foundation.UserDefaults.standard.string(forKey: "CurrentLanguage")
    }
    public class func setCurrentLanguage(_ currentLang:String?) {
        Foundation.UserDefaults.standard.setValue(currentLang, forKey: "CurrentLanguage")
        Foundation.UserDefaults.standard.synchronize()
    }
    // MARK: Grocery Persistence With Location
    class func getGroceryIdWithLocationId(_ locationId:String) -> String? {
        let finalID = locationId + "elgrocer"
        if let valueString = Foundation.UserDefaults.standard.string(forKey: finalID) {
            return valueString
        }
        return Foundation.UserDefaults.standard.string(forKey: locationId)
    }
    class func setGroceryId(_ groceryId:String?, WithLocationId locationId:String){
        let finalID = locationId + "elgrocer"
        Foundation.UserDefaults.standard.setValue(groceryId, forKey: finalID)
        Foundation.UserDefaults.standard.synchronize()
        elDebugPrint("groceryId : \(String(describing: groceryId)) & locationId : \(finalID)")
    }
    // MARK: Basket Initiation
    class func isBasketInitiated() -> Bool {
       return Foundation.UserDefaults.standard.bool(forKey: "BasketInitiated")
    }
    class func setBasketInitiated(_ logged:Bool) {
        Foundation.UserDefaults.standard.set(logged, forKey: "BasketInitiated")
        Foundation.UserDefaults.standard.synchronize()
    }
    // MARK: Review Popup Count
    class func getOrderReviewPopUpCount() -> Int {
        return Foundation.UserDefaults.standard.integer(forKey: "OrderReviewPopUpCount")
    }
    class func setOrderReviewPopUpCount(_ viewCount:Int) {
        Foundation.UserDefaults.standard.set(viewCount, forKey: "OrderReviewPopUpCount")
        Foundation.UserDefaults.standard.synchronize()
    }
    //MARK: checkout place order aditional instructions
    class func getAdditionalInstructionsNote() -> String? {
        return Foundation.UserDefaults.standard.string(forKey: "AdditionalInstructionsNote")
    }
    
    class func setAdditionalInstructionsNote(_ Note:String?) {
        Foundation.UserDefaults.standard.set(Note, forKey: "AdditionalInstructionsNote")
        Foundation.UserDefaults.standard.synchronize()
    }
    // MARK: Set View Option
    class func isGridView() -> Bool {
        return Foundation.UserDefaults.standard.bool(forKey: "GridView")
    }
    
    class func setIsGridView(_ isGridView:Bool) {
        Foundation.UserDefaults.standard.set(isGridView, forKey: "GridView")
        Foundation.UserDefaults.standard.synchronize()
    }

    class func setLastSearchList(_ listString : String) -> Void {
        Foundation.UserDefaults.standard.set(listString, forKey: "searchList")
        Foundation.UserDefaults.standard.synchronize()
    }
    
    class func getLastSearchList() -> String? {
        return Foundation.UserDefaults.standard.string(forKey: "searchList")
    }
    //MARK:- Edit Order
    class func setEditOrder(_ order : Order)  {
        guard order.dbID.stringValue.isEmpty else {
            let reasonKey = order.substitutionPreference ?? NSNumber.init(value: -1)
            let reason = Reasons.init(key: reasonKey, reason: "")
            let reasonData = try? NSKeyedArchiver.archivedData(withRootObject: reason , requiringSecureCoding: false)
            UserDefaults.setSelectedReason(reasonData)
            Foundation.UserDefaults.standard.set( order.dbID , forKey: "editOrderID")
            Foundation.UserDefaults.standard.set( Date().dataInCurrent() , forKey: "editOrderDate")
            Foundation.UserDefaults.standard.set((order.cardType == "7" || order.cardType == "8"), forKey: "isApplePay")
            UserDefaults.setLeaveUsNote(order.orderNote)
            if let promoCode = order.promoCode {
                let promoCodeObjData = NSKeyedArchiver.archivedData(withRootObject: promoCode)
                UserDefaults.setPromoCodeValue(promoCodeObjData)
            }
            if let deliverySlot = order.deliverySlot {
                let deliveryData = ["dbID" : deliverySlot.dbID , "usid" : deliverySlot.dbID  , "start_time" : deliverySlot.start_time?.convertDateToUTCString() ?? "" , "end_time" : deliverySlot.end_time?.convertDateToUTCString() ?? ""  , "estimated_delivery_at" :  deliverySlot.estimated_delivery_at.convertDateToUTCString() ?? "" , "time_milli" : deliverySlot.time_milli , "isInstant" : deliverySlot.isInstant  ] as [String : Any]
                            UserDefaults.setEditOrderSelectedDelivery(deliveryData)
                            UserDefaults.setCurrentSelectedDeliverySlotId(deliverySlot.dbID)
            }
            if let slots =  UserDefaults.getEditOrderSelectedDeliverySlot() {
                let _ = DeliverySlot.createDeliverySlotFromCustomDictionary(slots as! NSDictionary, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            }
            if let paymentType = order.payementType {
                UserDefaults.setPaymentMethod(UInt32(paymentType.int32Value), forStoreId: ElGrocerUtility.sharedInstance.cleanGroceryID(order.dbID.stringValue))
            }
            
            
            return
        }
    }
    
    class func isApplePayOrder() -> Bool  {
       let isApplePay = Foundation.UserDefaults.standard.bool(forKey: "isApplePay")
        if isApplePay {
            return true
        }
        
        return false
    }
    
    class func resetEditOrder(_ isNeedToResetPromo : Bool = true)  {
        Foundation.UserDefaults.standard.removeObject(forKey: "editOrderID")
        Foundation.UserDefaults.standard.removeObject(forKey: "editOrderDate")
        Foundation.UserDefaults.standard.removeObject(forKey: "DeliverySlotId")
        Foundation.UserDefaults.standard.removeObject(forKey: "DeliverySlotObj")
        Foundation.UserDefaults.standard.removeObject(forKey: "isApplePay")
        
        if isNeedToResetPromo {
            UserDefaults.setLeaveUsNote(nil)
            UserDefaults.setPromoCodeValue(nil)
        }
        UserDefaults.setCurrentSelectedDeliverySlotId(0)
        UserDefaults.setEditOrderSelectedDelivery(nil)
    }
    class func isOrderInEdit() -> Bool  {
        if let orderiD = Foundation.UserDefaults.standard.string(forKey: "editOrderID") {
            if !orderiD.isEmpty {
                return true
            }
        }
        return false
    }
    class func getEditOrderDate () -> Date? {
        return Foundation.UserDefaults.standard.object(forKey: "editOrderDate") as? Date
    }
    class func getEditOrderDbId () -> NSNumber? {
        return Foundation.UserDefaults.standard.object(forKey: "editOrderID") as? NSNumber
    }
    class func removeOrderFromEdit()  {
       Foundation.UserDefaults.standard.removeObject(forKey: "editOrderID")
    }
    class func setClearEditOrder (_ needToClear : Bool) {
     Foundation.UserDefaults.standard.set(needToClear , forKey: "clearEditOrder")
    }
    
    class func isNeedToClearEditOrder() -> Bool {
        return Foundation.UserDefaults.standard.bool(forKey: "clearEditOrder")
    }
    //MARK:- Over18
    class func setOver18 (_ over18 : Bool , _ isFirstTime : Bool = false) {
        Foundation.UserDefaults.standard.set(over18 , forKey: "isUserSelectOver18")
        if let appDelegate = UIApplication.shared.delegate {
            if let winDowsView = appDelegate.window {
                if let _ = winDowsView?.viewWithTag(KtobbacoViewTag) {
                    FireBaseEventsLogger.trackAbove18(over18)
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                        ElGrocerApi.sharedInstance.changePGStatus(status: over18, msg: ElGrocerUtility.sharedInstance.appConfigData?.pg_18_msg ?? "") { (data) in
                        }
                    }
                }
            }
        }
    }
    
    class func isUserOver18() -> Bool {
        return Foundation.UserDefaults.standard.bool(forKey: "isUserSelectOver18")
    }
    //MARK: Substitute
    class func setSubstituteAgainstOrderID(_ orderID : String , productID : String) -> Void  {
        Foundation.UserDefaults.standard.set(productID , forKey: "\(orderID)\(productID)"  )
        Foundation.UserDefaults.standard.synchronize()
    }
    class func selectedProductID (_ orderID : String , productID : String ) -> String?  {
         return Foundation.UserDefaults.standard.object(forKey: "\(orderID)\(productID)") as? String
    }
    class func removeSubSelectedAgainst (_ orderID : String , productID : String ) -> Void  {
        Foundation.UserDefaults.standard.removeObject(forKey: "\(orderID)\(productID)")
    }
    //MARK:- Last selected Payment
    class func setLastPaymentType( type : Int , userID : String) {
        Foundation.UserDefaults.standard.set(type , forKey: userID)
        Foundation.UserDefaults.standard.synchronize()
    }
    class func getLastPaymentTypeForUser(  userID : String)  -> Any {
        return Foundation.UserDefaults.standard.object(forKey: userID ) as Any
    }
    //MARK: Sponsored
    class func setSponsoredItems(_ product:Product , WithGrocerID GrocerID:String){
        
        let productID = "\(Product.getCleanProductId(fromId: product.dbID))"
        let finalID = GrocerID + "elgrocerSponsered"
        var userExsistingData : [String] = []
        if let data = UserDefaults.getSponsoredItemArray(grocerID: GrocerID) {
            userExsistingData = data
        }
        userExsistingData.append(productID)
        Foundation.UserDefaults.standard.setValue(userExsistingData, forKey: finalID)
        Foundation.UserDefaults.standard.synchronize()
        elDebugPrint("sponseredData : \(String(describing: userExsistingData)) & GrocerID : \(finalID)")
        
    }
    class func getSponsoredItemArray (grocerID : String) -> [String]? {
         let finalID = grocerID + "elgrocerSponsered"
        return Foundation.UserDefaults.standard.value(forKey: finalID) as? [String]
    }
    class func removeSponsoredItemArray (grocerID : String) {
        let finalID = grocerID + "elgrocerSponsered"
         Foundation.UserDefaults.standard.setValue(nil, forKey: finalID)
         Foundation.UserDefaults.standard.synchronize()
    }
    //MARK: Banners
    class func isBannerDisplayed (_ bannerID : String , topControllerName : String) -> Bool {
         let bannerIDList = UserDefaults.getBannerIDListForVC(topControllerName: topControllerName)
            if bannerIDList is [String] {
                let bannerIDListA = bannerIDList as! [String]
                return bannerIDListA.indexes(of: bannerID).count > 0
            }
         return false
    }
    class func addBannerID (_ bannerID : String , topControllerName : String) -> Void {
        let bannerIDList = UserDefaults.getBannerIDListForVC(topControllerName: topControllerName)
        if bannerIDList is [String] {
            var listString = bannerIDList as! [String]
            listString.append(bannerID)
            Foundation.UserDefaults.standard.setValue(listString, forKey: topControllerName)
            Foundation.UserDefaults.standard.synchronize()
        }else{
            Foundation.UserDefaults.standard.setValue([bannerID], forKey: topControllerName)
            Foundation.UserDefaults.standard.synchronize()
        }
    }
    class func getBannerIDListForVC (topControllerName : String) -> Any {
        return Foundation.UserDefaults.standard.object(forKey: topControllerName ) as Any
    }
    class func removeBannerView (topControllerName : String) -> Void {
        Foundation.UserDefaults.standard.setValue(nil, forKey: topControllerName)
        Foundation.UserDefaults.standard.synchronize()
    }
    //MARK: CreditCard Save
    class func setCardID (cardID : String , userID : String) {
        let finalID = userID + "cardID" + "elgrocer"
        Foundation.UserDefaults.standard.setValue(cardID, forKey: finalID)
    }
    class func getCardID ( userID : String) -> String {
        let finalID = userID + "cardID" + "elgrocer"
        return Foundation.UserDefaults.standard.string(forKey: finalID) ?? ""
    }
    class func removeCurrentSelectedCard (userID : String) {
        let finalID = userID + "cardID" + "elgrocer"
        Foundation.UserDefaults.standard.removeObject(forKey: finalID)
    }
    //MARK: Merchant
    class func setMerchantRef ( ref : String  , userID : String) {
        let finalID = UserDefaults.getCardID(userID: userID) + userID + "ref" + "elgrocer"
        Foundation.UserDefaults.standard.setValue(ref, forKey: finalID)
    }
    class func getMerchantRef (  userID : String ) -> String {
        let finalID = UserDefaults.getCardID(userID: userID) + userID + "ref" + "elgrocer"
        return Foundation.UserDefaults.standard.string(forKey: finalID) ?? ""
    }
    class func removeMerchantRef ( userID : String ) {
        let finalID = UserDefaults.getCardID(userID: userID) + userID + "ref" + "elgrocer"
        Foundation.UserDefaults.standard.setValue(nil, forKey: finalID)
        Foundation.UserDefaults.standard.synchronize()
    }
    
 //MARK: Amount
    class func setAmountRef ( userID : String , ammount : String) {
        let finalID = UserDefaults.getCardID(userID: userID) + userID + "amount" + "elgrocer"
        Foundation.UserDefaults.standard.setValue(ammount, forKey: finalID)
    }
    class func getAmountRef ( userID : String) -> String {
        let finalID = UserDefaults.getCardID(userID: userID) + userID + "amount" + "elgrocer"
        return Foundation.UserDefaults.standard.string(forKey: finalID) ?? ""
    }
    class func removeAmountRef (userID : String) {
        let finalID = UserDefaults.getCardID(userID: userID) + userID + "amount" + "elgrocer"
        Foundation.UserDefaults.standard.setValue(nil, forKey: finalID)
        Foundation.UserDefaults.standard.synchronize()
    }
    //MARK: Set CVV
    class func setSecureCVV(userID : String , cardID : String , cvv: String) -> Bool {
     return KeychainService.savePassword(service: CustomKeyChainConst.service.rawValue, account: "elgrocer" + userID + cardID  , data: cvv)
    }
    class func getSecureCVV(userID : String , cardID : String) -> String? {
        return KeychainService.loadPassword(service: CustomKeyChainConst.service.rawValue, account: "elgrocer" + userID + cardID )
    }
    class func setIsPopAlreadyDisplayed(_ value : Bool) -> Void {
        Foundation.UserDefaults.standard.set(value, forKey: "isNeedToShowPopUp")
        Foundation.UserDefaults.standard.synchronize()
    }
    class func getIsPopAlreadyDisplayed() -> Bool? {
        return Foundation.UserDefaults.standard.bool(forKey: "isNeedToShowPopUp")
    }
    //MARK: Algolia Analytics Data
    class func setAddToCartInAlgolia (productID : [String], querIDs : String , in grocerID : String) {
        var data = UserDefaults.getAddToCartInAlgolia(groceryID: grocerID)
        var productIDA : [String] = data[querIDs] ?? []
        productIDA.append(contentsOf: productID)
        data[querIDs] = productIDA
        let finalID = grocerID + "elgrocerAlgolia"
        Foundation.UserDefaults.standard.setValue(data, forKey: finalID)
    }
    class func getAddToCartInAlgolia (  groceryID : String ) -> Dictionary <String, [String]> {
        let finalID = groceryID + "elgrocerAlgolia"
        if ((Foundation.UserDefaults.standard.dictionary(forKey: finalID) as? Dictionary<String, [String]>) != nil) {
            return Foundation.UserDefaults.standard.dictionary(forKey: finalID) as! Dictionary<String, [String]>
        }
        return [:]
    }
    class func removeAddToCartInAlgoliaData ( groceryID : String ) {
        let finalID = groceryID + "elgrocerAlgolia"
        Foundation.UserDefaults.standard.setValue(nil, forKey: finalID)
        Foundation.UserDefaults.standard.synchronize()
    }
    //MARK: user accepted Payment terms state
    class func setPaymentAcceptedState (_ isAccecpted : Bool) {
        Foundation.UserDefaults.standard.set(isAccecpted , forKey: "isAccecpted")
        Foundation.UserDefaults.standard.synchronize()
    }
    class func getPaymentAcceptedState () -> Bool? {
        Foundation.UserDefaults.standard.bool(forKey: "isAccecpted")
    }
    //MARK: User search
    // user search
    // to make it user depedent assign userid
    // sign and logout logic need to implement from not login case
    class func setUserSearchData (_ searchString : String , _ userID : String? = nil)  {
        guard searchString.count > 0 else {
            return
        }
        var keyValue = "currentUserSearch"
        if userID != nil {
            keyValue = keyValue+userID!
        }
        var currentDataA = [String]()
        if let dataA = UserDefaults.getUserSearchData() {
            currentDataA = dataA
        }
        let data =  currentDataA.firstIndex(where: {  $0.lowercased() == searchString.lowercased() })
        if data == nil {
            if currentDataA.count == 0 {
                currentDataA.append(searchString.lowercased())
            }else{
                currentDataA.insert(searchString.lowercased(), at: 0)
            }
            if currentDataA.count > 8 {
                currentDataA = Array(currentDataA.prefix(8)) as [String]
            }
            Foundation.UserDefaults.standard.set(currentDataA , forKey: keyValue)
            Foundation.UserDefaults.standard.synchronize()
        }
    }
    class func getUserSearchData (_ userID : String? = nil ) -> [String]? {
        var keyValue = "currentUserSearch"
        if userID != nil {
            keyValue = keyValue+userID!
        }
        return Foundation.UserDefaults.standard.object(forKey: keyValue) as? [String]
    }
    class func clearUserSearchData (_ userID : String? = nil ) -> Void {
        var keyValue = "currentUserSearch"
        if userID != nil {
            keyValue = keyValue+userID!
        }
        Foundation.UserDefaults.standard.set([] , forKey: keyValue)
        Foundation.UserDefaults.standard.synchronize()
    }
    class func removeUserSearchData (_ searchString : String , _ userID : String? = nil)  {
        guard searchString.count > 0 else {
            return
        }
        var keyValue = "currentUserSearch"
        if userID != nil {
            keyValue = keyValue+userID!
        }
        var currentDataA = [String]()
        if let dataA = UserDefaults.getUserSearchData() {
            currentDataA = dataA
        }
        let data =  currentDataA.firstIndex(where: {  $0.lowercased() == searchString.lowercased() })
        if data != nil {
            if let index = data {
                currentDataA.remove(at: index)
            }
          
        }
        Foundation.UserDefaults.standard.set(currentDataA , forKey: keyValue)
        Foundation.UserDefaults.standard.synchronize()
    }
    //MARK: Collector
    class func setCurrentSelectedCollector (_ dbID : Int ) -> Void {
        let keyValue = "setCurrentSelectedCollector"
        Foundation.UserDefaults.standard.set(dbID , forKey: keyValue)
        Foundation.UserDefaults.standard.synchronize()
    }
    class func getCurrentSelectedCollector () -> Int? {
        let keyValue = "setCurrentSelectedCollector"
        return Foundation.UserDefaults.standard.integer(forKey: keyValue)
    }
    class func removeCurrentSelectedCollector () {
        let keyValue = "setCurrentSelectedCollector"
        Foundation.UserDefaults.standard.removeObject(forKey: keyValue)
    }
    //MARK: Car
    class func setCurrentSelectedCar (_ dbID : Int ) -> Void {
        
        let keyValue = "setCurrentSelectedCar"
        Foundation.UserDefaults.standard.set(dbID , forKey: keyValue)
        Foundation.UserDefaults.standard.synchronize()
    }
    class func getCurrentSelectedCar () -> Int? {
        let keyValue = "setCurrentSelectedCar"
        return Foundation.UserDefaults.standard.integer(forKey: keyValue)
    }
    class func removeCurrentSelectedCar () {
        let keyValue = "setCurrentSelectedCar"
        Foundation.UserDefaults.standard.removeObject(forKey: keyValue)
    }
    //MARK: Tutorial
    class func setSwitchModeTutorialShow ()  {
        let keyValue = "isSwitchModeTutorialShow"
        Foundation.UserDefaults.standard.set(true , forKey: keyValue)
        Foundation.UserDefaults.standard.synchronize()
    }
    class func isSwitchModeTutorialShow () -> Bool? {
        let keyValue = "isSwitchModeTutorialShow"
        return Foundation.UserDefaults.standard.object(forKey: keyValue) as? Bool
    }
    //MARK: Order screen Banner logic
    class func isOrderDisplayed (_ orderId : String , topControllerName : String) -> Bool {
        
        let bannerIDList = UserDefaults.getOrderIdListForVC(topControllerName: topControllerName)
        if bannerIDList is [String] {
            let bannerIDListA = bannerIDList as! [String]
            return bannerIDListA.indexes(of: orderId).count > 0
        }
        return false
    }
    class func addOrderID (_ bannerID : String , topControllerName : String) -> Void {
        
        let bannerIDList = UserDefaults.getOrderIdListForVC(topControllerName: topControllerName )
        if bannerIDList is [String] {
            var listString = bannerIDList as! [String]
            listString.append(bannerID)
            Foundation.UserDefaults.standard.setValue(listString, forKey: topControllerName + "orderID")
            Foundation.UserDefaults.standard.synchronize()
        }else{
            Foundation.UserDefaults.standard.setValue([bannerID], forKey: topControllerName + "orderID")
            Foundation.UserDefaults.standard.synchronize()
        }
        
    }
    class func getOrderIdListForVC (topControllerName : String) -> Any {
        return Foundation.UserDefaults.standard.object(forKey: topControllerName + "orderID") as Any
    }
    class func removeOrderIdView (topControllerName : String) -> Void {
        Foundation.UserDefaults.standard.setValue(nil, forKey: topControllerName + "orderID")
        Foundation.UserDefaults.standard.synchronize()
    }
    
    
    //MARK:- Reasons local data
    
    class func getSelectedReason() -> Reasons? {
        
        var loadedReasons : Reasons? = nil
        if let loadedData = Foundation.UserDefaults().data(forKey: "loadedReasons") {
            do {
                let promotionCode = try NSKeyedUnarchiver.unarchivedObject(ofClass: Reasons.self, from: loadedData)
                loadedReasons = promotionCode
            } catch (let error) {
                elDebugPrint("error: \(error.localizedDescription)")
            }
        }
        return loadedReasons
    }
    
    class func setSelectedReason(_ value:Data?) {
        Foundation.UserDefaults.standard.set(value, forKey: "loadedReasons")
        Foundation.UserDefaults.standard.synchronize()
    }
    
    class func resetSelectedReason () {
        UserDefaults.setSelectedReason(nil)
    }
    
    
    // MARK: Location Cahnge Check Date
    
    class func getLastLocationChangedDate() -> Date? {
        return Foundation.UserDefaults.standard.object(forKey: "LocationChangeCheckdate") as? Date
    }
    
    class func setLocationChanged( date: Date) {
        Foundation.UserDefaults.standard.set(date, forKey: "LocationChangeCheckdate")
        Foundation.UserDefaults.standard.synchronize()
    }

    
    // MARK: Smiles

    class func setIsSmileUser(_ logged:Bool) {
        Foundation.UserDefaults.standard.set(logged, forKey: "isSmileUser")
        Foundation.UserDefaults.standard.synchronize()
    }
    class func getIsSmileUser() -> Bool {
       return Foundation.UserDefaults.standard.bool(forKey: "isSmileUser")
    }
    
    class func setSmilesPoints(_ points:Int) {
        Foundation.UserDefaults.standard.set(points, forKey: "smilesPoints")
        Foundation.UserDefaults.standard.synchronize()
    }
    class func getSmilesPoints() -> Int {
        return Foundation.UserDefaults.standard.integer(forKey: "smilesPoints")
    }
}

class HomeTileDefaults :  UserDefaults {
    
    class func getTileViewedForTileID(_ tileName : String, screenName : String) -> Bool {
        let listString = HomeTileDefaults.getTileViewedFor(tileName: tileName, screenName)
        if listString[tileName] == "1" {
            return true
        }
        return false
        
    }
    
    class func getTileViewedFor(tileName : String, _ screenName : String) -> [String: String] {
        let key = screenName
        let obj = Foundation.UserDefaults.standard.object(forKey: key)
        if let data = obj as? [String : String] {
            return data
        }
        return [:]
        
    }
    
    class func setTileViewedFor(_ tileName : String, screenName : String)  {
        
        elDebugPrint("tileName: tileName \(tileName)")
        elDebugPrint("tileName: screenName \(screenName)")
        
        var listString = HomeTileDefaults.getTileViewedFor(tileName: tileName, screenName)
        listString[tileName] = "1"
        Foundation.UserDefaults.standard.setValue(listString, forKey: screenName)
        Foundation.UserDefaults.standard.synchronize()
        
    }
    
    class func removedTileViewedFor(screenName : String)  {
        Foundation.UserDefaults.standard.setValue(nil, forKey: screenName)
    }
    
    
}


class BrandUserDefaults :  UserDefaults {
    
    
    class func getProductViewedForProductID(_ productID : String, screenName : String) -> Bool {
           let productIDList = BrandUserDefaults.getProductsViewedFor(screenName)
            if productIDList is [String : String] {
            var listString = productIDList as! [String : String]
            if listString[productID] == "1" {
                return true
            }
        }
        return false
        
    }
    
    class func getProductsViewedFor(_ screenName : String) -> Any {
        return Foundation.UserDefaults.standard.object(forKey: screenName) as Any
        
    }
    
    class func setProductViewedFor(_ productID : String, screenName : String)  {
        
        let productIDList = BrandUserDefaults.getProductsViewedFor(screenName)
        if productIDList is [String : String] {
            var listString = productIDList as! [String : String]
            listString[productID] = "1"
            Foundation.UserDefaults.standard.setValue(listString, forKey: screenName)
            Foundation.UserDefaults.standard.synchronize()
        }else{
            Foundation.UserDefaults.standard.setValue([productID : "1"], forKey: screenName)
            Foundation.UserDefaults.standard.synchronize()
        }
        
    }
    
    class func removedProductViewedFor(screenName : String)  {
        Foundation.UserDefaults.standard.setValue(nil, forKey: screenName)
    }
    
    // add item
    
    
    class func getAddItemProduct() -> Any {
        return Foundation.UserDefaults.standard.object(forKey: "AddItemsFromDeepLink") as Any
        
    }
    
    class func setProductAddFromDeepLink(_ productID : String, deepLink : String)  {
        
        let productIDList = BrandUserDefaults.getAddItemProduct()
        if productIDList is [String : String] {
            var listString = productIDList as! [String : String]
            listString[productID] = deepLink
            Foundation.UserDefaults.standard.setValue(listString, forKey: "AddItemsFromDeepLink")
            Foundation.UserDefaults.standard.synchronize()
        }else{
            Foundation.UserDefaults.standard.setValue([productID : deepLink], forKey: "AddItemsFromDeepLink")
            Foundation.UserDefaults.standard.synchronize()
        }
        
    }
    class func removedProductsAddItemFromDeepLink()  {
        Foundation.UserDefaults.standard.setValue(nil, forKey: "AddItemsFromDeepLink")
    }
    
    
    
    
}
