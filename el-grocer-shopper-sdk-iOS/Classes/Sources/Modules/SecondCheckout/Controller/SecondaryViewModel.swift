//
//  SecondryCheckoutViewModel.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 26/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import Adyen

class SecondaryViewModel {
    var basketData: BehaviorSubject<BasketDataClass?> = BehaviorSubject(value: nil)
    var basketError: BehaviorSubject<ElGrocerError?> = BehaviorSubject(value: nil)
    var apiCall: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    var getBasketData: BehaviorSubject<BasketDataClass?> = BehaviorSubject(value: nil)
    var getBasketError: BehaviorSubject<ElGrocerError?> = BehaviorSubject(value: nil)
    var getApiCall: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    private let disposeBag = DisposeBag()
    private var netWork : SecondCheckOutApi! = SecondCheckOutApi()
    private var grocery: Grocery? = nil
    private var address: DeliveryAddress? = nil
    private var deliveryAddress: String? = nil // private, use get method getDeliveryAddress
    private var selectedSlotId: NSNumber? = nil
    private var selectedSlot: DeliverySlot? = nil
    private var promoRealizationId: String? = nil
    private var promoAmount: Double? = nil
    private var orderId: String? = nil
    private var isSmileTrue: Bool = false
    private var isWalletTrue: Bool = false
    private var isPromoCodeTrue: Bool = false
    private var shopingItems: [ShoppingBasketItem]? = []
    private var finalisedProductA: [Product]? = []
    private var selectedPreferenceId : Int? = nil
    private var additionalInstructions: String?
    var basketDataValue: BasketDataClass? = nil
    private var selectedCreditCard: CreditCard? = nil
    private var applePaySelectedMethod: ApplePayPaymentMethod? = nil
    private var order: Order?
    private var userid: NSNumber?
    
    
    private var defaultApiData: [String : Any] = [:] // will provide default data with grocery delivery address and slot if provide in init method
    
    init(address: DeliveryAddress, grocery: Grocery, slot: NSNumber?, orderId: String? = nil, shopingItems: [ShoppingBasketItem]? = [], finalisedProducts: [Product]? = [], selectedPreferenceId: Int?, deliverySlot: DeliverySlot?) {
      
        self.grocery = grocery
        self.address = address
        self.selectedSlotId = slot
        self.shopingItems = shopingItems
        self.finalisedProductA = finalisedProducts
        self.orderId = orderId
        self.selectedPreferenceId = selectedPreferenceId
        self.setDeliveryAddress(address)
        self.setDeliverySlot(deliverySlot)
        self.setDefaultApiData()
    }

    func getBasketDetailWithSlot() {
        let params = createParamsForCheckoutFromMyBasket()
        createAndUpdateCartDetailsApi(parameter: params)
    }

