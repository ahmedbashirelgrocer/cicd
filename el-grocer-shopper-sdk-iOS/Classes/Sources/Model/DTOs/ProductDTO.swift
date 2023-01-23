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
    let promotionalShops, shops: [ShopDTO]?

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
        case promotionalShops = "promotional_shops"
        case shops
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = (try! values.decode(Int.self, forKey: .id))
        retailerID = (try? values.decode(Int.self, forKey: .retailerID))
        name = (try? values.decode(String.self, forKey: .name))
        slug = (try? values.decode(String.self, forKey: .slug))
        description = (try? values.decode(String.self, forKey: .description))
        barcode = (try? values.decode(String.self, forKey: .barcode))
        imageURL = (try? values.decode(String.self, forKey: .imageURL))
        fullImageURL = (try? values.decode(String.self, forKey: .fullImageURL))
        sizeUnit = (try? values.decode(String.self, forKey: .sizeUnit))
        fullPrice = (try? values.decode(Double.self, forKey: .fullPrice))
        priceCurrency = (try? values.decode(String.self, forKey: .priceCurrency))
        promotion = (try? values.decode(Bool.self, forKey: .promotion))
        brand = (try? values.decode(BrandDTO.self, forKey: .brand))
        categories = (try? values.decode([CategoryDTO].self, forKey: .categories))
        subcategories = (try? values.decode([CategoryDTO].self, forKey: .subcategories))
        isAvailable = (try? values.decode(Bool.self, forKey: .isAvailable))
        isPublished = (try? values.decode(Bool.self, forKey: .isPublished))
        isP = (try? values.decode(Bool.self, forKey: .isP))
        availableQuantity = (try? values.decode(Int.self, forKey: .availableQuantity))
        promotionalShops = (try? values.decode([ShopDTO].self, forKey: .promotionalShops))
        shops = (try? values.decode([ShopDTO].self, forKey: .shops))
    }
}

struct ShopDTO: Codable {
    let retailerId: Int
    let retailerSlug: String?
    let price: Double?
    let promotionOnly: Int?
    let isP: Bool?
    let priceCurrency: String?
    let availableQuantity: String?
    
    enum CodingKeys: String, CodingKey {
        case retailerId = "retailer_id"
        case retailerSlug = "retailer_slug"
        case price
        case promotionOnly = "promotion_only"
        case isP = "is_p"
        case priceCurrency = "price_currency"
        case availableQuantity = "available_quantity"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.retailerId = try container.decode(Int.self, forKey: .retailerId)
        self.retailerSlug = try container.decodeIfPresent(String.self, forKey: .retailerSlug)
        self.price = try container.decodeIfPresent(Double.self, forKey: .price)
        self.promotionOnly = try container.decodeIfPresent(Int.self, forKey: .promotionOnly)
        self.isP = try container.decodeIfPresent(Bool.self, forKey: .isP)
        self.priceCurrency = try container.decodeIfPresent(String.self, forKey: .priceCurrency)
        self.availableQuantity = try container.decodeIfPresent(String.self, forKey: .availableQuantity)
    }
}
