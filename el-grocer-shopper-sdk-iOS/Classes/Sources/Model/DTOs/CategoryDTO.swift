//
//  CategoryDTO.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 18/01/2023.
//

import Foundation

// MARK: DTOs
struct CategoriesResponse: Codable {
    let status: String
    let categories: [CategoryDTO]
    
    enum CodingKeys: String, CodingKey {
        case status
        case categories = "data"
    }
}

struct CategoryDTO: Codable {
    let id: Int
    let name: String
    let coloredImageUrl: String?
    let description: String?
    let isFood: Bool
    let isShowBrand: Bool
    let message: String
    let pg18: Bool // ask backend for type of this
    let photoUrl: String?
    let slug: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case coloredImageUrl = "colored_img_url"
        case description
        case isFood = "is_food"
        case isShowBrand = "is_show_brand"
        case message
        case pg18 = "pg_18"
        case photoUrl = "photo_url"
        case slug
    }
}
