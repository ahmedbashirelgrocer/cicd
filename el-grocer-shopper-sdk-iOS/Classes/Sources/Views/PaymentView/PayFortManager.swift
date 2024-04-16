//
//  PayFortManager.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 03/03/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import Foundation
import CommonCrypto
import CCValidator
import Adyen

struct Encryption {
    static func sha256Hex(string: String) -> String? {
        guard let messageData = string.data(using: String.Encoding.utf8) else { return nil }
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_SHA256(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
    
    static func ccSha256(data: Data) -> Data {
        var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = digest.withUnsafeMutableBytes { (digestBytes) in
            data.withUnsafeBytes { (stringBytes) in
                CC_SHA256(stringBytes, CC_LONG(data.count), digestBytes)
            }
        }
        return digest
    }
}

struct DynamicOrderStatus {
    
    var nameAr : String = ""
    var nameEn : String = ""
    var key : String = ""
    var stepNumber : NSNumber = -1
    var imageName : String = "orderStatus0"
    var color : UIColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
}

extension DynamicOrderStatus {
    
    init( dict : NSDictionary){
        nameAr = dict["ar"] as? String ?? ""
        nameEn = dict["en"]  as? String ?? ""
        key = dict["key"]  as? String ?? ""
        stepNumber = dict["step_number"]  as? NSNumber ?? -1
        let imageNameAndColor = self.getImageName()
        imageName = imageNameAndColor.0
        color = imageNameAndColor.1
    }
    
    
    //Error:- Please update this code. 
    func getImageName () -> (String , UIColor) {
        
        let data = self.getStatusKeyLogic()
        let status = data.status_id
        let deliveryType = data.delivery_type //MARK: 0 for instant , 1 for scheduled
        let OrderType = data.service_id //MARK: 1 for delivery , 2 for C&C
        
        var returnedName : String = ""
        var returnedColour : UIColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
        
        
        if OrderType == 1{
            //MARK: Delivery
            if status == -1{
                //Pending Payment Approval
                returnedName = "orderStatus0"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 0{
                //pending & scheduled
                returnedName = "orderStatus0"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 1{
                // shopping items
                returnedName = "OrderStatusShopping"
                //returnedName = "orderStatus1"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 2{
                // On the way
                returnedName = "orderStatus2"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 3{
                //delivery
                returnedName = "orderStatus3"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 4{
                //canceled
                returnedName = "orderStatus4"
                returnedColour = ApplicationTheme.currentTheme.labelHighlightedOOSColor
            }else if status == 5{
                //delivery -> ambigous status code already handled on status code 3
                returnedName = "orderStatus3"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 6{
                returnedName = "orderStatus6"
                returnedColour = ApplicationTheme.currentTheme.labelPromotionalTextColor
            }else if status == 7{
                //card payment failed
                returnedName = "orderStatus0"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 8{
                // in edit
                returnedName = "orderStatus0"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 9{
                //Packing
                returnedName = "orderStatus9"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 11{
                // Ready to deliver
                returnedName = "orderStatus11"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 12{
                //Packing -> ambigous status code already handled on status code 9
                returnedName = "orderStatus9"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else{
                returnedName = "orderStatus0"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }
            
        }else if OrderType == 2{
            //MARK: C&C
            if status == -1{
                //Pending Payment Approval
                returnedName = "orderStatus0"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 0{
                //pending & scheduled
                returnedName = "orderStatus0"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 1{
                // shopping items
                returnedName = "OrderStatusShopping"
                //returnedName = "orderStatus1"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 2{
                // On the way
                returnedName = "orderStatus2"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 3{
                //delivery
                returnedName = "orderStatus3"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 4{
                //canceled
                returnedName = "orderStatus4"
                returnedColour = ApplicationTheme.currentTheme.labelHighlightedOOSColor
            }else if status == 5{
                //delivery -> ambigous status code already handled on status code 3
                returnedName = "orderStatus3"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 6{
                //in substitution
                returnedName = "orderStatus6"
                returnedColour = ApplicationTheme.currentTheme.labelPromotionalTextColor
            }else if status == 7{
                //card payment failed
                returnedName = "orderStatus0"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 8{
                // in edit
                returnedName = "orderStatus0"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 9{
                //Packing
                returnedName = "orderStatus9"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 11{
                // Ready to deliver
                returnedName = "orderStatus11"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else if status == 12{
                //Packing -> ambigous status code already handled on status code 9
                returnedName = "orderStatus9"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }else{
                returnedName = "orderStatus0"
                returnedColour = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
            }
        }
        
        
        return (returnedName , returnedColour)
    }
    
    
    // ssd - > status_id, service_id, delivery_type
    func getStatusKeyLogic() -> (status_id : NSNumber , service_id : NSNumber , delivery_type : NSNumber ) {
        
        let keyA = self.key.components(separatedBy: ".")
        if keyA.count == 3 {
            let formatter = NumberFormatter()
            formatter.numberStyle = NumberFormatter.Style.decimal
            if let status_id = formatter.number(from: keyA[0]) , let service_id = formatter.number(from: keyA[1]) , let delivery_type = formatter.number(from: keyA[2]) {
                return (status_id , service_id , delivery_type)
            }
        }
        return (-10 , -10 , -10)
    }
    
    func getMappingTypeWithOrderStatus() -> OrderStatus {
        
        let status_Id = self.getStatusKeyLogic()
        
        if status_Id.status_id.intValue == OrderStatus.pending.rawValue {
            return .pending
        }else if status_Id.status_id.intValue == OrderStatus.payment_pending.rawValue {
            return .payment_pending
        }else if status_Id.status_id.intValue == OrderStatus.accepted.rawValue {
            return .accepted
        }else if status_Id.status_id.intValue == OrderStatus.enRoute.rawValue {
            return .enRoute
        }else if status_Id.status_id.intValue == OrderStatus.completed.rawValue {
            return .completed
        }else if status_Id.status_id.intValue == OrderStatus.canceled.rawValue {
            return .canceled
        }else if status_Id.status_id.intValue == OrderStatus.delivered.rawValue {
            return .delivered
        }else if status_Id.status_id.intValue == OrderStatus.nonHandle.rawValue {
            return .nonHandle
        }else if status_Id.status_id.intValue == OrderStatus.inEdit.rawValue {
            return .inEdit
        }else if status_Id.status_id.intValue == OrderStatus.STATUS_READY_CHECKOUT.rawValue {
            return .STATUS_READY_CHECKOUT
        }else if status_Id.status_id.intValue == OrderStatus.STATUS_WAITING_APPROVAL.rawValue {
            return .STATUS_WAITING_APPROVAL
        }else if status_Id.status_id.intValue == OrderStatus.STATUS_READY_TO_DELIVER.rawValue {
            return .STATUS_READY_TO_DELIVER
        }else if status_Id.status_id.intValue == OrderStatus.STATUS_CHECKING_OUT.rawValue {
            return .STATUS_CHECKING_OUT
        }else if status_Id.status_id.intValue == OrderStatus.STATUS_PAYMENT_APPROVED.rawValue {
            return .STATUS_PAYMENT_APPROVED
        }else if status_Id.status_id.intValue == OrderStatus.STATUS_PAYMENT_REJECTED.rawValue {
            return .STATUS_PAYMENT_REJECTED
        }else if status_Id.status_id.intValue == OrderStatus.inSubtitution.rawValue {
            return .inSubtitution
        }
        
        
        return .pending
        
    }
    
    static func getDataA (_ dataA : [NSDictionary]) -> [String:DynamicOrderStatus] {
        var objA : [String : DynamicOrderStatus] = [:]
        for dict in dataA {
            let obj = DynamicOrderStatus.init(dict: dict)
            objA[obj.key] = obj
        }
        return objA
    }
    
    // ssd - > status_id, service_id, delivery_type
    static func getKeyFrom (status_id : NSNumber , service_id : NSNumber , delivery_type : NSNumber ) -> String {
        return status_id.stringValue + "." + service_id.stringValue + "." + delivery_type.stringValue
    }
    
    
    
    
    
}

struct AppConfiguration {
    
    
    var payFortMerchantIdentifier : String = ""
    var payFortAccessCode : String = ""
    var payFortSHARequestPhrase : String = ""
    var payFortPaymentServicesUrl : String = ""
    var payFortCheckoutUrl  : String = ""
    var PublicIp  : String = ""
    var payFortExtraAmount : String = ""
    var pg_18_msg = localizedString("pg_18_msg", comment: "")
    var storlyInstanceId = ""
    //var orderStatus : [DynamicOrderStatus] = []
    var orderStatus :  [String:DynamicOrderStatus] = [:]
    var orderTotalSteps : NSNumber = 0
    var promoImage : String = ""
    var isApplePayEnable : Bool = false
    var fetchCatalogFromAlgolia : Bool = true
    var smilesData: SmilesData = SmilesData()
    var initialAuthAmount: Double = 0.00
    var sdkMaxAddressLimit: Int = 5
}
extension AppConfiguration {
    
    init( dict : Dictionary<String,Any>) {
        
        payFortMerchantIdentifier = dict["payfort_merchant_identifier"] as? String ?? ""
        payFortAccessCode  = dict["payfort_access_code"] as? String ?? ""
        payFortSHARequestPhrase  = dict["payfort_sha_request_phrase"] as? String ?? ""
        payFortPaymentServicesUrl  = dict["payfort_paymentservices_url"] as? String ?? ""
        payFortCheckoutUrl  = dict["payfort_checkout_url"] as? String ?? ""
        PublicIp  = dict["client_ip"] as? String ?? ""
        payFortExtraAmount  = dict["extra_amount"] as? String ?? ""
        pg_18_msg = dict["pg_18"] as? String ?? localizedString("pg_18_msg", comment: "")
        storlyInstanceId = dict["storyly_instance"] as? String ?? ""
        orderTotalSteps = dict["order_total_steps"] as? NSNumber ?? 0
        promoImage = dict["sale_tag"] as? String ?? ""
        orderStatus = DynamicOrderStatus.getDataA(dict["order_statuses"] as? [NSDictionary] ?? [])
        isApplePayEnable  = dict["applepay_switch"] as? Bool ?? false
        fetchCatalogFromAlgolia = dict["fetch_catalog_from_algolia"] as? Bool ?? true
        initialAuthAmount = dict["initial_auth_amount"] as? Double ?? 0.00
        if let smilesDictionary = dict["smile_data"] as? Dictionary<String, Any> {
            smilesData = SmilesData.init(smilesDict: smilesDictionary)
        }
        sdkMaxAddressLimit = dict["sdk_max_address_limit"] as? Int ?? 5
    }
    
}

struct SmilesData {
    
    var earning : Double = 0.0
    var burning : Double = 1.0
    var allowRetry : Int = 1
    var retryInterval : String = ""
    var retryIntervalDelayMultiplier : Int = 1
}

extension SmilesData {
    
    init( smilesDict : Dictionary<String, Any>) {
        earning = smilesDict["earning"] as? Double ?? 0.0
        burning = smilesDict["burning"] as? Double ?? 1.0
        allowRetry = smilesDict["allow_retry"] as? Int ?? 1
        retryInterval = smilesDict["retry_interval"] as? String ?? ""
        retryIntervalDelayMultiplier = smilesDict["retry_interval_delay_multiplier"] as? Int ?? 1
        /*
         allowRetry = smilesDict["allowRetry"] as? Int ?? 1
         retryInterval = smilesDict["retryInterval"] as? String ?? ""
         retryIntervalDelayMultiplier = smilesDict["retryIntervalDelayMultiplier"] as? Int ?? 1
         */
    }
}





struct CreditCard  {
    
    var cardType : CreditCardType = .unKnown
    var country : String = ""
    var expiry_month : String = ""
    var expiry_year : String = ""
    var cardID : String = ""
    var first6  : String = ""
    var last4  : String = ""
    var transRef : String = ""
    var cardHolderName : String = ""
    var cardNumber: String = ""
    var securityCode: String = ""
    var marchentRef : String = ""
    var adyenPaymentMethod: StoredCardPaymentMethod?
    
}
extension CreditCard {
    
    init( cardDict : Dictionary<String,Any>){
        
        cardType = cardType.getCardTypeFromType(cardDict["card_type"] as? String ?? "")
        country = cardDict["country"] as? String ?? ""
        expiry_month = cardDict["expiry_month"] as? String ?? ""
        expiry_year = cardDict["expiry_year"] as? String ?? ""
        cardID = cardDict["id"] as? String ?? ""
        last4 =  (cardDict["last4"] as? String ?? "") 
        transRef = cardDict["trans_ref"] as? String ?? ""
        first6 = cardDict["first6"] as? String ?? ""
        
    }
    
    func getCardExpaireDate() -> String {
        return expiry_year + expiry_month
    }
    
    func getDefaultDevCard () -> CreditCard {
        
        var card = CreditCard()
        card.cardType = .VISA
        card.country = "ua"
        card.expiry_month = "05"
        card.expiry_year = "21"
        card.cardID = ""
        card.last4 =  ""
        card.transRef = ""
        card.cardHolderName  = "ABM"
        card.cardNumber  = "4005550000000001";
        card.securityCode  = "123"
        
        return card
        
    }
}

extension CreditCardType {
    
    func getCardTypeFromCardNumber(cardNumber : String) ->  CreditCardType {
        
        let recognizedType = CCValidator.typeCheckingPrefixOnly(creditCardNumber: cardNumber)
        if recognizedType == .Visa {
            return .VISA
        }
        if recognizedType == .MasterCard {
            return .MASTER_CARD
        }
        if recognizedType == .AmericanExpress {
            return .AMERICAN_EXPRESS
        }
        if recognizedType == .DinersClub {
            return .DINE_CLUB
        }
        if recognizedType == .Discover {
            return .DISCOVER
        }
        if recognizedType == .JCB {
            return .JCB
        }
        return .unKnown
        
        
        
        
        //        var cardString = cardNumber
        //        cardString =  cardString.replacingOccurrences(of: " ", with: "")
        //        let range = NSRange(location: 0, length: cardString.utf16.count)
        //        let regexVisa = try! NSRegularExpression(pattern: "4[0-9]{6,}$")
        //        let regexMaster = try! NSRegularExpression(pattern: "^5[1-5][0-9]{5,}$")
        //        let regexAmerican = try! NSRegularExpression(pattern: "^3[47][0-9]{5,}$")
        //        let regexDine = try! NSRegularExpression(pattern: "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$")
        //        let regexDiscover = try! NSRegularExpression(pattern: "^6(?:011|5[0-9]{2})[0-9]{3,}$")
        //        let regexJCB = try! NSRegularExpression(pattern: "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$")
        //
        //        if regexVisa.firstMatch(in: cardString, options: [], range: range) != nil {
        //            return .VISA
        //        }
        //        if regexMaster.firstMatch(in: cardString, options: [], range: range) != nil {
        //            return .MASTER_CARD
        //        }
        //        if regexAmerican.firstMatch(in: cardString, options: [], range: range) != nil {
        //            return .AMERICAN_EXPRESS
        //        }
        //        if regexDine.firstMatch(in: cardString, options: [], range: range) != nil {
        //            return .DINE_CLUB
        //        }
        //        if regexDiscover.firstMatch(in: cardString, options: [], range: range) != nil {
        //            return .DISCOVER
        //        }
        //        if regexJCB.firstMatch(in: cardString, options: [], range: range) != nil {
        //            return .JCB
        //        }
        //        return .unKnown
        
    }
    
    
    
}

enum CreditCardType : String {
    
    
    
    case VISA
    case MASTER_CARD
    case AMERICAN_EXPRESS
    case DINE_CLUB
    case DISCOVER
    case JCB
    case unKnown
    
    
    func getCardTypeString() ->  String {
        switch self {
            case .VISA:
                return "VISA"
            case .MASTER_CARD:
                return "MASTER_CARD"
            case .AMERICAN_EXPRESS:
                return "AMERICAN_EXPRESS"
            case .DINE_CLUB:
                return "DINE_CLUB"
            case .DISCOVER:
                return "DISCOVER"
            case .JCB:
                return "JCB"
            case .unKnown:
                return "unKnown"
        }
    }
    
    
    
    
    func getCardTypeFromType(_ cardType : String) ->  CreditCardType {
        
        switch cardType {
            case "1":
                return .VISA
            case "2":
                return .MASTER_CARD
            case "3":
                return .AMERICAN_EXPRESS
            case "4":
                return .DINE_CLUB
            case "5":
                return .DISCOVER
            case "6":
                return .JCB
            default:
                return .unKnown
        }
        
    }
    
    func getCardTypeIDString() ->  String {
        switch self {
            case .VISA:
                return "1"
            case .MASTER_CARD:
                return "2"
            case .AMERICAN_EXPRESS:
                return "3"
            case .DINE_CLUB:
                return "4"
            case .DISCOVER:
                return "5"
            case .JCB:
                return "6"
            case .unKnown:
                return "-1"
        }
    }
    
    func getCardColorImageFromType() ->  UIImage {
        
        
        switch self {
            case .VISA:
                return UIImage(name: "ic_visa")!
            case .MASTER_CARD :
                return UIImage(name: "ic_mastercard")!
            default:
                return UIImage(name: "category_placeholder")!
        }
    }
    
    
    func getCardColorImageFromTypeOnAddCardScreen() ->  UIImage {
        
        
        switch self {
            case .VISA:
                return UIImage(name: "ic_visa")!
            case .MASTER_CARD :
                return UIImage(name: "ic_mastercard")!
            default:
                return UIImage(name: "ic_visa")!
        }
    }
    
    func getCardColorImageFromTypeForWallet() ->  UIImage {
        
        
        switch self {
            case .VISA:
                return UIImage(name: "ic_visaColored")!
            case .MASTER_CARD :
                return UIImage(name: "ic_mastercardColored")!
            default:
                return UIImage(name: "category_placeholder")!
        }
    }
    
    
}


enum PathAPI {
    case paymentAPI
    case pageAPI
    func getAPIString() -> String{
        switch self {
            case  .paymentAPI:
                return ElGrocerUtility.sharedInstance.appConfigData.payFortPaymentServicesUrl
            case  .pageAPI:
                return ElGrocerUtility.sharedInstance.appConfigData.payFortCheckoutUrl
        }
    }
}

private let KEY_ACCESS_CODE = "access_code";
private let KEY_MERCHANT_IDENTIFIER = "merchant_identifier";
private let KEY_SERVICE_COMMAND = "service_command";
private let KEY_COMMAND = "command";
private let KEY_MERCHANT_REFERENCE = "merchant_reference";
public let KEY_FORT_ID = "fort_id";
private let KEY_LANGUAGE = "language";
private let KEY_SIGNATURE = "signature";
public let KEY_TOKEN_NAME = "token_name";
public let KEY_RESPONSE_CODE = "response_code";
private let KEY_AMOUNT = "amount";
private let KEY_CURRENCY = "currency";
private let KEY_CUSTOMER_EMAIL = "customer_email";
private let KEY_CUSTOMER_IP = "customer_ip";


enum PayFortParmsKey {
    
    case KEY_ACCESS_CODE
    case KEY_MERCHANT_IDENTIFIER
    case KEY_SERVICE_COMMAND
    case KEY_COMMAND
    case KEY_MERCHANT_REFERENCE
    case KEY_FORT_ID
    case KEY_LANGUAGE
    case KEY_SIGNATURE
    case KEY_TOKEN_NAME
    case KEY_RESPONSE_CODE
    case KEY_AMOUNT
    case KEY_Check_3ds
    case KEY_CURRENCY
    case KEY_CUSTOMER_EMAIL
    case KEY_CUSTOMER_IP
    // creditCard
    case KEY_CARD_HOLDER_NAME
    case KEY_CARD_NUMBER
    case KEY_CARD_SECURITY_CODE
    case KEY_CARD_EXPIRY_DATE
    
    func getAPIString() -> String{
        
        switch self {
            
            case .KEY_ACCESS_CODE: return "access_code"
            case .KEY_MERCHANT_IDENTIFIER: return "merchant_identifier"
            case .KEY_COMMAND: return "command";
            case .KEY_MERCHANT_REFERENCE: return "merchant_reference";
            case .KEY_FORT_ID: return "fort_id";
            case .KEY_LANGUAGE: return "language";
            case .KEY_SIGNATURE: return "signature";
            case .KEY_TOKEN_NAME: return "token_name";
            case .KEY_RESPONSE_CODE: return "response_code";
            case .KEY_AMOUNT: return "amount";
            case .KEY_CURRENCY: return "currency";
            case .KEY_CUSTOMER_EMAIL: return "customer_email";
            case .KEY_CUSTOMER_IP: return "customer_ip";
            case .KEY_SERVICE_COMMAND: return "service_command"
            case .KEY_CARD_HOLDER_NAME: return "card_holder_name";
            case .KEY_CARD_NUMBER: return "card_number";
            case .KEY_CARD_SECURITY_CODE: return "card_security_code";
            case .KEY_CARD_EXPIRY_DATE: return "expiry_date";
            case .KEY_Check_3ds : return "check_3ds"
        }
    }
}


enum PayFortCredintials {
    
    
    //    case development(udid: String)
    //    case production(udid: String)
    
    case development
    case production
    
    var merchantId: String {
        
        switch self {
            case .development:
                return ElGrocerUtility.sharedInstance.appConfigData.payFortMerchantIdentifier
            default:
                return ElGrocerUtility.sharedInstance.appConfigData.payFortMerchantIdentifier
        }
        
    }
    
    // let SERVICE_COMMAND_TOKENIZATION = "TOKENIZATION";
    
    // private let COMMAND_VOID_AUTHORIZATION = "";
    
    
    var serviceCommandVoidAUTHORIZATION: String {
        switch self {
            case .development:
                return "VOID_AUTHORIZATION"
            default:
                return "VOID_AUTHORIZATION"
        }
    }
    
    var ThreeDCheckAllow: String {
        switch self {
            case .development:
                return "YES"
            default:
                return "YES"
        }
    }
    
    
    
    var serviceCommandAUTHORIZATION: String {
        switch self {
            case .development:
                return "AUTHORIZATION"
            default:
                return "AUTHORIZATION"
        }
    }
    
    
    
    var serviceCommandTokenization: String {
        switch self {
            case .development:
                return "TOKENIZATION"
            default:
                return "TOKENIZATION"
        }
    }
    
    
    var mainURLCheckOut: String {
        switch self {
            case .development:
                return  ""
            default:
                return  ""
        }
    }
    
    
    var mainURLPayment: String {
        switch self {
            case .development:
                return  ""
            default:
                return  ""
        }
    }
    
    var accessCode: String {
        switch self {
            case .development:
                return ElGrocerUtility.sharedInstance.appConfigData.payFortAccessCode
            default:
                return ElGrocerUtility.sharedInstance.appConfigData.payFortAccessCode
        }
    }
    
    
    var shaRequest: String {
        switch self {
            case .development:
                return ElGrocerUtility.sharedInstance.appConfigData.payFortSHARequestPhrase
            default:
                return ElGrocerUtility.sharedInstance.appConfigData.payFortSHARequestPhrase
        }
    }
    
    var currency: String { return "AED" }
    
    var language: String {
        switch self {
            //   let phoneLanguage = UserDefaults.getCurrentLanguage()
            case .development:
                return "en"
            default:
                return "en"
        }
    }
    
    
    
    func signature(uid: String) -> String {
        return Encryption.sha256Hex(string: self.preSignature(uid)) ?? "Can't happen."
    }
    
    private func preSignature(_ uid: String) -> String {
        
        //        let concatenatedString = self.shaRequest + "access_code=\(self.accessCode)" + "card_holder_name" + "=" + "Zeeshan Khalid" + "card_number" + "=" + "4005550000000001" + "card_security_code" + "=" + "123" + "currency" + "=" + "AED" + "expiry_date" + "=" + "2105" + "language" + "=" + "en" + "\(self.merchantId)" + "=" + "\(self.merchantId)" + "merchant_reference" + "=" + "123458" +  "return_url" + "=" + "https://www.google.com/" + "CREATE_TOKEN" + "=" + "CREATE_TOKEN" + "token_name" + "=" + "53606D58379111EAACB00E2BD5E42CD6" + self.shaRequest;
        //
        //        return concatenatedString
        return self.shaRequest + "access_code=\(self.accessCode)" + "device_id=\(uid)" + "language=enmerchant_identifier=\(self.merchantId)" + "service_command=SDK_TOKEN\(self.shaRequest)"
    }
    
}


class PayFortManager {
    
    
    
    //payfort response codes
    private let KRESPONSE_CODE_CARD_NUMBER_INVALID = "016";
    private let KRESPONSE_CODE_CARD_EXPIRY_INVALID = "100";
    private let KRESPONSE_CODE_CARD_EXPIRED = "012";
    private let KRESPONSE_CODE_CARD_NOT_SUPPORTED = "003";
    private let KRESPONSE_CODE_TECHNICAL_ISSUE = "006";
    public  let KRESPONSE_CODE_SUCCESS = "18";
    
    
    
    class func  getFinalAmountToHold (ammount : Double , _  isNeedToAdd : Bool = true ) -> String {
        
        if isNeedToAdd && ElGrocerUtility.sharedInstance.appConfigData != nil {
            let extraAmmount =  ElGrocerUtility.sharedInstance.appConfigData.payFortExtraAmount
            if extraAmmount.contains("%") {
                let finalAmount = extraAmmount.replacingOccurrences(of: "%", with: "")
                let percentagePriceAmount = ammount * ((Double(finalAmount) ?? 0)/100.0)
                let actualPrice = percentagePriceAmount + ammount
                let priceToHold = actualPrice * PriceHoldMulitplierForPayfort
                return String(format: "%.0f", priceToHold)
            }else{
                let actualPrice = ammount + (Double(extraAmmount) ?? 0)
                let priceToHold = actualPrice * PriceHoldMulitplierForPayfort
                return String(format: "%.0f", priceToHold)
            }
        }else{
            let actualPrice = ammount
            let priceToHold = actualPrice * PriceHoldMulitplierForPayfort
            return String(format: "%.0f", priceToHold)
        }
        
    }
    
    
    class func  getMapsForCreditCardToken(creditCard : CreditCard ) -> [String : Any] {
        
        
        let reference = String(format: "%.0f", Date.timeIntervalSinceReferenceDate) 
        let shaRequest = PayFortCredintials.development.shaRequest
        let accesscode = PayFortParmsKey.KEY_ACCESS_CODE.getAPIString() + "=" +  PayFortCredintials.development.accessCode
        let langaugeParms = PayFortParmsKey.KEY_LANGUAGE.getAPIString() + "=" +  PayFortCredintials.development.language
        let marchentIDParm = PayFortParmsKey.KEY_MERCHANT_IDENTIFIER.getAPIString() + "=" + PayFortCredintials.development.merchantId
        let refernceParms = PayFortParmsKey.KEY_MERCHANT_REFERENCE.getAPIString() + "=" +  reference
        let serviceCommandParms = PayFortParmsKey.KEY_SERVICE_COMMAND.getAPIString() + "=" +  PayFortCredintials.development.serviceCommandTokenization
        
        let finalSignature = shaRequest + "ab=ab" + accesscode + langaugeParms + marchentIDParm + refernceParms + serviceCommandParms + shaRequest
        let encryptedStringHash = Encryption.sha256Hex(string: finalSignature)
        
        var data : [String : Any] = [:]
        data[PayFortParmsKey.KEY_ACCESS_CODE.getAPIString()] = PayFortCredintials.development.accessCode
        
        data[PayFortParmsKey.KEY_CARD_HOLDER_NAME.getAPIString()] = creditCard.cardHolderName
        
        data[PayFortParmsKey.KEY_CARD_NUMBER.getAPIString()] = ElGrocerUtility.sharedInstance.convertToEnglish(creditCard.cardNumber)
        
        data[PayFortParmsKey.KEY_CARD_SECURITY_CODE.getAPIString()] =  ElGrocerUtility.sharedInstance.convertToEnglish(creditCard.securityCode)
        
        data[PayFortParmsKey.KEY_CARD_EXPIRY_DATE.getAPIString()] =   ElGrocerUtility.sharedInstance.convertToEnglish(creditCard.getCardExpaireDate())
        
        data[PayFortParmsKey.KEY_LANGUAGE.getAPIString()] = PayFortCredintials.development.language
        
        data[PayFortParmsKey.KEY_MERCHANT_IDENTIFIER.getAPIString()] = PayFortCredintials.development.merchantId
        
        data[PayFortParmsKey.KEY_MERCHANT_REFERENCE.getAPIString()] = reference
        
        data[PayFortParmsKey.KEY_SERVICE_COMMAND.getAPIString()] = PayFortCredintials.development.serviceCommandTokenization
        
        data["ab"] = "ab"
        
        data[PayFortParmsKey.KEY_SIGNATURE.getAPIString()] = encryptedStringHash
        
        return data
        
    }
    
    class func  getAuthorizationMap(cvv : String , token : String , email : String , amountToHold : Double , ip : String , _ isNeedToExtraFromServer: Bool = true  ) -> [String : Any] {
        
        let finalAmmount =  isNeedToExtraFromServer ?  PayFortManager.getFinalAmountToHold(ammount: amountToHold) : PayFortManager.getFinalAmountToHold(ammount: amountToHold , isNeedToExtraFromServer )
        let engCvv = ElGrocerUtility.sharedInstance.convertToEnglish(cvv)
        let reference = String(format: "%.0f", Date.timeIntervalSinceReferenceDate)
        let shaRequest = PayFortCredintials.development.shaRequest
        let accesscode = PayFortParmsKey.KEY_ACCESS_CODE.getAPIString() + "=" +  PayFortCredintials.development.accessCode
        let ammount = PayFortParmsKey.KEY_AMOUNT.getAPIString() + "=" +  finalAmmount
        // let check3ds = PayFortParmsKey.KEY_Check_3ds.getAPIString() + "=" +  PayFortCredintials.development.ThreeDCheckAllow
        let command = PayFortParmsKey.KEY_COMMAND.getAPIString() + "=" +  PayFortCredintials.development.serviceCommandAUTHORIZATION
        let currency = PayFortParmsKey.KEY_CURRENCY.getAPIString() + "=" +  PayFortCredintials.development.currency
        let emailCustomer = PayFortParmsKey.KEY_CUSTOMER_EMAIL.getAPIString() + "=" +  email
        let customerIp = PayFortParmsKey.KEY_CUSTOMER_IP.getAPIString() + "=" +  ip
        let customerCvv = engCvv.count > 0 ? (PayFortParmsKey.KEY_CARD_SECURITY_CODE.getAPIString() + "=" + engCvv) : ""
        let langaugeParms = PayFortParmsKey.KEY_LANGUAGE.getAPIString() + "=" +  PayFortCredintials.development.language
        let marchentIDParm = PayFortParmsKey.KEY_MERCHANT_IDENTIFIER.getAPIString() + "=" + PayFortCredintials.development.merchantId
        let refernceParms = PayFortParmsKey.KEY_MERCHANT_REFERENCE.getAPIString() + "=" +  reference
        let keyToken = PayFortParmsKey.KEY_TOKEN_NAME.getAPIString() + "=" +  token
        
        //        let finalSignature = shaRequest + accesscode + ammount + check3ds + command + currency + emailCustomer + customerIp + langaugeParms + marchentIDParm + refernceParms + keyToken + shaRequest
        let finalSignature = shaRequest + accesscode + ammount + customerCvv + command + currency + emailCustomer + customerIp  + langaugeParms + marchentIDParm + refernceParms + keyToken + shaRequest
        let encryptedStringHash = Encryption.sha256Hex(string: finalSignature)
        elDebugPrint(finalSignature)
        
        var data : [String : Any] = [:]
        
        data[PayFortParmsKey.KEY_ACCESS_CODE.getAPIString()] = PayFortCredintials.development.accessCode
        data[PayFortParmsKey.KEY_AMOUNT.getAPIString()] = finalAmmount
        data[PayFortParmsKey.KEY_CURRENCY.getAPIString()] = PayFortCredintials.development.currency
        data[PayFortParmsKey.KEY_CUSTOMER_EMAIL.getAPIString()] = email
        data[PayFortParmsKey.KEY_CUSTOMER_IP.getAPIString()] = ip
        data[PayFortParmsKey.KEY_LANGUAGE.getAPIString()] = PayFortCredintials.development.language
        data[PayFortParmsKey.KEY_MERCHANT_IDENTIFIER.getAPIString()] = PayFortCredintials.development.merchantId
        data[PayFortParmsKey.KEY_MERCHANT_REFERENCE.getAPIString()] = reference
        data[PayFortParmsKey.KEY_TOKEN_NAME.getAPIString()] = token
        data[PayFortParmsKey.KEY_COMMAND.getAPIString()] = PayFortCredintials.development.serviceCommandAUTHORIZATION
        if engCvv.count > 0 {
            data[PayFortParmsKey.KEY_CARD_SECURITY_CODE.getAPIString()] = engCvv
        }
        //data[PayFortParmsKey.KEY_Check_3ds.getAPIString()]  =  PayFortCredintials.development.ThreeDCheckAllow
        data[PayFortParmsKey.KEY_SIGNATURE.getAPIString()] = encryptedStringHash
        
        return data
        
    }
    
    class func  getVoidAuthorizationMap(fortId : String) -> [String : Any] {
        
        let shaRequest = PayFortCredintials.development.shaRequest
        let accesscode = PayFortParmsKey.KEY_ACCESS_CODE.getAPIString() + "=" +  PayFortCredintials.development.accessCode
        let command = PayFortParmsKey.KEY_COMMAND.getAPIString() + "=" +  PayFortCredintials.development.serviceCommandVoidAUTHORIZATION
        let fortParm = PayFortParmsKey.KEY_MERCHANT_REFERENCE.getAPIString() + "=" +  fortId
        let langaugeParms = PayFortParmsKey.KEY_LANGUAGE.getAPIString() + "=" +  PayFortCredintials.development.language
        let marchentIDParm = PayFortParmsKey.KEY_MERCHANT_IDENTIFIER.getAPIString() + "=" + PayFortCredintials.development.merchantId
        
        let finalSignature = shaRequest + accesscode + command +   langaugeParms + marchentIDParm +  fortParm   + shaRequest
        let encryptedStringHash = Encryption.sha256Hex(string: finalSignature)
        
        var data : [String : Any] = [:]
        data[PayFortParmsKey.KEY_ACCESS_CODE.getAPIString()] = PayFortCredintials.development.accessCode
        data[PayFortParmsKey.KEY_LANGUAGE.getAPIString()] = PayFortCredintials.development.language
        data[PayFortParmsKey.KEY_MERCHANT_IDENTIFIER.getAPIString()] = PayFortCredintials.development.merchantId
        data[PayFortParmsKey.KEY_MERCHANT_REFERENCE.getAPIString()] = fortId
        data[PayFortParmsKey.KEY_COMMAND.getAPIString()] = PayFortCredintials.development.serviceCommandVoidAUTHORIZATION
        data[PayFortParmsKey.KEY_SIGNATURE.getAPIString()] = encryptedStringHash
        return data
        
    }
    
    class func  getErrorMessage(responseCode : String) -> String {
        
        return ""
        
        //                int errorMessage = R.string.message_something_went_wrong;
        //                if (responseCode.endsWith(RESPONSE_CODE_CARD_NUMBER_INVALID)) {
        //                    errorMessage = R.string.msg_card_number_invalid;
        //                } else if (responseCode.endsWith(RESPONSE_CODE_CARD_EXPIRY_INVALID)) {
        //                    errorMessage = R.string.msg_card_expiry_invalid;
        //                } else if (responseCode.endsWith(PayFortManager.RESPONSE_CODE_CARD_EXPIRED)) {
        //                    errorMessage = R.string.msg_card_expired;
        //                } else if (responseCode.endsWith(PayFortManager.RESPONSE_CODE_CARD_NOT_SUPPORTED)) {
        //                    errorMessage = R.string.msg_card_not_supported;
        //                } else if (responseCode.endsWith(PayFortManager.RESPONSE_CODE_TECHNICAL_ISSUE)) {
        //                    errorMessage = R.string.msg_technical_issue;
        //                }
        //                return errorMessage;
        
    }
    
}



class DeviceIp {
    
    
    class func getWiFiAddress() -> String? {
        return UIDevice.current.ipAddress()
    }
    class func getPublicAddress() -> String? {
        if  ElGrocerUtility.sharedInstance.appConfigData.PublicIp.count > 0 {
            return ElGrocerUtility.sharedInstance.appConfigData.PublicIp
        }else{
            let url = URL(string: "https://api.ipify.org/")
            let ipAddress =  try? String.init(contentsOf: url!)
            return ipAddress
        }
    }
    
}

extension UIDevice {
    
    private struct InterfaceNames {
        static let wifi = ["en0"]
        static let wired = ["en2", "en3", "en4"]
        static let cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
        static let supported = wifi + wired + cellular
    }
    
    func ipAddress() -> String? {
        var ipAddress: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var pointer = ifaddr
            
            while pointer != nil {
                defer { pointer = pointer?.pointee.ifa_next }
                
                guard
                    let interface = pointer?.pointee,
                    interface.ifa_addr.pointee.sa_family == UInt8(AF_INET) || interface.ifa_addr.pointee.sa_family == UInt8(AF_INET6),
                    let interfaceName = interface.ifa_name,
                    let interfaceNameFormatted = String(cString: interfaceName, encoding: .utf8),
                    InterfaceNames.supported.contains(interfaceNameFormatted)
                else { continue }
                
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                
                getnameinfo(interface.ifa_addr,
                            socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname,
                            socklen_t(hostname.count),
                            nil,
                            socklen_t(0),
                            NI_NUMERICHOST)
                
                guard
                    let formattedIpAddress = String(cString: hostname, encoding: .utf8),
                    !formattedIpAddress.isEmpty
                else { continue }
                
                ipAddress = formattedIpAddress
                break
            }
            
            freeifaddrs(ifaddr)
        }
        
        return ipAddress
    }
    
}


