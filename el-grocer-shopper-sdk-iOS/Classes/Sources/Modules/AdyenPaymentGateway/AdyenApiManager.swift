//
//  AdyenApiManager.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 20/12/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import Foundation
import Adyen

enum AdyenApiEndPoints: String {
    case getPaymentMethods = "v1/payments/payment_methods"
    case makeInitialPayment = "v1/payments/initiate_payment"
    case submitAdditionalPaymentDetails = "v1/payments/submit_additional_details"
    case submitRedirectResult = "v1/payments/handle_shopper_redirect"
    case deleteAdyenCreditCard = "v1/payments/disable"
}

class AdyenApiManager {
    // S- for pre auth , O- for order placing
    let shopperRefernceInitial = "S-"
    let orderRefernceInitial = "O-"
    typealias adyenApiCompletionHandler = (_ error: ElGrocerError?, _ response: NSDictionary?)-> Void
    //MARK: Adyen payment gateway
    func getPaymentMethods(amount: Amount, completion: @escaping (_ error: ElGrocerError?, _ paymentMethods: PaymentMethods?)-> Void) {
        
        guard let user = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext) else {
            return
        }
        
        let amountDict = NSMutableDictionary()
        amountDict["currency"] = amount.currencyCode
        amountDict["value"] = "\(amount.value)"
        
        let params = NSMutableDictionary()
        params["shopperReference"] = user.dbID.stringValue
        params["channel"] = "iOS"
        params["amount"] = amountDict
        