    private func createAndUpdateCartDetailsApi(parameter: [String: Any]) {
        
//        guard self.orderId == nil else {
//            self.createAndUpdateCartDetailsApiForEditOrder(parameter: parameter)
//            return
//        }
        self.apiCall.onNext(true)
        debugPrint("SplitPayment: createApi: \(parameter)")
        netWork.createSecondCheckoutCartDetails(parameters: parameter) { result in
            self.apiCall.onNext(false)
            switch result {
                case .success(let response):
                    print(response)
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                        let checkoutData = try JSONDecoder().decode(BasketDataResponse.self, from: jsonData)
                        print(checkoutData)
                        if let slot = Int(checkoutData.data.selectedDeliverySlot ?? "") {
                            UserDefaults.setCurrentSelectedDeliverySlotId(NSNumber.init(value: slot))
                        }
                        self.basketDataValue = checkoutData.data
                        self.basketData.onNext(checkoutData.data)
                        self.updateViewModelDataAccordingToBasket(data: checkoutData.data)
                    } catch(let error) {
                        print(error)
                        self.basketError.onNext(ElGrocerError.parsingError())
                    }
                case .failure(let error):
                    self.basketError.onNext(error)
            }
            
        }
        
    }
    
    func getCartDetailsApi() {
        self.getApiCall.onNext(true)
        netWork.getSecondCheckoutDetails(retailerId: self.getGrocery()?.dbID ?? "" , retailerZone: self.getGrocery()?.deliveryZoneId ?? "", slots: true, orderId: self.orderId) { (result) in
            self.getApiCall.onNext(false)
            switch result {
                case .success(let response):
                   print(response)
                guard let slots = (response["data"] as? NSDictionary)?["delivery_slots"] as? [NSDictionary] else {
                    self.getBasketError.onNext(ElGrocerError.parsingError())
                    return
                }
                
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                        let checkoutData = try JSONDecoder().decode(BasketDataResponse.self, from: jsonData)
                        print(checkoutData)
                        if let slot = Int(checkoutData.data.selectedDeliverySlot ?? "") {
                            UserDefaults.setCurrentSelectedDeliverySlotId(NSNumber.init(value: slot))
                        }
                        self.getBasketData.onNext(checkoutData.data)
                        self.basketDataValue = checkoutData.data
                        self.updateViewModelDataAccordingToBasket(data: checkoutData.data)
                    }catch(let error) {
                        print(error)
                        self.getBasketError.onNext(ElGrocerError.parsingError())
                    }
                case .failure(let error):
                    self.getBasketError.onNext(error)
            }
        }
    }
    
}

extension SecondaryViewModel {
    
