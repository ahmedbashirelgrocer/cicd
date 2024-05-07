//
//  BannerDTO.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Rashid Khan on 21/11/2022.
//

import Foundation

struct BannerDTO: Codable {
    var id: Int?
    let name: String?
    var priority: Int?
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
    let customScreenId: Int? 
    var resolvedBidId: String?
    var isStoryly: Bool?
    
    
    enum CodingKeys: String, CodingKey {
        case id, name, priority
        case customScreenId = "custom_screen_id"
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

extension BannerDTO {
    
    func toCategoryDTO () -> CategoryDTO {
        return CategoryDTO(id: self.id ?? -2, name: self.name, coloredImageUrl: self.imageURL ?? self.bannerImageURL, description: nil, isFood: nil, isShowBrand: nil, message: nil, pg18: nil, photoUrl: self.imageURL ?? self.bannerImageURL, slug: nil, customPage: self.customScreenId ?? nil, messageAr: nil, nameAr: self.name,algoliaQuery: nil)
    }
    
    
}
