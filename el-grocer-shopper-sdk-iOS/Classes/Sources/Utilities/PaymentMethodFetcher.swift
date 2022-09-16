//
//  PaymentMethodFetcher.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 23/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import Adyen

typealias paymentFetcherCompletion = (_ paymentMethodA: [Any]?, _ creditCardA: [CreditCard]?, _ applePayPaymentMethod: ApplePayPaymentMethod?, _ error: ElGrocerError?)-> Void

typealias PaymentOptionsCompletion = (_ paymentOptions: [PaymentOption]?, _ error: ElGrocerError?) -> Void
typealias PaymentMethodsCompletion = (_ paymentMethods: [CreditCard]?, _ applePay: ApplePayPaymentMethod?, _ error: ElGrocerError?) -> Void

class PaymentMethodFetcher {
    
    class func getGroceryPaymentMethod(groceryId: String, shouldShowSmile: Bool = false, completion: @escaping (_ groceryPaymentA: [PaymentOption],_ error: ElGrocerError?) -> Void) {
        var paymentMethodArray: [PaymentOption] = []
        ElGrocerApi.sharedInstance.getAllPaymentMethods(retailer_id: groceryId) { (result) in
            SpinnerView.hideSpinnerView()
            switch result {
                case .success(let response):
                    debugPrint(response)
                    
                    if let dataDict = response["data"] as? NSDictionary {
                        if let paymentTypesA = dataDict["payment_types"]  as? [NSDictionary] {
                            paymentMethodArray.removeAll()
                            for paymentMethods in paymentTypesA {
                                let  paymentID : NSNumber =   paymentMethods.object(forKey: "id") as! NSNumber
                                if paymentID.uint32Value == PaymentOption.cash.rawValue {
                                    paymentMethodArray.append(PaymentOption.cash)
                                }else if paymentID.uint32Value == PaymentOption.card.rawValue {
                                    paymentMethodArray.append(PaymentOption.card)
                                }
                                else if paymentID.uint32Value == PaymentOption.creditCard.rawValue {
                                    paymentMethodArray.append(PaymentOption.creditCard)
                                }
                                else if paymentID.uint32Value == PaymentOption.smilePoints.rawValue && shouldShowSmile {
                                    paymentMethodArray.append(PaymentOption.smilePoints)
                                }
                                completion(paymentMethodArray, nil)
                            }
                        }else {
                            completion(paymentMethodArray, ElGrocerError.parsingError())
                        }
                    }else {
                        completion(paymentMethodArray, ElGrocerError.parsingError())
                    }
                    
                case .failure(let error ):
                    completion(paymentMethodArray,error)
            }
        }
    }

    class func getAdyenPaymentMethods(isApplePayAvailbe: Bool = false, shouldAddVoucher: Bool = false, completion: @escaping paymentFetcherCompletion) {
        
