//
//  ApplePaymentHandler.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 20/10/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//
/*

Abstract:
A shared class for handling payments across an app and its related extensions.
*/

import UIKit
import PassKit
//// import FlagPhoneNumber

typealias PaymentCompletionHandler = (Bool) -> Void
typealias PaymentDetailsAuthorisation = ([String: Any]) -> Void
let applicationNameForApple = SDKManager.shared.isSmileSDK ? "el grocer DMCC via Smiles" : "el Grocer DMCC"
class ApplePaymentHandler: NSObject {
    
    var paymentController: PKPaymentAuthorizationController?
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    var completionHandler: PaymentCompletionHandler!
    var paymentDetailsHandler : PaymentDetailsAuthorisation?
    var paymentRequestHashValue : Int = 0
    let authorisationSuccessCode: String = "02"
    static let supportedNetworks: [PKPaymentNetwork] = [
        .masterCard,
        .visa
    ]

    class func applePayStatus() -> (canMakePayments: Bool, canSetupCards: Bool) {
        return (PKPaymentAuthorizationController.canMakePayments(),
                PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks))
    }
    
    func startPayment(totalAmount : String,completion: @escaping PaymentCompletionHandler) {

        completionHandler = completion
        
        let total = PKPaymentSummaryItem(label: applicationNameForApple, amount: NSDecimalNumber(string: totalAmount), type: .final)
        paymentSummaryItems = [total]

        // Create a payment request.
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = paymentSummaryItems
        paymentRequest.merchantIdentifier =  (sdkManager.launchOptions?.isSmileSDK ?? false) ? ApplePaymentConfigrations.Merchant.smileProductionIdentifier : ApplePaymentConfigrations.Merchant.identifier
        paymentRequest.merchantCapabilities = .capability3DS
        
//        if let regionCode = Locale.getCurrentLocale().regionCode, let countryCode = FPNCountryCode(rawValue: regionCode) {
//            paymentRequest.countryCode = countryCode.rawValue
//        }else{
//            paymentRequest.countryCode = FPNCountryCode.AE.rawValue
//        }
//        paymentRequest.currencyCode = CurrencyManager.getCurrentCurrency()
        
        //MARK: uncomment above lines and comment bellow two lines to set country code dynamically
        paymentRequest.countryCode = "AE"//FPNCountryCode.AE.rawValue
        paymentRequest.currencyCode = "AED"

        paymentRequest.supportedNetworks = ApplePaymentHandler.supportedNetworks
        self.paymentRequestHashValue = paymentRequest.hashValue
        // Display the payment request.
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        paymentController?.present(completion: { (presented: Bool) in
            if presented {
                elDebugPrint("Presented payment controller")
            } else {
                elDebugPrint("Failed to present payment controller")
                self.completionHandler(false)
            }
        })
    }
    
    func showErrorAlert(message: String) {
        
        ElGrocerAlertView.createAlert(localizedString(message, comment: ""),
            description: nil,
            positiveButton: localizedString("no_internet_connection_alert_button", comment: ""),
            negativeButton: nil, buttonClickCallback: nil).show()
    }
    
    func performServerRequestOnPayFort(appleQueryItem : [String : Any]?, orderId: String, amount: Double, completion: @escaping (Bool)-> Void ) {
        
        if var appleQueryItem = appleQueryItem {
            
            //A=Apple or C=Checkout - 469045777 = ORDER_ID - 31312 = price in cents - timestamp = 343412312 "A-469045777-31312-343412312"
            let merchantRefInitial = "A" + "-"
            let orderID = orderId
            let merchantRefEnd = "-" + PayFortManager.getFinalAmountToHold(ammount: amount) + "-" + String(format: "%.0f", Date.timeIntervalSinceReferenceDate)
            let refFinal = merchantRefInitial + orderID + merchantRefEnd
            
            ElGrocerApi.sharedInstance.placeOrderWithApplePay(merchantRef: refFinal, params: appleQueryItem) { result, responseObject in
                
                switch responseObject {
                    case .success(let data):
                        elDebugPrint(data)
                    if let dataPayFort = data["payfort_response"] as? NSDictionary{
                        if let responseCode = dataPayFort["status"] as? String{
                            if responseCode == self.authorisationSuccessCode{
                               elDebugPrint("order authorised ny apple pay successfully")
                                completion(true)
                            }else{
                                completion(false)
                                let message = data["response_message"] as? String ?? ""
                                self.showErrorAlert(message: message)
                            }
                        }
                    }else{
                        if let errorMessage = data["error_message"] as? String{
                            completion(false)
                            self.showErrorAlert(message: errorMessage)
                        }
                    }
                    case .failure(let error):
                    completion(false)
                    self.showErrorAlert(message: error.message ?? "\(error.code)")
                }
            }
        }
    }
    
    
}