    func getOrderPlaceApiParams() -> [String: Any] {
        
        /*
         
         {
         "delivery_fee":0.0,
         "usid":20223795237,
         "food_subscription_status":false,
         "same_card":false,
         "shopper_note":"",
         "payment_type_id":2,
         "substitution_preference_key":5,
         "products":[
         {
         "product_id":8911,
         "amount":1
         },
         {
         "product_id":9177,
         "amount":1
         },
         {
         "product_id":9278,
         "amount":1
         }
         ],
         "retailer_id":16,
         "retailer_service_id":1,
         "rider_fee":0.0,
         "service_fee":6.0,
         "shopper_address_id":96081,
         "realization_present":false,
         "vat":5,
         "secondary_payments":[
         {
         "payment_type_id":4,
         "amount": 34
         }
         ]
         }
         2:33

         
         
         
         */
      
        var finalParams: [String: Any] = [:]
        
        
        if let preference = self.selectedPreferenceId {
            finalParams["substitution_preference_key"] = preference
        }
        
        if let promoRealizationId = self.promoRealizationId {
            finalParams["realization_id"] = promoRealizationId
        }
        if self.orderId?.count ?? 0 > 0 {
            finalParams["order_id"] = self.orderId
        }
        
        // Float(self.basketDataValue?.smilesRedeem ?? "0.00") ?? 0.00]
        var secondaryPayments: [[String : Any]] = []
        if self.isSmileTrue && ((self.basketDataValue?.paymentTypes?.first(where: { type in
            type.id == PaymentOption.smilePoints.rawValue
        })) != nil)  {
            secondaryPayments.append([  "payment_type_id" : PaymentOption.smilePoints.rawValue,
                                        "amount" : Float(self.basketDataValue?.smilesRedeem ?? "0.00") ?? 0.00])
        }
        if self.isWalletTrue && ((self.basketDataValue?.paymentTypes?.first(where: { type in
            type.id == PaymentOption.voucher.rawValue
        })) != nil) {
            secondaryPayments.append([  "payment_type_id" : PaymentOption.voucher.rawValue,
                                        "amount" : Float(self.basketDataValue?.elWalletRedeem ?? "0.00") ?? 0.00 ])
        }
        if let promoRealizationId = self.promoRealizationId {
            secondaryPayments.append([  "payment_type_id" : PaymentOption.PromoCode.rawValue,
                                        "amount" : self.promoAmount ?? 0.0,
                                        "promotion_code_realization_id" : promoRealizationId ])
        }
        
        if let additionalInstruction  = self.additionalInstructions {
            finalParams["shopper_note"] = additionalInstruction
        }
        
        var products = [NSDictionary]()
        for item in self.getShoppingItems() ?? [] {
            
            let productId = Product.getCleanProductId(fromId: item.productId)
            
            let productDict = [
                "product_id" : productId,
                "amount" : item.count
            ] as [String : Any]
            
            products.append(productDict as NSDictionary)
        }
        
        var primaryPaymentTypeId = self.getSelectedPaymentMethodId()
        if primaryPaymentTypeId == PaymentOption.applePay.rawValue {
            primaryPaymentTypeId = PaymentOption.creditCard.rawValue
        }
        
        
        finalParams["products"] = products
        finalParams["retailer_delivery_zone_id"] = self.getGrocery()?.deliveryZoneId
        finalParams["payment_type_id"] = primaryPaymentTypeId
        finalParams["selected_delivery_slot"] = self.selectedSlotId
        if let slot = self.getDeliverySlot() {
            if !(slot.isInstant.boolValue) {
                finalParams["usid"] = slot.getdbID()
            }
        }
        finalParams["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(self.getGroceryId())
        finalParams["secondary_payments"] = secondaryPayments
        finalParams["retailer_service_id"] =  OrderType.delivery.rawValue
        finalParams["shopper_address_id"] = DeliveryAddress.getAddressIdForDeliveryAddress(self.address)
        finalParams["service_fee"] = self.getGrocery()?.serviceFee
        finalParams["delivery_fee"] = self.getGrocery()?.deliveryFee
        finalParams["rider_fee"] = self.getGrocery()?.riderFee
        finalParams["vat"] = self.getGrocery()?.vat
        finalParams["device_type"] = 1
        finalParams["realization_present"] = self.promoRealizationId != nil
        
        if primaryPaymentTypeId == PaymentOption.creditCard.rawValue, let card = self.getCreditCard() {
            finalParams["card_id"] = card.cardID
            finalParams["auth_amount"] = self.basketDataValue?.finalAmount
        }
        
        return finalParams
    }
    
    func getCreditCardsFromAdyen() {
        
        
        PaymentMethodFetcher.getPaymentMethods(amount: AdyenManager.createAmount(amount: 100), addApplePay: true) { paymentMethods, applePay, error in
            if self.getSelectedPaymentOption() == .creditCard {
                if let cardsArray = paymentMethods {
                    if let _ = self.getCreditCard() {
                        
                    }else {
                        let cardId = UserDefaults.getCardID(userID: self.getUserId()?.stringValue ?? "")
                        for creditCard in cardsArray {
                            if cardId.elementsEqual(creditCard.cardID) {
                                self.updateCreditCard(creditCard)
                                self.basketData.onNext(self.basketDataValue)
                                break
                            }
                        }
                    }
                }
            }else if self.getSelectedPaymentOption() == .applePay{
                self.applePaySelectedMethod = applePay
            }
        }
    }
    
    func updateViewModelDataAccordingToBasket(data: BasketDataClass) {
        
        if let elwalletRedeem = Double(data.elWalletRedeem ?? "0.00"), elwalletRedeem > 0 {
            self.isWalletTrue = true
        }else {
            self.isWalletTrue = false
        }
        
        if let smileRedeem = Double(data.smilesRedeem ?? "0.00"), smileRedeem > 0 {
            self.isSmileTrue = true
        }else {
            self.isSmileTrue = false
        }
        
        if let promo = data.promoCode, (promo.value ?? 0) > 0 {
            self.isPromoCodeTrue = true
            self.promoRealizationId = String(data.promoCode?.promotionCodeRealizationID ?? 0)
            self.promoAmount = Double(data.promoCode?.value ?? 0)
        }else {
            self.isPromoCodeTrue = false
        }
        
    }
}



//MARK: secondary payment methods handling
extension SecondaryViewModel {
    
   
    func updatePaymentMethod(_ selectPaymentMethod : PaymentOption) {
        let params = createParamsUpdatePaymentType(selectPaymentMethod.rawValue)
        createAndUpdateCartDetailsApi(parameter: params)
    }
    
