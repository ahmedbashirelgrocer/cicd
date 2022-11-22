//
//  BannerDTO.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 21/11/2022.
//

import Foundation

// MARK: - CampaignsResponse
struct CampaignsResponse: Codable {
    let status: String?
    let data: [BannerDTO]
}

struct BannerDTO: Codable {
    let id: Int?
    let name: String?
    let priority: Int?
    let campaignType: Int?
    let imageURL: String?
    let bannerImageURL: String?
    let url: String?
    let categories, subcategories, brands: [BrandDTO]
    let retailerIDS: [Int]?
//    let excludeRetailerIDS: [JSONAny]?
    let locations: [Int]?
//    let storeTypes, retailerGroups: [JSONAny]?

    enum CodingKeys: String, CodingKey {
        case id, name, priority
        case campaignType = "campaign_type"
        case imageURL = "image_url"
        case bannerImageURL = "banner_image_url"
        case url, categories, subcategories, brands
        case retailerIDS = "retailer_ids"
//        case excludeRetailerIDS = "exclude_retailer_ids"
        case locations
//        case storeTypes = "store_types"
//        case retailerGroups = "retailer_groups"
    }
}

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
