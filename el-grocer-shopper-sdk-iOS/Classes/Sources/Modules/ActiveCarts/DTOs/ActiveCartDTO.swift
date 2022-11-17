//
//  CartDTO.swift
//  Adyen
//
//  Created by Rashid Khan on 14/11/2022.
//

import Foundation

enum DeliveryType: Codable {
    case instant
    case scheduled
}

struct ActiveCartResponseDTO: Codable {
    let status: String?
    let data: [ActiveCartDTO]
}

struct ActiveCartDTO: Codable {
    var id: Int?
    var companyName: String?
    var bgPhotoUrl: String?
    var isOpened: Bool?
    var deliverySlot: DeliverySlotDTO?
    var products: [ActiveCartProductDTO]
    
    var deliveryType: DeliveryType {
        if self.deliverySlot == nil {
            return .instant
        }
        
        return .scheduled
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case companyName = "company_name"
        case bgPhotoUrl = "bg_photo_url"
        case isOpened = "is_opened"
        case deliverySlot = "delivery_slot"
        case products
    }
}

struct ActiveCartProductDTO: Codable {
    var photoUrl: String?
    var quantity: Int?
    
    enum CodingKeys: String, CodingKey {
        case photoUrl = "photo_url"
        case quantity
    }
}
