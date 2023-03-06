//
//  BannerDTO.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 21/11/2022.
//

import Foundation

struct BannerDTO: Codable {
    let id: Int?
    let name: String?
    let priority: Int?
    let campaignType: BannerCampaignType?
    let imageURL: String?
    let bannerImageURL: String?
    let url: String?
    let categories: [BrandDTO]?
    let subcategories: [BrandDTO]?
    let brands: [BrandDTO]?
    let retailerIDS: [Int]?
    let locations: [Int]?
    let storeTypes: [Int]?
    let retailerGroups: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, priority
        case campaignType = "campaign_type"
        case imageURL = "image_url"
        case bannerImageURL = "banner_image_url"
        case url, categories, subcategories, brands
        case retailerIDS = "retailer_ids"
        case locations
        case storeTypes = "store_types"
        case retailerGroups = "retailer_groups"
    }
}
