    //
    //  myBasket.swift
    //  ElGrocerShopper
    //
    //  Created by Abdul Saboor on 07/10/2021.
    //  Copyright © 2021 elGrocer. All rights reserved.
    //

import Foundation

    // MARK:- MyBasketCheckOut & delegates -

protocol MyBasketCheckOut : class {
    func receivedReasonAndSelectedReason ( reasonA : [Reasons] , selectedReason : Int?)
    func basketDataUpdated ( _ products : [Product]? , _ notAvailableProducts : [Product]?)
    func basketDataUpdateFailed ()
}
extension MyBasketCheckOut {
    
    func receivedReasonAndSelectedReason ( reasonA : [Reasons] , selectedReason : Int?) {}
    func basketDataUpdated ( _ products : [Product]? , _ notAvailableProducts : [Product]?) {}
    func basketDataUpdateFailed () {}
    
}


class MyBasket  {
    
    
        // MARK:- Class Properties -
    
    weak var delegate : MyBasketCheckOut?
    var finalizedProductsA: [Product]
    var shoppingItemsA: [ShoppingBasketItem]
    var deliverySlotsA: [DeliverySlot]
    private var reasonsA: [Reasons]
    var activeDeliverySlot: DeliverySlot? = nil
    var activeGrocery: Grocery?
    var activeAddressObj : DeliveryAddress?
    var activeAddress: String
    var order : Order? = nil
    var orderType = OrderType.delivery
    
    
        // MARK:- Initialiser -
    
    init() {
        
        self.finalizedProductsA = []
        self.shoppingItemsA = []
        self.deliverySlotsA = []
        self.reasonsA = []
        self.activeDeliverySlot = nil
        self.activeGrocery = nil
        self.activeAddress = ""
        
        
    }
    
    convenience init( grocery  : Grocery ) {
        self.init()
        self.activeGrocery = grocery
    }
    
    convenience init(productArray : [Product] , shoppingItemsArray : [ShoppingBasketItem], deliverySlotArray: [DeliverySlot] , activeSlot : DeliverySlot?, activeAddress : String, Grocery : Grocery?) {
        
        self.init()
        self.finalizedProductsA = productArray
        self.shoppingItemsA = shoppingItemsArray
        self.deliverySlotsA = deliverySlotArray
        self.activeDeliverySlot = activeSlot
        self.activeAddress = activeAddress
        self.activeGrocery = Grocery
        
    }
    
    func getSortedReasonA() -> [Reasons] {
        var reason = self.reasonsA
        let selectedReason = self.getSelectedReason() ?? Reasons()
        
        if let index = self.reasonsA.firstIndex(where: { (reason) -> Bool in
            return reason.reasonKey == selectedReason.reasonKey
        }) {
            reason.move(from: index, to: 0)
        }
        return reason
    }
    
    func getReasonA() -> [Reasons] {
        return self.reasonsA
    }
    
        //MARK: price calculation
    fileprivate func shoppingItemForProduct(_ product:Product) -> ShoppingBasketItem? {
        
        for item in self.shoppingItemsA {
            if product.dbID == item.productId {
                return item
            }
        }
        return nil
        
    }
    