    func updateSecondaryPaymentMethods() {
        let params = createParamsForSecondaryPaymentUpdate()
        createAndUpdateCartDetailsApi(parameter: params)
    }
    
    func updateSlotToBackEnd() {
        let params = createParamsUpdateForSlotId()
        createAndUpdateCartDetailsApi(parameter: params)
    }
    
    func setSelectedSlotId(_ selectedSlotId: NSNumber?) {
        self.selectedSlotId = selectedSlotId
    }
    func setUserId(userId: NSNumber?) {
        self.userid = userId
    }
    func getUserId()-> NSNumber? {
        return self.userid
    }
    func setIsSmileTrue(isSmileTrue: Bool) {
        self.isSmileTrue = isSmileTrue
    }
    func setIsWalletTrue(isWalletTrue: Bool) {
        self.isWalletTrue = isWalletTrue
        
    }
    func setIsPromoTrue(isPromoTrue: Bool) {
        self.isPromoCodeTrue = isPromoTrue
    }
    func setPromoCodeRealisationId(realizationId: String, promoAmount : Double?) {
        self.promoRealizationId = realizationId
        self.promoAmount = promoAmount
    }
    func setAdditionalInstructions(text: String) {
        self.additionalInstructions = text
    }
    func getAdditionalInstructions()-> String {
        return self.additionalInstructions ?? ""
    }
    
    func updateCreditCard(_ selectedCreditCard : CreditCard?) {
        self.selectedCreditCard  = selectedCreditCard
    }
    func updateApplePay(_ selectedApplePay : ApplePayPaymentMethod?) {
        self.applePaySelectedMethod  = selectedApplePay
    }
    
    func getAddress() -> DeliveryAddress? {
        return self.address
    }
    func getIsSmileTrue()-> Bool {
        return self.isSmileTrue
    }
    func getGrocery() -> Grocery? {
        return self.grocery
    }
    func getShoppingItems() -> [ShoppingBasketItem]? {
        return self.shopingItems
    }
    func getOrderId() -> String? {
        return self.orderId
    }
    func getFinalisedProducts() -> [Product]? {
        return self.finalisedProductA
    }
    func getCreditCard() -> CreditCard? {
        return self.selectedCreditCard
    }
    func getApplePay() -> ApplePayPaymentMethod? {
        return self.applePaySelectedMethod
    }
    
}

//MARK: Helper methods
extension SecondaryViewModel {
        //MARK: Support Method For DefaultApiData
    @discardableResult
    private func setDefaultApiData()  -> [String : Any] {
        
        self.defaultApiData["retailer_id"]  =  self.grocery?.getCleanGroceryID()
        self.defaultApiData["retailer_delivery_zone_id"]  =  self.grocery?.deliveryZoneId
        self.defaultApiData["selected_delivery_slot"]  =  self.selectedSlotId
        self.defaultApiData["slots"] = true
        
        if self.orderId != nil {
            self.defaultApiData["order_id"]  =  self.orderId
        }else {
            
                //            var secondaryPayments: [String: Any] = [:]
                //            secondaryPayments["smiles"] = self.isSmileTrue
                //            secondaryPayments["el_wallet"] = self.isWalletTrue
                //            secondaryPayments["promo_code"] = self.isPromoCodeTrue
                //            self.defaultApiData["secondary_payments"] = secondaryPayments
        }
       
        return self.defaultApiData
    }
    private func getDefaultApiData() -> [String : Any] {
        return self.defaultApiData
    }
    
