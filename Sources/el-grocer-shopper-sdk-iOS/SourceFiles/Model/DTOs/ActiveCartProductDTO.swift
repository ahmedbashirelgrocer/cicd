//
//  ActiveCartProductDTO.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 07/12/2022.
//

import Foundation

struct ActiveCartProductDTO: Codable {
    var photoUrl: String?
    var quantity: Int?
    
    enum CodingKeys: String, CodingKey {
        case photoUrl = "photo_url"
        case quantity
    }
}
