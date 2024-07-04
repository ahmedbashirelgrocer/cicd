//
//  ExclusiveDealsPromoCode.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by saboor Khan on 27/03/2024.
//

import Foundation

struct ExclusiveDealsPromoCodeResponse: Codable {
    let status: String?
    let data: [ExclusiveDealsPromoCode]
}

struct ExclusiveDealsPromoCode: Codable {
    
    var code: String?
    var creation_date: Int?
    var detail: String?
    var expire_date: Int?
    var id: Int
    var max_cap_value: Double?
    var min_basket_value: Double?
    var name: String?
    var percentage_off: Double?
    var retailer_id: Int?
    var title: String?
    var name_ar: String?
    var title_ar: String?
    var detail_ar: String?
    
    internal init(code: String? = nil, creation_date: Int? = nil, detail: String? = nil, expire_date: Int? = nil, id: Int, max_cap_value: Double? = nil, min_basket_value: Double? = nil, name: String? = nil, percentage_off: Double? = nil, retailer_id: Int? = nil, title: String? = nil, name_ar: String? = nil, title_ar: String? = nil, detail_ar: String? = nil) {
        self.code = code
        self.creation_date = creation_date
        self.detail = detail
        self.expire_date = expire_date
        self.id = id
        self.max_cap_value = max_cap_value
        self.min_basket_value = min_basket_value
        self.name = name
        self.percentage_off = percentage_off
        self.retailer_id = retailer_id
        self.title = title
        self.name_ar = name_ar
        self.title_ar = title_ar
        self.detail_ar = detail_ar
    }
    
    init(promo: PromotionCode){
        
        self.init(code: promo.code, creation_date: nil, detail: promo.detail, expire_date: nil, id: 0, max_cap_value: nil, min_basket_value: nil, name: promo.title, percentage_off: nil, retailer_id: nil, title: promo.title, name_ar: promo.title, title_ar: promo.title, detail_ar: promo.detail)

    }
    
    
    
}


//struct ExclusiveDealsPromoCode: Codable {
//    let productName: String
//    let photoUrl: String
//    
//    enum CodingKeys: String, CodingKey {
//        case productName = "product_name"
//        case photoUrl = "photo_url"
//    }
//}