    func getPrice(_ isWithTobacco : Bool = false) -> Double {
        
        var priceSumV = 0.00
        for product in self.finalizedProductsA {
            let item = shoppingItemForProduct(product)
            if let notNilItem = item {
                
                if isWithTobacco{
                    if(product.isPublished.boolValue && product.isAvailable.boolValue){
                        var price = product.price.doubleValue
                        if product.promotion?.boolValue == true{
                            if product.promoPrice != nil{
                                price = product.promoPrice!.doubleValue
                            }
                        }
                        priceSumV += price * notNilItem.count.doubleValue
                    }
                }else{
                    if(product.isPublished.boolValue && product.isAvailable.boolValue && !product.isPg18.boolValue){
                        var price = product.price.doubleValue
                        if product.promotion?.boolValue == true{
                            if product.promoPrice != nil{
                                price = product.promoPrice!.doubleValue
                            }
                        }
                        priceSumV += price * notNilItem.count.doubleValue
                    }
                }
                
            }
        }
        return priceSumV
    }
    
    
    func getPriceWithServiceFeeAndPromoCode() -> (finalAmount:Double,promoAmount:Double) {
        var PriceToShow: Double = 0.00
        var promoPrice: Double = 0.00
        if let grocery =  self.activeGrocery {
                //            var serviceFee: Double = 0.0
            let priceWithTobacco = getPrice(true)
            let serviceFee = grocery.serviceFee
            
            PriceToShow = priceWithTobacco + serviceFee
            
            if let promoCodeValue = UserDefaults.getPromoCodeValue() {
                promoPrice = promoCodeValue.valueCents
                PriceToShow = PriceToShow - promoPrice
            }
        }
        
        if PriceToShow < 0{
            PriceToShow = 0.00
        }
        
        return (PriceToShow,promoPrice)
        
    }
    
    
    func getTotalSavingsAmount() -> Double {
        
        var Discount : Double = 0.0
        for product in self.finalizedProductsA {
            
            let item = shoppingItemForProduct(product)
            
            if let notNilItem = item {
                
                if(product.isPublished.boolValue && product.isAvailable.boolValue){
                    let promotionValues = ProductQuantiy.checkPromoNeedToDisplay(product)
                    if promotionValues.isNeedToDisplayPromo{
                        let price : Double = product.price.doubleValue
                        var promoPrice : Double = 0.0
                        if let promoPrices = product.promoPrice?.doubleValue {
                            promoPrice = promoPrices
                        }
                        let discountOnSingle: Double = (price - promoPrice) * notNilItem.count.doubleValue
                        Discount += discountOnSingle
                    }
                }
                
            }
        }
        
        if let promoCodeValue = UserDefaults.getPromoCodeValue() {
            if promoCodeValue.valueCents > 0 {
                Discount = (promoCodeValue.valueCents) + Discount
            }
        }
        
        return Discount
        
    }
    
    
        //MARK: deliverySlots
    
