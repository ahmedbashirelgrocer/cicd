//
//  PromotionCodeHandler.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 16/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class PromotionCodeHandler {
    
    var paymentOption: PaymentOption?
    var grocery: Grocery?
    var price: Double?
    var shoppingItems: [ShoppingBasketItem]?
    var orderId: String?
    
    init() {
        self.paymentOption = nil
        self.grocery = nil
        self.shoppingItems = []
        self.orderId = nil
        self.price = nil
    }
    init(paymentOption: PaymentOption, grocery: Grocery, price: Double, shoppingItems: [ShoppingBasketItem], orderId: String? = nil) {
        self.paymentOption = paymentOption
        self.grocery = grocery
        self.price = price
        self.shoppingItems = shoppingItems
        self.orderId = orderId
    }
    
    func getPromoList(limmit: Int, offset: Int, completion: @escaping ([PromotionCode]?, ElGrocerError?)-> Void) {
        guard let grocery = self.grocery?.dbID else {
            completion(nil, ElGrocerError(code: 10000))
            return
        }
        var promoCodeArray = [PromotionCode]()
        ElGrocerApi.sharedInstance.getPromoList(limmit: limmit, Offset: offset, grocery: grocery) { result in
            switch result {
                case .success(let response):
                    elDebugPrint(response)
                guard let responseData = response["data"] as? [NSDictionary] else{
                   elDebugPrint("invalid response")
                    completion(nil,ElGrocerError.parsingError())
                    return
                }
                
                for data in responseData {
                   elDebugPrint(data)
                    do {
                        let promo = PromotionCode.init(fromResponse: data as? AnyObject)
                        let promoCodeObjData = try NSKeyedArchiver.archivedData(withRootObject: promo, requiringSecureCoding: false)
//                     let promotionCode = try NSKeyedUnarchiver.unarchivedObject(ofClass: PromotionCode.self, from: promoCodeObjData)
                        let promotionCode = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [PromotionCode.self,NSArray.self,NSDictionary.self], from: promoCodeObjData) as? PromotionCode
                        if promotionCode != nil {
                            promoCodeArray.append(promotionCode!)
                        }
                       elDebugPrint(promotionCode)

                    } catch (let error) {
                       elDebugPrint(error.localizedDescription)
                        if let error = error as? NSError {
                            completion(nil, ElGrocerError(error: error))
                        }else {
                            completion(nil, ElGrocerError.parsingError())
                        }
                        break;
                    }
                }
                completion(promoCodeArray, nil)
                    
                case .failure(let error):
                   elDebugPrint(error)
                    completion(nil, error)
//                error.showErrorAlert()
            }
        }
    }

    func checkPromoCode(promoText: String,isFromText: Bool = false, completion: @escaping (PromotionCode?,ElGrocerError?)-> Void) {

        guard let grocery = self.grocery else {
//            showPromoError(false, message: localizedString("error_10000", comment: ""))
            completion(nil, ElGrocerError(code: 10000))
            return
        }
        guard self.paymentOption != nil,let price = self.price, let shoppingItemsArray = self.shoppingItems else {
//            showPromoError(false, message: localizedString("error_10009", comment: ""))
            completion(nil, ElGrocerError(code: 10009))
            return
        }
        
        if paymentOption == .applePay{
            paymentOption = .creditCard
        }

        var deliveryFee = 0.0
        var riderFee = 0.0
        
        if price < grocery.minBasketValue ?? 0 {
            deliveryFee = grocery.deliveryFee ?? 0
        }else{
            riderFee = grocery.riderFee ?? 0
        }

        ElGrocerApi.sharedInstance.checkAndRealizePromotionCode(promoText , grocery: grocery, basketItems: shoppingItemsArray,withPaymentType: paymentOption!, deliveryFee: String(format:"%f", deliveryFee) , riderFee: String(format:"%f", riderFee), orderID: self.orderId ) { (result) -> Void in
            
            switch result {
                case .success(let promoCode):
                    do {
                        
                        let promoCodeObjData = try NSKeyedArchiver.archivedData(withRootObject: promoCode , requiringSecureCoding: false)
                        UserDefaults.setPromoCodeValue(promoCodeObjData)
                        UserDefaults.setPromoCodeIsFromText(isFromText)
                        FireBaseEventsLogger.trackPromoCode(promoText)
                        completion(promoCode,nil)
                    }catch(let error){
                        elDebugPrint(error)
                        UserDefaults.setPromoCodeValue(nil)
                        UserDefaults.setPromoCodeIsFromText(nil)
                        if let error = error as? NSError {
                            completion(nil, ElGrocerError(error: error))
                        }else {
                            let elgError = ElGrocerError.parsingError()
                            completion(nil, elgError)
                        }
                        
                    }
                    break
                case .failure(let error):
                    UserDefaults.setPromoCodeValue(nil)
                    UserDefaults.setPromoCodeIsFromText(nil)
                    completion(nil, error)
            }
            
        }
        
    }
    
    class func checkIfBrandProductAdded(products: [Product], brandDict: [NSDictionary]) -> (isFound: Bool,brandName: String) {
        var isFound: Bool = false
        var brandNameToShow: String = ""
        if brandDict.count == 0 {
            return (true,"")
        }
        for product in products {
            for dictionary in brandDict {
                let brandId = dictionary["id"] as? NSNumber ?? NSNumber(0)
                let brandName = dictionary["name"] as? String ?? ""
                if brandId == product.brandId {
                    isFound = true
                    return (isFound,"")
                    break;
                }else {
                    brandNameToShow = brandName
                }
                
            }
        }
        
        return (isFound,brandNameToShow)
    }

}
