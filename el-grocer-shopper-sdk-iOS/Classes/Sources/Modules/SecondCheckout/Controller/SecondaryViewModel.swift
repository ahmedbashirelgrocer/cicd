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
    var getBasketData: BehaviorSubject<Bool?> = BehaviorSubject(value: nil)
    var getBasketError: BehaviorSubject<ElGrocerError?> = BehaviorSubject(value: nil)
    var getApiCall: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    var deliverySlotsSubject: BehaviorSubject<[DeliverySlotDTO]> = BehaviorSubject(value: [])
    var backSubject: PublishSubject<Void> = .init()
    private let disposeBag = DisposeBag()
    private var netWork : SecondCheckOutApi! = SecondCheckOutApi()
    private var grocery: Grocery? = nil
    private var address: DeliveryAddress? = nil
    private var deliveryAddress: String? = nil // private, use get method getDeliveryAddress
    private var deliveryAddressObj: DeliveryAddress? = nil
    private var selectedSlotId: Int? = nil
    private var selectedSlot: DeliverySlotDTO? = nil
    private var promoRealizationId: String? = nil
    private var promoAmount: Double? = nil
    private var orderId: String? = nil
    private var isPromoCodeTrue: Bool = false
    private var shopingItems: [ShoppingBasketItem]? = []
    private var finalisedProductA: [Product]? = []
    private var carouselProductsArray : [Product]? = []
    private var selectedPreferenceId : Int? = nil
    private var additionalInstructions: String?
    private var isNeedToFetchAdyenCreditCards: Bool = true
    
    var basketDataValue: BasketDataClass? = nil
    var deliverySlots: [DeliverySlotDTO] = []
    private var selectedCreditCard: CreditCard? = nil
    private var applePaySelectedMethod: ApplePayPaymentMethod? = nil
    private var order: Order?
    private var userid: NSNumber?
    private var editOrderPrimarySelectedMethod: Int?
    private var tabbyWebUrl: String?
    private var selectedSmilePoints: Double = 0.0
    private var selectedElwaletPoints: Double = 0.00
    
    
    private var defaultApiData: [String : Any] = [:] // will provide default data with grocery delivery address and slot if provide in init method
    
    init(address: DeliveryAddress, grocery: Grocery, slotId: Int?, orderId: String? = nil, shopingItems: [ShoppingBasketItem]? = [], finalisedProducts: [Product]? = [], selectedPreferenceId: Int?, deliverySlot: DeliverySlot?, deliverySlots: [DeliverySlotDTO] = []) {
      
        self.grocery = grocery
        self.address = address
        self.shopingItems = shopingItems
        self.finalisedProductA = finalisedProducts
        self.orderId = orderId
        self.selectedPreferenceId = selectedPreferenceId
        self.setDeliveryAddress(address)
        self.deliverySlots = deliverySlots
        self.setDefaultApiData()
        
        self.fetchDeliverySlots { [weak self] in
            guard let self = self else { return }
            
            
        }
        
    }

    func fetchDeliverySlots(_ completion : (()->())? = nil ) {
        guard let sRetailerID = grocery?.dbID, let retailerID = Int(sRetailerID), let sRetailerTimeZone = grocery?.deliveryZoneId, let retailerTimeZone = Int(sRetailerTimeZone)  else {
            self.basketError.onNext(ElGrocerError.parsingError())
            return
        }
        
        let basketItems = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        var itemsCount = 0
        
        for item in basketItems {
            itemsCount += item.count.intValue
        }
        
        ElGrocerApi.sharedInstance.getDeliverySlots(retailerID: retailerID, retailerDeliveryZondID: retailerTimeZone, orderID: Int(self.orderId ?? ""), orderItemCount: itemsCount) { result in
            switch result {
                
            case .success(let response):
                do {
                    elDebugPrint(response)
                    let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                    Grocery.updateActiveGroceryDeliverySlots(with: response, context: context)
                    _ = DeliverySlot.insertOrReplaceDeliverySlotsFromDictionary(response, groceryObj: self.grocery, context: context)
                    let data = try JSONSerialization.data(withJSONObject: response, options: [])
                    let deliverySlots = try JSONDecoder().decode(DeliverySlotsData.self, from: data)
                    if let slot =  deliverySlots.deliverySlots {
                        self.deliverySlots = slot
                        self.deliverySlotsSubject.onNext(slot)
                    }
                    completion?()
                } catch {
                    self.basketError.onNext(ElGrocerError.parsingError())
                    completion?()
                }
                break
                
            case .failure(let error):
                self.basketError.onNext(error)
                completion?()
                break
            }
        }
    }
    
    func getBasketDetailWithSlot() {
        let params = createParamsForCheckoutFromMyBasket()
        createAndUpdateCartDetailsApi(parameter: params)
    }
    
    func getEditOrderBasketDetailWithSlot() {
        let params = createParamsForCheckoutFromMyBasket()
        createAndUpdateCartDetailsEditOrderApi(parameter: params)
    }

    private func createAndUpdateCartDetailsEditOrderApi(parameter: [String: Any]) {
        
        self.apiCall.onNext(true)
        debugPrint("SplitPayment: createApi: \(parameter)")
        netWork.createSecondCheckoutCartDetailsEditOrder(parameters: parameter) { result in
            switch result {
                case .success(let response):
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                        let checkoutData = try JSONDecoder().decode(BasketDataResponse.self, from: jsonData)
                        //  print(checkoutData)
                        if let slot = checkoutData.data.selectedDeliverySlot {
                            UserDefaults.setCurrentSelectedDeliverySlotId(NSNumber.init(value: slot))
                        }
                        self.basketDataValue = checkoutData.data
                        self.basketData.onNext(checkoutData.data)
                        self.updateViewModelDataAccordingToBasket(data: checkoutData.data)
                        
                        if self.isNeedToFetchAdyenCreditCards {
                            self.getCreditCardsFromAdyen { self.apiCall.onNext(false) }
                        } else {
                            self.apiCall.onNext(false)
                        }
                    } catch(let error) {
                        //  print(error)
                        self.basketError.onNext(ElGrocerError.parsingError())
                    }
                case .failure(let error):
                    self.basketError.onNext(error)
            }
            
        }
        
    }
    private func createAndUpdateCartDetailsApi(parameter: [String: Any]) {
        
        guard self.orderId == nil else {
            self.createAndUpdateCartDetailsEditOrderApi(parameter: parameter)
            return
        }
        self.apiCall.onNext(true)
        debugPrint("SplitPayment: createApi: \(parameter)")
        netWork.createSecondCheckoutCartDetails(parameters: parameter) { result in
            switch result {
                case .success(let response):
                  print("API Response >>> \(response)")
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                        let checkoutData = try JSONDecoder().decode(BasketDataResponse.self, from: jsonData)
                        //    print(checkoutData)
                        if let slot = checkoutData.data.selectedDeliverySlot {
                            UserDefaults.setCurrentSelectedDeliverySlotId(NSNumber.init(value: slot))
                        }
                        self.basketDataValue = checkoutData.data
                        self.basketData.onNext(checkoutData.data)
                        self.updateViewModelDataAccordingToBasket(data: checkoutData.data)
                        self.apiCall.onNext(false)
                        
                        if self.isNeedToFetchAdyenCreditCards {
                            self.getCreditCardsFromAdyen { self.apiCall.onNext(false) }
                        } else {
                            self.apiCall.onNext(false)
                        }
                    } catch(let error) {
                        //    print(error)
                        self.basketError.onNext(ElGrocerError.parsingError())
                    }
                case .failure(let error):
                    if (error as ElGrocerError).code == 4199 {
                        self.backSubject.onNext(())
                    } else {
                        self.basketError.onNext(error)
                    }
            }
            
        }
        
    }
    
    func callSetCartBalanceAccountCacheApi() {
        self.getApiCall.onNext(true)
        netWork.setCartBalanceAccountCacheApi { (result) in
            self.getApiCall.onNext(false)
            switch result {
                case .success(let response):
                //     print(response)
                    guard let success = (response["data"] as? NSDictionary)?["Success"] as? Bool else {
                        self.getBasketError.onNext(ElGrocerError.parsingError())
                        return
                    }
                    self.getBasketData.onNext(success)
                case .failure(let error):
                    self.getBasketError.onNext(error)
            }
        }
    }
    
}

