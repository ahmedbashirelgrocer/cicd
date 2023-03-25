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

extension BrandDTO {
    init(from dic: [String: Any]) {
        if let id = dic["id"] as? Int {
            self.id = id
        } else {
            self.id = nil
        }
        
        if let name = dic["name"] as? String {
            self.name = name
        } else {
            self.name = nil
        }
        
        if let imageURL = dic["photo_url"] as? String {
            self.imageURL = imageURL
        } else {
            self.imageURL = nil
        }
        
        if let slug = dic["slug"] as? String {
            self.slug = slug
        } else {
            self.slug = nil
        }
    }
}