    //MARK: helper methods for smile point conversions
    
    
    func getBurnPointsFromAed() -> Int {
        if let doubleAmount = Double(self.basketDataValue?.finalAmount ?? "") {
            let smilesConfig = ElGrocerUtility.sharedInstance.appConfigData.smilesData
            let points =  Int(round(doubleAmount/smilesConfig.burning))
            return points
        }else {
            return 0
        }
    }
    
    func getEarnPointsFromAed() -> Int {
        if let doubleAmount = Double(self.basketDataValue?.totalValue ?? "0.00"),let smileAED = Double(self.basketDataValue?.smilesRedeem ?? "0.00") {
            let points = SmilesManager.getEarnPointsFromAed(doubleAmount - smileAED)
            return points
        }else {
            return 0
        }
    }
    
    func getAedFromPoints(_ points: Int)-> Double {
        let smilesConfig = ElGrocerUtility.sharedInstance.appConfigData.smilesData
        return Double(points) * smilesConfig.burning
    }
    
    func getSelectedPaymentOption() -> PaymentOption {
        if let paymentOptionType = UInt32(self.basketDataValue?.primaryPaymentTypeID ?? "0") {
            return PaymentOption(rawValue: paymentOptionType) ?? PaymentOption.none
        }else {
            return PaymentOption.none
        }
    }
    
    func getSelectedPaymentMethodId() -> UInt32? {
        
        if let typeId = UInt32(self.basketDataValue?.primaryPaymentTypeID ?? "0") {
            return typeId
        }
        return .none
        
    }
}

    //MARK: Support function for update Basket Data Backend
extension SecondaryViewModel {
    
    private func createParamsForCheckoutFromMyBasket() -> [String: Any] {
        
        self.setDefaultApiData()
        
        var parameters: [String: Any] = [
            //"promo_code": "REESE",
            "slots": true
        ]
        parameters.update(other: self.setDefaultApiData())
        return parameters
    }
    
    
    private func createParamsUpdatePaymentType(_ paymentId : UInt32) -> [String: Any] {
        
        var parameters: [String: Any] = [
            //"promo_code": "REESE",
            "primary_payment_type_id": paymentId
        ]
        parameters.update(other: self.setDefaultApiData())
        return parameters
    }
    
    private func createParamsUpdateForSlotId() -> [String: Any] {
        
        guard let slotId = self.selectedSlotId else { return [:] }
        var parameters: [String: Any] = self.setDefaultApiData()
        parameters.update(other: [ "selected_delivery_slot": slotId.stringValue ])
        return parameters
    }
    
    
    private func createParamsForSecondaryPaymentUpdate() -> [String: Any] {
        var parameters: [String: Any] = [:]
        if let id = self.promoRealizationId {
            parameters["realization_id"] = id
        }
        var secondaryPayments: [String: Any] = [:]
        secondaryPayments["smiles"] = self.isSmileTrue
        secondaryPayments["el_wallet"] = self.isWalletTrue
        secondaryPayments["promo_code"] = self.isPromoCodeTrue
        
        parameters["secondary_payments"] = secondaryPayments
        parameters.update(other: self.setDefaultApiData())
        return parameters
    }
    
    func getShouldShowSecondaryPayments(paymentMethods: [PaymentType]) -> SecondaryPaymentViewType{
        
        var isSmile = false
        var isWallet = false
        for payment in paymentMethods {
            if (payment.name ?? "").elementsEqual("smiles_points") {
                isSmile = true
            }else if (payment.name ?? "").elementsEqual("el_wallet") {
                isWallet = true
            }
        }
            //        //check is user
            //        let smileUser = UserDefaults.getIsSmileUser()
            //        if !smileUser {
            //            isSmile = false
            //        }
        if isSmile && isWallet {
            return SecondaryPaymentViewType.both
        }else if isSmile {
            return SecondaryPaymentViewType.smiles
        }else if isWallet {
            return SecondaryPaymentViewType.elWallet
        }else {
            return SecondaryPaymentViewType.none
        }
    }

}