        var paymentMethodA = [Any]()
        var creditCardA = [CreditCard]()
        var selectedApplePayMethod: ApplePayPaymentMethod?
        let amount = AdyenManager.createAmount(amount: 100.0)
        AdyenApiManager().getPaymentMethods(amount: amount) { error, paymentMethods in
          if let error = error{
            completion(nil,nil,nil,error)
            return
          }
          Thread.OnMainThread {
            if let paymentMethod = paymentMethods {
              print(paymentMethods)
              for method in paymentMethod.regular{
                if method.type.elementsEqual("scheme") {
                    
                }else if method.type.elementsEqual("applepay") {
                  if ApplePaymentHandler.applePayStatus().canMakePayments {
                    paymentMethodA.append(PaymentOption.applePay)
                    if let applePay = method as? ApplePayPaymentMethod {
                      selectedApplePayMethod = applePay
                    }
                     
                  }
                }
              }
                if shouldAddVoucher {
                    paymentMethodA.append(PaymentOption.voucher)
                }
    
              for method in paymentMethod.stored {
                if method is StoredCardPaymentMethod {
                   
                  if let cardAdyen = method as? StoredCardPaymentMethod {
                    var card = CreditCard()
                    card.cardID = cardAdyen.identifier
                    card.last4 = cardAdyen.lastFour
                    if cardAdyen.brand.elementsEqual("mc") {
                      card.cardType = .MASTER_CARD
                    }else if cardAdyen.brand.elementsEqual("visa") {
                      card.cardType = .VISA
                    }else{
                      card.cardType = .unKnown
                    }
                     
                    card.adyenPaymentMethod = cardAdyen
                    if cardAdyen.brand.contains("applepay") {
                       
                    }else{
                      paymentMethodA.append(card)
                      creditCardA.append(card)
                    }
                     
                  }
                }
              }
              paymentMethodA.append(KAddNewCellString)
              completion(paymentMethodA,creditCardA,selectedApplePayMethod,nil)
            }
          }
        }
      }
    
    
    class func getPaymentOptions(groceryID: String, addSmiles: Bool = false, addVoucher: Bool = false, completion: @escaping PaymentOptionsCompletion) {
        ElGrocerApi.sharedInstance.getAllPaymentMethods(retailer_id: groceryID) { result in
            switch result {
                
            case .success(let dictionary):
                if let dataDictionary = dictionary["data"] as? [String: Any] {
                    if let paymentTypesDictionary = dataDictionary["payment_types"] as? [[String: Any]] {
                        do {
                            var options: [PaymentOption] = []
                            
                            for item in paymentTypesDictionary {
                                let data = try JSONSerialization.data(withJSONObject: item, options: [])
                                let paymentType: PaymentType = try JSONDecoder().decode(PaymentType.self, from: data)
                                
                                let id = paymentType.id as NSNumber
                                let paymentOption = PaymentOption.init(rawValue: id.uint32Value)
                                
                                // this logic should be outside of this method
                                if paymentOption == .cash {
                                    options.append(.cash)
                                } else if paymentOption == .card {
                                    options.append(.card)
                                } else if paymentOption == .creditCard {
                                    options.append(.creditCard)
                                } else if paymentOption == .smilePoints && addSmiles {
                                    options.append(.smilePoints)
                                } else if paymentOption == .voucher && addVoucher {
                                    options.append(.voucher)
                                }
                            }
                            
                            completion(options, nil)
                        } catch {
                            completion(nil, ElGrocerError.parsingError())
                        }
                    }
                }
                
                completion(nil, ElGrocerError.parsingError())
                break
                
            case .failure(let error):
                completion(nil, error)
                break
            }
        }
    }
    
    class func getPaymentMethods(amount: Amount, addApplePay: Bool, completion: @escaping PaymentMethodsCompletion) {
        AdyenApiManager().getPaymentMethods(amount: amount) { error, paymentMethods in
            if let error = error {
                completion(nil, nil, error)
                return
            }
            
            if let paymentMethods = paymentMethods {
                var applePaymentMethod: ApplePayPaymentMethod?
                var creditCards: [CreditCard] = []
                
                paymentMethods.regular.forEach { regularMethod in
                    
                    if regularMethod.type == "applepay" && ApplePaymentHandler.applePayStatus().canMakePayments {
                        if let applePay = regularMethod as? ApplePayPaymentMethod {
                            applePaymentMethod = applePay
                        }
                    }
                }
                
                paymentMethods.stored.forEach { storedMethod in
                    if let method = storedMethod as? StoredCardPaymentMethod {
                        var creditCard = CreditCard()
                        
                        if method.brand == "mc" {
                            creditCard.cardType = .MASTER_CARD
                        } else if method.brand == "visa" {
                            creditCard.cardType = .VISA
                        } else {
                            creditCard.cardType = .unKnown
                        }
                        creditCard.cardID = method.identifier
                        creditCard.last4 = method.lastFour
                        creditCard.adyenPaymentMethod = method
                        if method.brand.contains("applepay") {
                           
                        }else{
                            creditCards.append(creditCard)
                        }
                        
                    }
                }
                
                completion(creditCards, applePaymentMethod, nil)
                return
            }
            
            completion(nil, nil, ElGrocerError.genericError())
        }
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
            return NSLocalizedString("pay_via_cash", comment: "")
        }else if self.id == 2 {
            return NSLocalizedString("pay_via_card", comment: "")
        }else if self.id == 3 {
            return NSLocalizedString("pay_via_CreditCard", comment: "")
        }else if self.id == PaymentOption.applePay.rawValue {
            return NSLocalizedString("pay_via_Apple_pay", comment: "")
        }else {
            return self.name ?? ""
        }
    }
}
    // MARK: - PromoCode
struct PromoCode: Codable {
    let code: String?
    let promotionCodeRealizationID: Int?
    let value: Int?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case promotionCodeRealizationID = "promotion_code_realization_id"
        case value
        case errorMessage = "error_message"
    }
}

