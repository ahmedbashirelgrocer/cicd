//
//  ShopeDTO.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 27/01/2023.
//

import Foundation

struct ShopDTO: Codable {
    let retailerId: Int
    let retailerSlug: String?
    var price: Double?
    let promotionOnly: Int?
    let isP: Bool?
    let priceCurrency: String?
    let availableQuantity: String?
    let startTime: Int?
    let endTime: Int?
    let standardPrice: Double?
    let productLimit: Int?
    
    enum CodingKeys: String, CodingKey {
        case retailerId = "retailer_id"
        case retailerSlug = "retailer_slug"
        case price
        case promotionOnly = "promotion_only"
        case isP = "is_p"
        case priceCurrency = "price_currency"
        case availableQuantity = "available_quantity"
        case startTime = "start_time"
        case endTime = "end_time"
        case standardPrice = "standard_price"
        case productLimit = "product_limit"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.retailerId = (try! container.decode(Int.self, forKey: .retailerId))
        self.retailerSlug = (try? container.decode(String.self, forKey: .retailerSlug))
        self.price = (try? container.decode(Double.self, forKey: .price))
        self.promotionOnly = (try? container.decode(Int.self, forKey: .promotionOnly))
        self.isP = (try? container.decode(Bool.self, forKey: .isP))
        self.priceCurrency = (try? container.decode(String.self, forKey: .priceCurrency))
        self.availableQuantity = (try? container.decode(String.self, forKey: .availableQuantity))
        self.startTime = (try? container.decode(Int.self, forKey: .startTime))
        self.endTime = (try? container.decode(Int.self, forKey: .endTime))
        self.standardPrice = (try? container.decode(Double.self, forKey: .standardPrice))
        self.productLimit = (try? container.decode(Int.self, forKey: .productLimit))
    }
}

// Algolia API response parsing
extension ShopDTO {
    init(dic: [String: Any]) {
        if let retailerId = dic["retailer_id"] as? Int {
            self.retailerId = retailerId
        } else {
            self.retailerId = 0
        }
        
        if let retailerSlug = dic["retailer_slug"] as? String {
            self.retailerSlug = retailerSlug
        } else {
            self.retailerSlug = nil
        }
        
        if let price = dic["price"] as? Double {
            self.price = price
        } else {
            self.price = nil
        }
        
        if let promotionOnly = dic["promotion_only"] as? Int {
            self.promotionOnly = promotionOnly
        } else {
            self.promotionOnly = nil
        }
        
        if let isP = dic["is_p"] as? Bool {
            self.isP = isP
        } else {
            self.isP = nil
        }
        
        if let priceCurrency = dic["price_currency"] as? String {
            self.priceCurrency = priceCurrency
        } else {
            self.priceCurrency = nil
        }
        
        if let availableQuantity = dic["available_quantity"] as? String {
            self.availableQuantity = availableQuantity
        } else if let availableQuantity = dic["available_quantity"] as? Int {
            self.availableQuantity = String(availableQuantity)
        } else {
            self.availableQuantity = nil
        }
        
        if let startTime = dic["start_time"] as? Int {
            self.startTime = startTime
        } else {
            self.startTime = nil
        }
        
        if let endTime = dic["end_time"] as? Int {
            self.endTime = endTime
        }  else {
            self.endTime = nil
        }
        
        if let standardPrice = dic["standard_price"] as? Double {
            self.standardPrice = standardPrice
        }  else {
            self.standardPrice = nil
        }
        
        if let productLimit = dic["product_limit"] as? Int {
            self.productLimit = productLimit
        }  else {
            self.productLimit = nil
        }
    }
}