    //MARK: Support function for DeliverySlot, order, grocery
extension SecondaryViewModel {
    
    // order
    func setEditOrderInitialDetail(_ order : Order?) {
        self.order = order
    }
    
    func getEditOrderInitialDetail() -> Order? {
        return self.order
    }
    
    // slots
    
    func setCurrentDeliverySlot(_ slotId : NSNumber) {
        self.selectedSlotId = slotId
    }
    
    func getCurrentDeliverySlot() -> NSNumber? {
        return self.selectedSlotId
    }
    
    func setDeliverySlot(_ slot : DeliverySlot?) {
        self.selectedSlot = slot
    }
    
    func getDeliverySlot() -> DeliverySlot? {
        return self.selectedSlot
    }
    
    // grocery id
    
    func getGroceryId() -> String? {
        return self.grocery?.getCleanGroceryID() ?? nil
    }
    
}

//MARK: Support function for DeliveryAddress
extension SecondaryViewModel {
    
    private func setDeliveryAddress(_ currentAddress : DeliveryAddress) {
        self.deliveryAddress = ElGrocerUtility.sharedInstance.getFormattedAddress(currentAddress)
    }
    func getDeliveryAddress() -> String {
        if let formatterAddress = self.deliveryAddress {
            return formatterAddress
        }else if let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            let formatAddressStr =  ElGrocerUtility.sharedInstance.getFormattedAddress(deliveryAddress).count > 0 ? ElGrocerUtility.sharedInstance.getFormattedAddress(deliveryAddress) : deliveryAddress.locationName + deliveryAddress.address
            return formatAddressStr
        }else {
            return ""
        }
    }
    
    func createPaymentOptionFromString(paymentTypeId: String) -> PaymentOption {
        if let paymentOptionType = UInt32(paymentTypeId) {
            return PaymentOption(rawValue: paymentOptionType) ?? PaymentOption.none
        }else {
            return PaymentOption.none
        }
        
    }
}

    // MARK: - BasketDataResponse
struct BasketDataResponse: Codable {
    let status: String
    let data: BasketDataClass
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case data = "data"
    }
}

    // MARK: - BasketDataClass
struct BasketDataClass: Codable {
    
    let primaryPaymentTypeID: String?
    let finalAmount, totalValue: String?
    let promoCodes: String?
    let smilesBalance: String?
    let elWalletBalance, productsTotal, serviceFee, productsSaving: String?
    let promoCode: PromoCode?
    let smilesRedeem, elWalletRedeem: String?
    let smilesPoints: String?
    let deliverySlots: [DeliverySlotDTO]?
    let selectedDeliverySlot: String?
    let paymentTypes: [PaymentType]?
    let retailerDeliveryZoneId: String?
    let quantity: String?
    let totalDiscount: String?
    
    enum CodingKeys: String, CodingKey {
        case finalAmount = "final_amount"
        case totalValue = "total"
        case promoCodes = "promo_codes"
        case primaryPaymentTypeID = "primary_payment_type_id"
        case serviceFee = "service_fee"
        case smilesBalance = "smiles_balance"
        case elWalletBalance = "el_wallet_balance"
        case productsSaving = "products_saving"
        case promoCode = "promo_code"
        case smilesRedeem = "smiles_redeem"
        case elWalletRedeem = "el_wallet_redeem"
        case deliverySlots = "delivery_slots"
        case paymentTypes = "payment_types"
        case selectedDeliverySlot = "selected_delivery_slot"
        case productsTotal = "products_total"
        case smilesPoints = "smiles_points"
        case retailerDeliveryZoneId = "retailer_delivery_zone_id"
        case quantity
        case totalDiscount = "total_discount"
        
    }
    