extension SecondaryViewModel {
    
    func getOrderPlaceApiParams() -> [String: Any] {
      
        var finalParams: [String: Any] = [:]
        
        
        if let preference = self.selectedPreferenceId {
            finalParams["substitution_preference_key"] = preference
        }
        
        if let promoRealizationId = self.promoRealizationId {
            finalParams["promotion_code_realization_id"] = promoRealizationId
        }
        if (self.orderId?.count ?? 0) > 0 {
            finalParams["order_id"] = self.orderId
        }
        
        // Float(self.basketDataValue?.smilesRedeem ?? "0.00") ?? 0.00]
        var secondaryPayments: [String : Any] = [:]
        
        secondaryPayments["smiles"] = self.selectedSmilePoints
        secondaryPayments["el_wallet"] = self.selectedElwaletPoints
        
        if let _ = self.promoRealizationId {
            secondaryPayments["promo_code"] = true
        }else {
            secondaryPayments["promo_code"] = false
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
        if let deliverySlotID = self.selectedSlotId {
            finalParams["selected_delivery_slot"] = String(describing: deliverySlotID)
        }
        if let slot = self.getDeliverySlot() {
            if slot.isInstant == false {
                finalParams["usid"] = slot.usid
            }
        }
        finalParams["retailer_id"] = ElGrocerUtility.sharedInstance.cleanGroceryID(self.getGroceryId())
        finalParams["secondary_payments"] = secondaryPayments
        finalParams["retailer_service_id"] =  OrderType.delivery.rawValue
        if ElGrocerUtility.isAddressCentralisation == false {
            finalParams["shopper_address_id"] = DeliveryAddress.getAddressIdForDeliveryAddress(self.address)
        } else {
            finalParams["smiles_address_id"] = DeliveryAddress.getAddressIdForDeliveryAddress(self.address)
        }
        finalParams["service_fee"] = self.getGrocery()?.serviceFee
        finalParams["delivery_fee"] = self.getGrocery()?.deliveryFee
        finalParams["rider_fee"] = self.getGrocery()?.riderFee
        finalParams["vat"] = self.getGrocery()?.vat
        finalParams["device_type"] = 1
        finalParams["realization_present"] = self.promoRealizationId != nil
        
        if primaryPaymentTypeId == PaymentOption.creditCard.rawValue, let card = self.getCreditCard() {
            finalParams["card_id"] = card.cardID
            finalParams["auth_amount"] = self.basketDataValue?.finalAmount
            if let orderCard = self.getEditOrderInitialDetail()?.cardID, orderCard.elementsEqual(card.cardID) {
                finalParams["same_card"] = true
            }else {
                finalParams["same_card"] = false
            }
        }
        
        return finalParams
    }
    
    func getCreditCardsFromAdyen(completion: (()->Void)? = nil) {
        self.isNeedToFetchAdyenCreditCards = false
        
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
                        if self.selectedCreditCard == nil && applePay != nil && self.order != nil {
                            self.applePaySelectedMethod = applePay
                        }
                    }
                }
            }else if self.getSelectedPaymentOption() == .applePay{
                self.applePaySelectedMethod = applePay
            }
            
            completion?()
        }
    }
    
    func updateViewModelDataAccordingToBasket(data: BasketDataClass) {
        
        if self.basketDataValue?.paymentTypes?.first( where: { ($0.id == self.basketDataValue?.primaryPaymentTypeID) || ( (self.basketDataValue?.primaryPaymentTypeID ?? -1) == PaymentOption.applePay.rawValue &&  $0.id == PaymentOption.creditCard.rawValue) }) == nil {
            self.basketDataValue?.primaryPaymentTypeID = nil
            self.basketData.onNext(self.basketDataValue)
        }
        
        self.selectedSmilePoints = data.smilesRedeem ?? 0.0
        self.selectedElwaletPoints = data.elWalletRedeem ?? 0.0
        
        if let promo = data.promoCode, (promo.value ?? 0) > 0 {
            self.isPromoCodeTrue = true
            self.promoRealizationId = String(data.promoCode?.promotionCodeRealizationID ?? 0)
            self.promoAmount = Double(data.promoCode?.value ?? 0)
        }else {
            self.isPromoCodeTrue = false
        }
        
        if let selectedDeliverySlot = self.deliverySlots.first(where: { $0.id == data.selectedDeliverySlot || $0.usid == data.selectedDeliverySlot }) {
            self.setDeliverySlot(selectedDeliverySlot)
            self.setSelectedSlotId(selectedDeliverySlot.id)
        } else {
            let selectedSlot = self.deliverySlots.first
            self.setDeliverySlot(selectedSlot)
            self.setSelectedSlotId(selectedSlot?.id)
        }

        self.tabbyWebUrl = data.tabbyWebUrl
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
    
    func setSelectedSlotId(_ selectedSlotId: Int?) {
        self.selectedSlotId = selectedSlotId
    }
    func setUserId(userId: NSNumber?) {
        self.userid = userId
    }
    func getUserId()-> NSNumber? {
        return self.userid
    }

    func setSelectedSmilePoints(selectedSmilePoints: Int) {
        self.selectedSmilePoints = ElGrocerUtility.sharedInstance.calculateAEDsForSmilesPoints(selectedSmilePoints, smilesBurntRatio: self.basketDataValue?.smilesBurnRatio)
    }
    func setSelectedElwaletPoints(selectedElWalletPoints: Double) {
        self.selectedElwaletPoints = selectedElWalletPoints
    }
    
    func getSelectedSmilesPoints() -> Double {
        return self.selectedSmilePoints
    }
    
    func getSelectedElwalletCredit() -> Double {
        return self.selectedElwaletPoints
    }
    
    func setGroceryAndAddressAndRefreshData(_ grocery: Grocery?, deliveryAddress: DeliveryAddress)  {
         self.grocery = grocery
        self.address = deliveryAddress
        self.selectedSlotId = nil
        self.setDeliveryAddress(deliveryAddress)
        self.setDeliverySlot(nil)
        self.setDefaultApiData()
        self.fetchDeliverySlots { [weak self]  in
            let slots = DeliverySlot.getAllDeliverySlots(DatabaseHelper.sharedInstance.mainManagedObjectContext, forGroceryID: grocery?.dbID ?? "-1")
                if slots.count > 0 {
                    let slot = slots[0]
                    self?.selectedSlotId = slot.dbID.intValue
                }
                self?.updateSlotToBackEnd()
        }
    }
    
    func isPromoApplied() -> Bool {
        return isPromoCodeTrue
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
    func getCarouselProductsArray() -> [Product]? {
        return self.carouselProductsArray
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
            if self.getSelectedPaymentMethodId() != nil {
                self.defaultApiData["primary_payment_type_id"] = self.getSelectedPaymentMethodId()
            }else if self.getEditOrderSelectedPaymentMethodId() != nil {
                self.defaultApiData["primary_payment_type_id"] = self.getEditOrderSelectedPaymentMethodId()
            }
        }else {
            if self.getSelectedPaymentMethodId() != nil {
                self.defaultApiData["primary_payment_type_id"] = self.getSelectedPaymentMethodId()
            }
        }
        
        let addressID = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)?.dbID
        self.defaultApiData["smiles_address_id"] = addressID ?? "0"
       
        return self.defaultApiData
    }
    private func getDefaultApiData() -> [String : Any] {
        return self.defaultApiData
    }
    
    //MARK: helper methods for smile point conversions
    
    
    func getBurnPointsFromAed() -> Int {
        guard ElGrocerUtility.sharedInstance.appConfigData != nil else {
            return 0
        }
        let doubleAmount = self.basketDataValue?.finalAmount ?? 0.0
        let smilesConfig = ElGrocerUtility.sharedInstance.appConfigData.smilesData
        let points =  Int(round(doubleAmount/smilesConfig.burning))
        return points
    }
    
    func getEarnPointsFromAed() -> Int {
        if let doubleAmount = self.basketDataValue?.totalValue,let smileAED = self.basketDataValue?.smilesRedeem {
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
        let paymentOptionType = UInt32(self.basketDataValue?.primaryPaymentTypeID ?? 0)
        return PaymentOption(rawValue: paymentOptionType) ?? PaymentOption.none
    }
    
    func getSelectedPaymentMethodId() -> UInt32? {
        if let selectedMethod = self.basketDataValue?.primaryPaymentTypeID {
            let typeId = UInt32(selectedMethod )
            return typeId
        }
        
        return nil
    }
    
    func getEditOrderSelectedPaymentMethodId() -> Int? {
        let typeId = self.editOrderPrimarySelectedMethod
        return typeId
    }
    
    func getTabbyAuthenticationURL() -> String? {
        return self.tabbyWebUrl
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
        
        var parameters: [String: Any] = [:]
        parameters.update(other: self.setDefaultApiData())
        return parameters
    }
    
    private func createParamsUpdateForSlotId() -> [String: Any] {
        guard let slotId = self.selectedSlotId else { return [:] }
        var parameters: [String: Any] = self.setDefaultApiData()
        parameters.update(other: [ "selected_delivery_slot": "\(slotId)" ])
        return parameters
    }
    
    
    private func createParamsForSecondaryPaymentUpdate() -> [String: Any] {
        var parameters: [String: Any] = [:]
        if let id = self.promoRealizationId {
            parameters["realization_id"] = id
        }
        var secondaryPayments: [String: Any] = [:]
        secondaryPayments["smiles"] = self.selectedSmilePoints
        secondaryPayments["el_wallet"] = self.selectedElwaletPoints
        secondaryPayments["promo_code"] = self.isPromoCodeTrue
        
        parameters["secondary_payments"] = secondaryPayments
        parameters.update(other: self.setDefaultApiData())
        return parameters
    }
    
    func hidesSecondaryPaymentsViews(paymentMethods: [PaymentType]) -> (smilesPoint: Bool, elWallet: Bool) {
        
        let isSmilesApplicable = paymentMethods.first(where: { $0.name == "smiles_points" })
        let elWalletApplicable = paymentMethods.first(where: { $0.name == "el_wallet" })
        
        return (isSmilesApplicable == nil, elWalletApplicable == nil)
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
    
    func setInitialDataForEditOrder(_ order : Order?) {
        guard let order = order else {
            return
        }
        
        self.setEditOrderSelectedPaymentOption(id: nil)
        if let orderPayments = order.orderPayments {
            for payment in orderPayments {
                let amount = payment["amount"] as? NSNumber ?? NSNumber(0)
                let paymentTypeId = payment["payment_type_id"] as? Int
                
                if (paymentTypeId ?? 0) == 4 {
                    self.selectedSmilePoints = amount.doubleValue
                    
                }else if (paymentTypeId ?? 0) == 5 {
                    self.selectedElwaletPoints = amount.doubleValue
                    
                }else if (paymentTypeId ?? 0) == 6 {
                    if amount > 0 {
                        let id  = payment["id"] as? NSNumber ?? NSNumber(0)
                        self.setPromoCodeRealisationId(realizationId: id.stringValue, promoAmount: amount.doubleValue)
                        self.setIsPromoTrue(isPromoTrue: true)
                    }else {
                        self.setIsPromoTrue(isPromoTrue: false)
                    }
                }
            }
        }
    }
    
    func getCurrentDeliverySlotId() -> Int? {
        return self.selectedSlotId
    }
    
    func setDeliverySlot(_ slot : DeliverySlotDTO?) {
        self.selectedSlot = slot
    }
    
    func getDeliverySlot() -> DeliverySlotDTO? {
        return self.selectedSlot
    }
    
    // grocery id
    
    func getGroceryId() -> String? {
        return self.grocery?.getCleanGroceryID() ?? nil
    }
    func setSelectedPaymentOption(id: Int) {
        self.basketDataValue?.primaryPaymentTypeID = id
    }
    func setEditOrderSelectedPaymentOption(id: Int?) {
        self.editOrderPrimarySelectedMethod = id
    }
}

//MARK: Support function for DeliveryAddress
extension SecondaryViewModel {
    
    private func setDeliveryAddress(_ currentAddress : DeliveryAddress) {
        if ElGrocerUtility.isAddressCentralisation {
            self.deliveryAddress = ElGrocerUtility.sharedInstance.getFormattedCentralisedAddress(currentAddress, showNickName: false)
        }  else {
            self.deliveryAddress = ElGrocerUtility.sharedInstance.getFormattedAddress(currentAddress)
        }
        self.deliveryAddressObj = currentAddress
    }
    func getDeliveryAddress() -> String {
        if let formatterAddress = self.deliveryAddress {
            return formatterAddress
        }else if let deliveryAddress = DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            if ElGrocerUtility.isAddressCentralisation {
                return ElGrocerUtility.sharedInstance.getFormattedCentralisedAddress(deliveryAddress, showNickName: false)
            }  else {
                let formatAddressStr =  ElGrocerUtility.sharedInstance.getFormattedAddress(deliveryAddress).count > 0 ? ElGrocerUtility.sharedInstance.getFormattedAddress(deliveryAddress) : deliveryAddress.locationName + deliveryAddress.address
                return formatAddressStr
            }
        }else {
            return ""
        }
    }
    
    func getDeliveryAddressObj() -> DeliveryAddress? {
        return self.deliveryAddressObj
    }
    
    func createPaymentOptionFromString(paymentTypeId: Int) -> PaymentOption {
        let paymentOptionType = UInt32(paymentTypeId)
        return PaymentOption(rawValue: paymentOptionType) ?? PaymentOption.none
    }
}

