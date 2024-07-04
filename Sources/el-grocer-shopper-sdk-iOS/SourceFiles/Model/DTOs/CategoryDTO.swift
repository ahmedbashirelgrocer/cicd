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
    var photoUrl: String?
    let slug: String?
    let customPage: Int?
    
    
    let messageAr: String?
    let nameAr: String?
    var categoryDB: Category? = nil
    var algoliaQuery: String?
    var bgColor: String? = nil
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case algoliaQuery
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
        case customPage = "customPage"
    }
    
    init(id: Int, name: String?, algoliaQuery: String?, nameAr: String?, bgColor: String? ) {
        self.id = id
        self.name = name
        self.algoliaQuery = algoliaQuery
        self.nameAr = nameAr
        self.bgColor = bgColor
        self.coloredImageUrl = nil
        self.description = nil
        self.isFood = nil
        self.isShowBrand = nil
        self.message = nil
        self.pg18 = nil
        self.photoUrl = nil
        self.slug = nil
        self.messageAr = nil
        self.customPage = nil
        self.categoryDB = nil
       
        
    }
    
    init(id: Int, name: String?, coloredImageUrl: String?, description: String?, isFood: Bool?, isShowBrand: Bool?, message: String?, pg18: Bool?, photoUrl: String?, slug: String?, customPage: Int?, messageAr: String?, nameAr: String?, categoryDB: Category? = nil, algoliaQuery: String? = nil) {
        self.id = id
        self.name = name
        self.coloredImageUrl = coloredImageUrl
        self.description = description
        self.isFood = isFood
        self.isShowBrand = isShowBrand
        self.message = message
        self.pg18 = pg18
        self.photoUrl = photoUrl
        self.slug = slug
        self.customPage = customPage
        self.messageAr = messageAr
        self.nameAr = nameAr
        self.categoryDB = categoryDB
        self.algoliaQuery = algoliaQuery
        self.bgColor = nil
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
        
        self.customPage = dic["custom_screen_id"] as? Int
        self.bgColor =  dic["bgColor"] as? String
    }
}

extension CategoryDTO {
    init(category: Category) {
        self.categoryDB = category
        
        self.id = category.dbID.intValue
        self.name = category.name
        self.coloredImageUrl = category.coloredImageUrl
        self.description = category.desc
        self.isFood = nil
        self.isShowBrand = nil
        self.message = nil
        self.pg18 = category.isPg18.boolValue
        self.photoUrl = category.imageUrl
        self.slug = nil
        self.nameAr = nil
        self.messageAr = nil
        self.customPage = nil
    }
}

extension CategoryDTO: Equatable {
    static func == (lhs: CategoryDTO, rhs: CategoryDTO) -> Bool {
        return lhs.id == rhs.id
    }
}
