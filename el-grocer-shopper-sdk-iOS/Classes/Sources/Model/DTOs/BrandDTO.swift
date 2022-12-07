//
//  BrandDTO.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 07/12/2022.
//

import Foundation

struct BrandDTO: Codable {
    let id: Int?
    let name: String?
    let imageURL: String?
    let slug: String?

    enum CodingKeys: String, CodingKey {
       case id, name
       case imageURL = "image_url"
       case slug
    }
}