    func setOrderTypeLabelText() -> String {
        
        var orderTypeDescription = ""
        var isNextSlotAvailable = true
        
        /*1- instant or Instant + Schedule + open - ASAP.
         2- Schedule or (Instant + Schedule + close) - Next available slot.*/
        
        let slotId = UserDefaults.getCurrentSelectedDeliverySlotId()
        if (self.activeGrocery?.deliveryTypeId != nil && (self.activeGrocery?.deliveryTypeId == "1" || (self.activeGrocery?.deliveryTypeId == "2" && self.activeGrocery?.isOpen.boolValue == false))) {
            
                //  print("Delivery Slots Array Count:%d",self.deliverySlotsArray.count)
            
            if (self.deliverySlotsA.count > 0) {
                var currentSlots : [DeliverySlot] = []
                let slot = self.deliverySlotsA[0]
                currentSlots = [slot]
            }else{
                orderTypeDescription =  NSLocalizedString("no_slots_available", comment: "")
            }
        }
        if slotId != 0 {
            let index = self.deliverySlotsA.firstIndex(where: { $0.dbID == slotId })
            if (index != nil) {
                self.activeDeliverySlot = self.deliverySlotsA[index!]
            }else{
                    //self.showCustomTipBar()
                self.activeDeliverySlot = nil
            }
            if self.activeDeliverySlot != nil && Int(truncating: self.activeDeliverySlot!.getdbID()) != asapDbId && (self.activeDeliverySlot?.estimated_delivery_at.minutesFrom(Date()) ?? 0) < 0 {
                    // self.updateSlotsAndChooseNextAvailable()
                let currentSlotIndex = self.deliverySlotsA.firstIndex(where: {$0.dbID == self.activeDeliverySlot?.dbID})
                if (currentSlotIndex != nil) {
                        //  print("Current Slot Index:%d",currentSlotIndex!)
                    let nextAvailableSlotIndex = currentSlotIndex! + 1
                        // print("Next Available Slot Index:%d",nextAvailableSlotIndex)
                    if(nextAvailableSlotIndex < self.deliverySlotsA.count){
                        self.activeDeliverySlot = self.deliverySlotsA[nextAvailableSlotIndex]
                    }else{
                        isNextSlotAvailable = false
                    }
                }
            }
        }else{
            self.activeDeliverySlot = nil
            
        }
        if self.activeDeliverySlot != nil && isNextSlotAvailable == true {
            UserDefaults.setCurrentSelectedDeliverySlotId(self.activeDeliverySlot!.dbID)
            orderTypeDescription = self.activeDeliverySlot!.getSlotFormattedString(true, isDeliveryMode: ElGrocerUtility.sharedInstance.isDeliveryMode)
        }else{
            if (self.activeGrocery?.deliveryTypeId == "0" || (self.activeGrocery?.deliveryTypeId == "2" && self.activeGrocery?.isOpen.boolValue == true)) {
                
                let instantSlots = self.deliverySlotsA.filter { slot in
                    slot.isInstant.boolValue
                }
                
                if  instantSlots.count > 0 {
                    
                    self.activeDeliverySlot = instantSlots[0]
                    orderTypeDescription =   NSLocalizedString("today_title", comment: "") + " "   +  NSLocalizedString("60_min", comment: "")

                } else {
                    orderTypeDescription = NSLocalizedString("choose_slot", comment: "")
                }
                
            }else{
                if  self.deliverySlotsA.count > 0 {
                    self.activeDeliverySlot = self.deliverySlotsA[0]
                    orderTypeDescription = self.activeDeliverySlot!.getSlotFormattedString(true, isDeliveryMode: ElGrocerUtility.sharedInstance.isDeliveryMode)
                    
                }else{
                    orderTypeDescription = NSLocalizedString("choose_slot", comment: "")
                }
            }
        }
        
        return orderTypeDescription
    }
    
    
    func getCurrentActiveSlot() -> ( DeliverySlot? , Bool ) {
        
        var isNextSlotAvailable = true
        var selectedSlot : DeliverySlot? = nil
        
        /*1- instant or Instant + Schedule + open - ASAP.
         2- Schedule or (Instant + Schedule + close) - Next available slot.*/
        
        let slotId = UserDefaults.getCurrentSelectedDeliverySlotId()
        if (self.activeGrocery?.deliveryTypeId != nil && (self.activeGrocery?.deliveryTypeId == "1" || (self.activeGrocery?.deliveryTypeId == "2" && self.activeGrocery?.isOpen.boolValue == false))) {
            if (self.deliverySlotsA.count > 0) {
                let slot = self.deliverySlotsA[0]
                selectedSlot = slot
            }else{
                selectedSlot = nil
            }
        }
        if slotId != 0 {
            let index = self.deliverySlotsA.firstIndex(where: { $0.dbID == slotId })
            if (index != nil) {
                selectedSlot = self.deliverySlotsA[index!]
            }else{
                selectedSlot = nil
            }
            
            if self.activeDeliverySlot != nil && Int(truncating: self.activeDeliverySlot!.getdbID()) != asapDbId && (self.activeDeliverySlot?.estimated_delivery_at.minutesFrom(Date()) ?? 0) < 0 {
                    // self.updateSlotsAndChooseNextAvailable()
                let currentSlotIndex = self.deliverySlotsA.firstIndex(where: {$0.dbID == self.activeDeliverySlot?.dbID})
                if (currentSlotIndex != nil) {
                        //  print("Current Slot Index:%d",currentSlotIndex!)
                    let nextAvailableSlotIndex = currentSlotIndex! + 1
                        // print("Next Available Slot Index:%d",nextAvailableSlotIndex)
                    if(nextAvailableSlotIndex < self.deliverySlotsA.count){
                        selectedSlot = self.deliverySlotsA[nextAvailableSlotIndex]
                    }else{
                        isNextSlotAvailable = false
                    }
                }
            }
        } else {
            selectedSlot = nil
        }
        if selectedSlot != nil && isNextSlotAvailable == true {
            
        }else {
            if (self.activeGrocery?.deliveryTypeId == "0" || (self.activeGrocery?.deliveryTypeId == "2" && self.activeGrocery?.isOpen.boolValue == true)) {
                selectedSlot = nil
            }else{
                if  self.deliverySlotsA.count > 0 {
                    selectedSlot = self.deliverySlotsA[0]
                }else{
                    selectedSlot = nil
                }
            }
        }
        let isChanged = (self.activeDeliverySlot?.dbID != selectedSlot?.dbID)
        return (selectedSlot , isChanged)
    }
    
    
        // Mark:- refresh BasketData
    
