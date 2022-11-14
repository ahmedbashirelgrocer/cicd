//
//  CartDTO.swift
//  Adyen
//
//  Created by Rashid Khan on 14/11/2022.
//

import Foundation

struct ActiveCartDTO: Codable {
    var id: Int?
    var companyName: String?
    var bgPhotoUrl: String?
    var isOpened: Bool?
    var deliverySlot: DeliverySlotDTO?
    var products: [ActiveCartProductDTO]
}

struct ActiveCartProductDTO: Codable {
    var photoUrl: String?
    var quantity: Int?
}
