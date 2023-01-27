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
    let name: String?
    let coloredImageUrl: String?
    let description: String?
    let isFood: Bool?
    let isShowBrand: Bool?
    let message: String?
    let pg18: Bool? // ask backend for type of this
    let photoUrl: String?
    let slug: String?
    
    let messageAr: String?
    let nameAr: String?
    
    
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
        case nameAr = "name_ar"
        case messageAr = "message_ar"
    }
}

extension CategoryDTO {
    init(dic: [String: Any]) {
        if let id = dic["id"] as? Int {
            self.id = id
        } else {
            self.id = -1
        }
        
        if let imageUrl = dic["image_url"] as? String {
            self.photoUrl = imageUrl
        } else if let imageUrl = dic["photo_url"] as? String {
            self.photoUrl = imageUrl
        } else {
            self.photoUrl = nil
        }
        
        if let isFood = dic["is_food"] as? Int {
            self.isFood = isFood == 1
        } else {
            self.isFood = nil
        }
        
        if let isShowBrand = dic["is_show_brand"] as? Int {
            self.isShowBrand = isShowBrand == 1
        } else {
            self.isShowBrand = nil
        }
        
        if let message = dic["message"] as? String {
            self.message = message
        } else {
            self.message = nil
        }
        
        if let messageAr = dic["message_ar"] as? String {
            self.messageAr = messageAr
        } else {
            self.messageAr = nil
        }
        
        if let name = dic["name"] as? String {
            self.name = name
        } else {
            self.name = nil
        }
        
        if let nameAr = dic["name_ar"] as? String {
            self.nameAr = nameAr
        } else {
            self.nameAr = nil
        }
        
        if let pg18 = dic["pg_18"] as? Int {
            self.pg18 = pg18 == 1
        } else {
            self.pg18 = nil
        }
        
        if let slug = dic["slug"] as? String {
            self.slug = slug
        } else {
            self.slug = nil
        }
        
        self.coloredImageUrl = nil
        self.description = nil
    }
}
