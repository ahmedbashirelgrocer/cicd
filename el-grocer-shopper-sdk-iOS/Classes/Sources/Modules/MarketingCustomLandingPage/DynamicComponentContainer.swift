//
//  DynamicComponentContainer.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 09/11/2023.
//

import Foundation

enum SectionName: String, Codable {
    case backgroundBannerImage = "background_banner_image"
    case bannerImage = "banner_image"
    case topDeals = "top_deals"
    case productsOnly = "products_only"
    case categorySection = "category_section"
    case subcategorySection = "subcategory_section"
}

struct CampaignSection: Codable {
    
    let id: Int
    let title: String?
    let titleAr: String?
    let sectionName: SectionName
    let priority: Int
    let query: String?
    let image: String?
    let backgroundColor: String?
    let filters: [Filter]?
    enum CodingKeys: String, CodingKey {
            case id, title, titleAr, sectionName = "section_name", priority, query, image, backgroundColor, filters
    }
    
}

struct CampaignData: Codable {
    let id: Int
    let name: String
    let campaignSections: [CampaignSection]
   
    enum CodingKeys: String, CodingKey {
            case id, name, campaignSections = "campaign_sections"
    }
}

struct CampaignResponse: Codable {
    let status: String
    let data: CampaignData
}

struct Filter: Codable {
    let name: String
    let nameAR: String?
    let query: String?
    let priority: Int?
    
    enum CodingKeys: String, CodingKey {
        case name, nameAR = "name_ar", query, priority
    }
}
