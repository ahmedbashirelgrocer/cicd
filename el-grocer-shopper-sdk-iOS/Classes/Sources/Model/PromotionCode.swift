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
    var id: Int!
    var precentageOff: Int!
    var maxCapValue: NSNumber!
    var title: String!
    var detail: String!
    var allBrands: Bool!
    var minBasketValue: NSNumber!
    var brands : [NSDictionary]!
    var groceryName: String?
    var groceryImage: String?
    
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
        
        if (decoder.decodeObject(forKey: "title") != nil) {
            self.title = decoder.decodeObject(forKey: "title") as! String
        }
        if (decoder.decodeObject(forKey: "precentage_off") != nil) {
            self.precentageOff = decoder.decodeObject(forKey: "precentage_off") as! Int
        }
        if (decoder.decodeObject(forKey: "detail") != nil) {
            self.detail = decoder.decodeObject(forKey: "detail") as! String
        }
        if (decoder.decodeObject(forKey: "all_brands") != nil) {
            self.allBrands = decoder.decodeObject(forKey: "all_brands") as! Bool
        }
        if (decoder.decodeObject(forKey: "min_basket_value") != nil) {
            self.minBasketValue = decoder.decodeObject(forKey: "min_basket_value") as! NSNumber
        }
        if (decoder.decodeObject(forKey: "max_cap_value") != nil) {
            self.maxCapValue = decoder.decodeObject(forKey: "max_cap_value") as! NSNumber
        }
        if (decoder.decodeObject(forKey: "id") != nil) {
            self.id = decoder.decodeObject(forKey: "id") as? Int
        }
        if (decoder.decodeObject(forKey: "brands") != nil) {
            self.brands = decoder.decodeObject(forKey: "brands") as? [NSDictionary] ?? []
        }
        if (decoder.decodeObject(forKey: "photo_url") != nil) {
            self.groceryImage = decoder.decodeObject(forKey: "photo_url") as? String ?? ""
        }
        if (decoder.decodeObject(forKey: "name") != nil) {
            self.groceryName = decoder.decodeObject(forKey: "name") as? String ?? ""
        }
        
        /*self.valueCents = decoder.decodeObject(forKey: "valueCents") as! Double
         self.valueCurrency = decoder.decodeObject(forKey: "valueCurrency") as! String
         self.code = decoder.decodeObject(forKey: "code") as! String
         self.promotionCodeRealizationId = decoder.decodeObject(forKey: "promotionCodeRealizationId") as? Int*/
    }
    
    convenience init(valueCents:Double, valueCurrency:String, code:String, promotionCodeRealizationId:Int?, precentageOff: Int, maxCapValue: NSNumber, title: String, detail: String, allBrands: Bool, minBasketValue: NSNumber, id: Int, brands: [NSDictionary], groceryImage: String? = "", groceryName: String = "") {
        self.init()
        self.valueCents = valueCents / 100.0
        self.valueCurrency = valueCurrency
        self.code = code
        self.promotionCodeRealizationId = promotionCodeRealizationId
        self.title = title
        self.precentageOff = precentageOff
        self.maxCapValue = maxCapValue
        self.minBasketValue = minBasketValue
        self.detail = detail
        self.allBrands = allBrands
        self.id = id
        self.brands = brands
        self.groceryName = groceryName
        self.groceryImage = groceryImage
    }
    
    convenience init?(fromResponse response: AnyObject?) {
        self.init()
        
        guard let data = response as? NSDictionary else {
            return
        }
        
        if let valueCents = data["value_cents"] as? Double, let valueCurrency = data["value_currency"] as? String, let realizationId = data["promotion_code_realization_id"] as? Int {
            self.valueCents = valueCents / 100.0
            self.valueCurrency = valueCurrency
            self.promotionCodeRealizationId = realizationId
        }
        self.id = data["id"] as? Int ?? 0
        self.code = data["code"] as? String ?? ""
        self.precentageOff = data["precentage_off"] as? Int ?? 0
        self.maxCapValue = data["max_cap_value"] as? NSNumber ?? NSNumber(0)
        self.title = data["title"] as? String ?? ""
        self.detail = data["detail"] as? String ?? ""
        self.allBrands = data["all_brands"] as? Bool ?? false
        self.minBasketValue = data["min_basket_value"] as? NSNumber ?? NSNumber(0)
        self.brands = data["brands"] as? [NSDictionary] ?? []
        self.groceryName = data["name"] as? String ?? ""
        self.groceryImage = data["photo_url"] as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        
        if let valueCents = valueCents { coder.encode(valueCents, forKey: "valueCents") }
        
        if let valueCurrency = valueCurrency { coder.encode(valueCurrency, forKey: "valueCurrency") }
        if let code = code { coder.encode(code, forKey: "code") }
        if let promotionCodeRealizationId = promotionCodeRealizationId { coder.encode(promotionCodeRealizationId, forKey: "promotionCodeRealizationId") }
        if let title = title { coder.encode(title, forKey: "title") }
        if let precentageOff = precentageOff { coder.encode(precentageOff, forKey: "precentage_off") }
        if let maxCapValue = maxCapValue { coder.encode(maxCapValue, forKey: "max_cap_value") }
        if let detail = detail { coder.encode(detail, forKey: "detail") }
        if let allBrands = allBrands { coder.encode(allBrands, forKey: "all_brands") }
        if let minBasketValue = minBasketValue { coder.encode(minBasketValue, forKey: "min_basket_value") }
        if let id = id { coder.encode(id, forKey: "id") }
        if let brands = brands {
            coder.encode(brands, forKey: "brands")
        }
        if let name = groceryName { coder.encode(name, forKey: "name") }
        if let image = groceryImage { coder.encode(image, forKey: "photo_url") }
    }
}