        ElGrocerApi.sharedInstance.getPaymentMethods(params) { results in
            print(results)
            switch results {
                case .success(let data):
                guard let dataDict = data["data"] as? NSDictionary else {
                    let error = ElGrocerError.parsingError()
                    completion(error, nil)
                    return
                }
                guard let response = dataDict["response"] as? NSDictionary else {
                    let error = ElGrocerError.parsingError()
                    completion(error, nil)
                    return
                }
                
                if let code = response["errorCode"] as? String {
                    let error = ElGrocerError(forAdyen: response)
                    completion(error, nil)
                    return
                }
                
                if let paymentMethodDict = response["paymentMethods"] as? [[String: Any]] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: response, options: [])
                           let paymentMethods = try JSONDecoder().decode(PaymentMethods.self, from: jsonData)
                           // get stored cards
                           print(paymentMethods.stored)
                           completion(nil,paymentMethods)
                         
                    } catch let error {
                        print(error.localizedDescription)
                        let error = ElGrocerError.parsingError()
                        completion(error, nil)
                    }
                }
                case .failure(let error):
                    debugPrint(error.localizedMessage)
                    completion(error, nil)
                    
            }
        }
        
    }
    
    func makePayment(amount: Amount, orderNum: String, paymentMethodDict: [String: Any],isForZeroAuth: Bool, browserInfo : BrowserInfo?, completion: @escaping adyenApiCompletionHandler) {
     
        let userID = UserDefaults.getLogInUserID()
     
        guard userID != "0" else {
            let error = ElGrocerError.genericError()
            completion(error,nil)
            return
        }
        
        let amountDict = NSMutableDictionary()
        amountDict["currency"] = amount.currencyCode
        amountDict["value"] = "\(amount.value)"
        
        let params = NSMutableDictionary()
       
        params["channel"] = "iOS"
        params["amount"] = amountDict
        params["reference"] = isForZeroAuth ? shopperRefernceInitial + userID : orderRefernceInitial + orderNum
        params["shopperInteraction"] = isForZeroAuth ? "Ecommerce" : "ContAuth"
        params["recurringProcessingModel"] = "CardOnFile"
        params["storePaymentMethod"] = true
        params["shopperReference"] = userID
        params["return_url"] = "elgrocer.com.ElGrocerShopper://"
        params["channel"] = "iOS"
        
        if let parm = params as? [String : Any] {
            FireBaseEventsLogger.trackCustomEvent(eventType: "payment", action: "makePayment", parm)
        }
        
        let header = "text\\/html,application\\/xhtml+xml,application\\/xml;q=0.9,image\\/webp,image\\/apng,*\\/*;q=0.8"
        if let browser = browserInfo, let userAgent = browser.userAgent {
            params["browserInfo"] = ["userAgent" :  userAgent, "acceptHeader" : header ]
        }
   
        
        let address = ElGrocerUtility.sharedInstance.getCurrentDeliveryAddress()
        let formatAddressStr =  ElGrocerUtility.sharedInstance.getFormattedAddress(address)
        params["billingAddress"] = formatAddressStr
      
        if let userProfile = UserProfile.getOptionalUserProfile( DatabaseHelper.sharedInstance.mainManagedObjectContext) {
            params["shopperEmail"] = userProfile.email
        }
        
        
    
        params["paymentMethod"] = paymentMethodDict
        
        
        
//        params["shopperEmail"] = user.email
//        if let ip = DeviceIp.getWiFiAddress() {
//            params["remote_ip"] = ip
//        }else {
//            if let publicAddress = DeviceIp.getPublicAddress() {
//                params["remote_ip"] = publicAddress
//            }
//
//        }
        
        
        ElGrocerApi.sharedInstance.makePayment(params) { results in
            print(results)
            switch results {
                case .success(let data):
                guard let dataDict = data["data"] as? NSDictionary else {
                    let error = ElGrocerError.parsingError()
                    completion(error, nil)
                    return
                }
                guard let response = dataDict["response"] as? NSDictionary else {
                    let error = ElGrocerError.parsingError()
                    completion(error, nil)
                    return
                }
                
            
                    if let code = response["errorCode"] as? String {
                        let error = ElGrocerError(forAdyen: response)
                        completion(error, nil)
                        return
                    }
                
                if let action = response["action"] as? NSDictionary {
                    completion(nil,response)
                }else {
                    let resultCode = response["resultCode"] as? String ?? ""
                    if resultCode.elementsEqual("Authorised") || resultCode.elementsEqual("Received") || resultCode.elementsEqual("Pending") {
                        completion(nil,response)
                    }else{
                        let error = ElGrocerError.genericError()
                        completion(error,response)
                    }
                }
                print(response)
                
                case .failure(let error):
                    debugPrint(error.localizedMessage)
                    completion(error, nil)
                    
            }
        }
        
    }
    //handlePayment additional steps
    func handlePaymentAction(data: ActionComponentData, completion: @escaping adyenApiCompletionHandler) {
        
        guard let user = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext) else {
            return
        }

        
        let params = NSMutableDictionary()
        params["paymentData"] = data.paymentData.dictionary
        params["details"] = data.details.dictionary
        
        
        ElGrocerApi.sharedInstance.handlePaymentAction(params) { results in
            print(results)
            switch results {
                case .success(let data):
                guard let dataDict = data["data"] as? NSDictionary else {
                    let error = ElGrocerError.parsingError()
                    completion(error, nil)
                    return
                }
                guard let response = dataDict["response"] as? NSDictionary else {
                    let error = ElGrocerError.parsingError()
                    completion(error, nil)
                    return
                }
                if let code = response["errorCode"] as? String {
                    let error = ElGrocerError(forAdyen: response)
                    completion(error, nil)
                    return
                }
                let resultCode = response["resultCode"] as? String ?? ""
                if resultCode.elementsEqual("Authorised") || resultCode.elementsEqual("Received") || resultCode.elementsEqual("Pending") {
                    completion(nil,response)
                }else{
                    let error = ElGrocerError()
                    completion(error,response)
                }
                
                case .failure(let error):
                    debugPrint(error.localizedMessage)
//                    error.showErrorAlert()
                    completion(error, nil)
                    
            }
        }
        
    }
    //delete card
    func deleteCreditCard(recurringDetailReference: String,isNeedToCancelOrder: Bool = false,completion: @escaping adyenApiCompletionHandler) {
        
        guard let user = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext) else {
            return
        }
        
        let params = NSMutableDictionary()
        params["shopperReference"] = user.dbID.stringValue
        params["recurringDetailReference"] = recurringDetailReference
        params["cancel_orders"] = isNeedToCancelOrder

        ElGrocerApi.sharedInstance.deleteAdyenCreditCard(params) { results in
            print(results)
            switch results {
                case .success(let data):
                guard let dataDict = data["data"] as? NSDictionary else {
                    let error = ElGrocerError.parsingError()
                    completion(error, nil)
                    return
                }
                guard let response = dataDict["response"] as? NSDictionary else {
                    let error = ElGrocerError.parsingError()
                    completion(error, nil)
                    return
                }
                if let code = response["errorCode"] as? String {
                    let error = ElGrocerError(forAdyen: response)
                    if error.code == 4070 {
                        let alert = ElGrocerAlertView.createAlert("Error", description: error.localizedMessage, positiveButton: "Yes", negativeButton: "No") { buttonTag in
                            if buttonTag == 0 {
                                //user pressed YES
                                self.deleteCreditCard(recurringDetailReference: recurringDetailReference,isNeedToCancelOrder: true, completion: completion)
                            }else {
                                //user pressed No
                                completion(error, nil)
                            }
                        }
                    }else {
                        completion(error, nil)
                    }
                    
                    return
                }
                
                print(response)
                completion(nil, data)
                case .failure(let error):
                    debugPrint(error.localizedMessage)
                //error code 4070 indicates that there is an active order against this card.
                if error.code == 4070 {
                    let alert = ElGrocerAlertView.createAlert("Error", description: error.localizedMessage, positiveButton: "Yes", negativeButton: "No") { buttonTag in
                        if buttonTag == 0 {
                            //user pressed YES
                            self.deleteCreditCard(recurringDetailReference: recurringDetailReference,isNeedToCancelOrder: true, completion: completion)
                        }else {
                            //user pressed No
                            completion(error, nil)
                        }
                    }
                    alert.show()
                }else {
                    completion(error, nil)
                }
            }
        }
        
    }

}
