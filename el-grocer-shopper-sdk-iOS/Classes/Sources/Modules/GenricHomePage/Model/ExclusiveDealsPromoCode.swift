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
    let code: String?
    let creation_date: Int?
    let detail: String?
    let expire_date: Int?
    let id: Int
    let max_cap_value: Double?
    let min_basket_value: Double?
    let name: String?
    let percentage_off: Double?
    let retailer_id: Int?
    let title: String?
    let name_ar: String?
    let title_ar: String?
    let detail_ar: String?
    
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