//MARK: Events Support
extension SecondaryViewModel {
    
    func setRecipeCartAnalyticsAndRemoveRecipe() {
        
        let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
        let userProfile = UserProfile.getUserProfile(context)
        RecipeCart.GETSpecficUserAddToCartListRecipes(forDBID:  userProfile?.dbID ?? 0 , context) { [weak self](recipeCartList) in
                // guard let self = self else {return}
            guard let listData = recipeCartList else {
                RecipeCart.DeleteAll(forDBID: userProfile?.dbID as! Int64 , context)
                return
            }
            
            let productCurrentA = self?.getFinalisedProducts()
            
            for data :RecipeCart in listData {
                var isNeedToLockRecipeOrderEvent = false
                let ingredientsListID = data.ingredients
                let filterA = productCurrentA?.filter {
                    ingredientsListID.contains($0.productId)
                }
                if let finalA = filterA {
                    if finalA.count > 0 {
                        isNeedToLockRecipeOrderEvent = true
                    }
                    for prod in finalA {
                        if let productName = ElGrocerUtility.sharedInstance.isArabicSelected() ? prod.nameEn : prod.name {
                            let trackEventName = FireBaseElgrocerPrefix + FireBaseEventsName.RecipeIngredientPurchase.rawValue
                            FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: trackEventName , parameter: [FireBaseParmName.RecipeName.rawValue : data.recipeName , FireBaseParmName.recipeId.rawValue : data.recipeID , FireBaseParmName.RecipeIngredientid.rawValue :  prod.productId  , FireBaseParmName.ProductName.rawValue : productName , FireBaseParmName.BrandName.rawValue :  prod.brandNameEn ?? "" , FireBaseParmName.CategoryName.rawValue :  prod.categoryNameEn ?? "" , FireBaseParmName.SubCategoryName.rawValue :  prod.subcategoryNameEn ?? ""   ])
                                //GoogleAnalyticsHelper.trackRecipeIngredientsOrderEvent(trackEventName, data.recipeName)
                        }
                    }
                }
                if isNeedToLockRecipeOrderEvent {
                    let eventName = FireBaseElgrocerPrefix +  FireBaseEventsName.RecipePurchase.rawValue
                    GoogleAnalyticsHelper.trackRecipeOrderEvent(eventName)
                    FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: eventName , parameter: [FireBaseParmName.RecipeName.rawValue : data.recipeName , FireBaseParmName.recipeId.rawValue : data.recipeID])
                }
            }
            RecipeCart.DeleteAll(forDBID: userProfile?.dbID as! Int64 , context)
            
        }
        
        CarouselProducts.GetSpecficUserAddToCartListCarousel(forUserDBID: userProfile?.dbID ?? 0 , context) { [weak self] (carouselProducts) in
            
            guard let listData = carouselProducts else {
                CarouselProducts.DeleteAll(forDBID: userProfile?.dbID as! Int64 , context)
                return
            }
            self?.carouselProductsArray?.removeAll()
            let productCurrentA = self?.getFinalisedProducts()
            for data :CarouselProducts in listData {
                let filterA = productCurrentA?.filter {
                    data.dbID == Int64(truncating: $0.productId)
                }
                for product:Product in filterA ?? [] {
                    if let productName = ElGrocerUtility.sharedInstance.isArabicSelected() ? product.nameEn : product.name {
                        let trackEventName = FireBaseElgrocerPrefix + FireBaseEventsName.CarousalIngredientPurchase.rawValue
                        FireBaseEventsLogger.logEventToFirebaseWithEventName("", eventName: trackEventName , parameter: [ FireBaseParmName.ProductId.rawValue :  product.productId  , FireBaseParmName.ProductName.rawValue : productName , FireBaseParmName.BrandName.rawValue :  product.brandNameEn ?? "" , FireBaseParmName.CategoryName.rawValue :  product.categoryNameEn ?? "" , FireBaseParmName.SubCategoryName.rawValue :  product.subcategoryNameEn ?? ""   ])
                    }
                    self?.carouselProductsArray?.append(product)
                }
            }
            CarouselProducts.DeleteAll(forDBID: userProfile?.dbID as! Int64 , context)
        }
    }
}
