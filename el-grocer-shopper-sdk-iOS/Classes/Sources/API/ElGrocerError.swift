//
//  ElGrocerError.swift
//  ElGrocerShopper
//
//  Created by Piotr Gorzelany on 25/02/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import Foundation
import AFNetworking
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


private let genericErrorCode = 10000
private let parsingErrorCode = -1




private let errorCodes: [Int: String] = [
    
    // Internal
    
    parsingErrorCode: NSLocalizedString("error_-1", comment: ""),
    -2: NSLocalizedString("error_-2", comment: ""),
    -3: NSLocalizedString("error_-3", comment: ""),
    -4: NSLocalizedString("error_-4", comment: ""),
    -5: NSLocalizedString("error_-5", comment: ""),
    -6: NSLocalizedString("error_-6", comment: ""),
    
    // Api
    
    genericErrorCode: NSLocalizedString("error_10000", comment: ""),
    10001: NSLocalizedString("error_10001", comment: ""),
    10002: NSLocalizedString("error_10002", comment: ""),
    10003: NSLocalizedString("error_10003", comment: ""),
    10004: NSLocalizedString("error_10004", comment: ""),
    10005: NSLocalizedString("error_10005", comment: ""),
    10006: NSLocalizedString("error_10006", comment: ""),
    10007: NSLocalizedString("error_10007", comment: ""),
    10008: NSLocalizedString("error_10008", comment: ""),
    10009: NSLocalizedString("error_10009", comment: "")
]

struct ElGrocerError {
    
    // Static Methods
    
    static func genericError() -> ElGrocerError {
        return ElGrocerError()
    }
    
    static func parsingError() -> ElGrocerError {
        return ElGrocerError(code: parsingErrorCode)
    }
    
    static func locationServicesDisabledError() -> ElGrocerError {
        return ElGrocerError(code: -4)
    }
    
    static func locationServicesAuthorizationError() -> ElGrocerError {
        return ElGrocerError(code: -5)
    }
    
    static func currentLocationError() -> ElGrocerError {
        return ElGrocerError(code: -2)
    }
    
    static func locationAddressError() -> ElGrocerError {
        return ElGrocerError(code: -3)
    }
    
    static func unableToSetDefaultLocationError() -> ElGrocerError {
        return ElGrocerError(code: -6)
    }
    
    // MARK: Properties
    
    /** Error code returned from the server */
    fileprivate (set) var code: Int = genericErrorCode
    
    /** Error message returned from the server */
    fileprivate (set) var message: String?
    
    fileprivate (set) var jsonValue: [String : Any]? = [:]
    
    var localizedMessage: String {
        
        guard var msg = errorCodes[code] else {
            return message ?? ElGrocerError.genericError().localizedMessage + " - error \(code)"
        }
        
        if self.message != nil {
            msg = self.message!
        }
        
        
        
        return msg
    }
    
    // MARK: Initializers
    
    init(forAdyen data: NSDictionary) {
        if let code = data["errorCode"] as? String, let message = data["message"] as? String {
            
            self.code = Int(code) ?? genericErrorCode
            self.message = message
        }else {
            self.code = genericErrorCode
        }
    }
    
    init(code: Int = genericErrorCode) {
        self.code = code
    }
    
    /** Initialize error from API response */
    init(error: NSError) {
        
        guard let data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? Data, let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [String:Any] else {
            self.code = error.code
            self.message = error.localizedDescription
            return
        }
        self.jsonValue = json
        
        guard let status = json?["status"] as? String , status == "error" else {
            return
        }
    
        
        var errorCode = error.code
        if let httpresponse = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] as? HTTPURLResponse {
            errorCode = httpresponse.statusCode
        }
        
