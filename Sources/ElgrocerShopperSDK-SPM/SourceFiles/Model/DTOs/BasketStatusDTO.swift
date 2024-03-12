//
//  HasBasketDTO.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 27/12/2022.
//

import Foundation

struct HasBasketResponse: Codable {
    let status: String?
    let data: BasketStatusDTO
}
struct BasketStatusDTO: Codable {
    let hasBasket: Bool?
    
    enum CodingKeys: String, CodingKey {
        case hasBasket = "has_basket"
    }
}
