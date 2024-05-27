//
//  BannerSlots.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 23/02/2023.
//

import Foundation

struct AdSlotDTO: Codable {
    
    static let userDefualtKeyNameForGroceryAndMore = "AdSlotDTOGroceryAndMore"
    static let userDefualtKeyNameForSmilesMarket = "AdSlotDTOSmilesMarket"
    
    let productSlots: [ProductSlotDTO]
    let normalBannerSlots: [BannerSlotDTO]
    let productBannerSlots: [ProductBannerSlotDTO]
    let thinBannerSlots: [ThinBannerSlotDTO]
    
    enum CodingKeys: String, CodingKey {
        case productSlots = "product_slots"
        case normalBannerSlots = "normal_banner_slots"
        case productBannerSlots = "product_banner_slots"
        case thinBannerSlots = "thin_banner_slots"
    }
}

struct ProductSlotDTO: Codable {
    var globalPlacementsSponsored: Int = 0
    var sponsoredSlotsSubcategories: Int = 0
    var productsSlotsSubcategories: Int = 0
    var sponsoredSlotsBrandPage: Int = 0
    var productsSlotsBrandPage: Int = 0
    var sponsoredSlotsStorePage: Int = 0
    var productsSlotsStorePage: Int = 0
    var sponsoredSlotsStoreSearch: Int = 0
    var productsSlotsStoreSearch: Int = 0

    enum CodingKeys: String, CodingKey {
        case globalPlacementsSponsored = "global_placements_sponsored"
        case sponsoredSlotsSubcategories = "sponsored_slots_subcategories"
        case productsSlotsSubcategories = "products_slots_subcategories"
        case sponsoredSlotsBrandPage = "sponsored_slots_brand_page"
        case productsSlotsBrandPage = "products_slots_brand_page"
        case sponsoredSlotsStorePage = "sponsored_slots_store_page"
        case productsSlotsStorePage = "products_slots_store_page"
        case sponsoredSlotsStoreSearch = "sponsored_slots_store_search"
        case productsSlotsStoreSearch = "products_slots_store_search"
    }
    
    init(from decoder: Decoder) {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }
        
        globalPlacementsSponsored = (try? container.decode(Int.self, forKey: .globalPlacementsSponsored)) ?? 0
        sponsoredSlotsSubcategories = (try? container.decode(Int.self, forKey: .sponsoredSlotsSubcategories)) ?? 0
        productsSlotsSubcategories = (try? container.decode(Int.self, forKey: .productsSlotsSubcategories)) ?? 0
        sponsoredSlotsBrandPage = (try? container.decode(Int.self, forKey: .sponsoredSlotsBrandPage)) ?? 0
        productsSlotsBrandPage = (try? container.decode(Int.self, forKey: .productsSlotsBrandPage)) ?? 0
        sponsoredSlotsStorePage = (try? container.decode(Int.self, forKey: .sponsoredSlotsStorePage)) ?? 0
        productsSlotsStorePage = (try? container.decode(Int.self, forKey: .productsSlotsStorePage)) ?? 0
        sponsoredSlotsStoreSearch = (try? container.decode(Int.self, forKey: .sponsoredSlotsStoreSearch)) ?? 0
        productsSlotsStoreSearch = (try? container.decode(Int.self, forKey: .productsSlotsStoreSearch)) ?? 0
    }
    
}

struct BannerSlotDTO: Codable {
    var placementId: String = ""
    var noOfSlots: Int = 0
    var adLocationId: BannerLocation = .home_tier_1
    
    enum CodingKeys: String, CodingKey {
        case placementId = "placement_id"
        case noOfSlots = "no_of_slots"
        case adLocationId = "ad_location_id"
    }
    
    init(from decoder: Decoder) {
        guard let contailer = try? decoder.container(keyedBy: CodingKeys.self) else { return }
        
        placementId = (try? contailer.decode(String.self, forKey: .placementId)) ?? ""
        noOfSlots = (try? contailer.decode(Int.self, forKey: .noOfSlots)) ?? 0
        adLocationId = (try? contailer.decode(BannerLocation.self, forKey: .adLocationId)) ?? .home_tier_1
    }
}

struct ProductBannerSlotDTO: Codable {
    let placementId: String
    let noOfSlots: Int
    let position: [Int]
    
    enum CodingKeys: String, CodingKey {
        case placementId = "placement_id"
        case noOfSlots = "no_of_slots"
        case position = "position"
    }
    
    init(from decoder: Decoder) throws {
        let contailer = try decoder.container(keyedBy: CodingKeys.self)
        
        placementId = try contailer.decode(String.self, forKey: .placementId)
        noOfSlots = try contailer.decode(Int.self, forKey: .noOfSlots)
        position = try contailer.decode([Int].self, forKey: .position).map{ $0 - 1 }
    }
}

struct ThinBannerSlotDTO: Codable {
    let placementId: String
    let noOfSlots: Int
    let position: [Int]
    
    enum CodingKeys: String, CodingKey {
        case placementId = "placement_id"
        case noOfSlots = "no_of_slots"
        case position = "position"
    }
    
    init(from decoder: Decoder) throws {
        let contailer = try decoder.container(keyedBy: CodingKeys.self)
        
        placementId = try contailer.decode(String.self, forKey: .placementId)
        noOfSlots = try contailer.decode(Int.self, forKey: .noOfSlots)
        position = try contailer.decode([Int].self, forKey: .position)
    }
}