        FireBaseEventsLogger.trackCustomEvent(eventType: "errorToParse", action: "error.localizedDescription : \(error.localizedDescription)"  ,  json! )
        let messages = json?["messages"] as? NSDictionary
        if let dataMessage = messages {
            errorCode = dataMessage["error_code"] as? Int ?? genericErrorCode
        }
        self.code = errorCode
        if let errorMsgDict = messages?["error_message"] as? NSDictionary {
            
            if(errorCode == 10002){
                
                if let errorArray = errorMsgDict["order_value_is_not_enough"] as? NSArray {
                    
                    if errorArray.count > 0 {
                        
                        let serverMsg = errorArray[0] as? String
                        let messageComponents = serverMsg?.components(separatedBy: " ")
                        
                        if messageComponents?.count > 0 {
                            self.message = NSString(format: "%@ %@ %@",NSLocalizedString("promo_code_minimum_value_alert_description", comment: ""),messageComponents![0],NSLocalizedString("promo_code_minimum_value_alert_remianing_description", comment: "")) as String
                        }else{
                            self.message = messages?["error_message"] as? String
                        }
                    }else{
                        
                        self.message = messages?["error_message"] as? String
                    }
                    
                }else{
                    self.message = messages?["error_message"] as? String
                }
                
            }else{
                
                if let errorArray = errorMsgDict["order_not_in_edit"] as? NSArray {
                    if errorArray.count > 0 {
                        self.message = errorArray[0] as? String
                    }else{
                        self.message = ""
                    }
                }else if let errorArray = errorMsgDict["promotion_invalid_brands"] as? NSArray{
                    
                    if errorArray.count > 2 {
                        
                        let brandName = errorArray[1] as? String
                        let brandPrice = errorArray[2] as? Float
                        let description = NSLocalizedString("promo_code_brand_alert_description", comment: "")
                        let minimumOf = NSLocalizedString("promo_code_brand_alert_products", comment: "")
                        let priceStr = NSString(format: "%@ %0.2f",CurrencyManager.getCurrentCurrency(),brandPrice!)
                        let worthOf = NSLocalizedString("promo_code_brand_alert_worth_of", comment: "")
                        let purchased = NSLocalizedString("promo_code_brand_alert_products_purchased", comment: "")
                        
                        self.message = NSString(format: "%@ \"%@\" %@ %@ %@ \"%@\" %@",description,brandName ?? "",minimumOf,priceStr,worthOf,brandName ?? "" ,purchased) as String
                        
                    }else{
                        if errorArray.count == 1 {
                            self.message = errorArray[0] as? String
                        }else{
                            self.message = messages?["error_message"] as? String
                        }
                    }
                    
                }
                
                else{
                    
                    if errorMsgDict.allKeys.count > 0 {
                        print("Error Keys:%@",errorMsgDict.allKeys)
                        var errorKey = errorMsgDict.allKeys[0] as! String
                        
                        for errKey in errorMsgDict.allKeys {
                            let errKey1 = errKey as! String
                            if let errorArray = errorMsgDict[errKey1] as? NSArray{
                                if errorArray.count > 0 {
                                    errorKey = errKey1
                                    break
                                }
                            }
                        }
                        print("Current Error Key:%@",errorKey)
                        var genericError = ""
                        if let errorArray = errorMsgDict[errorKey] as? NSArray{
                            genericError = errorArray.componentsJoined(by: "")
                        }
                        self.message = NSLocalizedString(errorKey, value:genericError,comment: "")
                    }
                }
            }
            
        }else{
            self.message = messages?["error_message"] as? String
            if self.message == nil {
                self.message = json?["error_message"] as? String
            }
            if self.message == nil {
                self.message = json?["messages"] as? String
            }
            if let dataMessage = messages {
                if dataMessage["error_message"] != nil {
                    self.message = String(format: "%@", (dataMessage["error_message"] as? String ?? error.localizedDescription) )
                }
               
            }
            
            
            if self.code == 471 {
                if self.message == "Order Accepted!" || self.message == "Order En route!" || self.message == "Order Completed!" || self.message == "Order Delivered!" || self.message == "Order In substitution!" || self.message == "Order Canceled!" {
                    self.message = NSLocalizedString("error_1112", comment: "You order is already processed to deliver. Please continue to place new order.")
                }
            }
        }
    }

    // MARK: Methods
    
    /** Creates a generic el Grocer alert based on the error code and message */
    func createErrorAlert() -> ElGrocerAlertView {
        
        
        
        let errorTitle = NSLocalizedString("alert_error_title", comment: "")
        let okButtonTitle = NSLocalizedString("ok_button_title", comment: "")
        
        let alert = ElGrocerAlertView.createAlert(errorTitle, description: self.localizedMessage, positiveButton: okButtonTitle, negativeButton: nil, buttonClickCallback: nil)
      //  alert.positiveButton.setBackgroundImage(UIImage(named: "modal_button_red"), for: UIControl.State())
     //   alert.positiveButton.setBackgroundImage(UIImage(named: "modal_button_red"), for: UIControl.State.highlighted)
        return alert
        
    }
    
    /** Shows the generic el Grocer alert based on the error code and message */
    func showErrorAlert() {
        
        let alert = self.createErrorAlert()
        alert.show()
      
        
    }
    
    func getErrorMessageStr() -> String{
        return self.localizedMessage
    }
    
}


extension String {
    
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    
    //AWAIS -- Swift4
   /* subscript (r: Range<Int>) -> String {
        let start = characters.index(startIndex, offsetBy: r.lowerBound)
        let end = String.CharacterView.index(start, offsetBy: r.upperBound - r.lowerBound)
        return self[Range(start ..< end)]
    }*/
}
