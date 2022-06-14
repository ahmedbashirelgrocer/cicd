//
//  PromotionalCode.swift
//  ElGrocerShopper
//
//  Created by Robert Ignasiak on 09.12.2015.
//  Copyright © 2015 RST IT. All rights reserved.
//

import Foundation

class PromotionCode: NSObject, NSCoding, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    
    
    var valueCents: Double!
    var valueCurrency: String!
    var code:String!
    var promotionCodeRealizationId:Int?
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        
        if (decoder.decodeObject(forKey: "valueCents") != nil) {
            self.valueCents = decoder.decodeObject(forKey: "valueCents") as! Double
        }else{
            self.valueCents = decoder.decodeDouble(forKey: "valueCents")
        }
        
        if (decoder.decodeObject(forKey: "valueCurrency") != nil) {
             self.valueCurrency = decoder.decodeObject(forKey: "valueCurrency") as! String
        }
        
        if (decoder.decodeObject(forKey: "code") != nil) {
            self.code = decoder.decodeObject(forKey: "code") as! String
        }
        
        self.promotionCodeRealizationId = decoder.decodeInteger(forKey: "promotionCodeRealizationId")

        /*self.valueCents = decoder.decodeObject(forKey: "valueCents") as! Double
        self.valueCurrency = decoder.decodeObject(forKey: "valueCurrency") as! String
        self.code = decoder.decodeObject(forKey: "code") as! String
        self.promotionCodeRealizationId = decoder.decodeObject(forKey: "promotionCodeRealizationId") as? Int*/
    }
    
    convenience init(valueCents:Double, valueCurrency:String, code:String, promotionCodeRealizationId:Int?) {
        self.init()
        self.valueCents = valueCents / 100.0
        self.valueCurrency = valueCurrency
        self.code = code
        self.promotionCodeRealizationId = promotionCodeRealizationId
    }
    
    convenience init?(fromResponse response: AnyObject?) {
        self.init()
        
        guard let response = response, let dict = response as? NSDictionary, let data = dict["data"] as? NSDictionary else {
            return nil
        }
        
        guard let valueCents = data["value_cents"] as? Double, let valueCurrency = data["value_currency"] as? String, let code = data["code"] as? String, let realizationId = data["promotion_code_realization_id"] as? Int else {
            return nil
        }
        
        self.valueCents = valueCents / 100.0
        self.valueCurrency = valueCurrency
        self.code = code
        self.promotionCodeRealizationId = realizationId

    }
    
    func encode(with coder: NSCoder) {
        
         if let valueCents = valueCents { coder.encode(valueCents, forKey: "valueCents") }
        
        if let valueCurrency = valueCurrency { coder.encode(valueCurrency, forKey: "valueCurrency") }
        if let code = code { coder.encode(code, forKey: "code") }
        if let promotionCodeRealizationId = promotionCodeRealizationId { coder.encode(promotionCodeRealizationId, forKey: "promotionCodeRealizationId") }
    }
    
}