    init(from decoder: Decoder) throws {
       
    
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let stringValue = (try? values.decodeIfPresent(String.self, forKey: .finalAmount))
        let doubleValue = (try? values.decodeIfPresent(Double.self, forKey: .finalAmount))
        finalAmount =  stringValue! //(stringValue ?? String(doubleValue ?? 0)) as! String
        totalValue = try values.decodeIfPresent(String.self, forKey: .totalValue)
        promoCodes  = try values.decodeIfPresent(String.self, forKey: .promoCodes)
        primaryPaymentTypeID = try values.decodeIfPresent(String.self, forKey: .primaryPaymentTypeID)
        smilesBalance = try values.decodeIfPresent(String.self, forKey: .smilesBalance)
        elWalletBalance = try values.decodeIfPresent(String.self, forKey: .elWalletBalance)
        productsTotal = try values.decodeIfPresent(String.self, forKey: .productsTotal)
        serviceFee = try values.decodeIfPresent(String.self, forKey: .serviceFee)
        productsSaving = try values.decodeIfPresent(String.self, forKey: .productsSaving)
        promoCode = try values.decodeIfPresent(PromoCode.self, forKey: .promoCode)
        smilesRedeem = try values.decodeIfPresent(String.self, forKey: .smilesRedeem)
        elWalletRedeem = try values.decodeIfPresent(String.self, forKey: .elWalletRedeem)
        smilesPoints = try values.decodeIfPresent(String.self, forKey: .smilesPoints)
        deliverySlots = try values.decodeIfPresent([DeliverySlotDTO].self, forKey: .deliverySlots)
        selectedDeliverySlot = try values.decodeIfPresent(String.self, forKey: .selectedDeliverySlot)
        paymentTypes = try values.decodeIfPresent([PaymentType].self, forKey: .paymentTypes)
        retailerDeliveryZoneId = try values.decodeIfPresent(String.self, forKey: .retailerDeliveryZoneId)
        quantity = try values.decodeIfPresent(String.self, forKey: .quantity)
        totalDiscount = try values.decodeIfPresent(String.self, forKey: .totalDiscount)
    }
}

    // MARK: - DeliverySlot
struct DeliverySlotDTO: Codable {
    let id, timeMilli, usid: Int?
    let startTime, endTime, estimatedDeliveryAt: String?
    
    var isToday: Bool {
        return self.startTime?.toDate()?.date.isToday ?? false
    }
    
    var isTomorrow: Bool {
        return self.startTime?.toDate()?.date.isTomorrow ?? false
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case timeMilli = "time_milli"
        case usid
        case startTime = "start_time"
        case endTime = "end_time"
        case estimatedDeliveryAt = "estimated_delivery_at"
    }
    
    func getInstantText() -> String {
        return localizedString("today_title", comment: "") + " " + localizedString("60_min", comment: "") + "⚡️"
    }
}

    // MARK: - PaymentType
struct PaymentType: Codable {
    let id: Int
    let name: String?
    let accountType: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case accountType = "account_type"
    }
    
    func getLocalPaymentOption() -> PaymentOption {
        
        if self.id == 1 {
            return PaymentOption.cash
        }else if self.id == 2 {
            return PaymentOption.card
        }else if self.id == 3 {
            return PaymentOption.creditCard
        }else if self.id == PaymentOption.applePay.rawValue {
            return PaymentOption.applePay
        }else {
            return PaymentOption.none
        }
    }
    func getLocalizedName() -> String {
        
        if self.id == 1 {
            return localizedString("pay_via_cash", comment: "")
        }else if self.id == 2 {
            return localizedString("pay_via_card", comment: "")
        }else if self.id == 3 {
            return localizedString("pay_via_CreditCard", comment: "")
        }else if self.id == PaymentOption.applePay.rawValue {
            return localizedString("pay_via_Apple_pay", comment: "")
        }else {
            return self.name ?? ""
        }
    }
}
    // MARK: - PromoCode
struct PromoCode: Codable {
    let code: String?
    let promotionCodeRealizationID: Int?
    let value: Double?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case promotionCodeRealizationID = "realization_id"
        case value
        case errorMessage = "error_message"
    }
}

