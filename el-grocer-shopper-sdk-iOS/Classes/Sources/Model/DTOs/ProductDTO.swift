//
//  ProductDTO.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 18/01/2023.
//

import Foundation

// MARK: - ProductResponse
struct ProductResponse: Codable {
    let status: String?
    let data: [ProductDTO]
}

struct ProductDTO: Codable {
    let id: Int
    let retailerID: Int?
    let name, slug, description, barcode: String?
    let imageURL, fullImageURL: String?
    let sizeUnit: String?
    let fullPrice: Double?
    let priceCurrency: String?
    let promotion: Bool?
    let brand: BrandDTO?
    let categories, subcategories: [CategoryDTO]?
    let isAvailable, isPublished, isP: Bool?
    let availableQuantity: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case retailerID = "retailer_id"
        case name, slug, description, barcode
        case imageURL = "image_url"
        case fullImageURL = "full_image_url"
        case sizeUnit = "size_unit"
        case fullPrice = "full_price"
        case priceCurrency = "price_currency"
        case promotion, brand, categories, subcategories
        case isAvailable = "is_available"
        case isPublished = "is_published"
        case isP = "is_p"
        case availableQuantity = "available_quantity"
    }
    
    // added this method for parsing Algolia response
    static func fromDictionary(dictionary: [[String: Any]]) -> [ProductDTO] {
        var results = [ProductDTO]()

        dictionary.forEach { productDictionary in
            let id = productDictionary["id"] as! Int
            let imageUrl = productDictionary["photo_url"] as? String
            let name = productDictionary["name"] as? String

            let product = ProductDTO(id: id, retailerID: nil, name: name, slug: nil, description: nil, barcode: nil, imageURL: imageUrl, fullImageURL: nil, sizeUnit: nil, fullPrice: nil, priceCurrency: nil, promotion: nil, brand: nil, categories: nil, subcategories: nil, isAvailable: false, isPublished: false, isP: false, availableQuantity: nil)
            
            results.append(product)
        }

        return results

    }
}