// Set up PKPaymentAuthorizationControllerDelegate conformance.
extension ApplePaymentHandler: PKPaymentAuthorizationControllerDelegate {

    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        // Perform basic validation on the provided contact information.
        var errors = [Error]()
        var status = PKPaymentAuthorizationStatus.success
        
        //MARK: if need to check shipping address in apple pay
//        if payment.shippingContact?.postalAddress?.isoCountryCode != "AE" {
//            let pickupError = PKPaymentRequest.paymentShippingAddressUnserviceableError(withLocalizedDescription: "Apple Pay is only available in the United Arab Emirates")
//            let countryError = PKPaymentRequest.paymentShippingAddressInvalidError(withKey: CNPostalAddressCountryKey, localizedDescription: "Invalid country")
//            errors.append(pickupError)
//            errors.append(countryError)
//            status = .failure
//        } else {
//            // Send the payment token to your server or payment provider to process here.
//            // Once processed, return an appropriate status in the completion handler (success, failure, and so on).
//        }
        
        self.paymentStatus = status
        if status.rawValue == 0{
            // raw value 0 means payment authorizsation is sucessfull
            self.convertToDictionary(paymentDetails: payment)
        }
        completion(PKPaymentAuthorizationResult(status: status, errors: errors))
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        
        DispatchQueue.main.async {
            controller.dismiss {
                // The payment sheet doesn't automatically dismiss once it has finished. Dismiss the payment sheet.
                if self.paymentStatus == .success {
                    self.completionHandler!(true)
                } else {
                    self.completionHandler!(false)
                }
            }
        }
    }
    
    func convertToDictionary(paymentDetails: PKPayment){
        var paymentDataDictionary: [AnyHashable: Any]? = [:]
        do {
            paymentDataDictionary = try JSONSerialization.jsonObject(with: paymentDetails.token.paymentData, options: .mutableContainers) as? [AnyHashable : Any]
        } catch {
            
        }
        let headerDict = paymentDataDictionary?[AnyHashable("header")] as? NSDictionary ?? ["":""]
        let appleApplicationData : String = String(self.paymentRequestHashValue)
        let signature : String = paymentDataDictionary?[AnyHashable("signature")] as? String ?? ""
        let appleData : String = paymentDataDictionary?[AnyHashable("data")] as? String ?? ""
        //headerFields
        let appleTransactionId = headerDict["transactionId"] as? String ?? ""
        let publicKeyHash = headerDict["publicKeyHash"] as? String ?? ""
        let ephemeralPublicKey = headerDict["ephemeralPublicKey"] as? String ?? ""
        let headerToSend = ["apple_transactionId": appleTransactionId, "apple_publicKeyHash": publicKeyHash, "apple_ephemeralPublicKey": ephemeralPublicKey]
        //paymentMethod details fields
        var paymentType: String = "credit"
        var paymentMethodDictionary: [AnyHashable: Any] = ["network": "", "type": paymentType, "displayName": ""]
        if #available(iOS 9.0, *) {
            switch paymentDetails.token.paymentMethod.type {
                case .debit:
                    paymentType = "debit"
                case .credit:
                    paymentType = "credit"
                case .store:
                    paymentType = "store"
                case .prepaid:
                    paymentType = "prepaid"
                default:
                    paymentType = "unknown"
                }
            paymentMethodDictionary = ["network": paymentDetails.token.paymentMethod.network ?? "", "type": paymentType, "displayName": paymentDetails.token.paymentMethod.displayName ?? ""]
        }
        
        let applePaymentMethod = paymentMethodDictionary as? NSDictionary ?? ["":""]
        let appleDisplayName = applePaymentMethod["displayName"] as? String ?? ""
        let network = applePaymentMethod["network"] as? String ?? ""
        let type = applePaymentMethod["type"] as? String ?? ""
        let paymentMethodToSend = ["apple_displayName": appleDisplayName , "apple_network": network ,"apple_type": type]
        let dictToSend: [String: Any] = ["apple_header": headerToSend , "apple_paymentMethod": paymentMethodToSend ,"apple_signature": signature,"apple_applicationData": appleApplicationData , "apple_data": appleData ]
        
        if let closure = self.paymentDetailsHandler{
            closure(dictToSend)
        }
        
    }
}