    func refreshBasketData() {
        
        guard self.activeGrocery != nil else {
            self.delegate?.basketDataUpdateFailed()
            return
        }
        self.getBasketFromServerWithGrocery(self.activeGrocery)
        
    }
    
    
        // MARK: Helpers
    
    
    func checkIsOverLimitProductAvailable() -> Product? {
        
        var overLimitProduct : Product? = nil
        for product in self.finalizedProductsA {
            if let promotionAvailable = product.promotion , promotionAvailable == true {
                if let item = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.activeGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                    if let limit = product.promoProductLimit?.doubleValue {
                        if item.count.doubleValue > limit && limit > 0 {
                            overLimitProduct = product
                        }
                    }
                }
            }
            if overLimitProduct != nil {
                break
            }
        }
        return overLimitProduct
    }
    
    
}


extension MyBasket  {
    
        // MARK:- My basket CheckOut  Handling -
    
    func getSelectedReason() -> Reasons? {
        return UserDefaults.getSelectedReason()
    }
    
    func setNewSelectedReason(_ reason : Reasons) {
        let reasonData = try? NSKeyedArchiver.archivedData(withRootObject: reason , requiringSecureCoding: false)
        UserDefaults.setSelectedReason(reasonData)
    }
    
    func getReasons() {
        
        guard self.reasonsA.count == 0 else {
            let reason = getSelectedReason()
            self.delegate?.receivedReasonAndSelectedReason(reasonA: self.reasonsA, selectedReason: reason != nil ? reason?.reasonKey.intValue :  nil)
            return
        }
        
        
        ElGrocerApi.sharedInstance.getIfOOSReasons { (results) in
            switch results {
                case .success(let data):
                    self.handleReasonApiResponse(data["data"] as? [NSDictionary])
                case .failure(let error):
                    debugPrint(error.localizedMessage)
                    ElGrocerUtility.sharedInstance.delay(0.5) {
                        self.getReasons()
                    }
            }
        }
    }
    
    private func handleReasonApiResponse (_ data : [NSDictionary]?) {
        
        guard data != nil else {
            return
        }
        self.reasonsA = data?.map({ (reasonDict) -> Reasons in
            return Reasons.init(key: reasonDict["key"] as! NSNumber, reason: reasonDict["value"] as! String)
        }) ?? []
        
        let reason = getSelectedReason()
        self.delegate?.receivedReasonAndSelectedReason(reasonA: self.reasonsA, selectedReason: reason != nil ? reason?.reasonKey.intValue :  nil)
        
    }
    
    
}


extension MyBasket {
    
    
        // MARK: - Get Basket Data -
    
    private func getBasketFromServerWithGrocery(_ grocery:Grocery?){
        
        
        ElGrocerApi.sharedInstance.fetchBasketFromServerWithGrocery(grocery) { (result) in
            switch result {
                case .success(let responseDict):
                    print("Fetch Basket Response:%@",responseDict)
                    self.saveResponseData(responseDict, andWithGrocery: grocery)
                case .failure(_ ):
                    self.delegate?.basketDataUpdateFailed()
            }
        }
    }
    
    private func saveResponseData(_ responseObject:NSDictionary, andWithGrocery grocery:Grocery?) {
        
        
        guard let shopperCartProducts = responseObject["data"] as? [NSDictionary] else {return}
        
        var isPromoChanged = false
        var promotionalItemChangedMessage : String = ""
        
        for responseDict in shopperCartProducts {
            
            
            if let productDict =  responseDict["product"] as? NSDictionary {
                
                let quantity = responseDict["quantity"] as! Int
                let updatedAt = responseDict["updated_at"] as? String ?? ""
                let createdAt = responseDict["created_at"] as? String ?? ""
                
                let updatedDate : Date? = updatedAt.isEmpty ? nil : updatedAt.convertStringToCurrentTimeZoneDate()
                let createdDate : Date? = createdAt.isEmpty ? nil : createdAt.convertStringToCurrentTimeZoneDate()
                
                let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                let product = Product.createProductFromDictionary(productDict, context: context ,  createdDate ,  updatedDate )
                
                    //insert brand
                if let brandDict = productDict["brand"] as? NSDictionary {
                    
                    let brandId = brandDict["id"] as! Int
                    let brandName = brandDict["name"] as? String
                    let brandImage = brandDict["image_url"] as? String
                    let brandSlugName = brandDict["slug"] as? String
                    
                    
                    let brand = DatabaseHelper.sharedInstance.insertOrReplaceObjectForEntityForName(BrandEntity, entityDbId: brandId as AnyObject, keyId: "dbID", context: context) as! Brand
                    brand.name = brandName
                    brand.nameEn = brandSlugName
                    brand.imageUrl = brandImage
                    product.brandId = brand.dbID
                    
                }
                if let messages = productDict["messages"] as? [NSDictionary] {
                    for message in messages {
                        if let messageCode = message["message_code"] as? NSNumber{
                            if messageCode == 2000 {
                                if !isPromoChanged{
                                    isPromoChanged = true
                                    break
                                }
                            }
                        }
                        if let messageString = message["message"] as? String{
                            promotionalItemChangedMessage = messageString
                            
                        }
                    }
                }
                ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: grocery, brandName:nil, quantity: quantity, context: context)
            }
        }
        
        if isPromoChanged && promotionalItemChangedMessage.count > 0 {
            let msg = promotionalItemChangedMessage //NSLocalizedString("promotion_changed_alert_title", comment: "")
            ElGrocerUtility.sharedInstance.showTopMessageView( msg , image: UIImage(named: "MyBasketOutOfStockStatusBar") , -1 , false) { (sender , index , isUnDo) in  }
        }
        
        self.finalizedProductsA = ShoppingBasketItem.getBasketProductsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        self.shoppingItemsA = ShoppingBasketItem.getBasketItemsForActiveGroceryBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        
        let notAvailableProducts =  self.finalizedProductsA.filter({ (product) -> Bool in
            if let item = ShoppingBasketItem.checkIfProductIsInBasket(product, grocery: self.activeGrocery, context: DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                if item.isSubtituted.boolValue {
                    let firstIndex = self.finalizedProductsA.filter({ (data) -> Bool in
                        if data.dbID == item.subStituteItemID {
                            return true
                        }
                        return false
                    })
                    if firstIndex.count > 0 {
                        return false
                    }
                }
            }
            return !(product.isAvailable.boolValue && product.isPublished.boolValue )
        })
        
        self.delegate?.basketDataUpdated(self.finalizedProductsA , notAvailableProducts)
        
    }
    
    
    
}

